# modules/ingreso_datos/actividad_diaria_server.R
# Server para el módulo de Actividad Diaria

actividad_diaria_server <- function(id, conn, usuario) {
  moduleServer(id, function(input, output, session) {
    # Verificar si el pool es válido antes de usarlo
    if (is.null(conn) || !pool::dbIsValid(conn)) {
      message("Conexión a la base de datos no válida al iniciar el módulo.")
      return()
    }
    
    # Valores reactivos
    actividades <- reactiveVal(data.frame())
    modo_edicion <- reactiveVal(FALSE)
    id_edicion <- reactiveVal(NULL)
    
    # Cargar datos iniciales
    observeEvent(session$userData$triggers$refrescar_actividades, {
      req(conn)
      actualizar_datos()
    }, ignoreInit = FALSE)
    
    # Función para actualizar la tabla de actividades
    actualizar_datos <- function() {
      tryCatch({
        # Consulta usando los nombres correctos de las columnas
        query <- "SELECT * FROM actividades_diarias ORDER BY fecha DESC, fecha_creacion DESC"
        
        datos <- dbGetQuery(conn, query)
        
        # Si hay datos, intentamos añadir nombres descriptivos
        if (nrow(datos) > 0) {
          # Inicializar con valores predeterminados
          datos$nombre_registrador <- datos$registrador_id
          datos$nombre_arte <- datos$arte_pesca_id
          datos$nombre_sitio <- datos$zona_desembarco_id
          
          # Enriquecer con nombres descriptivos desde las tablas de referencia
          tryCatch({
            # Obtener nombres de registradores
            registradores <- dbGetQuery(conn, "SELECT codreg, nomreg FROM registrador")
            if (nrow(registradores) > 0) {
              for (i in 1:nrow(datos)) {
                reg_id <- datos$registrador_id[i]
                match_idx <- which(registradores$codreg == reg_id)
                if (length(match_idx) > 0) {
                  datos$nombre_registrador[i] <- registradores$nomreg[match_idx[1]]
                }
              }
            }
            
            # Obtener nombres de artes de pesca
            artes <- dbGetQuery(conn, "SELECT codart, nomart FROM arte")
            if (nrow(artes) > 0) {
              for (i in 1:nrow(datos)) {
                arte_id <- datos$arte_pesca_id[i]
                match_idx <- which(artes$codart == arte_id)
                if (length(match_idx) > 0) {
                  datos$nombre_arte[i] <- artes$nomart[match_idx[1]]
                }
              }
            }
            
            # Obtener nombres de sitios
            sitios <- dbGetQuery(conn, "SELECT codsit, nomsit FROM sitios")
            if (nrow(sitios) > 0) {
              for (i in 1:nrow(datos)) {
                sitio_id <- datos$zona_desembarco_id[i]
                match_idx <- which(sitios$codsit == sitio_id)
                if (length(match_idx) > 0) {
                  datos$nombre_sitio[i] <- sitios$nomsit[match_idx[1]]
                }
              }
            }
          }, error = function(e) {
            message("Error al enriquecer datos: ", e$message)
          })
        }
        
        actividades(datos)
      }, error = function(e) {
        message("Error al consultar actividades: ", e$message)
        actividades(data.frame())
      })
    }
    
    # Renderizar la tabla de actividades
    output$tabla_actividades <- renderDT({
      datos <- actividades()
      if (nrow(datos) > 0) {
        # Seleccionar y renombrar columnas para mostrar
        datos_mostrar <- data.frame(
          ID = datos$id,
          Fecha = datos$fecha,
          Registrador = datos$nombre_registrador,
          "Arte de Pesca" = datos$nombre_arte,
          "Zona de Desembarco" = datos$nombre_sitio,
          "Embarcaciones Activas" = datos$num_embarcaciones_activas,
          "Embarcaciones Muestreadas" = datos$num_embarcaciones_muestreadas,
          Observaciones = datos$observaciones
        )
        
        datatable(
          datos_mostrar,
          options = list(
            pageLength = 10,
            scrollX = TRUE,
            dom = 'Bfrtip',
            buttons = c('copy', 'csv', 'excel', 'pdf')
          ),
          selection = 'single',
          rownames = FALSE
        )
      } else {
        datatable(
          data.frame(Mensaje = "No hay datos disponibles"),
          options = list(dom = 't'),
          selection = 'none',
          rownames = FALSE
        )
      }
    })
    
    # Cargar opciones de las listas desplegables una sola vez al iniciar el módulo
    observeEvent(session$clientData, {
      req(conn)
      
      message("Intentando cargar opciones para las listas desplegables...")
      message("Contenido de registrador_choices: ", paste(capture.output(str(registrador_choices)), collapse = "\n"))
      message("Contenido de arte_pesca_choices: ", paste(capture.output(str(arte_pesca_choices)), collapse = "\n"))
      message("Contenido de sitio_desembarque_choices: ", paste(capture.output(str(sitio_desembarque_choices)), collapse = "\n"))
      
      tryCatch({
        if (length(registrador_choices) > 0) {
          updateSelectInput(session, "registrador", choices = registrador_choices)
          message("Opciones de registrador actualizadas: ", length(registrador_choices), " registros")
        } else {
          updateSelectInput(session, "registrador", choices = c("Sin datos" = ""))
          message("No hay registradores disponibles en la base de datos")
        }
      }, error = function(e) {
        message("Error al cargar registradores: ", e$message)
        updateSelectInput(session, "registrador", choices = c("Error" = ""))
      })
      
      tryCatch({
        if (length(arte_pesca_choices) > 0) {
          updateSelectInput(session, "arte_pesca", choices = arte_pesca_choices)
          message("Opciones de arte actualizadas: ", length(arte_pesca_choices), " registros")
        } else {
          updateSelectInput(session, "arte_pesca", choices = c("Sin datos" = ""))
          message("No hay artes de pesca disponibles en la base de datos")
        }
      }, error = function(e) {
        message("Error al cargar artes: ", e$message)
        updateSelectInput(session, "arte_pesca", choices = c("Error" = ""))
      })
      
      tryCatch({
        if (length(sitio_desembarque_choices) > 0) {
          updateSelectInput(session, "zona_desembarco", choices = sitio_desembarque_choices)
          message("Opciones de zonas actualizadas: ", length(sitio_desembarque_choices), " registros")
        } else {
          updateSelectInput(session, "zona_desembarco", choices = c("Sin datos" = ""))
          message("No hay zonas de desembarque disponibles en la base de datos")
        }
      }, error = function(e) {
        message("Error al cargar zonas: ", e$message)
        updateSelectInput(session, "zona_desembarco", choices = c("Error" = ""))
      })
    }, once = TRUE)
    
    # Botón para nuevo registro
    observeEvent(input$nuevo, {
      # Resetear formulario
      updateDateInput(session, "fecha", value = Sys.Date())
      updateSelectInput(session, "registrador", selected = character(0))
      updateSelectInput(session, "arte_pesca", selected = character(0))
      updateSelectInput(session, "zona_desembarco", selected = character(0))
      updateNumericInput(session, "num_embarcaciones_activas", value = 0)
      updateNumericInput(session, "num_embarcaciones_muestreadas", value = 0)
      updateTextAreaInput(session, "observaciones", value = "")
      
      # Cambiar a modo creación
      modo_edicion(FALSE)
      id_edicion(NULL)
    })
    
    # Botón para editar actividad seleccionada
    observeEvent(input$modificar, {
      req(input$tabla_actividades_rows_selected)
      
      selected_row <- input$tabla_actividades_rows_selected
      datos <- actividades()
      
      if (length(selected_row) > 0 && nrow(datos) >= selected_row) {
        actividad <- datos[selected_row, ]
        
        # Llenar formulario con datos para edición
        updateDateInput(session, "fecha", value = as.Date(actividad$fecha))
        updateSelectInput(session, "registrador", selected = actividad$registrador_id)
        updateSelectInput(session, "arte_pesca", selected = actividad$arte_pesca_id)
        updateSelectInput(session, "zona_desembarco", selected = actividad$zona_desembarco_id)
        updateNumericInput(session, "num_embarcaciones_activas", value = actividad$num_embarcaciones_activas)
        updateNumericInput(session, "num_embarcaciones_muestreadas", value = actividad$num_embarcaciones_muestreadas)
        updateTextAreaInput(session, "observaciones", value = actividad$observaciones)
        
        # Cambiar a modo edición
        modo_edicion(TRUE)
        id_edicion(actividad$id)
      } else {
        showNotification("Por favor seleccione un registro para modificar", type = "warning")
      }
    })
    
    # Botón para eliminar actividad seleccionada
    observeEvent(input$borrar, {
      req(input$tabla_actividades_rows_selected)
      
      selected_row <- input$tabla_actividades_rows_selected
      datos <- actividades()
      
      if (length(selected_row) > 0 && nrow(datos) >= selected_row) {
        actividad_id <- datos$id[selected_row]
        
        # Mostrar diálogo de confirmación
        showModal(modalDialog(
          title = "Confirmar eliminación",
          "¿Está seguro que desea eliminar esta actividad?",
          footer = tagList(
            modalButton("Cancelar"),
            actionButton(session$ns("confirmar_eliminar"), "Eliminar", class = "btn-danger")
          )
        ))
        
        # Guardar el ID a eliminar para usarlo en la confirmación
        id_edicion(actividad_id)
      } else {
        showNotification("Por favor seleccione un registro para eliminar", type = "warning")
      }
    })
    
    # Confirmación de eliminación
    observeEvent(input$confirmar_eliminar, {
      req(id_edicion())
      if (pool::dbIsValid(conn)) {
        tryCatch({
          query <- paste0("DELETE FROM actividades_diarias WHERE id = ", id_edicion())
          dbExecute(conn, query)
          
          showNotification("Actividad eliminada correctamente", type = "message")
          removeModal()
          actualizar_datos()
        }, error = function(e) {
          showNotification(paste("Error al eliminar:", e$message), type = "error")
        })
      } else {
        message("Conexión no válida al intentar eliminar.")
      }
    })
    
    # Botón para guardar o actualizar actividad
    observeEvent(input$guardar, {
      # Validación básica
      req(input$fecha, input$registrador, input$arte_pesca, input$zona_desembarco, 
          input$num_embarcaciones_activas, input$num_embarcaciones_muestreadas)
      
      if (input$num_embarcaciones_activas < 0 || input$num_embarcaciones_muestreadas < 0) {
        showNotification("Los valores de embarcaciones no pueden ser negativos", type = "error")
        return()
      }
      
      if (input$num_embarcaciones_muestreadas > input$num_embarcaciones_activas) {
        showNotification("El número de embarcaciones muestreadas no puede ser mayor al de embarcaciones activas", type = "error")
        return()
      }
      
      if (pool::dbIsValid(conn)) {
        tryCatch({
          if (modo_edicion()) {
            # Actualizar registro existente
            query <- paste0(
              "UPDATE actividades_diarias SET ",
              "fecha = '", format(input$fecha, "%Y-%m-%d"), "', ",
              "registrador_id = '", input$registrador, "', ",
              "arte_pesca_id = '", input$arte_pesca, "', ",
              "zona_desembarco_id = '", input$zona_desembarco, "', ",
              "num_embarcaciones_activas = ", input$num_embarcaciones_activas, ", ",
              "num_embarcaciones_muestreadas = ", input$num_embarcaciones_muestreadas, ", ",
              "observaciones = '", gsub("'", "''", input$observaciones), "', ",
              "modificado_por = '", usuario(), "', ",
              "fecha_modificacion = CURRENT_TIMESTAMP, ",
              "sincronizado = 0 ",
              "WHERE id = ", id_edicion()
            )
            
            dbExecute(conn, query)
            showNotification("Actividad actualizada correctamente", type = "message")
            
            # Resetear formulario después de actualizar
            updateDateInput(session, "fecha", value = Sys.Date())
            updateSelectInput(session, "registrador", selected = character(0))
            updateSelectInput(session, "arte_pesca", selected = character(0))
            updateSelectInput(session, "zona_desembarco", selected = character(0))
            updateNumericInput(session, "num_embarcaciones_activas", value = 0)
            updateNumericInput(session, "num_embarcaciones_muestreadas", value = 0)
            updateTextAreaInput(session, "observaciones", value = "")
            
            modo_edicion(FALSE)
            id_edicion(NULL)
          } else {
            # Verificar si ya existe un registro para esta fecha, arte y sitio
            query_check <- paste0(
              "SELECT id FROM actividades_diarias WHERE fecha = '", format(input$fecha, "%Y-%m-%d"), 
              "' AND registrador_id = '", input$registrador, 
              "' AND arte_pesca_id = '", input$arte_pesca, 
              "' AND zona_desembarco_id = '", input$zona_desembarco, "'"
            )
            
            result <- dbGetQuery(conn, query_check)
            
            if (nrow(result) > 0) {
              # Ya existe, preguntar si desea actualizar
              showModal(modalDialog(
                title = "Registro existente",
                "Ya existe un registro para esta fecha, registrador, arte y zona. ¿Desea actualizarlo?",
                footer = tagList(
                  modalButton("Cancelar"),
                  actionButton(session$ns("confirmar_actualizar"), "Actualizar", class = "btn-warning")
                )
              ))
              
              # Guardar datos temporalmente para usarlos en la confirmación
              id_edicion(result$id[1])
              return()
            }
            
            # Insertar nuevo registro
            query <- paste0(
              "INSERT INTO actividades_diarias ",
              "(fecha, registrador_id, arte_pesca_id, zona_desembarco_id, ",
              "num_embarcaciones_activas, num_embarcaciones_muestreadas, ",
              "observaciones, creado_por, fecha_creacion, sincronizado) ",
              "VALUES ('", format(input$fecha, "%Y-%m-%d"), "', '", input$registrador, "', '", 
              input$arte_pesca, "', '", input$zona_desembarco, "', ", 
              input$num_embarcaciones_activas, ", ", input$num_embarcaciones_muestreadas, ", '", 
              gsub("'", "''", input$observaciones), "', '", usuario(), "', CURRENT_TIMESTAMP, 0)"
            )
            
            dbExecute(conn, query)
            showNotification("Actividad guardada correctamente", type = "message")
            
            # Resetear formulario después de guardar
            updateDateInput(session, "fecha", value = Sys.Date())
            updateSelectInput(session, "registrador", selected = character(0))
            updateSelectInput(session, "arte_pesca", selected = character(0))
            updateSelectInput(session, "zona_desembarco", selected = character(0))
            updateNumericInput(session, "num_embarcaciones_activas", value = 0)
            updateNumericInput(session, "num_embarcaciones_muestreadas", value = 0)
            updateTextAreaInput(session, "observaciones", value = "")
          }
          
          # Actualizar tabla
          actualizar_datos()
          
        }, error = function(e) {
          showNotification(paste("Error al guardar:", e$message), type = "error")
        })
      } else {
        showNotification("Conexión a la base de datos no válida", type = "error")
      }
    })
    
    # Confirmación de actualización de registro existente
    observeEvent(input$confirmar_actualizar, {
      req(id_edicion())
      if (pool::dbIsValid(conn)) {
        tryCatch({
          # Actualizar registro existente
          query <- paste0(
            "UPDATE actividades_diarias SET ",
            "num_embarcaciones_activas = ", input$num_embarcaciones_activas, ", ",
            "num_embarcaciones_muestreadas = ", input$num_embarcaciones_muestreadas, ", ",
            "observaciones = '", gsub("'", "''", input$observaciones), "', ",
            "modificado_por = '", usuario(), "', ",
            "fecha_modificacion = CURRENT_TIMESTAMP, ",
            "sincronizado = 0 ",
            "WHERE id = ", id_edicion()
          )
          
          dbExecute(conn, query)
          showNotification("Actividad actualizada correctamente", type = "message")
          
          # Resetear formulario y actualizar tabla
          updateDateInput(session, "fecha", value = Sys.Date())
          updateSelectInput(session, "registrador", selected = character(0))
          updateSelectInput(session, "arte_pesca", selected = character(0))
          updateSelectInput(session, "zona_desembarco", selected = character(0))
          updateNumericInput(session, "num_embarcaciones_activas", value = 0)
          updateNumericInput(session, "num_embarcaciones_muestreadas", value = 0)
          updateTextAreaInput(session, "observaciones", value = "")
          
          modo_edicion(FALSE)
          id_edicion(NULL)
          removeModal()
          actualizar_datos()
          
        }, error = function(e) {
          showNotification(paste("Error al actualizar:", e$message), type = "error")
        })
      } else {
        showNotification("Conexión a la base de datos no válida", type = "error")
      }
    })
    
    # Botón para exportar datos
    observeEvent(input$exportar, {
      # Generar archivo CSV para descargar
      datos <- actividades()
      
      if (nrow(datos) > 0 && pool::dbIsValid(conn)) {
        # Seleccionar y renombrar columnas para exportar
        datos_exportar <- data.frame(
          ID = datos$id,
          Fecha = datos$fecha,
          Registrador = datos$nombre_registrador,
          Arte_de_Pesca = datos$nombre_arte,
          Zona_de_Desembarco = datos$nombre_sitio,
          Embarcaciones_Activas = datos$num_embarcaciones_activas,
          Embarcaciones_Muestreadas = datos$num_embarcaciones_muestreadas,
          Observaciones = datos$observaciones,
          Creado_Por = datos$creado_por,
          Fecha_Creacion = datos$fecha_creacion,
          Modificado_Por = datos$modificado_por,
          Fecha_Modificacion = datos$fecha_modificacion,
          Sincronizado = datos$sincronizado
        )
        
        # Crear archivo temporal
        temp_file <- tempfile(fileext = ".csv")
        write.csv(datos_exportar, temp_file, row.names = FALSE)
        
        # Descargar archivo usando shinyjs
        shinyjs::runjs(sprintf(
          "var link = document.createElement('a');
           link.href = 'data:text/csv;charset=utf-8,%s';
           link.download = 'actividades_diarias_%s.csv';
           document.body.appendChild(link);
           link.click();
           document.body.removeChild(link);",
          URLencode(paste(readLines(temp_file), collapse = "\n")),
          format(Sys.Date(), "%Y%m%d")
        ))
        
        # Notificar al usuario
        showNotification("Datos exportados correctamente", type = "message")
      } else {
        showNotification("No hay datos para exportar o conexión no válida", type = "warning")
      }
    })
    
    # Retornar valores para uso en otros módulos si es necesario
    return(list(
      actividades = actividades,
      refrescar = actualizar_datos
    ))
  })
}