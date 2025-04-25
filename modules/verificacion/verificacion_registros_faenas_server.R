# modules/verificacion/verificacion_registros_faenas_server.R

verificacion_registros_faenas_server <- function(id, conn) {
  moduleServer(id, function(input, output, session) {
    # Obtener datos
    datos_verificacion <- reactive({
      # Contar faenas activas (estado_verificacion = 'E1' y sin fecha_arribo)
      query_faenas <- "
        SELECT COUNT(*) AS faenas_activas
        FROM faena_principal
        WHERE estado_verificacion = 'E1' AND (fecha_arribo IS NULL OR fecha_arribo > CURRENT_DATE);
      "
      faenas_activas <- tryCatch({
        dbGetQuery(conn, query_faenas)$faenas_activas[1]
      }, error = function(e) {
        message("Error al contar faenas activas: ", e$message)
        0
      })
      
      # Contar registros en detalles_captura por faena activa
      query_registros <- "
        SELECT fp.id AS Faena_ID, fp.registro AS Faena, fp.fecha_zarpe, fp.fecha_arribo,
               COUNT(dc.id) AS num_registros
        FROM faena_principal fp
        LEFT JOIN detalles_captura dc ON fp.id = dc.faena_id
        WHERE fp.estado_verificacion = 'E1' AND (fp.fecha_arribo IS NULL OR fp.fecha_arribo > CURRENT_DATE)
        GROUP BY fp.id, fp.registro, fp.fecha_zarpe, fp.fecha_arribo;
      "
      registros <- tryCatch({
        dbGetQuery(conn, query_registros)
      }, error = function(e) {
        message("Error al contar registros: ", e$message)
        data.frame(Faena_ID = integer(), Faena = character(), fecha_zarpe = character(), fecha_arribo = character(), num_registros = integer())
      })
      
      # Agregar columna de verificación solo si hay datos
      if (nrow(registros) > 0) {
        registros$faenas_activas_total <- faenas_activas
        registros$coincide <- registros$num_registros > 0 & faenas_activas > 0
        registros$observacion <- ifelse(registros$coincide, "OK", "Posible problema: registros no coinciden con faenas activas")
      } else {
        # Si no hay datos, devolvemos un data.frame vacío con las columnas esperadas
        registros <- data.frame(
          Faena_ID = integer(),
          Faena = character(),
          fecha_zarpe = character(),
          fecha_arribo = character(),
          num_registros = integer(),
          faenas_activas_total = integer(),
          coincide = logical(),
          observacion = character()
        )
      }
      registros
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
        paste("reporte_registros_faenas_", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        datos <- datos_verificacion()
        datos_reporte <- datos[, c("Faena", "fecha_zarpe", "fecha_arribo", "num_registros", "faenas_activas_total", "observacion")]
        colnames(datos_reporte) <- c("Registro Faena", "Fecha Zarpe", "Fecha Arribo", "Número de Registros", "Faenas Activas Total", "Observación")
        openxlsx::write.xlsx(datos_reporte, file, rowNames = FALSE)
      }
    )
  })
}