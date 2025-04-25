# modules/verificacion/verificacion_capturas_desproporcionadas_server.R

verificacion_capturas_desproporcionadas_server <- function(id, conn) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Obtener datos
    datos_verificacion <- reactiveVal(NULL)
    
    # Cargar datos al hacer clic en "Ejecutar"
    observeEvent(input$ejecutar, {
      # Validar entradas
      threshold_indv <- as.numeric(input$threshold_indv %||% 100)
      threshold_peso <- as.numeric(input$threshold_peso %||% 500)
      
      # Usar nombres exactos de columnas según el esquema
      query <- sprintf(
        "SELECT dc.id AS registro_id, fp.registro AS faena, fp.fecha_zarpe, fp.fecha_arribo,
                e.nombre_comun AS especie, dc.\"Indv\" AS indv, dc.\"Peso\" AS peso
         FROM detalles_captura dc
         JOIN faena_principal fp ON dc.\"Faena_ID\" = fp.id
         JOIN especies e ON dc.\"Especie_ID\" = e.codesp
         WHERE (dc.\"Indv\" IS NOT NULL AND dc.\"Indv\" > %f) OR (dc.\"Peso\" IS NOT NULL AND dc.\"Peso\" > %f);",
        threshold_indv,
        threshold_peso
      )
      
      capturas <- tryCatch({
        result <- dbGetQuery(conn, query)
        message("Filas en capturas: ", nrow(result))
        # Renombrar columnas a nombres consistentes
        colnames(result) <- c("registro_id", "faena", "fecha_zarpe", "fecha_arribo", "especie", "indv", "peso")
        # Convertir a numérico, manejando NA
        result$indv <- as.numeric(as.character(result$indv))
        result$peso <- as.numeric(as.character(result$peso))
        message("Valores de indv: ", paste(result$indv, collapse = ", "))
        message("Valores de peso: ", paste(result$peso, collapse = ", "))
        result
      }, error = function(e) {
        message("Error al buscar capturas desproporcionadas: ", e$message)
        showNotification("Error al cargar los datos. Verifique la conexión a la base de datos o los nombres de las columnas.", type = "error")
        data.frame(
          registro_id = integer(),
          faena = character(),
          fecha_zarpe = character(),
          fecha_arribo = character(),
          especie = character(),
          indv = numeric(),
          peso = numeric(),
          stringsAsFactors = FALSE
        )
      })
      
      # Agregar la columna observacion
      if (nrow(capturas) > 0) {
        message("Asignando observacion para ", nrow(capturas), " filas")
        capturas$observacion <- mapply(
          function(indv, peso) {
            if (is.na(indv) && is.na(peso)) {
              "Valores no válidos"
            } else if (!is.na(indv) && indv > threshold_indv) {
              "Indv demasiado alto"
            } else if (!is.na(peso) && peso > threshold_peso) {
              "Peso demasiado alto"
            } else {
              "Valores dentro del rango"
            }
          },
          capturas$indv,
          capturas$peso,
          SIMPLIFY = TRUE
        )
        message("Observaciones asignadas: ", paste(capturas$observacion, collapse = ", "))
      } else {
        message("No hay capturas desproporcionadas, inicializando observacion como vacía")
        capturas$observacion <- character(nrow(capturas))
      }
      
      datos_verificacion(capturas)
    })
    
    # Renderizar tabla
    output$tabla <- renderDT({
      datos <- datos_verificacion()
      if (is.null(datos) || nrow(datos) == 0) {
        datatable(
          data.frame(Mensaje = "No se encontraron capturas desproporcionadas. Ajuste los umbrales y haga clic en 'Ejecutar'."),
          options = list(
            pageLength = 10,
            language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
          )
        )
      } else {
        datatable(
          datos,
          selection = "single",
          options = list(
            pageLength = 10,
            language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
          ),
          callback = JS(
            "table.on('click.dt', 'tr', function() {",
            "  var data = table.row(this).data();",
            "  Shiny.setInputValue('", ns("selected_row"), "', data[0]);",
            "});"
          )
        )
      }
    })
    
    # Mostrar modal al seleccionar un registro
    observeEvent(input$selected_row, {
      selected_row <- input$selected_row
      datos <- datos_verificacion()
      row <- datos[datos$registro_id == as.integer(selected_row), ]
      
      if (nrow(row) == 0) return()
      
      showModal(modalDialog(
        title = "Ajustar Valores de Captura",
        numericInput(ns("indv"), "Número de Individuos", value = row$indv %||% 0, min = 0, step = 1),
        numericInput(ns("peso"), "Peso (kg)", value = row$peso %||% 0, min = 0, step = 0.01),
        footer = tagList(
          modalButton("Cancelar"),
          actionButton(ns("guardar"), "Guardar", class = "btn-primary")
        )
      ))
    })
    
    # Guardar cambios
    observeEvent(input$guardar, {
      selected_row <- input$selected_row
      datos <- datos_verificacion()
      row <- datos[datos$registro_id == as.integer(selected_row), ]
      
      if (nrow(row) == 0) return()
      
      # Actualizar en la base de datos
      query_update <- sprintf(
        "UPDATE detalles_captura
         SET \"Indv\" = %s, \"Peso\" = %s
         WHERE id = %s;",
        input$indv %||% 0,
        if (is.null(input$peso) || input$peso <= 0) "NULL" else input$peso,
        selected_row
      )
      
      tryCatch({
        dbExecute(conn, query_update)
        showNotification("Registro actualizado correctamente.", type = "message")
        
        # No refrescamos automáticamente, el usuario debe hacer clic en "Ejecutar" nuevamente
        removeModal()
      }, error = function(e) {
        showNotification(paste("Error al actualizar el registro:", e$message), type = "error")
      })
    })
    
    # Descargar reporte en Excel
    output$descargar <- downloadHandler(
      filename = function() {
        paste("reporte_capturas_desproporcionadas_", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        datos <- datos_verificacion()
        if (nrow(datos) == 0) {
          datos <- data.frame(Mensaje = "No hay datos para exportar")
        }
        datos_reporte <- datos[, c("faena", "fecha_zarpe", "fecha_arribo", "especie", "indv", "peso", "observacion")]
        colnames(datos_reporte) <- c("Registro Faena", "Fecha Zarpe", "Fecha Arribo", "Especie", "Individuos", "Peso (kg)", "Observación")
        openxlsx::write.xlsx(datos_reporte, file, rowNames = FALSE)
      }
    )
  })
}