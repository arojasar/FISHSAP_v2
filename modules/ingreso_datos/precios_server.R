# modules/ingreso_datos/precios_server.R
precios_server <- function(id, central_conn) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # modules/ingreso_datos/precios_server.R
    precios_server <- function(id, central_conn) {
      moduleServer(id, function(input, output, session) {
        ns <- session$ns
        
        # Cargar datos iniciales
        observe({
          if (is.null(central_conn) || !dbIsValid(central_conn)) {
            showNotification("Error: No se puede conectar a la base de datos.", type = "error")
            message("Error: Conexión a la base de datos no válida en precios_server.")
            return()
          }
          
          tryCatch({
            # Cargar datos (ajusta según tu lógica)
            data <- dbGetQuery(central_conn, "SELECT * FROM precios")
            # Usa los datos según sea necesario
          }, error = function(e) {
            showNotification(paste("Error al cargar datos en precios:", e$message), type = "error")
            message("Error al cargar datos en precios: ", e$message)
          })
        })
        
    
    # Reactivo para almacenar los precios temporalmente
    precios_data <- reactiveVal(data.frame(
      Especie = character(),
      Precio_Por_Unidad = numeric(),
      Valor_Total = numeric(),
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
    
    # Añadir precio a la tabla temporal
    observeEvent(input$add_precio, {
      new_row <- data.frame(
        Especie = input$especie,
        Precio_Por_Unidad = input$precio_unidad,
        Valor_Total = input$valor_total,
        stringsAsFactors = FALSE
      )
      precios_data(rbind(precios_data(), new_row))
    })
    
    # Renderizar la tabla de precios
    output$precios_table <- renderDT({
      datatable(precios_data(), options = list(pageLength = 5), editable = TRUE)
    })
  })
}