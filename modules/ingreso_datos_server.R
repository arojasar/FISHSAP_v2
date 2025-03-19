# modules/ref_tables_server.R

ref_tables_server <- function(id, central_conn) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    message("Entrando en ref_tables_server (genérico) para ID:", id)
    
    # --- Función para obtener los datos de la tabla ---
    get_table_data <- function(conn, table_name) {
      message("get_table_data: Intentando obtener datos para: ", table_name)
      query <- paste0("SELECT * FROM ", table_name)
      result <- tryCatch({
        dbGetQuery(conn, query)
      }, error = function(e) {
        message("ERROR en get_table_data: ", e$message)
        return(NULL)
      })
      message("get_table_data: Filas devueltas: ", if (is.null(result)) 0 else nrow(result))
      return(result)
    }
    
    # --- Función para obtener la definición de los campos ---
    get_table_fields <- function(table_name) {
      #Todo el código que ya tenías, no lo cambio.
      if (table_name == "sitios") {
        return(list(
          list(id = "site_code", label = "Código", type = "text", required = TRUE),
          list(id = "site_name", label = "Nombre", type = "text", required = TRUE)
        ))
      } else if (table_name == "especies") {
        return(list(
          list(id = "species_code", label = "Código", type = "text", required = TRUE),
          list(id = "common_name", label = "Nombre Común", type = "text", required = TRUE),
          list(id = "scientific_name", label = "Nombre Científico", type = "text", required = FALSE),
          list(id = "constant_a", label = "Constante A", type = "number", required = FALSE),
          list(id = "constant_b", label = "Constante B", type = "number", required = FALSE)
        ))
      } else if(table_name == "estados"){
        return(list(
          list(id = "cat_code", label = "Código de categoría", type = "text", required = "true"),
          list(id = "cat_name", label = "Nombre de categoría", type = "text", required = "true")
        ))
      } else if (table_name == "clasifica") {
        return(list(
          list(id = "clas_code", label = "Código de Clasificación", type = "text", required = "true"),
          list(id = "clas_name", label = "Nombre de Clasificación", type = "text", required = "true")
        ))
      } else if (table_name == "subgrupo") {
        return(list(
          list(id = "subgrupo_code", label = "Código de Subgrupo", type = "text", required = "true"),
          list(id = "subgrupo_name", label = "Nombre de Subgrupo", type = "text", required = "true")
        ))
      } else if (table_name == "grupos") {
        return(list(
          list(id = "grupo_code", label = "Código", type = "text", required = "true"),
          list(id = "grupo_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "artes_pesca") {
        return(list(
          list(id = "arte_code", label = "Código", type = "text", required = "true"),
          list(id = "arte_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "metodo_tecnica_pesca") {
        return(list(
          list(id = "metodo_code", label = "Código", type = "text", required = "true"),
          list(id = "metodo_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "metodos_propulsion") {
        return(list(
          list(id = "propulsion_code", label = "Código", type = "text", required = "true"),
          list(id = "propulsion_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "area_pesca") {
        return(list(
          list(id = "area_code", label = "Código", type = "text", required = "true"),
          list(id = "area_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "subarea_pesca") {
        return(list(
          list(id = "subarea_code", label = "Código", type = "text", required = "true"),
          list(id = "subarea_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "registradores_campo") {
        return(list(
          list(id = "registrador_code", label = "Código", type = "text", required = "true"),
          list(id = "registrador_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "embarcaciones") {
        return(list(
          list(id = "embarcacion_code", label = "Código", type = "text", required = "true"),
          list(id = "embarcacion_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "gastos_faena") {
        return(list(
          list(id = "gasto_code", label = "Código", type = "text", required = "true"),
          list(id = "gasto_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "valor_mensual_gastos") {
        return(list(
          list(id = "gasto_id", label = "ID del Gasto", type = "text", required = TRUE),
          list(id = "ano", label = "Año", type = "number", required = TRUE),
          list(id = "mes", label = "Mes", type = "number", required = TRUE),
          list(id = "valor", label = "Valor", type = "number", required = TRUE)
        ))
      } else if (table_name == "trm_dolar") {
        return(list(
          list(id = "trm_date", label = "Fecha", type = "date", required = "true"),
          list(id = "trm_value", label = "Valor (Dólar)", type = "number", required = "true")
        ))
      }
      # ... (agregar más casos para otras tablas) ...
      else {
        return(NULL)  # O un valor predeterminado/mensaje de error
      }
    }
    
    # --- current_table (Reactivo - Obtiene el valor de session$userData) ---
    current_table <- reactive({
      req(session$userData$current_ref_table) #Espera que tenga un valor
      message("current_table se actualiza a: ", session$userData$current_ref_table) #Mensaje de depuración
      session$userData$current_ref_table
    })
    
    # --- observe para current_table (Depuración) ---
    observe({
      message("observe(current_table) ACTIVADO")
      message("Valor de current_table: ",
              if (is.null(current_table())) "NULL" else current_table())
    })
    
    
    # --- Renderizar la tabla (UNA SOLA VEZ, con dataTableProxy) ---
    output$ref_table_output <- renderDT({
      datatable(data.frame(), options = list(pageLength = 10), editable = TRUE)  # Tabla VACÍA inicialmente
    })
    
    # --- Proxy para la tabla ---
    proxy_ref_table <- dataTableProxy(ns("ref_table_output"))
    
    
    # --- Observe para actualizar la tabla cuando current_table cambia ---
    observe({
      req(central_conn, current_table())  # Espera conexión y tabla
      
      message("Actualizando tabla para: ", current_table())
      newData <- get_table_data(central_conn, current_table())
      
      if (!is.null(newData)) {
        replaceData(proxy_ref_table, newData, resetPaging = FALSE, clearSelection = "all")
      }
    })
    
    
    # --- Renderizar el formulario (SOLO si current_table tiene un valor) ---
    output$ref_form <- renderUI({
      req(current_table())
      message("Renderizando formulario para: ", current_table())
      formFields <- get_table_fields(current_table())
      
      if (is.null(formFields)) {
        return(p("Formulario no definido para esta tabla."))
      }
      
      tagList(
        lapply(formFields, function(field) {
          input_id <- field$id
          label <- field$label
          type_input <- field$type
          
          if (type_input == "text") {
            textInput(inputId = ns(input_id), label = label, value = "")
          } else if (type_input == "number") {
            numericInput(inputId = ns(input_id), label = label, value = 0)
          } else if (type_input == "date") {
            dateInput(inputId = ns(input_id), label = label, value = Sys.Date())
          }
        }),
        actionButton(ns("save_button"), "Guardar", class = "btn-primary")
      )
    })
    
    
    # --- Guardar/Actualizar datos ---
    observeEvent(input$save_button, {
      req(central_conn, current_table())
      formFields <- get_table_fields(current_table())
      if (is.null(formFields)) {
        showNotification("Error: Formulario no definido.", type = "error")
        return()
      }
      
      # Recopilar datos del formulario
      data <- list()
      for (field in formFields) {
        input_id <- field$id
        value <- input[[ns(input_id)]]
        
        if (is.null(value) || (is.character(value) && value == "")) {
          if (field$required == "true") {
            showNotification(paste("El campo", field$label, "es obligatorio"), type = "error")
            return()
          }
          data[[field$id]] <- NA
        } else {
          # Validaciones de tipo
          if (field$type == "number" && !is.na(as.numeric(value))) {
            data[[field$id]] <- as.numeric(value)
          } else if (field$type == "date" && !is.na(as.Date(value))) {
            data[[field$id]] <- as.Date(value)
          } else if (field$type == "time") {
            if (grepl("^[0-2][0-9]:[0-5][0-9]$", value)) {
              data[[field$id]] <- value
            } else {
              showNotification(
                paste("El campo", field$label, "debe tener el formato HH:MM"),
                type = "error"
              )
              return()
            }
          } else {
            data[[field$id]] <- value
          }
        }
      }
      
      # Obtener la clave primaria
      primary_key_name <- switch(current_table(),
                                 "sitios" = "site_code",
                                 "especies" = "species_code",
                                 "estados" = "cat_code",
                                 "clasifica" = "clas_code",
                                 "subgrupo" = "subgrupo_code",
                                 "grupos" = "grupo_code",
                                 "artes_pesca" = "arte_code",
                                 "metodo_tecnica_pesca" = "metodo_code",
                                 "metodos_propulsion" = "propulsion_code",
                                 "area_pesca" = "area_code",
                                 "subarea_pesca" = "subarea_code",
                                 "registradores_campo" = "registrador_code",
                                 "embarcaciones" = "embarcacion_code",
                                 "gastos_faena" = "gasto_code",
                                 "valor_mensual_gastos" = "gasto_id",  # OJO
                                 "trm_dolar" = "trm_date",
                                 stop("Clave primaria no definida para la tabla: ", current_table())
      )
      
      # Verificar si el registro existe
      check_query <- paste0("SELECT COUNT(*) FROM ", current_table(), " WHERE ", primary_key_name, " = ?")
      record_exists <- dbGetQuery(central_conn, check_query, params = list(data[[primary_key_name]]))[[1]] > 0
      
      if (record_exists) {
        # Actualizar
        update_query <- paste0(
          "UPDATE ", current_table(),
          " SET ",
          paste0(names(data), " = ? ", collapse = ", "),
          " WHERE ", primary_key_name, " = ?"
        )
        params <- c(unname(data), data[[primary_key_name]])
        dbExecute(central_conn, update_query, params = params)
        showNotification(paste("Registro actualizado en", current_table()), type = "success")
        
      } else {
        # Insertar
        insert_query <- paste0(
          "INSERT INTO ", current_table(), " (",
          paste(names(data), collapse = ", "),
          ") VALUES (",
          paste0("?", rep(length(data), collapse = ", ")),
          ")"
        )
        dbExecute(central_conn, insert_query, params = unname(data))
        showNotification(paste("Nuevo registro insertado en", current_table()), type = "success")
      }
      
      # Actualizar la tabla en la UI (usando dataTableProxy y el ID *DINÁMICO*)
      proxy <- dataTableProxy(ns("ref_table_output"))  # ¡ID genérico!
      newData <- get_table_data(central_conn, current_table())
      replaceData(proxy, newData, resetPaging = FALSE, clearSelection = "all")
      
    }, ignoreInit = TRUE)
  })
}