# modules/ingreso_datos/actividad_diaria_ui.R
# UI para el módulo de Actividad Diaria
actividad_diaria_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    card(
      card_header("Registro de Actividad Diaria"),
      card_body(
        layout_sidebar(
          sidebar = sidebar(
            dateInput(ns("fecha"), "Fecha", value = Sys.Date()),
            selectInput(ns("registrador"), "Registrador", choices = NULL),
            selectInput(ns("arte_pesca"), "Arte de pesca", choices = NULL),
            selectInput(ns("zona_desembarco"), "Zona de desembarco", choices = NULL),
            numericInput(ns("num_embarcaciones_activas"), "Número de embarcaciones activas", 
                         value = 0, min = 0),
            numericInput(ns("num_embarcaciones_muestreadas"), "Número de embarcaciones muestreadas", 
                         value = 0, min = 0),
            textAreaInput(ns("observaciones"), "Observaciones"),
            actionButton(ns("guardar"), "Guardar Actividad", class = "btn-primary")
          ),
          layout_column_wrap(
            width = 1,
            card(
              card_header("Actividades Registradas"),
              dataTableOutput(ns("tabla_actividades"))
            )
          )
        )
      )
    )
  )
}