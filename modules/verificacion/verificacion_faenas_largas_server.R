# modules/verificacion/verificacion_faenas_largas_server.R

verificacion_faenas_largas_server <- function(id, conn) {
  moduleServer(id, function(input, output, session) {
    # Obtener datos
    datos_verificacion <- reactive({
      query <- "
        SELECT id AS Faena_ID, registro AS Faena, fecha_zarpe, fecha_arribo,
               EXTRACT(DAY FROM (COALESCE(fecha_arribo, CURRENT_DATE) - fecha_zarpe)) AS duracion
        FROM faena_principal
        WHERE estado_verificacion = 'E1'
        AND EXTRACT(DAY FROM (COALESCE(fecha_arribo, CURRENT_DATE) - fecha_zarpe)) > 30;
      "
      faenas <- tryCatch({
        dbGetQuery(conn, query)
      }, error = function(e) {
        message("Error al buscar faenas largas: ", e$message)
        data.frame(Faena_ID = integer(), Faena = character(), fecha_zarpe = character(),
                   fecha_arribo = character(), duracion = numeric(), observacion = character())
      })
      
      # Agregar columna de observación
      if (nrow(faenas) > 0) {
        faenas$observacion <- sprintf("Duración excesiva: %s días", faenas$duracion)
      } else {
        faenas <- data.frame(
          Faena_ID = integer(), Faena = character(), fecha_zarpe = character(),
          fecha_arribo = character(), duracion = numeric(), observacion = character()
        )
      }
      faenas
    })
    
    # Renderizar tabla
    output$tabla <- renderDT({
      datatable(
        datos_verificacion(),
        options = list(
          pageLength = 10,
          language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
        )
      )
    })
    
    # Descargar reporte en Excel
    output$descargar <- downloadHandler(
      filename = function() {
        paste("reporte_faenas_largas_", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        datos <- datos_verificacion()
        datos_reporte <- datos[, c("Faena", "fecha_zarpe", "fecha_arribo", "duracion", "observacion")]
        colnames(datos_reporte) <- c("Registro Faena", "Fecha Zarpe", "Fecha Arribo", "Duración (días)", "Observación")
        openxlsx::write.xlsx(datos_reporte, file, rowNames = FALSE)
      }
    )
  })
}