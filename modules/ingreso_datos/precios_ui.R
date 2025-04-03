# modules/ingreso_datos/precios_ui.R
precios_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h3("Precios"),
    fluidRow(
      column(6,
             selectInput(ns("especie"), "Especie", choices = c("")),
             numericInput(ns("precio_unidad"), "Precio por Unidad (por kg)", value = 0, min = 0),
             numericInput(ns("valor_total"), "Valor Total", value = 0, min = 0),
             actionButton(ns("add_precio"), "Añadir Precio", class = "btn-primary")
      )
    ),
    hr(),
    DTOutput(ns("precios_table"))
  )
}