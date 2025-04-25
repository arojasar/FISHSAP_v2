# server.R

library(shiny)
library(shinydashboard)
library(DT)
library(RPostgres)

server <- function(input, output, session) {
  # Definir un valor reactivo para usuario
  usuario <- reactiveVal("admin")  # Usamos reactiveVal para consistencia
  
  # Llamar a los módulos de tablas de referencia
  # Nota: Simplificamos la inicialización para usar un solo módulo para todas las tablas de referencia
  ref_tables_server("ref_tables_sitios", pool, reactive("sitios"), ref_tables_fields)
  ref_tables_server("ref_tables_especies", pool, reactive("especies"), ref_tables_fields)
  ref_tables_server("ref_tables_estados", pool, reactive("estados"), ref_tables_fields)
  ref_tables_server("ref_tables_clasifica", pool, reactive("clasifica"), ref_tables_fields)
  ref_tables_server("ref_tables_grupos", pool, reactive("grupos"), ref_tables_fields)
  ref_tables_server("ref_tables_subgrupo", pool, reactive("subgrupo"), ref_tables_fields)
  ref_tables_server("ref_tables_arte", pool, reactive("arte"), ref_tables_fields)
  ref_tables_server("ref_tables_metodo", pool, reactive("metodo"), ref_tables_fields)
  ref_tables_server("ref_tables_propulsion", pool, reactive("propulsion"), ref_tables_fields)
  ref_tables_server("ref_tables_area", pool, reactive("area"), ref_tables_fields)
  ref_tables_server("ref_tables_subarea", pool, reactive("subarea"), ref_tables_fields)
  ref_tables_server("ref_tables_registrador", pool, reactive("registrador"), ref_tables_fields)
  ref_tables_server("ref_tables_embarcaciones", pool, reactive("embarcaciones"), ref_tables_fields)
  ref_tables_server("ref_tables_gastos", pool, reactive("gastos"), ref_tables_fields)
  ref_tables_server("ref_tables_valor_mensual_gastos", pool, reactive("valor_mensual_gastos"), ref_tables_fields)
  ref_tables_server("ref_tables_trm_dolar", pool, reactive("trm_dolar"), ref_tables_fields)
  ref_tables_server("ref_tables_clases_medida", pool, reactive("clases_medida"), ref_tables_fields)
  ref_tables_server("ref_tables_nombre_pescador", pool, reactive("nombre_pescador"), ref_tables_fields)
  
  # Llamar a los módulos de ingreso de datos
  captura_esfuerzo_server("captura_esfuerzo", pool)
  
  # Llamar al módulo de actividad diaria, pasando el usuario
  actividad_diaria_server("actividad_diaria", pool, usuario)
  
  # Llamar al módulo de frecuencia de tallas, pasando el usuario
  frecuencia_tallas_server("frecuencia_tallas", pool, usuario)
  
  # Llamar al módulo de verificación de datos
  verificacion_datos_server("verificacion_datos", pool)
  
  # Llamar al módulo de procesamiento de datos
  procesamiento_datos_server("procesamiento_datos", pool)
  
  # Mejorar la gestión de errores durante la sesión
  observeEvent(list(session$clientData$url_protocol, session$clientData$url_hostname), {
    message("Aplicación iniciada en: ", session$clientData$url_protocol, "//", session$clientData$url_hostname)
  })
  
  # Verificar periódicamente la conexión a la base de datos
  observe({
    invalidateLater(300000) # Verificar cada 5 minutos
    tryCatch({
      conn <- poolCheckout(pool)
      valid <- dbIsValid(conn)
      poolReturn(conn)
      if (!valid) {
        message("¡Advertencia! Conexión a la base de datos no válida. Intentando reconectar...")
      }
    }, error = function(e) {
      message("Error al verificar la conexión: ", e$message)
    })
  })
  
  # Cerrar la conexión a la base de datos al finalizar
  onStop(function() {
    poolClose(pool)
  })
}