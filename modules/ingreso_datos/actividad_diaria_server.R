# Server para el módulo de Actividad Diaria
actividad_diaria_server <- function(id, conn, opciones = NULL) {
  moduleServer(id, function(input, output, session) {
    # Cargar opciones para los selectInputs
    observe({
      # Cargar registradores - usar opciones si están disponibles
      if (!is.null(opciones) && !is.null(opciones$registrador)) {
        updateSelectInput(session, "registrador", 
                          choices = opciones$registrador)
      } else {
        tryCatch({
          registradores <- dbGetQuery(conn, "SELECT CODREG, NOMREG FROM registrador ORDER BY NOMREG")
          if (nrow(registradores) > 0) {
            updateSelectInput(session, "registrador", 
                              choices = setNames(registradores$CODREG, registradores$NOMREG))
          } else {
            updateSelectInput(session, "registrador", 
                              choices = c("No hay registradores disponibles" = ""))
          }
        }, error = function(e) {
          message("Error al cargar registradores: ", e$message)
          updateSelectInput(session, "registrador", 
                            choices = c("Error al cargar datos" = ""))
        })
      }
      
      # Cargar artes de pesca - usar opciones si están disponibles
      if (!is.null(opciones) && !is.null(opciones$arte_pesca)) {
        updateSelectInput(session, "arte_pesca", 
                          choices = opciones$arte_pesca)
      } else {
        tryCatch({
          artes <- dbGetQuery(conn, "SELECT CODART, NOMART FROM arte ORDER BY NOMART")
          if (nrow(artes) > 0) {
            updateSelectInput(session, "arte_pesca", 
                              choices = setNames(artes$CODART, artes$NOMART))
          } else {
            updateSelectInput(session, "arte_pesca", 
                              choices = c("No hay artes de pesca disponibles" = ""))
          }
        }, error = function(e) {
          message("Error al cargar artes de pesca: ", e$message)
          updateSelectInput(session, "arte_pesca", 
                            choices = c("Error al cargar datos" = ""))
        })
      }
      
      # Cargar zonas de desembarco (sitios) - usar opciones si están disponibles
      if (!is.null(opciones) && !is.null(opciones$sitio)) {
        updateSelectInput(session, "zona_desembarco", 
                          choices = opciones$sitio)
      } else {
        tryCatch({
          sitios <- dbGetQuery(conn, "SELECT CODSIT, NOMSIT FROM sitios ORDER BY NOMSIT")
          if (nrow(sitios) > 0) {
            updateSelectInput(session, "zona_desembarco", 
                              choices = setNames(sitios$CODSIT, sitios$NOMSIT))
          } else {
            updateSelectInput(session, "zona_desembarco", 
                              choices = c("No hay sitios disponibles" = ""))
          }
        }, error = function(e) {
          message("Error al cargar sitios: ", e$message)
          updateSelectInput(session, "zona_desembarco", 
                            choices = c("Error al cargar datos" = ""))
        })
      }
    })
    
    # Función para actualizar la tabla de actividades
    actualizar_tabla <- function() {
      tryCatch({
        # Consulta SQL para obtener las actividades con nombres en lugar de IDs
        query <- "
          SELECT 
            ad.id,
            ad.fecha,
            r.NOMREG as registrador,
            a.NOMART as arte_pesca,
            s.NOMSIT as zona_desembarco,
            ad.num_embarcaciones_activas,
            ad.num_embarcaciones_muestreadas,
            ad.observaciones,
            ad.fecha_creacion
          FROM 
            actividades_diarias ad
            JOIN registrador r ON ad.registrador_id = r.CODREG
            JOIN arte a ON ad.arte_pesca_id = a.CODART
            JOIN sitios s ON ad.zona_desembarco_id = s.CODSIT
          ORDER BY 
            ad.fecha DESC, 
            ad.fecha_creacion DESC
        "
        
        actividades <- dbGetQuery(conn, query)
        return(actividades)
      }, error = function(e) {
        message("Error al consultar actividades: ", e$message)
        return(data.frame())
      })
    }
    
    # Datos reactivos para la tabla
    actividades_data <- reactiveVal(data.frame())
    
    # Inicializar tabla
    observe({
      actividades_data(actualizar_tabla())
    })
    
    # Mostrar tabla de actividades
    output$tabla_actividades <- renderDataTable({
      actividades_data()
    }, options = list(
      pageLength = 10,
      lengthMenu = c(5, 10, 15, 20),
      scrollX = TRUE
    ))
    
    # Guardar nueva actividad
    observeEvent(input$guardar, {
      # Validar que los campos no estén vacíos
      req(input$fecha)
      req(input$registrador)
      req(input$arte_pesca)
      req(input$zona_desembarco)
      req(input$num_embarcaciones_activas)
      req(input$num_embarcaciones_muestreadas)
      
      # Validar que los números sean válidos
      if (input$num_embarcaciones_activas < 0 || input$num_embarcaciones_muestreadas < 0) {
        showNotification("Los números de embarcaciones deben ser mayores o iguales a cero", type = "error")
        return()
      }
      
      # Validar que las embarcaciones muestreadas no sean más que las activas
      if (input$num_embarcaciones_muestreadas > input$num_embarcaciones_activas) {
        showNotification("El número de embarcaciones muestreadas no puede ser mayor que las activas", type = "error")
        return()
      }
      
      # Preparar datos para insertar
      fecha_actual <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      usuario_actual <- "admin" # Esto debería venir de un sistema de autenticación
      
      # Crear consulta SQL para insertar
      query <- sprintf(
        "INSERT INTO actividades_diarias 
         (fecha, registrador_id, arte_pesca_id, zona_desembarco_id, 
          num_embarcaciones_activas, num_embarcaciones_muestreadas, 
          observaciones, creado_por, fecha_creacion, sincronizado) 
         VALUES 
         ('%s', '%s', '%s', '%s', %d, %d, '%s', '%s', '%s', 0)",
        input$fecha, input$registrador, input$arte_pesca, input$zona_desembarco,
        input$num_embarcaciones_activas, input$num_embarcaciones_muestreadas,
        input$observaciones, usuario_actual, fecha_actual
      )
      
      # Ejecutar la inserción
      tryCatch({
        dbExecute(conn, query)
        
        # Mostrar mensaje de éxito
        showNotification("Actividad diaria guardada correctamente", type = "message")
        
        # Actualizar la tabla
        actividades_data(actualizar_tabla())
        
        # Resetear campos del formulario
        updateDateInput(session, "fecha", value = Sys.Date())
        updateNumericInput(session, "num_embarcaciones_activas", value = 0)
        updateNumericInput(session, "num_embarcaciones_muestreadas", value = 0)
        updateTextAreaInput(session, "observaciones", value = "")
        
      }, error = function(e) {
        showNotification(paste("Error al guardar la actividad:", e$message), type = "error")
      })
    })
  })
}