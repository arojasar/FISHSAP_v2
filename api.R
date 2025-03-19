# api.R (CORREGIDO - ¡Usa Consultas Parametrizadas!)

#* @post /sync
function(req, res) { #Recibe el objeto res
  # Obtener los datos enviados desde IndexedDB
  body <- jsonlite::fromJSON(req$postBody)
  table <- body$table
  data <- body$data
  
  # Conectar a PostgreSQL (¡Usa una función para esto!)
  central_conn <- tryCatch({
    dbConnect(RPostgres::PostgreSQL(),
              host = Sys.getenv("PG_HOST", "localhost"),
              port = as.numeric(Sys.getenv("PG_PORT", 5432)),
              dbname = Sys.getenv("PG_DBNAME", "sipein"),
              user = Sys.getenv("PG_USER", "postgres"),
              password = Sys.getenv("PG_PASSWORD", "password"))
  }, error = function(e) {
    res$status <- 500  # Internal Server Error
    return(list(success = FALSE, message = paste("No se pudo conectar a la base de datos central:", e$message)))
  })
  #Verifica si la conexión es valida
  if (is.null(central_conn) || !dbIsValid(central_conn)) {
    res$status <- 500 #Internal server error
    return(list(success = FALSE, message = "No se pudo conectar a la base de datos central"))
  }
  
  # Obtener la clave primaria (¡de forma segura! - Ya no uses ifelse)
  primary_key <- switch(table,
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
                        "valor_mensual_gastos" = "gasto_id",
                        "trm_dolar" = "trm_date",
                        "faena_principal" = "registro",
                        "detalles_captura" = "id",  # Usar "id" para serial
                        "costos_operacion" = "id",   # Usar "id" para serial
                        {
                          res$status <- 400  # Bad Request
                          dbDisconnect(central_conn)
                          return(list(success = FALSE, message = paste("Tabla desconocida:", table)))
                        }
  )
  
  pk_value <- data[[primary_key]]
  if (is.null(pk_value)) {
    res$status <- 400 # Bad Request
    dbDisconnect(central_conn)
    return(list(success = FALSE, message = "Valor de clave primaria faltante"))
  }
  
  # Verificar si el registro existe (¡Consulta Parametrizada!)
  check_query <- paste0("SELECT * FROM ", table, " WHERE ", primary_key, " = ?")
  central_exists <- dbGetQuery(central_conn, check_query, params = list(pk_value)) #Usa params
  
  if (nrow(central_exists) > 0) {
    # Comparar Fecha_Modificacion para detectar conflictos
    local_mod_time <- lubridate::ymd_hms(data$Fecha_Modificacion)
    central_mod_time <- lubridate::ymd_hms(central_exists$Fecha_Modificacion[1])
    
    if (local_mod_time > central_mod_time) {
      # Actualizar el registro en PostgreSQL (¡Consulta Parametrizada!)
      update_query <- paste0(
        "UPDATE ", table,
        " SET ",
        paste0(names(data), " = ? ", collapse = ", "), # Los ? son placeholders
        " WHERE ", primary_key, " = ?"
      )
      params <- c(unname(data), pk_value) # Los valores, incluyendo la clave primaria
      
      dbExecute(central_conn, update_query, params = params) #Usa params
      dbDisconnect(central_conn)
      res$status <- 200  # OK
      return(list(success = TRUE))
    } else {
      # Conflicto
      dbDisconnect(central_conn)
      res$status <- 409  # Conflict
      return(list(success = FALSE, conflict = TRUE, local = data, central = as.list(central_exists)))
    }
  } else {
    # Insertar nuevo registro en PostgreSQL (¡Consulta Parametrizada!)
    insert_query <- paste0(
      "INSERT INTO ", table, " (",
      paste(names(data), collapse = ", "),
      ") VALUES (",
      paste0("?", rep(length(data), collapse = ", ")), # Se crean los ?
      ")"
    )
    
    dbExecute(central_conn, insert_query, params = unname(data)) #Usa params
    dbDisconnect(central_conn)
    res$status <- 201  # Created
    return(list(success = TRUE))
  }
}