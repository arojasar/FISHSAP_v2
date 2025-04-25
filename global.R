# global.R

# Cargar paquetes necesarios
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
library(openxlsx)  # Para descargas en Excel
library(shinyWidgets)  # Para componentes adicionales en la UI
library(shinyjs)  # Para funcionalidades de JavaScript
library(plotly)  # Para gráficos interactivos (opcional, para el módulo Procesamiento de Datos)

# Cargar funciones de utilidad
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

# Cerrar el pool cuando la aplicación se detenga (con manejo de errores)
onStop(function() {
  if (!is.null(pool) && pool::dbIsValid(pool)) {
    poolClose(pool)
    message("Pool de conexiones cerrado.")
  } else {
    message("El pool ya estaba cerrado o no era válido.")
  }
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
  list(id = "sitio_desembarque", label = "Sitio de Desembarque", type = "select", ref_table = "sitios", value_field = "codsit", display_field = "nomsit"),
  list(id = "subarea", label = "Subárea", type = "select", ref_table = "subarea", value_field = "codsubare", display_field = "nomsubare"),
  list(id = "registrador", label = "Registrador", type = "select", ref_table = "registrador", value_field = "codreg", display_field = "nomreg"),
  list(id = "pescadores", label = "Nombre del Pescador", type = "select", ref_table = "nombre_pescador", value_field = "codpes", display_field = "nompes", multiple = TRUE),
  list(id = "embarcacion", label = "Embarcación", type = "select", ref_table = "embarcaciones", value_field = "codemb", display_field = "nomemb"),
  list(id = "propulsion", label = "Propulsión", type = "select", ref_table = "propulsion", value_field = "codpro", display_field = "nompro"),
  list(id = "arte_pesca", label = "Arte de Pesca", type = "select", ref_table = "arte", value_field = "codart", display_field = "nomart"),
  list(id = "metodo_pesca", label = "Método de Pesca", type = "select", ref_table = "metodo", value_field = "codmet", display_field = "nommet", multiple = TRUE),
  list(id = "especie", label = "Especie", type = "select", ref_table = "especies", value_field = "codesp", display_field = "nombre_comun"),
  list(id = "estado", label = "Estado", type = "select", ref_table = "estados", value_field = "codest", display_field = "nomest"),
  list(id = "gasto", label = "Gasto", type = "select", ref_table = "gastos", value_field = "codgas", display_field = "nomgas"),
  list(id = "horario", label = "Horario", type = "select", choices = c("Diurno", "Nocturno"))
)

# Función para cargar opciones de referencia con manejo de errores mejorado
load_reference_choices <- function(field) {
  if (is.null(field$ref_table)) {
    message("Campo sin tabla de referencia: ", field$id, " - Usando choices predefinidos")
    return(field$choices)
  }
  
  query <- sprintf("SELECT %s, %s FROM %s", field$value_field, field$display_field, field$ref_table)
  message("Ejecutando consulta para ", field$ref_table, ": ", query)
  
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
  result <- setNames(data$value, data$display)
  message("Resultado de la consulta para ", field$ref_table, ": ", paste(capture.output(str(result)), collapse = "\n"))
  result
}

# Cargar las opciones para las listas desplegables
message("Cargando captura_esfuerzo_choices...")
captura_esfuerzo_choices <- lapply(captura_esfuerzo_fields, load_reference_choices)
names(captura_esfuerzo_choices) <- sapply(captura_esfuerzo_fields, function(field) field$id)
message("Contenido de captura_esfuerzo_choices: ", paste(capture.output(str(captura_esfuerzo_choices)), collapse = "\n"))

# Cargar opciones específicas para el módulo de actividad diaria
message("Cargando opciones para actividad diaria...")
registrador_choices <- tryCatch({
  query <- "SELECT codreg, nomreg FROM registrador ORDER BY nomreg"
  message("Ejecutando consulta para registrador: ", query)
  data <- dbGetQuery(pool, query)
  message("Datos obtenidos para registrador: ", paste(capture.output(str(data)), collapse = "\n"))
  if (nrow(data) > 0) {
    result <- setNames(data$codreg, data$nomreg)
    message("Contenido de registrador_choices: ", paste(capture.output(str(result)), collapse = "\n"))
    result
  } else {
    message("Advertencia: Tabla registrador está vacía o no devolvió datos")
    character(0)
  }
}, error = function(e) {
  message("Error al cargar registradores: ", e$message)
  character(0)
})

arte_pesca_choices <- tryCatch({
  query <- "SELECT codart, nomart FROM arte ORDER BY nomart"
  message("Ejecutando consulta para arte: ", query)
  data <- dbGetQuery(pool, query)
  message("Datos obtenidos para arte: ", paste(capture.output(str(data)), collapse = "\n"))
  if (nrow(data) > 0) {
    result <- setNames(data$codart, data$nomart)
    message("Contenido de arte_pesca_choices: ", paste(capture.output(str(result)), collapse = "\n"))
    result
  } else {
    message("Advertencia: Tabla arte está vacía o no devolvió datos")
    character(0)
  }
}, error = function(e) {
  message("Error al cargar artes de pesca: ", e$message)
  character(0)
})

sitio_desembarque_choices <- tryCatch({
  query <- "SELECT codsit, nomsit FROM sitios ORDER BY nomsit"
  message("Ejecutando consulta para sitios: ", query)
  data <- dbGetQuery(pool, query)
  message("Datos obtenidos para sitios: ", paste(capture.output(str(data)), collapse = "\n"))
  if (nrow(data) > 0) {
    result <- setNames(data$codsit, data$nomsit)
    message("Contenido de sitio_desembarque_choices: ", paste(capture.output(str(result)), collapse = "\n"))
    result
  } else {
    message("Advertencia: Tabla sitios está vacía o no devolvió datos")
    character(0)
  }
}, error = function(e) {
  message("Error al cargar sitios de desembarque: ", e$message)
  character(0)
})

# Cargar opciones para faenas
message("Cargando opciones para faenas...")
faena_choices <- tryCatch({
  query <- "SELECT id, registro FROM faena_principal ORDER BY fecha_zarpe DESC"
  message("Ejecutando consulta para faenas: ", query)
  data <- dbGetQuery(pool, query)
  message("Datos obtenidos para faenas: ", paste(capture.output(str(data)), collapse = "\n"))
  if (nrow(data) > 0) {
    result <- setNames(data$id, paste("Faena", data$id, "-", data$registro))
    message("Contenido de faena_choices: ", paste(capture.output(str(result)), collapse = "\n"))
    result
  } else {
    message("Advertencia: Tabla faena_principal está vacía o no devolvió datos")
    character(0)
  }
}, error = function(e) {
  message("Error al cargar faenas: ", e$message)
  character(0)
})

# Verificación adicional para evitar NULL
if (is.null(faena_choices)) {
  faena_choices <- character(0)
  message("faena_choices era NULL, asignado como character(0) por seguridad")
}

# Cargar opciones para especies (usadas en varios módulos)
especie_choices <- tryCatch({
  query <- "SELECT codesp, nombre_comun FROM especies ORDER BY nombre_comun"
  message("Ejecutando consulta para especies: ", query)
  data <- dbGetQuery(pool, query)
  message("Datos obtenidos para especies: ", paste(capture.output(str(data)), collapse = "\n"))
  if (nrow(data) > 0) {
    result <- setNames(data$codesp, data$nombre_comun)
    message("Contenido de especie_choices: ", paste(capture.output(str(result)), collapse = "\n"))
    result
  } else {
    message("Advertencia: Tabla especies está vacía o no devolvió datos")
    character(0)
  }
}, error = function(e) {
  message("Error al cargar especies: ", e$message)
  character(0)
})

# Cargar todos los módulos
message("Cargando módulos...")
# Cargar los archivos del módulo Tabla de referencia
source("modules/ref_tables_fields.R")
source("modules/ref_tables_ui.R")
source("modules/ref_tables_server.R")
# Cargar los archivos del módulo Ingresi de Datos
source("modules/ingreso_datos/captura_esfuerzo_ui.R")
source("modules/ingreso_datos/captura_esfuerzo_server.R")
source("modules/ingreso_datos/actividad_diaria_ui.R")
source("modules/ingreso_datos/actividad_diaria_server.R")
source("modules/ingreso_datos/frecuencia_tallas_ui.R")
source("modules/ingreso_datos/frecuencia_tallas_server.R")
# Cargar todos los archivos del módulo Verificación de Datos
source("modules/verificacion/verificacion_datos_ui.R")
source("modules/verificacion/verificacion_datos_server.R")
source("modules/verificacion/verificacion_registros_faenas_ui.R")
source("modules/verificacion/verificacion_registros_faenas_server.R")
source("modules/verificacion/verificacion_capturas_desproporcionadas_ui.R")
source("modules/verificacion/verificacion_capturas_desproporcionadas_server.R")
source("modules/verificacion/verificacion_tallas_desproporcionadas_ui.R")
source("modules/verificacion/verificacion_tallas_desproporcionadas_server.R")
source("modules/verificacion/verificacion_faenas_largas_ui.R")
source("modules/verificacion/verificacion_faenas_largas_server.R")
# Cargar los archivos del módulo Procesamiento de Datos
source("modules/procesamiento/procesamiento_datos_ui.R")
source("modules/procesamiento/procesamiento_datos_server.R")
message("Módulos cargados con éxito.")