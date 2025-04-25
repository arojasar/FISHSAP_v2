# modules/ingreso_datos/frecuencia_tallas_ui.R

frecuencia_tallas_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Registro de Frecuencia de Tallas"),
    fluidRow(
      # Columna izquierda: Formulario
      column(
        width = 6,
        wellPanel(
          h4("Ingresar Frecuencia de Tallas"),
          # Sección: Datos de la Faena
          h5("Datos de la Faena", style = "margin-top: 0;"),
          radioButtons(
            ns("vinculada_faena"),
            "Vincular a una faena",
            choices = c("Vinculada a una faena" = "si", "No vinculada" = "no"),
            selected = "no"
          ),
          uiOutput(ns("faena_input")),
          uiOutput(ns("faena_datos_input")),
          textInput(
            ns("codfre_original"),
            "Código de Frecuencia (Opcional)",
            placeholder = "Identificador del muestreo (agrupa varias tallas)"
          ),
          # Sección: Datos de la Talla
          h5("Datos de la Talla", style = "margin-top: 20px;"),
          selectInput(
            ns("especie"),
            "Especie *",
            choices = c("Seleccione una especie" = ""),
            selected = ""
          ),
          selectInput(
            ns("tipo_medida"),
            "Tipo de Medida *",
            choices = c(
              "Seleccione un tipo de medida" = "",
              "Longitud Total" = "Longitud Total",
              "Longitud Estándar" = "Longitud Estándar",
              "Longitud Horquilla" = "Longitud Horquilla",
              "Longitud Cefalotórax" = "Longitud Cefalotórax",
              "Longitud Cola" = "Longitud Cola",
              "Longitud Concha" = "Longitud Concha"
            ),
            selected = ""
          ),
          uiOutput(ns("talla_input")),
          numericInput(
            ns("frecuencia"),
            "Frecuencia (número de individuos) *",
            value = 1,
            min = 1,
            step = 1
          ),
          numericInput(
            ns("peso"),
            "Peso (opcional, en kg)",
            value = NULL,
            min = 0,
            step = 0.01
          ),
          selectInput(
            ns("sexo"),
            "Sexo (opcional)",
            choices = c(
              "No aplica" = "No aplica",
              "Hembra" = "H Hembra",
              "Macho" = "M Macho",
              "Indefinido" = "I Indefinido"
            ),
            selected = "No aplica"
          ),
          div(
            style = "margin-top: 20px; display: flex; gap: 10px; flex-wrap: wrap;",
            actionButton(
              ns("nuevo_muestreo"), 
              "Iniciar Nuevo Muestreo", 
              icon = icon("plus-square"),
              title = "Limpia el formulario y la tabla para empezar un nuevo muestreo",
              class = "btn-primary"
            ),
            actionButton(
              ns("nuevo"), 
              "Agregar Talla", 
              icon = icon("plus"),
              title = "Agrega la talla actual a la tabla temporal sin limpiar el formulario",
              class = "btn-primary"
            ),
            actionButton(
              ns("guardar"), 
              "Guardar", 
              icon = icon("save"),
              title = "Guarda todas las tallas de la tabla temporal en la base de datos",
              class = "btn-success"
            ),
            actionButton(
              ns("modificar"), 
              "Modificar", 
              icon = icon("edit"),
              title = "Muestra los registros almacenados para modificar uno de ellos",
              class = "btn-info"
            ),
            actionButton(
              ns("borrar"), 
              "Borrar", 
              icon = icon("trash"),
              title = "Elimina el registro seleccionado en la tabla de registros almacenados",
              class = "btn-danger"
            )
          )
        )
      ),
      # Columna derecha: Tabla temporal
      column(
        width = 6,
        h4("Datos del Registro Actual"),
        DTOutput(ns("tabla_temporal"))
      )
    ),
    # Tabla de registros almacenados (oculta por defecto)
    fluidRow(
      column(
        width = 12,
        conditionalPanel(
          condition = "output.mostrar_tabla_registros == true",
          ns = ns,
          h4("Registros de Frecuencia de Tallas"),
          DTOutput(ns("tabla")),
          div(
            style = "margin-top: 10px; display: flex; gap: 10px; flex-wrap: wrap;",
            downloadButton(
              ns("exportar"),
              "Exportar a CSV",
              icon = icon("download"),
              class = "btn-primary"
            ),
            actionButton(
              ns("ocultar_registros"),
              "Ocultar Registros",
              icon = icon("eye-slash"),
              title = "Oculta la tabla de registros almacenados",
              class = "btn-default"
            )
          )
        )
      )
    )
  )
}