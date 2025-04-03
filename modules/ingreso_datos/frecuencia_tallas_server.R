# modules/ingreso_datos/frecuencia_tallas_server.R
frecuencia_tallas_server <- function(id, central_conn) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Cargar datos iniciales
    observe({
      if (is.null(central_conn) || !dbIsValid(central_conn)) {
        showNotification("Error: No se puede conectar a la base de datos.", type = "error")
        message("Error: Conexión a la base de datos no válida en frecuencia_tallas_server.")
        return()
      }
      
      tryCatch({
        # Cargar datos (ajusta según tu lógica)
        data <- dbGetQuery(central_conn, "SELECT * FROM frecuencia_tallas")
        # Usa los datos según sea necesario
      }, error = function(e) {
        showNotification(paste("Error al cargar datos en frecuencia_tallas:", e$message), type = "error")
        message("Error al cargar datos en frecuencia_tallas: ", e$message)
      })
    })
    
    # Reactivo para almacenar las tallas temporalmente
    tallas_data <- reactiveVal(data.frame(
      Especie = character(),
      Talla = numeric(),
      Frecuencia = numeric(),
      stringsAsFactors = FALSE
    ))
    
    # Actualizar selectInputs
    observe({
      # Especie
      especies <- dbGetQuery(central_conn, "SELECT CODESP, Nombre_Comun FROM especies")
      if (nrow(especies) > 0) {
        updateSelectInput(session, "especie", choices = setNames(especies$CODESP, especies$Nombre_Comun))
      }
    })
    
    # Añadir talla a la tabla temporal
    observeEvent(input$add_talla, {
      new_row <- data.frame(
        Especie = input$especie,
        Talla = input$talla,
        Frecuencia = input$frecuencia,
        stringsAsFactors = FALSE
      )
      tallas_data(rbind(tallas_data(), new_row))
    })
    
    # Renderizar la tabla de tallas
    output$tallas_table <- renderDT({
      datatable(tallas_data(), options = list(pageLength = 5), editable = TRUE)
    })
  })
}