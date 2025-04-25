# modules/verificacion/verificacion_faenas_largas_ui.R

verificacion_faenas_largas_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h4("Verificación: Faenas Muy Largas"),
    p("Este submódulo identifica faenas con duraciones mayores a 30 días."),
    DTOutput(ns("tabla")),
    downloadButton(ns("descargar"), "Descargar Reporte en Excel", icon = icon("download"))
  )
}