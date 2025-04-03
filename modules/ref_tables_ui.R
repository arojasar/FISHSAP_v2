# modules/ref_tables_ui.R
ref_tables_ui <- function(id, ref_tables_fields) {
  ns <- NS(id)
  
  # Obtener el nombre de la tabla a partir del id
  table_name <- sub("ref_tables_", "", id)
  table_fields <- ref_tables_fields[[table_name]]$fields
  
  message("ref_tables_ui: table_name = ", table_name)
  message("ref_tables_ui: fields para ", table_name, " = ", paste(sapply(table_fields, function(f) f$id), collapse = ", "))
  
  # Generar los campos de entrada dinámicamente según el tipo
  input_fields <- lapply(table_fields, function(field) {
    field_id <- field$id
    label <- field$label
    type <- field$type
    required <- field$required
    
    # Generar el input según el tipo
    if (type == "text") {
      textInput(ns(field_id), label, value = "", placeholder = if (required) "Requerido" else NULL)
    } else if (type == "numeric") {
      numericInput(ns(field_id), label, value = NA, min = 0, step = 1)
    } else if (type == "date") {
      dateInput(ns(field_id), label, value = Sys.Date(), format = "yyyy-mm-dd")
    } else if (type == "select") {
      # Para campos de tipo select, inicialmente mostramos un placeholder
      # Las opciones se cargarán dinámicamente en ref_tables_server.R
      selectInput(ns(field_id), label, choices = c("Cargando..." = ""), multiple = FALSE)
    } else {
      textInput(ns(field_id), label, value = "", placeholder = if (required) "Requerido" else NULL)
    }
  })
  
  tagList(
    fluidRow(
      column(3,
             input_fields,
             actionButton(ns("guardar"), "Guardar")
      ),
      column(9,
             DTOutput(ns("table"))
      )
    )
  )
}