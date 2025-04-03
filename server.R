# server.R
library(shiny)
library(shinydashboard)
library(DT)
library(RPostgres)

server <- function(input, output, session) {
  # Variable reactiva para almacenar la tabla de referencia actual
  current_ref_table <- reactiveVal("sitios")  # Valor inicial
  
  # Actualizar current_ref_table cuando cambia la pestaña
  observe({
    message("Valor de input$sidebar: ", input$sidebar)
    if (!is.null(input$sidebar)) {
      current_ref_table(input$sidebar)
    }
    message("Valor de current_ref_table DESPUÉS de actualizar: ", current_ref_table())
  })
  
  # Llamar a los módulos para cada tabla de referencia, pasando el pool
  ref_tables_server("ref_tables_sitios", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_especies", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_estados", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_clasifica", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_grupos", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_subgrupo", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_arte", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_metodo", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_propulsion", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_area", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_subarea", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_registrador", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_embarcaciones", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_gastos", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_valor_mensual_gastos", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_trm_dolar", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_clases_medida", pool, current_ref_table, ref_tables_fields)
  ref_tables_server("ref_tables_nombre_pescador", pool, current_ref_table, ref_tables_fields)
  
  # Llamar a los módulos de ingreso de datos
  captura_esfuerzo_server("captura_esfuerzo", pool)
  
  # Llamar al nuevo módulo de actividad diaria
  actividad_diaria_server("actividad_diaria", pool, list(
    registrador = registrador_choices,
    arte_pesca = arte_pesca_choices,
    sitio = sitio_desembarque_choices
  ))
  
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
}