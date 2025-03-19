# global.R
library(shiny)
library(DT)
library(shinydashboard)  # ¡Usamos shinydashboard!
library(RPostgres)  # CORRECTO
library(DBI)
library(jsonlite) # Para depuración

# Configuración de la base de datos
db_config <- list(
  dbname = Sys.getenv("DB_NAME"),
  host = Sys.getenv("DB_HOST"),
  port = as.integer(Sys.getenv("DB_PORT")),
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD")
)

# Conexión a la base de datos
central_conn <- tryCatch({
  do.call(dbConnect, c(RPostgres::Postgres(), db_config))
}, error = function(e) {
  message("Error al conectar a la base de datos: ", e$message)
  NULL  # La aplicación *no* funcionará sin conexión en esta versión
})

# Cargar funciones de utilidad
source("utils/db_setup.R")

# Crear las tablas (si no existen y si hay conexión)
if (!is.null(central_conn)) {
  setup_databases(central_conn)
}

# --- Cargar módulos genéricos ---
source("modules/ref_tables_ui.R")
source("modules/ref_tables_server.R")

# --- Cargar módulos específicos ---
# source("modules/ref_tables/ref_tables_sitios_ui.R") # ELIMINADO
# source("modules/ref_tables/ref_tables_sitios_server.R") # ELIMINADO
source("modules/ingreso_datos/ingreso_datos_faena_ui.R")
source("modules/ingreso_datos/ingreso_datos_faena_server.R")

# ... (otros módulos específicos, si los tienes) ...