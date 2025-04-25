# modules/verificacion_datos/verificacion_registros_faenas_ui.R

verificacion_registros_faenas_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h4("Verificación: Cantidad de Registros vs. Faenas Activas"),
    p("Este submódulo verifica si el número de registros en detalles_captura coincide con el número de faenas activas."),
    DTOutput(ns("tabla")),
    downloadButton(ns("descargar"), "Descargar Reporte en Excel", icon = icon("download"))
  )
}