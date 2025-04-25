# modules/verificacion/verificacion_capturas_desproporcionadas_ui.R

verificacion_capturas_desproporcionadas_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h4("Verificación: Capturas Desproporcionadas"),
    p("Este submódulo identifica capturas con cantidades inusualmente altas (Indv > 1000 o Peso > 5000 kg)."),
    DTOutput(ns("tabla")),
    downloadButton(ns("descargar"), "Descargar Reporte en Excel", icon = icon("download"))
  )
}