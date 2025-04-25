# modules/ingreso_datos/actividad_diaria_ui.R
# UI para el módulo de Actividad Diaria
actividad_diaria_ui <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    shinyjs::useShinyjs(),  # Habilitar shinyjs para la exportación
    
    fluidRow(
      column(width = 4,
             box(
               title = "Ingreso de Actividad Diaria",
               status = "primary",
               solidHeader = TRUE,
               width = NULL,
               
               # Campos de formulario
               dateInput(ns("fecha"), "Fecha", value = Sys.Date()),
               
               selectInput(ns("registrador"), "Registrador", 
                           choices = c("Cargando..." = "")),
               
               selectInput(ns("arte_pesca"), "Arte de Pesca", 
                           choices = c("Cargando..." = "")),
               
               selectInput(ns("zona_desembarco"), "Zona de Desembarco", 
                           choices = c("Cargando..." = "")),
               
               numericInput(ns("num_embarcaciones_activas"), 
                            "Número de Embarcaciones Activas", 
                            value = 0, min = 0),
               
               numericInput(ns("num_embarcaciones_muestreadas"), 
                            "Número de Embarcaciones Muestreadas", 
                            value = 0, min = 0),
               
               textAreaInput(ns("observaciones"), "Observaciones", rows = 3),
               
               # Botones de acción
               div(
                 style = "display:flex; justify-content:space-between; margin-top: 15px;",
                 actionButton(ns("nuevo"), "Nuevo", icon = icon("file")),
                 actionButton(ns("guardar"), "Guardar", icon = icon("save"), class = "btn-success"),
                 actionButton(ns("modificar"), "Modificar", icon = icon("edit"), class = "btn-warning"),
                 actionButton(ns("borrar"), "Borrar", icon = icon("trash"), class = "btn-danger")
               )
             )
      ),
      
      column(width = 8,
             box(
               title = "Registros de Actividad Diaria",
               status = "primary",
               solidHeader = TRUE,
               width = NULL,
               
               # Botón de exportación en la parte superior
               div(
                 style = "text-align: right; margin-bottom: 10px;",
                 actionButton(ns("exportar"), "Exportar a CSV", icon = icon("download"), class = "btn-info")
               ),
               
               # Tabla de actividades
               dataTableOutput(ns("tabla_actividades")),
               
               # Información adicional
               tags$div(
                 style = "margin-top: 15px; font-size: 0.8em; color: #666;",
                 tags$p("Para editar o eliminar un registro, seleccione una fila de la tabla y use los botones correspondientes."),
                 tags$p("Los datos se muestran ordenados por fecha, con los más recientes primero.")
               )
             )
      )
    )
  )
}