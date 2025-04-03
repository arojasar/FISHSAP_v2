# utils/server_utils.R

# Función para limpiar el formulario
clear_form <- function(session, ns) {
  updateTextInput(session, "registro", value = "")
  updateDateInput(session, "fecha_zarpe", value = Sys.Date())
  updateDateInput(session, "fecha_arribo", value = Sys.Date())
  updateSelectInput(session, "sitio_desembarque", selected = "")
  updateSelectInput(session, "subarea", selected = "")
  updateSelectInput(session, "registrador", selected = "")
  updateSelectInput(session, "pescadores", selected = character(0))
  updateSelectInput(session, "embarcacion", selected = "")
  updateNumericInput(session, "galones", value = 0)
  updateNumericInput(session, "potencia", value = 0)
  updateNumericInput(session, "pescadores_count", value = 1)
  updateTimeInput(session, "hora_salida", value = Sys.time())
  updateTimeInput(session, "hora_arribo", value = Sys.time())
  updateSelectInput(session, "horario", selected = "Diurno")
  updateSelectInput(session, "arte_pesca", selected = "")
  updateSelectInput(session, "metodo_pesca", selected = character(0))
  updateTextAreaInput(session, "observaciones", value = "")
}

# Función para limpiar las tablas temporales
clear_temp_tables <- function(captura_data, costos_data) {
  captura_data(data.frame(
    Nombre_Cientifico = character(),
    Nombre_Comun = character(),
    Estado = character(),
    Indv = numeric(),
    Peso = numeric(),
    stringsAsFactors = FALSE
  ))
  costos_data(data.frame(
    Descripcion = character(),
    Valor = numeric(),
    stringsAsFactors = FALSE
  ))
}

# Función para insertar detalles de captura (completamente revisada)
insert_capturas <- function(conn, faena_id, capturas) {
  if (nrow(capturas) == 0) return(TRUE)
  
  # Procesar cada fila individualmente
  for (i in 1:nrow(capturas)) {
    captura <- capturas[i, ]
    
    # Depuración inicial
    message(sprintf("Procesando captura: %s, %s, Estado: %s", 
                    captura$Nombre_Cientifico, 
                    captura$Nombre_Comun, 
                    captura$Estado))
    
    # 1. OBTENER ID DE ESPECIE - MÉTODO DIRECTO
    # Primero intentamos usar directamente el codesp
    especie_id <- NULL
    
    # Intentamos buscar directamente por el nombre científico y común
    direct_query <- sprintf(
      "SELECT codesp FROM especies WHERE 
       UPPER(nombre_cientifico) = UPPER('%s') AND 
       UPPER(nombre_comun) = UPPER('%s')",
      captura$Nombre_Cientifico, 
      captura$Nombre_Comun
    )
    
    message("Consulta SQL directa: ", direct_query)
    direct_result <- tryCatch({
      dbGetQuery(conn, direct_query)
    }, error = function(e) {
      message("Error en consulta directa: ", e$message)
      data.frame(codesp = character(0))
    })
    
    # 2. SI FALLA, PROBAR OTROS MÉTODOS
    if (nrow(direct_result) == 0) {
      message("Búsqueda directa no encontró resultados, intentando métodos alternativos...")
      
      # 2.1 MÉTODO POR NOMBRE CIENTÍFICO ÚNICAMENTE
      sci_query <- sprintf(
        "SELECT codesp FROM especies WHERE UPPER(nombre_cientifico) = UPPER('%s')",
        captura$Nombre_Cientifico
      )
      
      message("Consulta SQL por nombre científico: ", sci_query)
      sci_result <- tryCatch({
        dbGetQuery(conn, sci_query)
      }, error = function(e) {
        message("Error en consulta por nombre científico: ", e$message)
        data.frame(codesp = character(0))
      })
      
      if (nrow(sci_result) > 0) {
        message("Encontrado por nombre científico: ", sci_result$codesp[1])
        especie_id <- sci_result$codesp[1]
      } else {
        # 2.2 MÉTODO POR NOMBRE COMÚN ÚNICAMENTE
        common_query <- sprintf(
          "SELECT codesp FROM especies WHERE UPPER(nombre_comun) = UPPER('%s')",
          captura$Nombre_Comun
        )
        
        message("Consulta SQL por nombre común: ", common_query)
        common_result <- tryCatch({
          dbGetQuery(conn, common_query)
        }, error = function(e) {
          message("Error en consulta por nombre común: ", e$message)
          data.frame(codesp = character(0))
        })
        
        if (nrow(common_result) > 0) {
          message("Encontrado por nombre común: ", common_result$codesp[1])
          especie_id <- common_result$codesp[1]
        } else {
          # 2.3 MÉTODO POR BÚSQUEDA PARCIAL
          partial_query <- sprintf(
            "SELECT codesp FROM especies WHERE 
             (UPPER(nombre_cientifico) LIKE UPPER('%%%s%%') OR
              UPPER(nombre_comun) LIKE UPPER('%%%s%%'))",
            captura$Nombre_Cientifico, 
            captura$Nombre_Comun
          )
          
          message("Consulta SQL por búsqueda parcial: ", partial_query)
          partial_result <- tryCatch({
            dbGetQuery(conn, partial_query)
          }, error = function(e) {
            message("Error en consulta parcial: ", e$message)
            data.frame(codesp = character(0))
          })
          
          if (nrow(partial_result) > 0) {
            message("Encontrado por búsqueda parcial: ", partial_result$codesp[1])
            especie_id <- partial_result$codesp[1]
          }
        }
      }
    } else {
      especie_id <- direct_result$codesp[1]
      message("Búsqueda directa encontró: ", especie_id)
    }
    
    # 3. SI AÚN NO TENEMOS ID, MOSTRAR LAS ESPECIES DISPONIBLES PARA DIAGNÓSTICO
    if (is.null(especie_id)) {
      # Depuración: listar todas las especies para diagnóstico
      all_especies_query <- "SELECT codesp, nombre_cientifico, nombre_comun FROM especies LIMIT 10"
      all_especies <- tryCatch({
        dbGetQuery(conn, all_especies_query)
      }, error = function(e) {
        message("Error al listar especies: ", e$message)
        data.frame()
      })
      
      message("Especies disponibles en la base de datos (primeras 10):")
      for (j in 1:nrow(all_especies)) {
        message(sprintf("%s: %s - %s", 
                        all_especies$codesp[j], 
                        all_especies$nombre_cientifico[j],
                        all_especies$nombre_comun[j]))
      }
      
      stop(paste("No se pudo encontrar la especie:", 
                 captura$Nombre_Cientifico, 
                 captura$Nombre_Comun,
                 "en la base de datos."))
    }
    
    # 4. OBTENER ID DE ESTADO
    estado_id <- captura$Estado  # Usamos directamente el código de estado
    
    # Verificamos si el estado existe
    estado_query <- sprintf("SELECT codest FROM estados WHERE codest = '%s'", estado_id)
    estado_result <- tryCatch({
      dbGetQuery(conn, estado_query)
    }, error = function(e) {
      message("Error al verificar estado: ", e$message)
      data.frame()
    })
    
    if (nrow(estado_result) == 0) {
      message("El estado con código", estado_id, "no se encontró. Usando el código E3 (limpio) por defecto.")
      estado_id <- "E3"  # Código por defecto (limpio)
    }
    
    # 5. VALORES POR DEFECTO
    indv_value <- ifelse(is.na(captura$Indv), 0, captura$Indv)
    peso_value <- ifelse(is.na(captura$Peso), 0, captura$Peso)
    
    # 6. INSERTAR REGISTRO
    insert_query <- sprintf(
      "INSERT INTO detalles_captura (Faena_ID, Especie_ID, Estado, Indv, Peso, Creado_Por, Fecha_Creacion, Sincronizado) 
       VALUES (%d, '%s', '%s', %d, %f, 'admin', CURRENT_TIMESTAMP, 0)",
      faena_id,
      especie_id,
      estado_id,
      indv_value,
      peso_value
    )
    
    message("Consulta de inserción: ", insert_query)
    
    result <- tryCatch({
      dbExecute(conn, insert_query)
    }, error = function(e) {
      message("Error al insertar captura: ", e$message)
      stop(paste("Error al insertar captura:", e$message))
    })
    
    message(sprintf("Captura insertada correctamente para faena_id: %d, especie_id: %s", faena_id, especie_id))
  }
  
  return(TRUE)
}

# Función para insertar costos (mejorada con diagnóstico y manejo de errores)
insert_costos <- function(conn, faena_id, costos) {
  if (nrow(costos) == 0) return(TRUE)
  
  # Procesar cada fila individualmente
  for (i in 1:nrow(costos)) {
    costo <- costos[i, ]
    
    # Depuración
    message(sprintf("Procesando costo: %s, Valor: %f", 
                    costo$Descripcion, 
                    costo$Valor))
    
    # 1. OBTENER ID DE GASTO 
    gasto_id <- NULL
    
    # Verificar si la Descripción es un código o un nombre
    # Primero intentamos buscar directamente por código
    code_query <- sprintf(
      "SELECT codgas FROM gastos WHERE UPPER(codgas) = UPPER('%s')",
      costo$Descripcion
    )
    
    message("Consulta SQL por código de gasto: ", code_query)
    code_result <- tryCatch({
      dbGetQuery(conn, code_query)
    }, error = function(e) {
      message("Error en consulta por código: ", e$message)
      data.frame(codgas = character(0))
    })
    
    if (nrow(code_result) > 0) {
      gasto_id <- code_result$codgas[1]
      message("Encontrado por código: ", gasto_id)
    } else {
      # Intentamos buscar por nombre
      name_query <- sprintf(
        "SELECT codgas FROM gastos WHERE UPPER(nomgas) = UPPER('%s')",
        costo$Descripcion
      )
      
      message("Consulta SQL por nombre de gasto: ", name_query)
      name_result <- tryCatch({
        dbGetQuery(conn, name_query)
      }, error = function(e) {
        message("Error en consulta por nombre: ", e$message)
        data.frame(codgas = character(0))
      })
      
      if (nrow(name_result) > 0) {
        gasto_id <- name_result$codgas[1]
        message("Encontrado por nombre: ", gasto_id)
      } else {
        # Método por búsqueda parcial
        partial_query <- sprintf(
          "SELECT codgas FROM gastos WHERE UPPER(nomgas) LIKE UPPER('%%%s%%')",
          costo$Descripcion
        )
        
        message("Consulta SQL por búsqueda parcial: ", partial_query)
        partial_result <- tryCatch({
          dbGetQuery(conn, partial_query)
        }, error = function(e) {
          message("Error en consulta parcial: ", e$message)
          data.frame(codgas = character(0))
        })
        
        if (nrow(partial_result) > 0) {
          gasto_id <- partial_result$codgas[1]
          message("Encontrado por búsqueda parcial: ", gasto_id)
        }
      }
    }
    
    # 2. SI AÚN NO TENEMOS ID, MOSTRAR LOS GASTOS DISPONIBLES PARA DIAGNÓSTICO
    if (is.null(gasto_id)) {
      # Depuración: listar todos los gastos para diagnóstico
      all_gastos_query <- "SELECT codgas, nomgas FROM gastos LIMIT 10"
      all_gastos <- tryCatch({
        dbGetQuery(conn, all_gastos_query)
      }, error = function(e) {
        message("Error al listar gastos: ", e$message)
        data.frame()
      })
      
      message("Gastos disponibles en la base de datos (primeros 10):")
      for (j in 1:nrow(all_gastos)) {
        message(sprintf("%s: %s", 
                        all_gastos$codgas[j], 
                        all_gastos$nomgas[j]))
      }
      
      stop(paste("No se pudo encontrar el gasto:", costo$Descripcion, "en la base de datos."))
    }
    
    # 3. VALORES POR DEFECTO
    valor_value <- ifelse(is.na(costo$Valor), 0, costo$Valor)
    
    # 4. INSERTAR REGISTRO
    insert_query <- sprintf(
      "INSERT INTO costos_operacion (Faena_ID, Gasto_ID, Valor, Creado_Por, Fecha_Creacion, Sincronizado) 
       VALUES (%d, '%s', %f, 'admin', CURRENT_TIMESTAMP, 0)",
      faena_id,
      gasto_id,
      valor_value
    )
    
    message("Consulta de inserción de gasto: ", insert_query)
    
    result <- tryCatch({
      dbExecute(conn, insert_query)
    }, error = function(e) {
      message("Error al insertar costo: ", e$message)
      stop(paste("Error al insertar costo:", e$message))
    })
    
    message(sprintf("Costo insertado correctamente para faena_id: %d, gasto_id: %s", faena_id, gasto_id))
  }
  
  return(TRUE)
}

# Función para actualizar la tabla de faenas
update_faenas_table <- function(conn, faenas_data) {
  tryCatch({
    data <- dbGetQuery(conn, "SELECT ID, Registro, Fecha_Zarpe, Fecha_Arribo, Sitio_Desembarque FROM faena_principal ORDER BY Fecha_Creacion DESC")
    faenas_data(data)
  }, error = function(e) {
    message("Error al actualizar la tabla de faenas: ", e$message)
  })
}