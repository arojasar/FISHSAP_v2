# modules/ref_tables_server.R

ref_tables_server <- function(id, central_conn) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    message("Entrando en ref_tables_server (genérico) para ID:", id)
    
    # --- Función para obtener los datos de la tabla ---
    get_table_data <- function(conn, table_name) {
      message("get_table_data: Intentando obtener datos para: ", table_name)
      if (is.null(conn) || !dbIsValid(conn)) {
        message("ERROR en get_table_data: Conexión a la base de datos NO válida.")
        return(NULL)
      }
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
      message("get_table_fields: Obteniendo campos para: ", table_name)
      # ... (tu código para get_table_fields, SIN CAMBIOS) ...
      #Asegurate que todos los returns de strings sean correctos, y no haya errores de tipeo
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
      } else if (table_name == "arte") {
        return(list(
          list(id = "arte_code", label = "Código", type = "text", required = "true"),
          list(id = "arte_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "metodo") {
        return(list(
          list(id = "metodo_code", label = "Código", type = "text", required = "true"),
          list(id = "metodo_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "propulsion") {
        return(list(
          list(id = "propulsion_code", label = "Código", type = "text", required = "true"),
          list(id = "propulsion_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "area") {
        return(list(
          list(id = "area_code", label = "Código", type = "text", required = "true"),
          list(id = "area_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "subarea") {
        return(list(
          list(id = "subarea_code", label = "Código", type = "text", required = "true"),
          list(id = "subarea_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "registrador") {
        return(list(
          list(id = "registrador_code", label = "Código", type = "text", required = "true"),
          list(id = "registrador_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "embarcaciones") {
        return(list(
          list(id = "embarcacion_code", label = "Código", type = "text", required = "true"),
          list(id = "embarcacion_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "gastos") {
        return(list(
          list(id = "gasto_code", label = "Código", type = "text", required = "true"),
          list(id = "gasto_name", label = "Nombre", type = "text", required = "true")
        ))
      } else if (table_name == "valor_mensual_gastos") {
        return(list(
          list(id = "gasto_id", label = "ID del Gasto", type = "text", required = TRUE), # Corregido
          list(id = "ano", label = "Año", type = "number", required = TRUE),          # Corregido
          list(id = "mes", label = "Mes", type = "number", required = TRUE),          # Corregido
          list(id = "valor", label = "Valor", type = "number", required = TRUE)       # Corregido
        ))
      } else if (table_name == "trm_dolar") {
        return(list(
          list(id = "trm_date", label = "Fecha", type = "date", required = "true"),
          list(id = "trm_value", label = "Valor (Dólar)", type = "number", required = "true")
        ))
      }
      # ... (agregar más casos para otras tablas) ...
      else {
        message("ERROR en get_table_fields: Tabla desconocida: ", table_name)
        return(NULL)
      }
    }
    
    # --- current_table (Reactivo - Obtiene el valor de session$userData) ---
    valid_tables <- reactive({
      c("sitios", "especies", "estados", "clasifica", "grupos", "subgrupo",
        "arte", "metodo", "propulsion", "area", "subarea", "registrador",
        "embarcaciones", "gastos", "valor_mensual_gastos", "trm_dolar")
    })
    
    current_table <- reactive({
      selected_table <- session$userData$current_ref_table
      req(selected_table)
      message("current_table (en el módulo) se está actualizando a: ", selected_table)
      if (selected_table %in% valid_tables()) {
        selected_table
      } else {
        NULL # O algún valor por defecto si es necesario
      }
    })
    
    # --- observe para current_table (Depuración) ---
    observe({
      message("observe(current_table) ACTIVADO")
      message("Valor de current_table (dentro del observe): ",
              if (is.null(current_table())) "NULL" else current_table())
    })
    
    
    # --- Renderizar la tabla (UN SOLO renderDT, ID FIJO) ---
    output$ref_table_output <- renderDT({
      req(central_conn, current_table())
      message("Renderizando tabla para: ", current_table())
      data <- get_table_data(central_conn, current_table())
      if (is.null(data)) {
        return(NULL)  # No mostrar nada si no hay datos
      }
      datatable(data, options = list(pageLength = 10), editable = TRUE)
    })
    
    # --- Renderizar el formulario (UN SOLO renderUI, ID FIJO) ---
    output$ref_form <- renderUI({
      req(current_table())
      message("Renderizando formulario para: ", current_table())
      formFields <- get_table_fields(current_table())
      
      if (is.null(formFields)) {
        message("formFields es NULL. No se renderiza el formulario.")
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
      
      req(current_table(), central_conn)
      
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
            if (grepl("^:$", value)) {
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
                                 "arte" = "arte_code",
                                 "metodo" = "metodo_code",
                                 "propulsion" = "propulsion_code",
                                 "area" = "area_code",
                                 "subarea" = "subarea_code",
                                 "registrador" = "registrador_code",
                                 "embarcaciones" = "embarcacion_code",
                                 "gastos" = "gasto_code",
                                 "valor_mensual_gastos" = "gasto_id",  # OJO
                                 "trm_dolar" = "trm_date",
                                 stop("Clave primaria no definida para la tabla: ", current_table())
      )
      
      # Verificar si el registro existe
      check_query <- paste0("SELECT COUNT(*) FROM ", current_table(), " WHERE ", primary_key_name, " = ?")
      record_exists <- dbGetQuery(central_conn, check_query, params = list(data[[primary_key_name]]))[[1]] > 0
      
      if (record_exists) {
        # Actualizar, solo si el registro ya existe.
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
        # Insertar, solo si el registro no existe
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
      
      # Refrescar la tabla usando dataTableProxy
      proxy <- dataTableProxy(ns("ref_table_output"))
      newData <- get_table_data(central_conn, current_table())
      replaceData(proxy, newData, resetPaging = FALSE, clearSelection = "all")
    },  ignoreInit = TRUE) #Cierre del observe
  })
}