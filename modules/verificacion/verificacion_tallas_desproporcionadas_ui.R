# modules/verificacion/verificacion_tallas_desproporcionadas_ui.R

verificacion_tallas_desproporcionadas_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    # Título del módulo
    titlePanel("Verificación de Tallas Desproporcionadas"),
    
    # Diseño principal
    fluidRow(
      # Columna para los filtros (izquierda)
      column(
        width = 4,
        wellPanel(
          h4("Filtros de Búsqueda"),
          
          # Filtro para seleccionar faena
          selectizeInput(
            ns("faena"),
            "Faena",
            choices = NULL,  # Las opciones se cargarán dinámicamente en el server
            options = list(
              placeholder = "Seleccione una faena",
              create = FALSE,
              maxOptions = 50
            )
          ),
          
          # Filtro para seleccionar especie
          selectInput(
            ns("especie"),
            "Especie",
            choices = c("Seleccione una especie" = ""),
            selected = ""
          ),
          
          # Filtro por rango de fechas
          dateRangeInput(
            ns("fecha_rango"),
            "Rango de Fechas",
            start = Sys.Date() - 30,  # Últimos 30 días por defecto
            end = Sys.Date(),
            format = "yyyy-mm-dd",
            language = "es"
          ),
          
          # Botón para buscar tallas desproporcionadas
          actionButton(
            ns("buscar"),
            "Buscar Tallas Desproporcionadas",
            icon = icon("search"),
            class = "btn-primary"
          )
        )
      ),
      
      # Columna para la tabla de resultados (derecha)
      column(
        width = 8,
        h4("Resultados de Tallas Desproporcionadas"),
        DTOutput(ns("tabla")),  # Tabla para mostrar las tallas desproporcionadas
        downloadButton(
          ns("exportar"),
          "Exportar a CSV",
          icon = icon("download")
        )
      )
    )
  )
}