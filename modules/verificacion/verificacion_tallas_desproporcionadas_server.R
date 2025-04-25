# modules/verificacion/verificacion_tallas_desproporcionadas_server.R

verificacion_tallas_desproporcionadas_server <- function(id, conn) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Variables reactivas para opciones de filtros
    faena_choices <- reactiveVal(NULL)
    especie_choices <- reactiveVal(NULL)
    
    # Cargar opciones de faenas (solo del año vigente para optimizar)
    observe({
      req(conn)
      message("Cargando opciones de faenas en verificacion_tallas_desproporcionadas_server...")
      
      choices <- tryCatch({
        query <- "
          SELECT id, registro, EXTRACT(YEAR FROM fecha_zarpe) AS anofre
          FROM faena_principal
          WHERE EXTRACT(YEAR FROM fecha_zarpe) = 2025
          ORDER BY fecha_zarpe DESC"
        data <- dbGetQuery(conn, query)
        if (nrow(data) > 0) {
          setNames(data$id, paste("Faena", data$id, "-", data$registro, "(", data$anofre, ")"))
        } else {
          message("Advertencia: No hay faenas para el año 2025")
          character(0)
        }
      }, error = function(e) {
        message("Error al cargar faenas: ", e$message)
        character(0)
      })
      
      faena_choices(choices)
      updateSelectizeInput(
        session,
        "faena",
        choices = c("Todas las faenas" = "", choices),
        selected = ""
      )
    })
    
    # Cargar opciones de especies
    observe({
      req(conn)
      message("Cargando opciones de especies en verificacion_tallas_desproporcionadas_server...")
      
      choices <- tryCatch({
        query <- "SELECT codesp, nombre_comun FROM especies ORDER BY nombre_comun"
        data <- dbGetQuery(conn, query)
        setNames(data$codesp, data$nombre_comun)
      }, error = function(e) {
        message("Error al cargar especies: ", e$message)
        character(0)
      })
      
      especie_choices(choices)
      updateSelectInput(
        session,
        "especie",
        choices = c("Todas las especies" = "", choices),
        selected = ""
      )
    })
    
    # Obtener datos de tallas desproporcionadas
    datos_verificacion <- reactiveVal(NULL)
    
    observeEvent(input$buscar, {
      req(conn)
      
      # Construir la consulta base para obtener todas las tallas
      query_base <- "
        SELECT fp.id AS faena_id, fp.registro AS faena, ft.especie_id, e.nombre_comun AS especie,
               ft.tipo_medida, ft.talla, ft.frecuencia,
               ft.fecha_creacion
        FROM faena_principal fp
        JOIN frecuencia_tallas ft ON fp.id = ft.faena_id
        JOIN especies e ON ft.especie_id = e.codesp
        WHERE 1=1"
      
      # Agregar filtros dinámicos
      conditions <- list()
      params <- list()
      
      # Filtro por faena
      if (!is.null(input$faena) && input$faena != "") {
        conditions <- c(conditions, "fp.id = $%d")
        params <- c(params, input$faena)
      }
      
      # Filtro por especie
      if (!is.null(input$especie) && input$especie != "") {
        conditions <- c(conditions, "ft.especie_id = $%d")
        params <- c(params, input$especie)
      }
      
      # Filtro por rango de fechas
      if (!is.null(input$fecha_rango)) {
        conditions <- c(conditions, "fp.fecha_zarpe BETWEEN $%d AND $%d")
        params <- c(params, as.character(input$fecha_rango[1]), as.character(input$fecha_rango[2]))
      }
      
      # Combinar condiciones
      if (length(conditions) > 0) {
        query_base <- paste(query_base, "AND", paste(conditions, collapse = " AND "))
      }
      
      # Reemplazar parámetros en la consulta
      query <- query_base
      for (i in seq_along(params)) {
        query <- sub(sprintf("\\$%d", i), params[[i]], query)
      }
      
      # Obtener los datos
      datos <- tryCatch({
        message("Ejecutando consulta para tallas: ", query)
        result <- dbGetQuery(conn, query)
        message("Datos obtenidos: ", nrow(result), " filas")
        result
      }, error = function(e) {
        message("Error al obtener datos de tallas: ", e$message)
        data.frame(
          faena_id = integer(), faena = character(), especie_id = character(),
          especie = character(), tipo_medida = character(), talla = numeric(),
          frecuencia = integer(), fecha_creacion = character()
        )
      })
      
      # Si no hay datos, retornar un data.frame vacío
      if (nrow(datos) == 0) {
        datos <- data.frame(
          faena_id = integer(), faena = character(), especie_id = character(),
          especie = character(), tipo_medida = character(), talla = numeric(),
          frecuencia = integer(), fecha_creacion = character(), observacion = character()
        )
        datos_verificacion(datos)
        return()
      }
      
      # Calcular rangos esperados por especie y tipo de medida
      rangos <- tryCatch({
        # Agrupar por especie y tipo de medida para calcular estadísticas
        stats <- aggregate(
          talla ~ especie_id + tipo_medida,
          data = datos,
          FUN = function(x) c(mean = mean(x), sd = sd(x))
        )
        
        # Extraer media y desviación estándar
        stats <- do.call(data.frame, stats)
        colnames(stats) <- c("especie_id", "tipo_medida", "mean_talla", "sd_talla")
        
        # Definir rangos (media ± 3 desviaciones estándar)
        stats$rango_min <- stats$mean_talla - 3 * stats$sd_talla
        stats$rango_max <- stats$mean_talla + 3 * stats$sd_talla
        
        # Asegurar que los rangos no sean negativos
        stats$rango_min <- pmax(stats$rango_min, 0)
        stats
      }, error = function(e) {
        message("Error al calcular rangos: ", e$message)
        data.frame(
          especie_id = character(), tipo_medida = character(),
          mean_talla = numeric(), sd_talla = numeric(),
          rango_min = numeric(), rango_max = numeric()
        )
      })
      
      # Identificar tallas desproporcionadas
      datos <- merge(datos, rangos, by = c("especie_id", "tipo_medida"), all.x = TRUE)
      datos$observacion <- ifelse(
        is.na(datos$rango_min) | is.na(datos$rango_max) |
          datos$talla < datos$rango_min | datos$talla > datos$rango_max,
        sprintf("Talla fuera de rango esperado: %.1f cm (rango: %.1f - %.1f cm)", 
                datos$talla, datos$rango_min, datos$rango_max),
        ""
      )
      
      # Filtrar solo las tallas desproporcionadas
      datos <- datos[datos$observacion != "", ]
      
      # Seleccionar columnas relevantes
      datos <- datos[, c("faena_id", "faena", "especie_id", "especie", "tipo_medida",
                         "talla", "frecuencia", "fecha_creacion", "observacion")]
      
      # Si no hay tallas desproporcionadas, retornar un data.frame vacío
      if (nrow(datos) == 0) {
        datos <- data.frame(
          faena_id = integer(), faena = character(), especie_id = character(),
          especie = character(), tipo_medida = character(), talla = numeric(),
          frecuencia = integer(), fecha_creacion = character(), observacion = character()
        )
      }
      
      datos_verificacion(datos)
    })
    
    # Renderizar tabla
    output$tabla <- renderDT({
      datos <- datos_verificacion()
      if (is.null(datos) || nrow(datos) == 0) {
        datatable(
          data.frame(Mensaje = "No se encontraron tallas desproporcionadas"),
          options = list(
            pageLength = 10,
            language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
          )
        )
      } else {
        datatable(
          datos[, c("faena", "especie", "tipo_medida", "talla", "frecuencia", "fecha_creacion", "observacion")],
          options = list(
            pageLength = 10,
            language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
          ),
          colnames = c("Registro Faena", "Especie", "Tipo de Medida", "Talla (cm)", 
                       "Frecuencia", "Fecha Creación", "Observación")
        )
      }
    })
    
    # Descargar reporte en CSV
    output$exportar <- downloadHandler(
      filename = function() {
        paste("reporte_tallas_desproporcionadas_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        datos <- datos_verificacion()
        if (nrow(datos) > 0) {
          datos_exportar <- datos[, c("faena", "especie", "tipo_medida", "talla", 
                                      "frecuencia", "fecha_creacion", "observacion")]
          colnames(datos_exportar) <- c("Registro Faena", "Especie", "Tipo de Medida", 
                                        "Talla (cm)", "Frecuencia", "Fecha Creación", 
                                        "Observación")
          write.csv(datos_exportar, file, row.names = FALSE, na = "")
        } else {
          write.csv(data.frame(Mensaje = "No se encontraron tallas desproporcionadas"), 
                    file, row.names = FALSE)
        }
      }
    )
  })
}