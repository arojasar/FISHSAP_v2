# global.R

library(shiny)
library(shinydashboard)
library(DT)
library(RPostgres)
library(DBI)
library(pool)
library(jsonlite)
library(shinyTime)
library(dplyr)
library(bslib)

source("utils/db_setup.R", local = TRUE)
source("utils/server_utils.R", local = TRUE)

# Configuración de la base de datos
db_config <- list(
  dbname = Sys.getenv("DB_NAME"),
  host = Sys.getenv("DB_HOST"),
  port = Sys.getenv("DB_PORT"),
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD")
)

# Validar que todas las variables de entorno estén configuradas
if (db_config$dbname == "" || db_config$host == "" || db_config$port == "" || 
    db_config$user == "" || db_config$password == "") {
  stop("Error: Una o más variables de entorno no están configuradas.")
}

# Crear el pool de conexiones
pool <- tryCatch({
  dbPool(
    drv = RPostgres::Postgres(),
    dbname = db_config$dbname,
    host = db_config$host,
    port = as.integer(db_config$port),
    user = db_config$user,
    password = db_config$password,
    sslmode = "require",
    minSize = 1,
    maxSize = 5,
    idleTimeout = 600000
  )
}, error = function(e) {
  message("Error al crear el pool de conexiones: ", e$message)
  NULL
})

if (is.null(pool)) {
  stop("No se pudo crear el pool de conexiones a la base de datos.")
}

# Cerrar el pool cuando la aplicación se detiene
onStop(function() {
  poolClose(pool)
  message("Pool de conexiones cerrado.")
})

# Ejecutar setup_databases para crear/verificar tablas necesarias
conn <- poolCheckout(pool)
tryCatch({
  if (!is.null(conn) && dbIsValid(conn)) {
    setup_databases(conn)
    message("Configuración de base de datos completada con éxito.")
  } else {
    stop("No se pudo ejecutar setup_databases: Conexión a la base de datos no válida.")
  }
}, error = function(e) {
  message("Error durante la configuración de la base de datos: ", e$message)
}, finally = {
  poolReturn(conn)
})

# Definición de los campos para las listas desplegables
captura_esfuerzo_fields <- list(
  list(id = "sitio_desembarque", label = "Sitio de Desembarque", type = "select", ref_table = "sitios", value_field = "CODSIT", display_field = "NOMSIT"),
  list(id = "subarea", label = "Subárea", type = "select", ref_table = "subarea", value_field = "CODSUBARE", display_field = "NOMSUBARE"),
  list(id = "registrador", label = "Registrador", type = "select", ref_table = "registrador", value_field = "CODREG", display_field = "NOMREG"),
  list(id = "pescadores", label = "Nombre del Pescador", type = "select", ref_table = "nombre_pescador", value_field = "CODPES", display_field = "NOMPES", multiple = TRUE),
  list(id = "embarcacion", label = "Embarcación", type = "select", ref_table = "embarcaciones", value_field = "CODEMB", display_field = "NOMEMB"),
  list(id = "propulsion", label = "Propulsión", type = "select", ref_table = "propulsion", value_field = "CODPRO", display_field = "NOMPRO"),
  list(id = "arte_pesca", label = "Arte de Pesca", type = "select", ref_table = "arte", value_field = "CODART", display_field = "NOMART"),
  list(id = "metodo_pesca", label = "Método de Pesca", type = "select", ref_table = "metodo", value_field = "CODMET", display_field = "NOMMET", multiple = TRUE),
  list(id = "especie", label = "Especie", type = "select", ref_table = "especies", value_field = "CODESP", display_field = "Nombre_Comun"),
  list(id = "estado", label = "Estado", type = "select", ref_table = "estados", value_field = "CODEST", display_field = "NOMEST"),
  list(id = "gasto", label = "Gasto", type = "select", ref_table = "gastos", value_field = "CODGAS", display_field = "NOMGAS"),
  list(id = "horario", label = "Horario", type = "select", choices = c("Diurno", "Nocturno"))
)

# Función para cargar opciones de referencia con manejo de errores mejorado
load_reference_choices <- function(field) {
  if (is.null(field$ref_table)) {
    return(field$choices)
  }
  
  query <- sprintf("SELECT %s, %s FROM %s", field$value_field, field$display_field, field$ref_table)
  message("Ejecutando consulta: ", query)
  
  data <- tryCatch({
    result <- dbGetQuery(pool, query)
    if (nrow(result) == 0) {
      message("Advertencia: No hay datos en la tabla ", field$ref_table)
      return(character(0))
    }
    result
  }, error = function(e) {
    message("Error en la consulta para ", field$ref_table, ": ", e$message)
    return(data.frame(value = character(0), display = character(0)))
  })
  
  colnames(data) <- c("value", "display")
  setNames(data$value, data$display)
}

# Cargar las opciones para las listas desplegables
captura_esfuerzo_choices <- lapply(captura_esfuerzo_fields, load_reference_choices)
names(captura_esfuerzo_choices) <- sapply(captura_esfuerzo_fields, function(field) field$id)

# También cargamos opciones específicas para el módulo de actividad diaria
registrador_choices <- tryCatch({
  query <- "SELECT CODREG, NOMREG FROM registrador"
  data <- dbGetQuery(pool, query)
  if (nrow(data) > 0) {
    setNames(data$CODREG, data$NOMREG)
  } else {
    character(0)
  }
}, error = function(e) {
  message("Error al cargar registradores: ", e$message)
  character(0)
})

arte_pesca_choices <- tryCatch({
  query <- "SELECT CODART, NOMART FROM arte"
  data <- dbGetQuery(pool, query)
  if (nrow(data) > 0) {
    setNames(data$CODART, data$NOMART)
  } else {
    character(0)
  }
}, error = function(e) {
  message("Error al cargar artes de pesca: ", e$message)
  character(0)
})

sitio_desembarque_choices <- tryCatch({
  query <- "SELECT CODSIT, NOMSIT FROM sitios"
  data <- dbGetQuery(pool, query)
  if (nrow(data) > 0) {
    setNames(data$CODSIT, data$NOMSIT)
  } else {
    character(0)
  }
}, error = function(e) {
  message("Error al cargar sitios de desembarque: ", e$message)
  character(0)
})

# Cargar todos los módulos
source("modules/ref_tables_fields.R")
source("modules/ref_tables_ui.R")
source("modules/ref_tables_server.R")
source("modules/ingreso_datos/captura_esfuerzo_ui.R")
source("modules/ingreso_datos/captura_esfuerzo_server.R")
source("modules/ingreso_datos/actividad_diaria_ui.R")
source("modules/ingreso_datos/actividad_diaria_server.R")

# Verificar que se hayan creado las tablas necesarias para el módulo de actividad diaria
conn <- poolCheckout(pool)
tryCatch({
  # Verificar si existe la tabla de actividades_diarias
  table_exists <- dbExistsTable(conn, "actividades_diarias")
  if (!table_exists) {
    # Crear la tabla si no existe
    query <- "
      CREATE TABLE IF NOT EXISTS actividades_diarias (
        id SERIAL PRIMARY KEY,
        fecha DATE NOT NULL,
        registrador VARCHAR(10) REFERENCES registrador(CODREG),
        arte_pesca VARCHAR(10) REFERENCES arte(CODART),
        sitio VARCHAR(10) REFERENCES sitios(CODSIT),
        embarcaciones_activas INTEGER DEFAULT 0,
        embarcaciones_muestreadas INTEGER DEFAULT 0,
        observaciones TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    "
    dbExecute(conn, query)
    message("Tabla actividades_diarias creada correctamente")
  }
}, error = function(e) {
  message("Error al verificar/crear tabla actividades_diarias: ", e$message)
}, finally = {
  poolReturn(conn)
})