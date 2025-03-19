# modules/ingreso_datos/ingreso_datos_faena_server.R

ingreso_datos_faena_server <- function(id, central_conn) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # --- Función para obtener los datos de la tabla 'faena_principal' ---
    get_faena_data <- function(conn) {
      query <- "SELECT * FROM faena_principal" # Consulta para obtener todos los datos
      result <- dbGetQuery(conn, query)
      return(result)
    }
    
    # --- Renderizar la tabla (opcional) ---
    output$faena_table <- renderDT({
      req(central_conn) #asegura la conexión
      data <- get_faena_data(central_conn)
      datatable(data, options = list(pageLength = 10), editable = FALSE) # Tabla, sin edición por ahora.
    })
    
    # --- Definición de los campos del formulario (específico para faena) ---
    formFields <- list(
      list(id = "registro", label = "Registro", type = "text", required = "true"),
      list(id = "fecha_zarpe", label = "Fecha de Zarpe", type = "date", required = "true"),
      list(id = "fecha_arribo", label = "Fecha de Arribo", type = "date", required = "false"),
      list(id = "sitio_desembarque", label = "Sitio de Desembarque", type = "text", required = "true"),
      list(id = "subarea", label = "Subarea", type = "text", required = "false"),
      list(id = "registrador", label = "Registrador", type = "text", required = "true"),
      list(id = "embarcacion", label = "Embarcación", type = "text", required = "true"),
      list(id = "pescadores", label = "Pescadores", type = "number", required = "true"),
      list(id = "hora_salida", label = "Hora de Salida", type = "time", required = "true"),
      list(id = "hora_arribo", label = "Hora de Arribo", type = "time", required = "true"),
      list(id = "horario", label = "Horario", type = "text", required = "false"),
      list(id = "galones", label = "Galones", type = "number", required = "true")
    )
    
    # --- Renderizar el formulario para 'faena_principal' ---
    output$faena_form <- renderUI({
      tagList( # Usamos tagList para agrupar los elementos
        lapply(formFields, function(field) { # Creamos los inputs a partir de formFields
          input_id <- field$id
          label <- field$label
          type_input <- field$type
          
          if (type_input == "text") {
            textInput(inputId = ns(input_id), label = label, value = "")
          } else if (type_input == "number") {
            numericInput(inputId = ns(input_id), label = label, value = 0)
          } else if (type_input == "date") {
            dateInput(inputId = ns(input_id), label = label, value = Sys.Date())
          } else if (type_input == "time") {
            textInput(inputId = ns(input_id), label = label, value = "00:00", placeholder = "HH:MM")
          }
        }),
        actionButton(ns("save_button"), "Guardar") # Botón de guardar
      )
    })
    
    # --- Guardar/Actualizar datos en la tabla 'faena_principal' ---
    observeEvent(input$save_button, {
      req(central_conn) #asegura conexión
      
      # Recopilar datos del formulario (¡usando formFields!)
      data <- list() # Lista vacia
      for (field in formFields) { # Recorremos los campos definidos
        input_id <- field$id
        value <- input[[ns(input_id)]] # Usamos ns() para obtener el valor del input
        
        if (is.null(value) || (is.character(value) && value == "")) {
          if (field$required == "true") { # Validamos si es un campo obligatorio
            showNotification(paste("El campo", field$label, "es obligatorio"), type = "error")
            return() # Detenemos la ejecución si falta un campo obligatorio
          }
          data[[input_id]] <- NA # Si no es obligatorio y esta vacío, se guarda como NA
        } else {
          #Validaciones y transformación de tipos
          if (field$type == "number" && !is.na(as.numeric(value))) {
            data[[input_id]] <- as.numeric(value)
          } else if (field$type == "date" && !is.na(as.Date(value))) {
            data[[input_id]] <- as.Date(value)
          } else if(field$type == "time"){
            if (grepl("^[0-2][0-9]:[0-5][0-9]$", value)) {
              data[[input_id]] <- value
            } else {
              showNotification(
                paste("El campo", field$label, "debe tener el formato HH:MM"),
                type = "error"
              )
              return()
            }
          } else {
            data[[input_id]] <- value
          }
        }
      }
      
      # Clave primaria para la tabla 'faena_principal'
      primary_key_name <- "registro"
      
      # Verificar si el registro existe (usando dbGetQuery y consultas parametrizadas)
      check_query <- paste0("SELECT COUNT(*) FROM faena_principal WHERE ", primary_key_name, " = ?")
      record_exists <- dbGetQuery(central_conn, check_query, params = list(data[[primary_key_name]]))[[1]] > 0
      
      if (record_exists) {
        # Actualizar registro existente
        update_query <- paste0(
          "UPDATE faena_principal SET ",
          paste0(names(data), " = ? ", collapse = ", "), # ¡Espacio después de ?
          " WHERE ", primary_key_name, " = ?"
        )
        params <- c(unname(data), data[[primary_key_name]]) # Parametros: datos y valor de la clave primaria
        dbExecute(central_conn, update_query, params = params)  # ¡Consulta parametrizada!
        showNotification("Faena principal actualizada", type = "success")
        
      } else {
        # Insertar nuevo registro
        insert_query <- paste0(
          "INSERT INTO faena_principal (",
          paste(names(data), collapse = ", "),
          ") VALUES (",
          paste0("?", rep(length(data), collapse = ", ")),  # Placeholders
          ")"
        )
        dbExecute(central_conn, insert_query, params = unname(data))  # ¡Consulta parametrizada!
        showNotification("Nueva faena principal insertada", type = "success")
      }
      
      # Actualizar la tabla en la UI (usando dataTableProxy)
      proxy <- dataTableProxy(ns("faena_table")) # Obtener el proxy de la tabla
      newData <- get_faena_data(central_conn)       # Volver a consultar los datos
      replaceData(proxy, newData, resetPaging = FALSE)  # Reemplazar los datos en la tabla
      
    }, ignoreInit = TRUE)
  })
}