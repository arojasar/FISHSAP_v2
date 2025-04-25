# modules/ingreso_datos/frecuencia_tallas_server.R

frecuencia_tallas_server <- function(id, conn, usuario) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Variables reactivas
    datos_tabla <- reactiveVal(NULL)
    unidad_medida <- reactiveVal("cm")
    codfre_current <- reactiveVal(NULL)
    faena_choices <- reactiveVal(NULL)
    arte_choices <- reactiveVal(NULL)
    sitio_choices <- reactiveVal(NULL)
    registrador_choices <- reactiveVal(NULL)
    datos_temporales <- reactiveVal(NULL)
    mostrar_tabla_registros <- reactiveVal(FALSE)  # Controla la visibilidad de la tabla de registros
    
    # Inicializar datos_temporales como un data.frame vacío
    observe({
      datos_temporales(data.frame(
        especie = character(),
        tipo_medida = character(),
        talla = numeric(),
        frecuencia = integer(),
        peso = numeric(),
        sexo = character(),
        stringsAsFactors = FALSE
      ))
    })
    
    # Variable para controlar la visibilidad de la tabla en la UI
    output$mostrar_tabla_registros <- reactive({
      mostrar_tabla_registros()
    })
    outputOptions(output, "mostrar_tabla_registros", suspendWhenHidden = FALSE)
    
    # Cargar faenas solo del año vigente (2025)
    observe({
      req(conn)
      message("Cargando opciones de faenas del año vigente (2025) en frecuencia_tallas_server...")
      
      choices <- tryCatch({
        query <- "
          SELECT id, registro, EXTRACT(YEAR FROM fecha_zarpe) AS anofre
          FROM faena_principal
          WHERE EXTRACT(YEAR FROM fecha_zarpe) = 2025
          ORDER BY fecha_zarpe DESC"
        message("Ejecutando consulta para faenas: ", query)
        data <- dbGetQuery(conn, query)
        message("Datos obtenidos para faenas: ", paste(capture.output(str(data)), collapse = "\n"))
        if (nrow(data) > 0) {
          result <- setNames(data$id, paste("Faena", data$id, "-", data$registro, "(", data$anofre, ")"))
          message("Contenido de faena_choices: ", paste(capture.output(str(result)), collapse = "\n"))
          result
        } else {
          message("Advertencia: No hay faenas para el año 2025")
          character(0)
        }
      }, error = function(e) {
        message("Error al cargar faenas: ", e$message)
        character(0)
      })
      
      if (is.null(choices)) {
        choices <- character(0)
        message("faena_choices era NULL, asignado como character(0) por seguridad")
      }
      
      faena_choices(choices)
    })
    
    # Cargar opciones para codart, codsit, codreg
    observe({
      # Arte de pesca
      arte <- tryCatch({
        query <- "SELECT codart, nomart FROM arte ORDER BY nomart"
        data <- dbGetQuery(conn, query)
        setNames(data$codart, data$nomart)
      }, error = function(e) {
        message("Error al cargar artes: ", e$message)
        character(0)
      })
      arte_choices(arte)
      
      # Sitios
      sitio <- tryCatch({
        query <- "SELECT codsit, nomsit FROM sitios ORDER BY nomsit"
        data <- dbGetQuery(conn, query)
        setNames(data$codsit, data$nomsit)
      }, error = function(e) {
        message("Error al cargar sitios: ", e$message)
        character(0)
      })
      sitio_choices(sitio)
      
      # Registradores
      registrador <- tryCatch({
        query <- "SELECT codreg, nomreg FROM registrador ORDER BY nomreg"
        data <- dbGetQuery(conn, query)
        setNames(data$codreg, data$nomreg)
      }, error = function(e) {
        message("Error al cargar registradores: ", e$message)
        character(0)
      })
      registrador_choices(registrador)
    })
    
    # Renderizar el input de faena con selectizeInput
    output$faena_input <- renderUI({
      if (input$vinculada_faena == "si") {
        req(faena_choices())
        choices <- faena_choices()
        if (length(choices) > 0) {
          selectizeInput(
            ns("faena"),
            "Faena",
            choices = c("Seleccione una faena" = "", choices),
            options = list(
              placeholder = "Seleccione una faena",
              create = FALSE,
              maxOptions = 50
            )
          )
        } else {
          selectInput(
            ns("faena"),
            "Faena",
            choices = c("No hay faenas disponibles para 2025" = ""),
            selected = ""
          )
        }
      }
    })
    
    # Renderizar los campos de datos de faena condicionalmente
    output$faena_datos_input <- renderUI({
      if (input$vinculada_faena == "no") {
        req(arte_choices(), sitio_choices(), registrador_choices())
        tagList(
          selectInput(
            ns("codart"),
            "Arte de Pesca",
            choices = c("Seleccione un arte" = "", arte_choices())
          ),
          selectInput(
            ns("codsit"),
            "Sitio de Desembarque",
            choices = c("Seleccione un sitio" = "", sitio_choices())
          ),
          selectInput(
            ns("codreg"),
            "Registrador",
            choices = c("Seleccione un registrador" = "", registrador_choices())
          ),
          numericInput(ns("mesfre"), "Mes", value = 1, min = 1, max = 12, step = 1),
          numericInput(ns("anofre"), "Año", value = 2025, min = 2000, max = 2050, step = 1)
        )
      }
    })
    
    # Filtrar especies cuando hay faena vinculada
    observeEvent(list(input$vinculada_faena, input$faena), {
      if (input$vinculada_faena == "si" && input$faena != "" && !is.null(input$faena)) {
        query <- sprintf(
          "SELECT DISTINCT dc.especie_id, e.nombre_comun, e.clase_medida
           FROM detalles_captura dc
           JOIN especies e ON dc.especie_id = e.codesp
           WHERE dc.faena_id = %s
           ORDER BY e.nombre_comun",
          input$faena
        )
        especies <- tryCatch({
          result <- dbGetQuery(conn, query)
          message("Nombres de columnas devueltas para especies filtradas: ", paste(names(result), collapse = ", "))
          message("Datos obtenidos para especies filtradas: ", paste(capture.output(str(result)), collapse = "\n"))
          result
        }, error = function(e) {
          message("Error al cargar especies filtradas: ", e$message)
          data.frame(especie_id = character(0), nombre_comun = character(0), clase_medida = character(0))
        })
        
        if (nrow(especies) > 0) {
          choices <- setNames(especies$especie_id, especies$nombre_comun)
          message("Opciones de especie filtradas actualizadas: ", paste(names(choices), collapse = ", "))
          updateSelectInput(session, "especie", choices = c("Seleccione una especie" = "", choices))
        } else {
          updateSelectInput(session, "especie", choices = c("No hay especies para esta faena" = ""))
          unidad_medida("cm")
        }
      } else {
        # Cargar todas las especies si no hay faena vinculada
        query <- "SELECT codesp AS especie_id, nombre_comun, clase_medida FROM especies ORDER BY nombre_comun"
        especies <- tryCatch({
          result <- dbGetQuery(conn, query)
          result
        }, error = function(e) {
          message("Error al cargar especies: ", e$message)
          data.frame(especie_id = character(0), nombre_comun = character(0), clase_medida = character(0))
        })
        
        if (nrow(especies) > 0) {
          choices <- setNames(especies$especie_id, especies$nombre_comun)
          updateSelectInput(session, "especie", choices = c("Seleccione una especie" = "", choices))
        }
      }
    })
    
    # Autocompletar datos de faena
    observeEvent(input$faena, {
      if (input$vinculada_faena == "si" && input$faena != "" && !is.null(input$faena)) {
        query <- sprintf(
          "SELECT artepesca AS codart, sitio_desembarque AS codsit, registrador AS codreg,
                  EXTRACT(MONTH FROM fecha_zarpe) AS mesfre,
                  EXTRACT(YEAR FROM fecha_zarpe) AS anofre
           FROM faena_principal
           WHERE id = %s",
          input$faena
        )
        datos_faena <- tryCatch({
          dbGetQuery(conn, query)
        }, error = function(e) {
          message("Error al cargar datos de faena: ", e$message)
          data.frame(codart = NA, codsit = NA, codreg = NA, mesfre = NA, anofre = NA)
        })
        
        updateSelectInput(session, "codart", selected = datos_faena$codart %||% "")
        updateSelectInput(session, "codsit", selected = datos_faena$codsit %||% "")
        updateSelectInput(session, "codreg", selected = datos_faena$codreg %||% "")
        updateNumericInput(session, "mesfre", value = datos_faena$mesfre %||% 1)
        updateNumericInput(session, "anofre", value = datos_faena$anofre %||% 2025)
      }
    })
    
    # Variable reactiva para manejar la especie seleccionada y su nombre
    especie_info <- reactiveValues(id = NULL, nombre = NULL, unidad = "cm")
    
    # Actualizar la unidad de medida y nombre de especie cuando cambia la especie
    observeEvent(input$especie, {
      if (input$especie != "" && !is.null(input$especie)) {
        query <- sprintf(
          "SELECT nombre_comun, clase_medida FROM especies WHERE codesp = '%s'",
          input$especie
        )
        result <- tryCatch({
          data <- dbGetQuery(conn, query)
          if (nrow(data) > 0) {
            list(
              nombre = data$nombre_comun[1],
              unidad = data$clase_medida[1] %||% "cm"
            )
          } else {
            list(
              nombre = "Desconocida",
              unidad = "cm"
            )
          }
        }, error = function(e) {
          message("Error al cargar datos de especie: ", e$message)
          showNotification(
            "Error al obtener datos de la especie. Usando valores por defecto.",
            type = "error"
          )
          list(
            nombre = "Desconocida",
            unidad = "cm"
          )
        })
        
        especie_info$id <- input$especie
        especie_info$nombre <- result$nombre
        especie_info$unidad <- result$unidad
        unidad_medida(result$unidad)
      } else {
        especie_info$id <- NULL
        especie_info$nombre <- NULL
        especie_info$unidad <- "cm"
        unidad_medida("cm")
      }
    })
    
    # Renderizar dinámicamente el input de talla
    output$talla_input <- renderUI({
      numericInput(
        ns("talla"),
        paste("Talla (", unidad_medida(), "): *"),
        value = NULL,
        min = 0,
        step = 0.1
      )
    })
    
    # Cargar los datos de la tabla principal (registros guardados)
    observe({
      req(conn)
      query <- "
        SELECT ft.id, fp.registro AS faena, e.nombre_comun AS especie,
               ft.tipo_medida, ft.talla, ft.frecuencia,
               COALESCE(CAST(ft.peso AS TEXT), 'N/A') AS peso,
               COALESCE(ft.sexo, 'N/A') AS sexo,
               ft.codfre_original,
               ft.creado_por, ft.fecha_creacion
        FROM frecuencia_tallas ft
        LEFT JOIN faena_principal fp ON ft.faena_id = fp.id
        JOIN especies e ON ft.especie_id = e.codesp
        ORDER BY ft.id DESC"
      datos <- tryCatch({
        result <- dbGetQuery(conn, query)
        message("Datos cargados para la tabla: ", nrow(result), " filas")
        message("Nombres de columnas devueltas para tabla: ", paste(names(result), collapse = ", "))
        result
      }, error = function(e) {
        message("Error al cargar datos de la tabla: ", e$message)
        data.frame(
          id = integer(),
          faena = character(),
          especie = character(),
          tipo_medida = character(),
          talla = numeric(),
          frecuencia = integer(),
          peso = character(),
          sexo = character(),
          codfre_original = character(),
          creado_por = character(),
          fecha_creacion = character(),
          stringsAsFactors = FALSE
        )
      })
      datos_tabla(datos)
    })
    
    # Renderizar la tabla principal (registros guardados)
    output$tabla <- renderDT({
      datos <- datos_tabla()
      if (is.null(datos) || nrow(datos) == 0) {
        datatable(
          data.frame(Mensaje = "No hay registros para mostrar"),
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
          )
        )
      }
    })
    
    # Renderizar la tabla temporal (datos del registro actual)
    output$tabla_temporal <- renderDT({
      datos <- datos_temporales()
      if (nrow(datos) == 0) {
        datatable(
          data.frame(Mensaje = "No hay datos ingresados para este registro"),
          options = list(
            pageLength = 5,
            language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json")
          )
        )
      } else {
        datatable(
          datos,
          options = list(
            pageLength = 5,
            language = list(url = "//cdn.datatables.net/plug-ins/1.10.25/i18n/Spanish.json"),
            searching = FALSE,
            paging = FALSE
          ),
          colnames = c("Especie", "Tipo de Medida", "Talla", "Frecuencia", "Peso (kg)", "Sexo")
        )
      }
    })
    
    # Limpiar el formulario (preservando datos repetitivos)
    limpiar_formulario <- function(preservar_repetitivos = TRUE) {
      if (!preservar_repetitivos) {
        updateRadioButtons(session, "vinculada_faena", selected = "no")
        updateSelectizeInput(session, "faena", selected = "")
        updateTextInput(session, "codfre_original", value = "")
        updateSelectInput(session, "codart", selected = "")
        updateSelectInput(session, "codsit", selected = "")
        updateSelectInput(session, "codreg", selected = "")
        updateNumericInput(session, "mesfre", value = 1)
        updateNumericInput(session, "anofre", value = 2025)
        codfre_current(NULL)
        # Limpiar datos temporales
        datos_temporales(data.frame(
          especie = character(),
          tipo_medida = character(),
          talla = numeric(),
          frecuencia = integer(),
          peso = numeric(),
          sexo = character(),
          stringsAsFactors = FALSE
        ))
      }
      updateSelectInput(session, "especie", selected = "")
      updateSelectInput(session, "tipo_medida", selected = "")
      updateNumericInput(session, "talla", value = NULL)
      updateNumericInput(session, "frecuencia", value = 1)
      updateNumericInput(session, "peso", value = NULL)
      updateSelectInput(session, "sexo", selected = "No aplica")
      # Ocultar la tabla de registros al limpiar el formulario
      mostrar_tabla_registros(FALSE)
    }
    
    # Mantener codfre_original entre registros
    observeEvent(input$codfre_original, {
      if (!is.null(input$codfre_original) && input$codfre_original != "") {
        codfre_current(input$codfre_original)
      }
    })
    
    # Acción del botón "Iniciar Nuevo Muestreo"
    observeEvent(input$nuevo_muestreo, {
      limpiar_formulario(preservar_repetitivos = FALSE)
    })
    
    # Acción del botón "Agregar Talla"
    observeEvent(input$nuevo, {
      # Validaciones: Solo requerimos los campos si la tabla temporal está vacía
      if (nrow(datos_temporales()) == 0) {
        if (is.null(especie_info$id) || especie_info$id == "") {
          showNotification(
            "Por favor, seleccione una especie antes de agregar la primera talla.",
            type = "error"
          )
          return()
        }
      }
      
      if (input$tipo_medida == "" || is.null(input$talla) || input$talla <= 0 || input$frecuencia < 1) {
        showNotification(
          "Por favor, complete los campos obligatorios (Tipo de Medida, Talla, Frecuencia) y asegúrese de que Talla y Frecuencia sean mayores que 0.",
          type = "error"
        )
        return()
      }
      
      # Usar el nombre de la especie almacenado en especie_info
      nombre_especie <- especie_info$nombre %||% "Desconocida"
      
      # Manejar el peso de manera segura
      peso_val <- NA
      if (!is.null(input$peso)) {
        if (is.numeric(input$peso) && input$peso > 0) {
          peso_val <- input$peso
        }
      }
      
      # Agregar el nuevo registro a datos_temporales
      nuevo_registro <- tryCatch({
        data.frame(
          especie = nombre_especie,
          tipo_medida = input$tipo_medida,
          talla = input$talla,
          frecuencia = input$frecuencia,
          peso = peso_val,
          sexo = input$sexo,
          stringsAsFactors = FALSE
        )
      }, error = function(e) {
        message("Error al crear nuevo registro: ", e$message)
        showNotification(
          "Error al agregar la talla. Por favor, intente de nuevo.",
          type = "error"
        )
        return(NULL)
      })
      
      if (is.null(nuevo_registro)) {
        return()
      }
      
      temp <- datos_temporales()
      temp <- rbind(temp, nuevo_registro)
      datos_temporales(temp)
      
      # Limpiar campos no repetitivos y establecer valores por defecto para facilitar el ingreso
      updateSelectInput(session, "tipo_medida", selected = "")
      updateNumericInput(session, "talla", value = NULL)
      updateNumericInput(session, "frecuencia", value = 1)
      updateNumericInput(session, "peso", value = NULL)
      updateSelectInput(session, "sexo", selected = "No aplica")
    })
    
    # Acción del botón "Guardar"
    observeEvent(input$guardar, {
      # Validaciones
      if (nrow(datos_temporales()) == 0) {
        showNotification(
          "No hay datos ingresados para guardar. Agregue al menos una talla.",
          type = "error"
        )
        return()
      }
      
      if (is.null(especie_info$id) || especie_info$id == "") {
        showNotification(
          "Por favor, seleccione una especie antes de guardar.",
          type = "error"
        )
        return()
      }
      
      if (input$vinculada_faena == "si" && (input$faena == "" || is.null(input$faena))) {
        showNotification(
          "Por favor, seleccione una faena si las tallas están vinculadas.",
          type = "error"
        )
        return()
      }
      
      if (input$vinculada_faena == "no") {
        if (input$mesfre < 1 || input$mesfre > 12) {
          showNotification("El mes debe estar entre 1 y 12.", type = "error")
          return()
        }
        if (input$anofre < 2000 || input$anofre > 2050) {
          showNotification("El año debe estar entre 2000 y 2050.", type = "error")
          return()
        }
      }
      
      # Verificar duplicados para cada registro en datos_temporales
      temp <- datos_temporales()
      faena_id <- if (input$vinculada_faena == "no" || input$faena == "") "NULL" else input$faena
      codfre <- if (is.null(codfre_current()) || codfre_current() == "") "NULL" else sprintf("'%s'", codfre_current())
      
      for (i in 1:nrow(temp)) {
        query_check <- sprintf(
          "SELECT COUNT(*) FROM frecuencia_tallas
           WHERE (faena_id = %s OR (faena_id IS NULL AND %s IS NULL))
             AND especie_id = '%s'
             AND tipo_medida = '%s'
             AND talla = %s
             AND (codfre_original = %s OR (codfre_original IS NULL AND %s IS NULL))",
          faena_id, faena_id, especie_info$id, temp$tipo_medida[i], temp$talla[i], codfre, codfre
        )
        count_result <- tryCatch({
          result <- dbGetQuery(conn, query_check)
          result$count
        }, error = function(e) {
          message("Error al verificar duplicados: ", e$message)
          0
        })
        
        if (count_result > 0) {
          showNotification(
            sprintf("Ya existe un registro con esta combinación: Faena %s, Especie %s, Tipo de Medida %s, Talla %.1f, Código de Frecuencia %s.",
                    faena_id, temp$especie[i], temp$tipo_medida[i], temp$talla[i], codfre_current() %||% "N/A"),
            type = "error"
          )
          return()
        }
      }
      
      usuario_actual <- usuario()
      if (is.null(usuario_actual) || usuario_actual == "") {
        usuario_actual <- "desconocido"
        message("Advertencia: usuario() no está definido, usando 'desconocido' como valor predeterminado.")
      }
      
      # Guardar cada registro en datos_temporales
      success <- TRUE
      for (i in 1:nrow(temp)) {
        peso <- if (is.na(temp$peso[i])) "NULL" else temp$peso[i]
        sexo <- if (temp$sexo[i] == "No aplica") "NULL" else sprintf("'%s'", temp$sexo[i])
        codart <- if (input$vinculada_faena == "no" && input$codart != "") sprintf("'%s'", input$codart) else "NULL"
        codsit <- if (input$vinculada_faena == "no" && input$codsit != "") sprintf("'%s'", input$codsit) else "NULL"
        codreg <- if (input$vinculada_faena == "no" && input$codreg != "") sprintf("'%s'", input$codreg) else "NULL"
        mesfre <- if (input$vinculada_faena == "no") input$mesfre else "NULL"
        anofre <- if (input$vinculada_faena == "no") input$anofre else "NULL"
        
        query_insert <- sprintf(
          "INSERT INTO frecuencia_tallas (faena_id, especie_id, tipo_medida, talla, frecuencia, peso, sexo, codfre_original, codart, codsit, codreg, mesfre, anofre, creado_por)
           VALUES (%s, '%s', '%s', %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, '%s')",
          faena_id, especie_info$id, temp$tipo_medida[i], temp$talla[i], temp$frecuencia[i], peso, sexo, codfre, codart, codsit, codreg, mesfre, anofre, usuario_actual
        )
        
        tryCatch({
          dbExecute(conn, query_insert)
        }, error = function(e) {
          message("Error al guardar el registro: ", e$message)
          showNotification(
            paste("Error al guardar el registro:", e$message),
            type = "error"
          )
          success <- FALSE
        })
      }
      
      if (success) {
        showNotification("Registros guardados correctamente.", type = "message")
        
        # Refrescar la tabla principal
        query_refresh <- "
          SELECT ft.id, fp.registro AS faena, e.nombre_comun AS especie,
                 ft.tipo_medida, ft.talla, ft.frecuencia,
                 COALESCE(CAST(ft.peso AS TEXT), 'N/A') AS peso,
                 COALESCE(ft.sexo, 'N/A') AS sexo,
                 ft.codfre_original,
                 ft.creado_por, ft.fecha_creacion
          FROM frecuencia_tallas ft
          LEFT JOIN faena_principal fp ON ft.faena_id = fp.id
          JOIN especies e ON ft.especie_id = e.codesp
          ORDER BY ft.id DESC"
        datos <- dbGetQuery(conn, query_refresh)
        message("Datos refrescados para la tabla: ", nrow(datos), " filas")
        datos_tabla(datos)
        
        # Limpiar datos temporales y formulario completamente
        limpiar_formulario(preservar_repetitivos = FALSE)
      }
    })
    
    # Acción del botón "Modificar"
    observeEvent(input$modificar, {
      mostrar_tabla_registros(TRUE)
      
      selected_row <- input$tabla_rows_selected
      if (length(selected_row) == 0) {
        showNotification("Por favor, seleccione un registro para modificar.", type = "warning")
        return()
      }
      
      datos <- datos_tabla()
      row <- datos[selected_row, ]
      
      updateRadioButtons(session, "vinculada_faena", selected = if (is.na(row$faena)) "no" else "si")
      updateSelectizeInput(session, "faena", selected = row$faena %||% "")
      updateTextInput(session, "codfre_original", value = row$codfre_original %||% "")
      updateSelectInput(session, "especie", selected = row$especie)
      updateSelectInput(session, "tipo_medida", selected = row$tipo_medida)
      updateNumericInput(session, "talla", value = as.numeric(row$talla))
      updateNumericInput(session, "frecuencia", value = as.integer(row$frecuencia))
      updateNumericInput(session, "peso", value = if (row$peso == "N/A") NULL else as.numeric(row$peso))
      updateSelectInput(session, "sexo", selected = if (row$sexo == "N/A") "No aplica" else row$sexo)
      
      observeEvent(input$guardar, {
        if (is.null(especie_info$id) || especie_info$id == "" || input$tipo_medida == "" ||
            is.null(input$talla) || input$talla <= 0 || input$frecuencia < 1) {
          showNotification(
            "Por favor, complete los campos obligatorios (Especie, Tipo de Medida, Talla, Frecuencia) y asegúrese de que Talla y Frecuencia sean mayores que 0.",
            type = "error"
          )
          return()
        }
        
        if (input$vinculada_faena == "si" && (input$faena == "" || is.null(input$faena))) {
          showNotification(
            "Por favor, seleccione una faena si las tallas están vinculadas.",
            type = "error"
          )
          return()
        }
        
        if (input$vinculada_faena == "no") {
          if (input$mesfre < 1 || input$mesfre > 12) {
            showNotification("El mes debe estar entre 1 y 12.", type = "error")
            return()
          }
          if (input$anofre < 2000 || input$anofre > 2050) {
            showNotification("El año debe estar entre 2000 y 2050.", type = "error")
            return()
          }
        }
        
        usuario_actual <- usuario()
        if (is.null(usuario_actual) || usuario_actual == "") {
          usuario_actual <- "desconocido"
          message("Advertencia: usuario() no está definido, usando 'desconocido' como valor predeterminado.")
        }
        
        peso <- if (is.null(input$peso) || !is.numeric(input$peso) || input$peso <= 0) "NULL" else input$peso
        sexo <- if (input$sexo == "No aplica") "NULL" else sprintf("'%s'", input$sexo)
        faena_id <- if (input$vinculada_faena == "no" || input$faena == "") "NULL" else input$faena
        codfre <- if (is.null(codfre_current()) || codfre_current() == "") "NULL" else sprintf("'%s'", codfre_current())
        codart <- if (input$vinculada_faena == "no" && input$codart != "") sprintf("'%s'", input$codart) else "NULL"
        codsit <- if (input$vinculada_faena == "no" && input$codsit != "") sprintf("'%s'", input$codsit) else "NULL"
        codreg <- if (input$vinculada_faena == "no" && input$codreg != "") sprintf("'%s'", input$codreg) else "NULL"
        mesfre <- if (input$vinculada_faena == "no") input$mesfre else "NULL"
        anofre <- if (input$vinculada_faena == "no") input$anofre else "NULL"
        
        query_update <- sprintf(
          "UPDATE frecuencia_tallas
           SET faena_id = %s, especie_id = '%s', tipo_medida = '%s', talla = %s,
               frecuencia = %s, peso = %s, sexo = %s,
               codfre_original = %s, codart = %s, codsit = %s, codreg = %s, mesfre = %s, anofre = %s,
               modificado_por = '%s', fecha_modificacion = CURRENT_TIMESTAMP
           WHERE id = %s",
          faena_id, especie_info$id, input$tipo_medida, input$talla, input$frecuencia, peso, sexo,
          codfre, codart, codsit, codreg, mesfre, anofre, usuario_actual, row$id
        )
        
        tryCatch({
          dbExecute(conn, query_update)
          showNotification("Registro actualizado correctamente.", type = "message")
          
          query_refresh <- "
            SELECT ft.id, fp.registro AS faena, e.nombre_comun AS especie,
                   ft.tipo_medida, ft.talla, ft.frecuencia,
                   COALESCE(CAST(ft.peso AS TEXT), 'N/A') AS peso,
                   COALESCE(ft.sexo, 'N/A') AS sexo,
                   ft.codfre_original,
                   ft.creado_por, ft.fecha_creacion
            FROM frecuencia_tallas ft
            LEFT JOIN faena_principal fp ON ft.faena_id = fp.id
            JOIN especies e ON ft.especie_id = e.codesp
            ORDER BY ft.id DESC"
          datos <- dbGetQuery(conn, query_refresh)
          message("Datos refrescados para la tabla: ", nrow(datos), " filas")
          datos_tabla(datos)
          
          limpiar_formulario(preservar_repetitivos = FALSE)
        }, error = function(e) {
          message("Error al actualizar el registro: ", e$message)
          showNotification(
            paste("Error al actualizar el registro:", e$message),
            type = "error"
          )
        })
      }, once = TRUE)
    })
    
    # Acción del botón "Ocultar Registros"
    observeEvent(input$ocultar_registros, {
      mostrar_tabla_registros(FALSE)
    })
    
    # Acción del botón "Borrar"
    observeEvent(input$borrar, {
      if (!mostrar_tabla_registros()) {
        showNotification("Por favor, haga clic en 'Modificar' para ver y seleccionar registros para borrar.", type = "warning")
        return()
      }
      
      selected_row <- input$tabla_rows_selected
      if (length(selected_row) == 0) {
        showNotification("Por favor, seleccione un registro para borrar.", type = "warning")
        return()
      }
      
      showModal(modalDialog(
        title = "Confirmar eliminación",
        "¿Está seguro de que desea eliminar este registro?",
        footer = tagList(
          modalButton("Cancelar"),
          actionButton(ns("confirmar_borrar"), "Eliminar", class = "btn-danger")
        )
      ))
    })
    
    # Confirmar la eliminación
    observeEvent(input$confirmar_borrar, {
      selected_row <- input$tabla_rows_selected
      datos <- datos_tabla()
      row <- datos[selected_row, ]
      
      query_delete <- sprintf("DELETE FROM frecuencia_tallas WHERE id = %s", row$id)
      
      tryCatch({
        dbExecute(conn, query_delete)
        showNotification("Registro eliminado correctamente.", type = "message")
        
        query_refresh <- "
          SELECT ft.id, fp.registro AS faena, e.nombre_comun AS especie,
                 ft.tipo_medida, ft.talla, ft.frecuencia,
                 COALESCE(CAST(ft.peso AS TEXT), 'N/A') AS peso,
                 COALESCE(ft.sexo, 'N/A') AS sexo,
                 ft.codfre_original,
                 ft.creado_por, ft.fecha_creacion
          FROM frecuencia_tallas ft
          LEFT JOIN faena_principal fp ON ft.faena_id = fp.id
          JOIN especies e ON ft.especie_id = e.codesp
          ORDER BY ft.id DESC"
        datos <- dbGetQuery(conn, query_refresh)
        message("Datos refrescados para la tabla: ", nrow(datos), " filas")
        datos_tabla(datos)
        
        removeModal()
        # Ocultar la tabla después de eliminar
        mostrar_tabla_registros(FALSE)
      }, error = function(e) {
        message("Error al eliminar el registro: ", e$message)
        showNotification(
          paste("Error al eliminar el registro:", e$message),
          type = "error"
        )
      })
    })
    
    # Acción del botón "Exportar"
    output$exportar <- downloadHandler(
      filename = function() {
        paste("frecuencia_tallas_", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        write.csv(datos_tabla(), file, row.names = FALSE, na = "N/A")
      }
    )
  })
}