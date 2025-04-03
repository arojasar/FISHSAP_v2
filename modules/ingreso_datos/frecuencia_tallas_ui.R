# modules/ingreso_datos/frecuencia_tallas_ui.R
frecuencia_tallas_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h3("Frecuencia de Tallas"),
    fluidRow(
      column(6,
             selectInput(ns("especie"), "Especie", choices = c("")),
             numericInput(ns("talla"), "Talla (cm)", value = 0, min = 0),
             numericInput(ns("frecuencia"), "Frecuencia", value = 0, min = 0),
             actionButton(ns("add_talla"), "Añadir Talla", class = "btn-primary")
      )
    ),
    hr(),
    DTOutput(ns("tallas_table"))
  )
}