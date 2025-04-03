captura_esfuerzo_server <- function(id, pool) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Valores reactivos para las tablas
    faenas_data <- reactiveVal()
    captura_data <- reactiveVal(data.frame(
      Nombre_Cientifico = character(),
      Nombre_Comun = character(),
      Estado = character(),
      Indv = numeric(),
      Peso = numeric(),
      stringsAsFactors = FALSE
    ))
    costos_data <- reactiveVal(data.frame(
      Descripcion = character(),
      Valor = numeric(),
      stringsAsFactors = FALSE
    ))
    
    # Valores reactivos para los campos no editables
    motores_value <- reactiveVal(0)
    propulsion_value <- reactiveVal("")
    potencia_value <- reactiveVal(0)
    
    # Bloque 1: Actualizar listas desplegables
    observe({
      updateSelectInput(session, "sitio_desembarque", choices = c("Seleccione" = "", captura_esfuerzo_choices$sitio_desembarque))
      updateSelectInput(session, "subarea", choices = c("Seleccione" = "", captura_esfuerzo_choices$subarea))
      updateSelectInput(session, "registrador", choices = c("Seleccione" = "", captura_esfuerzo_choices$registrador))
      updateSelectInput(session, "pescadores", choices = c("Seleccione" = "", captura_esfuerzo_choices$pescadores))
      updateSelectInput(session, "embarcacion", choices = c("Seleccione" = "", captura_esfuerzo_choices$embarcacion))
      updateSelectInput(session, "arte_pesca", choices = c("Seleccione" = "", captura_esfuerzo_choices$arte_pesca))
      updateSelectInput(session, "metodo_pesca", choices = c("Seleccione" = "", captura_esfuerzo_choices$metodo_pesca))
      
      # Construir etiquetas combinadas: "nombre_cientifico (nombre_comun)"
      conn <- poolCheckout(pool)
      on.exit(poolReturn(conn))
      
      # Obtener datos de especies
      especies_data <- dbGetQuery(conn, "SELECT codesp, nombre_cientifico, nombre_comun FROM especies")
      cat("Filas en especies_data:", nrow(especies_data), "\n")
      cat("Columnas en especies_data:", names(especies_data), "\n")
      cat("Contenido de especies_data:", toString(especies_data), "\n")
      
      especie_labels <- paste0(especies_data$nombre_cientifico, " (", especies_data$nombre_comun, ")")
      especie_choices <- setNames(especies_data$codesp, especie_labels)
      updateSelectInput(session, "especie", choices = c("Seleccione" = "", especie_choices))
      
      # Obtener datos de estados directamente de la base de datos
      estados_data <- dbGetQuery(conn, "SELECT codest, nomest FROM estados")
      cat("Filas en estados_data:", nrow(estados_data), "\n")
      cat("Columnas en estados_data:", names(estados_data), "\n")
      cat("Contenido de estados_data:", toString(estados_data), "\n")
      
      if (nrow(estados_data) == 0) {
        cat("Advertencia: No se encontraron datos en la tabla estados.\n")
        estado_choices <- character(0)  # Vector vacío para evitar errores
      } else {
        estado_choices <- setNames(estados_data$codest, estados_data$nomest)
      }
      updateSelectInput(session, "estado", choices = c("Seleccione" = "", estado_choices))
      
      updateSelectInput(session, "gasto", choices = c("Seleccione" = "", captura_esfuerzo_choices$gasto))
      updateSelectInput(session, "horario", choices = captura_esfuerzo_choices$horario, selected = "Diurno")
    })
    
    # Bloque: Cargar datos de la embarcación seleccionada
    observeEvent(input$embarcacion, {
      if (!is.null(input$embarcacion) && input$embarcacion != "") {
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        
        tryCatch({
          cat("Seleccionada embarcación:", input$embarcacion, "\n")
          query <- sprintf("SELECT numero_motores, propulsion, potencia FROM embarcaciones WHERE codemb = '%s'", input$embarcacion)
          data <- dbGetQuery(conn, query)
          
          cat("Datos obtenidos de embarcaciones:", toString(data), "\n")
          
          if (nrow(data) > 0) {
            motores_value(ifelse(is.na(data$numero_motores), 0, data$numero_motores))
            propulsion_value(ifelse(is.na(data$propulsion), "", data$propulsion))
            potencia_value(ifelse(is.na(data$potencia), 0, data$potencia))
          } else {
            cat("No se encontraron datos para codemb =", input$embarcacion, "\n")
            motores_value(0)
            propulsion_value("")
            potencia_value(0)
          }
        }, error = function(e) {
          showNotification(paste("Error al cargar datos de la embarcación:", e$message), type = "error")
          cat("Error al cargar datos de la embarcación:", e$message, "\n")
        })
      }
    })
    
    # Renderizar los valores como texto
    output$motores_text <- renderText({
      as.character(motores_value())
    })
    
    output$propulsion_text <- renderText({
      propulsion_value()
    })
    
    output$potencia_text <- renderText({
      as.character(potencia_value())
    })
    
    # Bloque 2: Cargar datos iniciales
    observe({
      conn <- poolCheckout(pool)
      on.exit(poolReturn(conn))
      
      tryCatch({
        data <- dbGetQuery(conn, "SELECT id, registro, fecha_zarpe, fecha_arribo, sitio_desembarque FROM faena_principal ORDER BY fecha_creacion DESC")
        faenas_data(data)
      }, error = function(e) {
        showNotification("Error al cargar las faenas: " + e$message, type = "error")
      })
    })
    
    # Bloque 3: Renderizar tabla de faenas
    output$faenas_table <- renderDT({
      datatable(
        faenas_data(),
        selection = "single",
        options = list(
          pageLength = 5,
          lengthMenu = c(5, 10, 15, 20),
          language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
        )
      )
    })
    
    # Bloque 6: Renderizar tablas de capturas y costos
    output$captura_table <- renderDT({
      datatable(
        captura_data(),
        selection = "single",
        options = list(
          pageLength = 5,
          lengthMenu = c(5, 10, 15, 20),
          language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
        )
      )
    })
    
    output$costos_table <- renderDT({
      datatable(
        costos_data(),
        selection = "single",
        options = list(
          pageLength = 5,
          lengthMenu = c(5, 10, 15, 20),
          language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
        )
      )
    })
    
    # Bloque 7: Añadir captura y costo
    observeEvent(input$add_captura, {
      if (is.null(input$especie) || input$especie == "" ||
          is.null(input$estado) || input$estado == "") {
        showNotification("Por favor, seleccione una especie y un estado.", type = "error")
        return()
      }
      
      conn <- poolCheckout(pool)
      on.exit(poolReturn(conn))
      
      tryCatch({
        cat("Valor de input$especie:", input$especie, "\n")
        cat("Valor de input$estado:", input$estado, "\n")
        
        # Buscar la especie por CODESP
        query_especie <- sprintf("SELECT nombre_cientifico, nombre_comun FROM especies WHERE UPPER(codesp) = UPPER('%s')", input$especie)
        cat("Consulta SQL para especie:", query_especie, "\n")
        especie_data <- dbGetQuery(conn, query_especie)
        cat("Resultado de especie_data:", toString(especie_data), "\n")
        cat("Filas en especie_data:", nrow(especie_data), "\n")
        cat("Columnas en especie_data:", names(especie_data), "\n")
        
        if (nrow(especie_data) == 0) {
          showNotification("Especie no encontrada.", type = "error")
          return()
        }
        
        # Buscar el estado por CODEST
        query_estado <- sprintf("SELECT codest FROM estados WHERE UPPER(codest) = UPPER('%s')", input$estado)
        cat("Consulta SQL para estado:", query_estado, "\n")
        estado_data <- dbGetQuery(conn, query_estado)
        cat("Resultado de estado_data:", toString(estado_data), "\n")
        cat("Filas en estado_data:", nrow(estado_data), "\n")
        cat("Columnas en estado_data:", names(estado_data), "\n")
        
        if (nrow(estado_data) == 0) {
          showNotification("Estado no encontrado.", type = "error")
          return()
        }
        
        estado_codest <- estado_data$codest
        cat("Valor de estado_codest:", estado_codest, "\n")
        
        # Depurar los valores antes de crear el data.frame
        cat("Nombre_Cientifico:", especie_data$nombre_cientifico, "\n")
        cat("Nombre_Comun:", especie_data$nombre_comun, "\n")
        cat("Estado:", estado_codest, "\n")
        cat("Indv:", input$indv, "\n")
        cat("Peso:", input$peso, "\n")
        
        new_captura <- data.frame(
          Nombre_Cientifico = especie_data$nombre_cientifico,
          Nombre_Comun = especie_data$nombre_comun,
          Estado = estado_codest,
          Indv = input$indv,
          Peso = input$peso,
          stringsAsFactors = FALSE
        )
        
        current_capturas <- captura_data()
        captura_data(rbind(current_capturas, new_captura))
        
        updateSelectInput(session, "especie", selected = "")
        updateSelectInput(session, "estado", selected = "")
        updateNumericInput(session, "indv", value = 0)
        updateNumericInput(session, "peso", value = 0)
      }, error = function(e) {
        showNotification(paste("Error al añadir captura:", e$message), type = "error")
        cat("Error al añadir captura:", e$message, "\n")
      })
    })
    
    observeEvent(input$add_gasto, {
      if (is.null(input$gasto) || input$gasto == "") {
        showNotification("Por favor, seleccione un gasto.", type = "error")
        return()
      }
      
      new_costo <- data.frame(
        Descripcion = input$gasto,
        Valor = input$valor_gasto,
        stringsAsFactors = FALSE
      )
      
      current_costos <- costos_data()
      costos_data(rbind(current_costos, new_costo))
      
      updateSelectInput(session, "gasto", selected = "")
      updateNumericInput(session, "valor_gasto", value = 0)
    })
    
    # Bloque 8: Lógica para "Guardar"
    observeEvent(input$guardar, {
      conn <- poolCheckout(pool)
      on.exit(poolReturn(conn))
      
      # Validar campos obligatorios
      if (is.null(input$fecha_zarpe) || is.null(input$fecha_arribo) ||
          is.null(input$sitio_desembarque) || input$sitio_desembarque == "" ||
          is.null(input$subarea) || input$subarea == "" ||
          is.null(input$registrador) || input$registrador == "" ||
          is.null(input$embarcacion) || input$embarcacion == "" ||
          length(input$pescadores) == 0 ||
          is.null(input$hora_salida) || is.null(input$hora_arribo) ||
          is.null(input$horario) || input$horario == "" ||
          is.null(input$arte_pesca) || input$arte_pesca == "" ||
          length(input$metodo_pesca) == 0) {
        showNotification("Por favor, complete todos los campos obligatorios.", type = "error")
        return()
      }
      
      # Obtener los datos del formulario
      registro <- if (is.null(input$registro) || input$registro == "") NA else input$registro
      fecha_zarpe <- as.character(input$fecha_zarpe)
      fecha_arribo <- as.character(input$fecha_arribo)
      sitio_desembarque <- input$sitio_desembarque
      subarea <- input$subarea
      registrador <- input$registrador
      pescadores_count <- length(input$pescadores)
      embarcacion <- input$embarcacion
      galones <- input$galones
      hora_salida <- format(input$hora_salida, "%H:%M:%S")
      hora_arribo <- format(input$hora_arribo, "%H:%M:%S")
      horario <- input$horario
      arte_pesca <- if (is.null(input$arte_pesca) || input$arte_pesca == "") NA else input$arte_pesca
      metodo_pesca <- if (length(input$metodo_pesca) > 0) paste(input$metodo_pesca, collapse = ",") else NA
      observaciones <- if (is.null(input$observaciones) || input$observaciones == "") NA else input$observaciones
      motores <- motores_value()
      propulsion <- propulsion_value()
      potencia <- potencia_value()
      
      tryCatch({
        dbExecute(conn, "BEGIN")
        
        # Manejar NA en galones y potencia
        galones <- if (is.na(galones)) "NULL" else sprintf("%f", galones)
        potencia <- if (is.na(potencia)) "NULL" else sprintf("%f", potencia)
        
        # Insertar en faena_principal (sin observaciones)
        query_faena <- sprintf(
          "INSERT INTO faena_principal (
        registro, fecha_zarpe, fecha_arribo, sitio_desembarque, subarea, registrador, 
        embarcacion, pescadores, hora_salida, hora_arribo, horario, galones, 
        artepesca, metodopesca, motores, propulsion, potencia, 
        creado_por, fecha_creacion, sincronizado
      ) VALUES (%s, '%s', '%s', '%s', '%s', '%s', '%s', %d, '%s', '%s', '%s', %s, %s, %s, %d, %s, %s, 'admin', CURRENT_TIMESTAMP, 0) RETURNING id",
          if (is.na(registro)) "NULL" else sprintf("'%s'", registro),
          fecha_zarpe,
          fecha_arribo,
          sitio_desembarque,
          subarea,
          registrador,
          embarcacion,
          pescadores_count,
          hora_salida,
          hora_arribo,
          horario,
          galones,  # Ahora es "NULL" si es NA
          if (is.na(arte_pesca)) "NULL" else sprintf("'%s'", arte_pesca),
          if (is.na(metodo_pesca)) "NULL" else sprintf("'%s'", metodo_pesca),
          motores,
          if (is.na(propulsion)) "NULL" else sprintf("'%s'", propulsion),
          potencia  # Ahora es "NULL" si es NA
        )
        faena_id <- dbGetQuery(conn, query_faena)$id
        
        # Insertar la observación en la tabla observaciones (si existe)
        if (!is.na(observaciones)) {
          query_observaciones <- sprintf(
            "INSERT INTO observaciones (
          faena_id, observacion, creado_por, fecha_creacion, sincronizado
        ) VALUES (%d, '%s', 'admin', CURRENT_TIMESTAMP, 0)",
            faena_id,
            observaciones
          )
          dbExecute(conn, query_observaciones)
        }
        
        # Insertar capturas y costos
        insert_capturas(conn, faena_id, captura_data())
        insert_costos(conn, faena_id, costos_data())
        
        dbExecute(conn, "COMMIT")
        showNotification("Datos guardados exitosamente.", type = "message")
        
        update_faenas_table(conn, faenas_data)
        clear_form(session, ns)
        clear_temp_tables(captura_data, costos_data)
      }, error = function(e) {
        dbExecute(conn, "ROLLBACK")
        showNotification(paste("Error al guardar los datos:", e$message), type = "error")
        message("Error al guardar los datos: ", e$message)
      })
    })
    
    observe({
      cat("Módulo Captura y Esfuerzo cargado.\n")
      showNotification("Módulo cargado correctamente.", type = "message")
    })
  })
}