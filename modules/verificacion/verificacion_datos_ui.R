# modules/verificacion/verificacion_datos_ui.R

verificacion_datos_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Verificación de Datos"),
    tabsetPanel(
      tabPanel("Registros vs. Faenas Activas", verificacion_registros_faenas_ui(ns("registros_faenas"))),
      tabPanel("Capturas Desproporcionadas", verificacion_capturas_desproporcionadas_ui(ns("capturas_desproporcionadas"))),
      tabPanel("Tallas Desproporcionadas", verificacion_tallas_desproporcionadas_ui(ns("tallas_desproporcionadas"))),
      tabPanel("Faenas Muy Largas", verificacion_faenas_largas_ui(ns("faenas_largas")))
    )
  )
}