# modules/procesamiento/procesamiento_datos_ui.R

procesamiento_datos_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Procesamiento de Datos"),
    fluidRow(
      column(3,
             dateRangeInput(ns("fecha_rango"), "Rango de Fechas",
                            start = Sys.Date() - 365, end = Sys.Date(),
                            language = "es")),
      column(3,
             selectInput(ns("especie"), "Especie",
                         choices = c("Todas" = "", especie_choices),
                         selected = "")),
      column(3,
             selectInput(ns("sitio"), "Sitio de Desembarque",
                         choices = c("Todos" = "", sitio_desembarque_choices),
                         selected = ""))
    ),
    br(),
    tabsetPanel(
      tabPanel("Estadísticas", procesamiento_estadisticas_ui(ns("estadisticas"))),
      tabPanel("Estimaciones", procesamiento_estimaciones_ui(ns("estimaciones")))
      # tabPanel("Análisis de la Información", procesamiento_analisis_ui(ns("analisis")))
    )
  )
}

procesamiento_estadisticas_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h4("Estadísticas Descriptivas"),
    p("Este submódulo calcula estadísticas básicas de las capturas y faenas."),
    actionButton(ns("calcular"), "Calcular Estadísticas", icon = icon("calculator"), class = "btn-primary"),
    br(), br(),
    DTOutput(ns("tabla_capturas")),
    downloadButton(ns("descargar_capturas"), "Descargar Capturas en Excel", icon = icon("download")),
    br(), br(),
    DTOutput(ns("tabla_faenas")),
    downloadButton(ns("descargar_faenas"), "Descargar Faenas en Excel", icon = icon("download"))
  )
}

procesamiento_estimaciones_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h4("Estimaciones"),
    p("Este submódulo calcula estimaciones de capturas totales basadas en las actividades diarias."),
    actionButton(ns("calcular"), "Calcular Estimaciones", icon = icon("calculator"), class = "btn-primary"),
    br(), br(),
    DTOutput(ns("tabla_estimaciones")),
    downloadButton(ns("descargar_estimaciones"), "Descargar Estimaciones en Excel", icon = icon("download"))
  )
}