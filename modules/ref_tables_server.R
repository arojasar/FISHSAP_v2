# modules/ref_tables_server.R
ref_tables_server <- function(id, pool, current_ref_table, ref_tables_fields) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Obtener el nombre de la tabla a partir del id
    table_name <- sub("ref_tables_", "", id)
    table_fields <- ref_tables_fields[[table_name]]$fields
    
    message("ref_tables_server: table_name = ", table_name)
    
    # Cargar opciones para los campos de tipo select
    observe({
      # Obtener una conexión del pool
      conn <- poolCheckout(pool)
      on.exit(poolReturn(conn))
      
      # Iterar sobre los campos para encontrar los de tipo select
      for (field in table_fields) {
        if (field$type == "select") {
          ref_table <- field$ref_table
          value_field <- field$value_field
          display_field <- field$display_field
          
          tryCatch({
            query <- sprintf("SELECT %s, %s FROM %s", value_field, display_field, ref_table)
            data <- dbGetQuery(conn, query)
            
            # Asegurarse de que los valores no sean NULL
            data[[value_field]] <- as.character(data[[value_field]])
            data[[display_field]] <- as.character(data[[display_field]])
            data[[value_field]][is.na(data[[value_field]]) | data[[value_field]] == ""] <- "Desconocido"
            data[[display_field]][is.na(data[[display_field]]) | data[[display_field]] == ""] <- "Desconocido"
            
            choices <- setNames(data[[value_field]], data[[display_field]])
            updateSelectInput(session, field$id, choices = choices)
          }, error = function(e) {
            showNotification(paste("Error al cargar opciones para", field$label, ":", e$message), type = "error")
            message("Error al cargar opciones para ", field$label, ": ", e$message)
          })
        }
      }
    })
    
    # Reactivo para almacenar los datos de la tabla
    table_data <- reactiveVal(NULL)
    
    # Cargar datos de la tabla solo si es la pestaña activa
    observe({
      if (current_ref_table() == table_name) {
        # Obtener una conexión del pool
        conn <- poolCheckout(pool)
        on.exit(poolReturn(conn))
        
        tryCatch({
          query <- sprintf("SELECT * FROM %s", table_name)
          data <- dbGetQuery(conn, query)
          table_data(data)
        }, error = function(e) {
          showNotification(paste("Error al cargar datos de la tabla", table_name, ":", e$message), type = "error")
          message("Error al cargar datos de la tabla ", table_name, ": ", e$message)
        })
      }
    })
    
    # Renderizar la tabla
    output$table <- renderDT({
      datatable(
        table_data(),
        options = list(
          pageLength = 10,
          dom = 't',
          language = list(emptyTable = "No hay datos disponibles")
        ),
        editable = TRUE
      )
    })
    
    # Lógica para guardar un nuevo registro
    observeEvent(input$guardar, {
      # Obtener una conexión del pool
      conn <- poolCheckout(pool)
      on.exit(poolReturn(conn))
      
      # Recolectar los valores de los campos
      values <- list()
      for (field in table_fields) {
        field_id <- field$id
        value <- input[[field_id]]
        
        # Validar campos requeridos
        if (field$required && (is.null(value) || value == "")) {
          showNotification(paste("El campo", field$label, "es requerido."), type = "error")
          return()
        }
        
        # Convertir el valor según el tipo
        if (field$type == "numeric") {
          value <- if (is.null(value) || value == "") "NULL" else as.numeric(value)
        } else if (field$type == "date") {
          value <- if (is.null(value) || value == "") "NULL" else sprintf("'%s'", as.character(value))
        } else if (field$type == "select" || field$type == "text") {
          value <- if (is.null(value) || value == "") "NULL" else sprintf("'%s'", value)
        }
        
        values[[field_id]] <- value
      }
      
      # Construir la consulta de inserción
      columns <- sapply(table_fields, function(f) toupper(f$id))
      values_str <- unlist(values)
      query <- sprintf(
        "INSERT INTO %s (%s, Creado_Por, Fecha_Creacion, Sincronizado) VALUES (%s, 'admin', CURRENT_TIMESTAMP, 0)",
        table_name,
        paste(columns, collapse = ", "),
        paste(values_str, collapse = ", ")
      )
      
      tryCatch({
        dbExecute(conn, query)
        showNotification("Registro guardado exitosamente.", type = "message")
        
        # Actualizar la tabla
        data <- dbGetQuery(conn, sprintf("SELECT * FROM %s", table_name))
        table_data(data)
        
        # Limpiar los campos
        for (field in table_fields) {
          if (field$type == "text" || field$type == "select") {
            updateTextInput(session, field$id, value = "")
          } else if (field$type == "numeric") {
            updateNumericInput(session, field$id, value = NA)
          } else if (field$type == "date") {
            updateDateInput(session, field$id, value = Sys.Date())
          }
        }
      }, error = function(e) {
        showNotification(paste("Error al guardar el registro:", e$message), type = "error")
        message("Error al guardar el registro: ", e$message)
      })
    })
  })
}