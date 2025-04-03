captura_esfuerzo_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h3("Captura y Esfuerzo"),
    fluidRow(
      box(width = 12, title = "Faenas Registradas", status = "primary", solidHeader = TRUE,
          DTOutput(ns("faenas_table"))
      )
    ),
    fluidRow(
      box(width = 12, title = "Detalles de la Faena", status = "primary", solidHeader = TRUE,
          fluidRow(
            column(3,
                   textInput(ns("registro"), "Registro No.", value = ""),
                   dateInput(ns("fecha_zarpe"), "Fecha de Zarpe", value = Sys.Date())
            ),
            column(3,
                   dateInput(ns("fecha_arribo"), "Fecha de Arribo", value = Sys.Date()),
                   selectInput(ns("sitio_desembarque"), "Sitio de Desembarque", choices = c(""))
            ),
            column(3,
                   selectInput(ns("subarea"), "Subárea", choices = c("")),
                   selectInput(ns("registrador"), "Registrador", choices = c(""))
            ),
            column(3,
                   selectInput(ns("pescadores"), "Nombre del Pescador", choices = c(""), multiple = TRUE)
            )
          )
      )
    ),
    fluidRow(
      box(width = 6, title = "Detalles de la Unidad de Pesca en Información del Esfuerzo Pesquero", status = "primary", solidHeader = TRUE,
          fluidRow(
            column(6,
                   selectInput(ns("embarcacion"), "Embarcación", choices = c("")),
                   h5("Motores"),
                   div(class = "non-editable-field", textOutput(ns("motores_text"))),  # Aplicar estilo
                   numericInput(ns("galones"), "Galones Consumidos", value = 0, min = 0)
            ),
            column(6,
                   h5("Propulsión"),
                   div(class = "non-editable-field", textOutput(ns("propulsion_text"))),  # Aplicar estilo
                   h5("Potencia"),
                   div(class = "non-editable-field", textOutput(ns("potencia_text"))),  # Aplicar estilo
                   numericInput(ns("pescadores_count"), "Número de Pescadores", value = 1, min = 1)
            )
          ),
          fluidRow(
            column(4,
                   timeInput(ns("hora_salida"), "Hora de Salida", value = Sys.time())
            ),
            column(4,
                   timeInput(ns("hora_arribo"), "Hora de Arribo", value = Sys.time())
            ),
            column(4,
                   selectInput(ns("horario"), "Horario", choices = c("Diurno", "Nocturno"))
            )
          )
      ),
      box(width = 6, title = "Captura Desembarcada", status = "primary", solidHeader = TRUE,
          fluidRow(
            column(12,
                   selectInput(ns("especie"), "Especie", choices = c("")),
                   selectInput(ns("estado"), "Estado", choices = c("")),
                   numericInput(ns("indv"), "Número de Individuos", value = 0, min = 0),
                   numericInput(ns("peso"), "Peso (kg)", value = 0, min = 0),
                   actionButton(ns("add_captura"), "Añadir Captura", class = "btn-primary")
            )
          ),
          hr(),
          DTOutput(ns("captura_table"))
      )
    ),
    fluidRow(
      box(width = 6, title = "Arte y Método de Pesca", status = "primary", solidHeader = TRUE,
          fluidRow(
            column(6,
                   selectInput(ns("arte_pesca"), "Arte de Pesca", choices = c(""))
            ),
            column(6,
                   selectInput(ns("metodo_pesca"), "Método de Pesca", choices = c(""), multiple = TRUE)
            )
          )
      ),
      box(width = 6, title = "Costos de Operación", status = "primary", solidHeader = TRUE,
          fluidRow(
            column(12,
                   selectInput(ns("gasto"), "Descripción", choices = c("")),
                   numericInput(ns("valor_gasto"), "Valor", value = 0, min = 0),
                   actionButton(ns("add_gasto"), "Añadir Gasto", class = "btn-primary")
            )
          ),
          hr(),
          DTOutput(ns("costos_table"))
      )
    ),
    fluidRow(
      box(width = 12, title = "Observaciones", status = "primary", solidHeader = TRUE,
          textAreaInput(ns("observaciones"), "Observaciones", value = "", rows = 3)
      )
    ),
    fluidRow(
      column(12,
             actionButton(ns("nuevo"), "Nuevo", class = "btn-primary"),
             actionButton(ns("modificar"), "Modificar", class = "btn-primary"),
             actionButton(ns("borrar"), "Borrar", class = "btn-danger"),
             actionButton(ns("guardar"), "Guardar", class = "btn-success")
      )
    )
  )
}