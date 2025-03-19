# modules/ingreso_datos/ingreso_datos_faena_ui.R

ingreso_datos_faena_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("faena_form")),  # Formulario para faena
    DTOutput(ns("faena_table"))   # Tabla de faenas (opcional, para mostrar los datos)
  )
}