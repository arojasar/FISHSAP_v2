# modules/procesamiento/procesamiento_datos_server.R

procesamiento_datos_server <- function(id, conn) {
  moduleServer(id, function(input, output, session) {
    # Inicializar los submódulos
    procesamiento_estadisticas_server("estadisticas", conn, 
                                      reactive(input$fecha_rango),
                                      reactive(input$especie),
                                      reactive(input$sitio))
    procesamiento_estimaciones_server("estimaciones", conn,
                                      reactive(input$fecha_rango),
                                      reactive(input$especie),
                                      reactive(input$sitio))
  })
}

procesamiento_estadisticas_server <- function(id, conn, fecha_rango, especie, sitio) {
  moduleServer(id, function(input, output, session) {
    # Variable reactiva para controlar si se debe recalcular
    calcular <- reactiveVal(FALSE)
    
    # Actualizar la variable cuando se haga clic en el botón
    observeEvent(input$calcular, {
      calcular(TRUE)
      showNotification("Calculando estadísticas...", type = "message")
    })
    
    # Obtener datos de capturas
    datos_capturas <- reactive({
      # Verificar si ya existe un reporte con los mismos filtros
      fecha_inicio <- fecha_rango()[1]
      fecha_fin <- fecha_rango()[2]
      especie_id <- if (especie() == "") NULL else especie()
      sitio_id <- if (sitio() == "") NULL else sitio()
      
      # Consulta para verificar si existe un reporte
      query_check <- "
        SELECT especie, num_registros, total_individuos, total_peso_kg
        FROM reporte_estadisticas
        WHERE fecha_inicio = $1 AND fecha_fin = $2
          AND (especie_id IS NULL OR especie_id = $3)
          AND (sitio_id IS NULL OR sitio_id = $4)
          AND sitio_id IS NULL;
      "
      params_check <- list(fecha_inicio, fecha_fin, especie_id, sitio_id)
      
      capturas_existentes <- tryCatch({
        dbGetQuery(conn, query_check, params = params_check)
      }, error = function(e) {
        message("Error al verificar reporte de estadísticas: ", e$message)
        data.frame()
      })
      
      # Si existe un reporte y no se ha solicitado recalcular, usar los datos almacenados
      if (nrow(capturas_existentes) > 0 && !calcular()) {
        return(capturas_existentes)
      }
      
      # Si no existe o se solicita recalcular, generar nuevos datos
      query <- "
        SELECT e.nombre_comun AS Especie,
               COUNT(dc.id) AS num_registros,
               SUM(dc.indv) AS total_individuos,
               SUM(dc.peso) AS total_peso_kg
        FROM detalles_captura dc
        JOIN faena_principal fp ON dc.faena_id = fp.id
        JOIN especies e ON dc.especie_id = e.codesp
        WHERE fp.fecha_zarpe BETWEEN $1 AND $2
      "
      params <- list(fecha_inicio, fecha_fin)
      
      # Ajustar la consulta y los parámetros dinámicamente
      param_count <- 2
      if (!is.null(especie_id)) {
        param_count <- param_count + 1
        query <- paste0(query, " AND dc.especie_id = $", param_count)
        params <- append(params, especie_id)
      }
      
      if (!is.null(sitio_id)) {
        param_count <- param_count + 1
        query <- paste0(query, " AND fp.sitio_desembarque = $", param_count)
        params <- append(params, sitio_id)
      }
      
      query <- paste0(query, " GROUP BY e.nombre_comun;")
      
      capturas <- tryCatch({
        dbGetQuery(conn, query, params = params)
      }, error = function(e) {
        message("Error al calcular estadísticas de capturas: ", e$message)
        data.frame(Especie = character(), num_registros = integer(),
                   total_individuos = integer(), total_peso_kg = numeric())
      })
      
      # Guardar los resultados en la tabla reporte_estadisticas
      if (nrow(capturas) > 0) {
        # Eliminar reportes anteriores con los mismos filtros
        dbExecute(conn, "
          DELETE FROM reporte_estadisticas
          WHERE fecha_inicio = $1 AND fecha_fin = $2
            AND (especie_id IS NULL OR especie_id = $3)
            AND (sitio_id IS NULL OR sitio_id = $4)
            AND sitio_id IS NULL;
        ", params = params_check)
        
        # Insertar nuevos datos
        for (i in 1:nrow(capturas)) {
          dbExecute(conn, "
            INSERT INTO reporte_estadisticas (fecha_inicio, fecha_fin, especie_id, sitio_id,
                                             especie, num_registros, total_individuos, total_peso_kg,
                                             creado_por, fecha_creacion)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, CURRENT_TIMESTAMP);
          ", params = list(fecha_inicio, fecha_fin, especie_id, sitio_id,
                           capturas$Especie[i], capturas$num_registros[i],
                           capturas$total_individuos[i], capturas$total_peso_kg[i],
                           "admin"))
        }
      }
      
      capturas
    })
    
    # Obtener datos de faenas por sitio
    datos_faenas <- reactive({
      fecha_inicio <- fecha_rango()[1]
      fecha_fin <- fecha_rango()[2]
      sitio_id <- if (sitio() == "") NULL else sitio()
      
      query_check <- "
        SELECT sitio, nombre_sitio, num_faenas
        FROM reporte_estadisticas
        WHERE fecha_inicio = $1 AND fecha_fin = $2
          AND (sitio_id IS NULL OR sitio_id = $3)
          AND especie_id IS NULL;
      "
      params_check <- list(fecha_inicio, fecha_fin, sitio_id)
      
      faenas_existentes <- tryCatch({
        dbGetQuery(conn, query_check, params = params_check)
      }, error = function(e) {
        message("Error al verificar reporte de faenas: ", e$message)
        data.frame()
      })
      
      if (nrow(faenas_existentes) > 0 && !calcular()) {
        return(faenas_existentes)
      }
      
      query <- "
        SELECT fp.sitio_desembarque AS Sitio,
               s.nomsit AS Nombre_Sitio,
               COUNT(fp.id) AS num_faenas
        FROM faena_principal fp
        LEFT JOIN sitios s ON fp.sitio_desembarque = s.codsit
        WHERE fp.fecha_zarpe BETWEEN $1 AND $2
      "
      params <- list(fecha_inicio, fecha_fin)
      
      if (!is.null(sitio_id)) {
        query <- paste0(query, " AND fp.sitio_desembarque = $3")
        params <- append(params, sitio_id)
      }
      
      query <- paste0(query, " GROUP BY fp.sitio_desembarque, s.nomsit;")
      
      faenas <- tryCatch({
        dbGetQuery(conn, query, params = params)
      }, error = function(e) {
        message("Error al calcular estadísticas de faenas: ", e$message)
        data.frame(Sitio = character(), Nombre_Sitio = character(), num_faenas = integer())
      })
      
      if (nrow(faenas) > 0) {
        dbExecute(conn, "
          DELETE FROM reporte_estadisticas
          WHERE fecha_inicio = $1 AND fecha_fin = $2
            AND (sitio_id IS NULL OR sitio_id = $3)
            AND especie_id IS NULL;
        ", params = params_check)
        
        for (i in 1:nrow(faenas)) {
          dbExecute(conn, "
            INSERT INTO reporte_estadisticas (fecha_inicio, fecha_fin, sitio_id,
                                             sitio, nombre_sitio, num_faenas,
                                             creado_por, fecha_creacion)
            VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP);
          ", params = list(fecha_inicio, fecha_fin, sitio_id,
                           faenas$Sitio[i], faenas$Nombre_Sitio[i], faenas$num_faenas[i],
                           "admin"))
        }
      }
      
      faenas
    })
    
    # Renderizar tabla de capturas
    output$tabla_capturas <- renderDT({
      datatable(
        datos_capturas(),
        options = list(
          pageLength = 10,
          language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
        )
      )
    })
    
    # Renderizar tabla de faenas
    output$tabla_faenas <- renderDT({
      datatable(
        datos_faenas(),
        options = list(
          pageLength = 10,
          language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
        )
      )
    })
    
    # Descargar reporte de capturas en Excel
    output$descargar_capturas <- downloadHandler(
      filename = function() {
        paste("reporte_capturas_estadisticas_", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        datos <- datos_capturas()
        openxlsx::write.xlsx(datos, file, rowNames = FALSE)
      }
    )
    
    # Descargar reporte de faenas en Excel
    output$descargar_faenas <- downloadHandler(
      filename = function() {
        paste("reporte_faenas_sitio_", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        datos <- datos_faenas()
        openxlsx::write.xlsx(datos, file, rowNames = FALSE)
      }
    )
  })
}

procesamiento_estimaciones_server <- function(id, conn, fecha_rango, especie, sitio) {
  moduleServer(id, function(input, output, session) {
    # Variable reactiva para controlar si se debe recalcular
    calcular <- reactiveVal(FALSE)
    
    # Actualizar la variable cuando se haga clic en el botón
    observeEvent(input$calcular, {
      calcular(TRUE)
      showNotification("Calculando estimaciones...", type = "message")
    })
    
    # Obtener datos para estimaciones
    datos_estimaciones <- reactive({
      # Verificar si ya existe un reporte con los mismos filtros
      fecha_inicio <- fecha_rango()[1]
      fecha_fin <- fecha_rango()[2]
      especie_id <- if (especie() == "") NULL else especie()
      sitio_id <- if (sitio() == "") NULL else sitio()
      
      query_check <- "
        SELECT fecha, sitio, nombre_sitio, especie,
               num_embarcaciones_activas, num_embarcaciones_muestreadas,
               indv_muestreados, peso_muestreados_kg,
               indv_estimados, peso_estimados_kg
        FROM reporte_estimaciones
        WHERE fecha_inicio = $1 AND fecha_fin = $2
          AND (especie_id IS NULL OR especie_id = $3)
          AND (sitio_id IS NULL OR sitio_id = $4);
      "
      params_check <- list(fecha_inicio, fecha_fin, especie_id, sitio_id)
      
      estimaciones_existentes <- tryCatch({
        dbGetQuery(conn, query_check, params = params_check)
      }, error = function(e) {
        message("Error al verificar reporte de estimaciones: ", e$message)
        data.frame()
      })
      
      if (nrow(estimaciones_existentes) > 0 && !calcular()) {
        return(estimaciones_existentes)
      }
      
      # Si no existe o se solicita recalcular, generar nuevos datos
      query <- "
        SELECT ad.fecha AS Fecha,
               ad.zona_desembarco_id AS Sitio,
               s.nomsit AS Nombre_Sitio,
               e.nombre_comun AS Especie,
               ad.num_embarcaciones_activas,
               ad.num_embarcaciones_muestreadas,
               SUM(dc.indv) AS indv_muestreados,
               SUM(dc.peso) AS peso_muestreados_kg
        FROM actividades_diarias ad
        LEFT JOIN faena_principal fp ON ad.zona_desembarco_id = fp.sitio_desembarque
            AND fp.fecha_zarpe = ad.fecha
        LEFT JOIN detalles_captura dc ON fp.id = dc.faena_id
        LEFT JOIN sitios s ON ad.zona_desembarco_id = s.codsit
        LEFT JOIN especies e ON dc.especie_id = e.codesp
        WHERE ad.fecha BETWEEN $1 AND $2
      "
      params <- list(fecha_inicio, fecha_fin)
      
      param_count <- 2
      if (!is.null(especie_id)) {
        param_count <- param_count + 1
        query <- paste0(query, " AND dc.especie_id = $", param_count)
        params <- append(params, especie_id)
      }
      
      if (!is.null(sitio_id)) {
        param_count <- param_count + 1
        query <- paste0(query, " AND ad.zona_desembarco_id = $", param_count)
        params <- append(params, sitio_id)
      }
      
      query <- paste0(query, "
        GROUP BY ad.fecha, ad.zona_desembarco_id, s.nomsit, e.nombre_comun,
                 ad.num_embarcaciones_activas, ad.num_embarcaciones_muestreadas
        HAVING ad.num_embarcaciones_muestreadas > 0;
      ")
      
      estimaciones <- tryCatch({
        dbGetQuery(conn, query, params = params)
      }, error = function(e) {
        message("Error al calcular estimaciones de capturas: ", e$message)
        data.frame(Fecha = character(), Sitio = character(), Nombre_Sitio = character(),
                   Especie = character(), num_embarcaciones_activas = integer(),
                   num_embarcaciones_muestreadas = integer(),
                   indv_muestreados = integer(), peso_muestreados_kg = numeric(),
                   indv_estimados = numeric(), peso_estimados_kg = numeric())
      })
      
      # Calcular estimaciones y guardar en la tabla
      if (nrow(estimaciones) > 0) {
        estimaciones$indv_promedio <- estimaciones$indv_muestreados / estimaciones$num_embarcaciones_muestreadas
        estimaciones$peso_promedio <- estimaciones$peso_muestreados_kg / estimaciones$num_embarcaciones_muestreadas
        estimaciones$indv_estimados <- round(estimaciones$indv_promedio * estimaciones$num_embarcaciones_activas)
        estimaciones$peso_estimados_kg <- round(estimaciones$peso_promedio * estimaciones$num_embarcaciones_activas)
        
        # Eliminar reportes anteriores con los mismos filtros
        dbExecute(conn, "
          DELETE FROM reporte_estimaciones
          WHERE fecha_inicio = $1 AND fecha_fin = $2
            AND (especie_id IS NULL OR especie_id = $3)
            AND (sitio_id IS NULL OR sitio_id = $4);
        ", params = params_check)
        
        # Insertar nuevos datos
        for (i in 1:nrow(estimaciones)) {
          dbExecute(conn, "
            INSERT INTO reporte_estimaciones (fecha_inicio, fecha_fin, especie_id, sitio_id,
                                             fecha, sitio, nombre_sitio, especie,
                                             num_embarcaciones_activas, num_embarcaciones_muestreadas,
                                             indv_muestreados, peso_muestreados_kg,
                                             indv_estimados, peso_estimados_kg,
                                             creado_por, fecha_creacion)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, CURRENT_TIMESTAMP);
          ", params = list(fecha_inicio, fecha_fin, especie_id, sitio_id,
                           estimaciones$Fecha[i], estimaciones$Sitio[i], estimaciones$Nombre_Sitio[i],
                           estimaciones$Especie[i], estimaciones$num_embarcaciones_activas[i],
                           estimaciones$num_embarcaciones_muestreadas[i],
                           estimaciones$indv_muestreados[i], estimaciones$peso_muestreados_kg[i],
                           estimaciones$indv_estimados[i], estimaciones$peso_estimados_kg[i],
                           "admin"))
        }
        
        # Seleccionar columnas relevantes
        estimaciones <- estimaciones[, c("Fecha", "Nombre_Sitio", "Especie",
                                         "num_embarcaciones_activas", "num_embarcaciones_muestreadas",
                                         "indv_muestreados", "peso_muestreados_kg",
                                         "indv_estimados", "peso_estimados_kg")]
      } else {
        estimaciones <- data.frame(
          Fecha = character(), Nombre_Sitio = character(), Especie = character(),
          num_embarcaciones_activas = integer(), num_embarcaciones_muestreadas = integer(),
          indv_muestreados = integer(), peso_muestreados_kg = numeric(),
          indv_estimados = numeric(), peso_estimados_kg = numeric()
        )
      }
      
      estimaciones
    })
    
    # Renderizar tabla de estimaciones
    output$tabla_estimaciones <- renderDT({
      datatable(
        datos_estimaciones(),
        options = list(
          pageLength = 10,
          language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
        )
      )
    })
    
    # Descargar reporte de estimaciones en Excel
    output$descargar_estimaciones <- downloadHandler(
      filename = function() {
        paste("reporte_estimaciones_capturas_", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        datos <- datos_estimaciones()
        colnames(datos) <- c("Fecha", "Sitio de Desembarque", "Especie",
                             "Embarcaciones Activas", "Embarcaciones Muestreadas",
                             "Individuos Muestreados", "Peso Muestreado (kg)",
                             "Individuos Estimados", "Peso Estimado (kg)")
        openxlsx::write.xlsx(datos, file, rowNames = FALSE)
      }
    )
  })
}