# utils/db_setup.R
# Define la función setup_databases para crear las tablas en la base de datos.
# Cambios: Añadimos la columna Observaciones a faena_principal.

# Lista global para almacenar las definiciones de las tablas
table_definitions <<- list()

setup_databases <- function(conn) {
  if (is.null(conn)) {
    warning("No se puede configurar la base de datos: conexión nula.")
    return()
  }
  
  # Lista de tablas y sus definiciones SQL
  tables <- list(
    "sitios" = "
      CREATE TABLE IF NOT EXISTS sitios (
        CODSIT VARCHAR(10) PRIMARY KEY,
        NOMSIT VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "especies" = "
      CREATE TABLE IF NOT EXISTS especies (
        CODESP VARCHAR(10) PRIMARY KEY,
        Nombre_Comun VARCHAR(100),
        Nombre_Cientifico VARCHAR(100),
        Subgrupo_ID VARCHAR(10),
        Clasificacion_ID VARCHAR(10),
        Constante_A DECIMAL,
        Constante_B DECIMAL,
        Clase_Medida VARCHAR(10),
        Clasificacion_Comercial VARCHAR(10),
        Grupo VARCHAR(50),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "estados" = "
      CREATE TABLE IF NOT EXISTS estados (
        CODEST VARCHAR(10) PRIMARY KEY,
        NOMEST VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "clasifica" = "
      CREATE TABLE IF NOT EXISTS clasifica (
        CODCLA VARCHAR(10) PRIMARY KEY,
        NOMCLA VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "grupos" = "
      CREATE TABLE IF NOT EXISTS grupos (
        CODGRU VARCHAR(10) PRIMARY KEY,
        NOMGRU VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "subgrupo" = "
      CREATE TABLE IF NOT EXISTS subgrupo (
        CODSUBGRU VARCHAR(10) PRIMARY KEY,
        NOMSUBGRU VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "arte" = "
      CREATE TABLE IF NOT EXISTS arte (
        CODART VARCHAR(10) PRIMARY KEY,
        NOMART VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "metodo" = "
      CREATE TABLE IF NOT EXISTS metodo (
        CODMET VARCHAR(10) PRIMARY KEY,
        NOMMET VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "propulsion" = "
      CREATE TABLE IF NOT EXISTS propulsion (
        CODPRO VARCHAR(10) PRIMARY KEY,
        NOMPRO VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "area" = "
      CREATE TABLE IF NOT EXISTS area (
        CODARE VARCHAR(10) PRIMARY KEY,
        NOMARE VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "subarea" = "
      CREATE TABLE IF NOT EXISTS subarea (
        CODSUBARE VARCHAR(10) PRIMARY KEY,
        NOMSUBARE VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "registrador" = "
      CREATE TABLE IF NOT EXISTS registrador (
        CODREG VARCHAR(10) PRIMARY KEY,
        NOMREG VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "embarcaciones" = "
      CREATE TABLE IF NOT EXISTS embarcaciones (
        CODEMB VARCHAR(10) PRIMARY KEY,
        NOMEMB VARCHAR(100),
        Matricula VARCHAR(20),
        Potencia INTEGER,
        Propulsion VARCHAR(50),
        Numero_Motores INTEGER,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "gastos" = "
      CREATE TABLE IF NOT EXISTS gastos (
        CODGAS VARCHAR(10) PRIMARY KEY,
        NOMGAS VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "valor_mensual_gastos" = "
      CREATE TABLE IF NOT EXISTS valor_mensual_gastos (
        ID SERIAL PRIMARY KEY,
        Gasto_ID VARCHAR(10),
        Ano INTEGER,
        Mes INTEGER,
        Valor DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "trm_dolar" = "
      CREATE TABLE IF NOT EXISTS trm_dolar (
        ID SERIAL PRIMARY KEY,
        Fecha DATE,
        Valor DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "faena_principal" = "
      CREATE TABLE IF NOT EXISTS faena_principal (
        id SERIAL PRIMARY KEY,
        registro VARCHAR(50),
        fecha_zarpe DATE,
        fecha_arribo DATE,
        sitio_desembarque VARCHAR(50),
        subarea VARCHAR(50),
        registrador VARCHAR(50),
        embarcacion VARCHAR(50),
        pescadores INTEGER,
        hora_salida TIME,
        hora_arribo TIME,
        horario VARCHAR(50),
        galones NUMERIC,
        artepesca VARCHAR(50),
        metodopesca VARCHAR(50),
        motores INTEGER,
        propulsion VARCHAR(50),
        potencia NUMERIC,
        estado_verificacion VARCHAR(50),
        verificado_por VARCHAR(50),
        fecha_verificacion TIMESTAMP,
        creado_por VARCHAR(50),
        fecha_creacion TIMESTAMP,
        modificado_por VARCHAR(50),
        fecha_modificacion TIMESTAMP,
        sincronizado INTEGER
      )",
    "detalles_captura" = "
      CREATE TABLE IF NOT EXISTS detalles_captura (
        ID SERIAL PRIMARY KEY,
        Faena_ID INTEGER,
        Especie_ID VARCHAR(10),
        Estado VARCHAR(10),
        Indv INTEGER,
        Peso DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "costos_operacion" = "
      CREATE TABLE IF NOT EXISTS costos_operacion (
        ID SERIAL PRIMARY KEY,
        Faena_ID INTEGER,
        Gasto_ID VARCHAR(10),
        Valor DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "nombre_pescador" = "
      CREATE TABLE IF NOT EXISTS nombre_pescador (
        CODPES VARCHAR(10) PRIMARY KEY,
        NOMPES VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "clases_medida" = "
      CREATE TABLE IF NOT EXISTS clases_medida (
        CODCLAMED VARCHAR(10) PRIMARY KEY,
        NOMCLAMED VARCHAR(100),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "frecuencia_tallas" = "
      CREATE TABLE IF NOT EXISTS frecuencia_tallas (
        ID SERIAL PRIMARY KEY,
        Faena_ID INTEGER,
        Especie_ID VARCHAR(10),
        Talla DECIMAL,
        Frecuencia INTEGER,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "precios" = "
      CREATE TABLE IF NOT EXISTS precios (
        ID SERIAL PRIMARY KEY,
        Faena_ID INTEGER,
        Especie_ID VARCHAR(10),
        Precio_Por_Unidad DECIMAL,
        Valor_Total DECIMAL,
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER
      )",
    "observaciones" = "
      CREATE TABLE IF NOT EXISTS observaciones (
        id SERIAL PRIMARY KEY,
        faena_id INTEGER,
        observacion TEXT,
        creado_por VARCHAR(50),
        fecha_creacion TIMESTAMP,
        modificado_por VARCHAR(50),
        fecha_modificacion TIMESTAMP,
        sincronizado INTEGER,
        CONSTRAINT fk_observaciones_faena
          FOREIGN KEY (faena_id)
          REFERENCES faena_principal (id)
          ON DELETE CASCADE
      )",
    "actividades_diarias" = "
      CREATE TABLE IF NOT EXISTS actividades_diarias (
        id SERIAL PRIMARY KEY,
        fecha DATE NOT NULL,
        registrador_id VARCHAR(10) NOT NULL,
        arte_pesca_id VARCHAR(10) NOT NULL,
        zona_desembarco_id VARCHAR(10) NOT NULL,
        num_embarcaciones_activas INTEGER NOT NULL,
        num_embarcaciones_muestreadas INTEGER NOT NULL,
        observaciones TEXT,
        creado_por VARCHAR(50),
        fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        modificado_por VARCHAR(50),
        fecha_modificacion TIMESTAMP,
        sincronizado INTEGER DEFAULT 0,
        CONSTRAINT fk_registrador_act
          FOREIGN KEY (registrador_id)
          REFERENCES registrador (CODREG)
          ON DELETE RESTRICT,
        CONSTRAINT fk_arte_pesca_act
          FOREIGN KEY (arte_pesca_id)
          REFERENCES arte (CODART)
          ON DELETE RESTRICT,
        CONSTRAINT fk_zona_desembarco_act
          FOREIGN KEY (zona_desembarco_id)
          REFERENCES sitios (CODSIT)
          ON DELETE RESTRICT
      )",
    
    # Tabla frecuencia_tallas (nueva definición)
    "frecuencia_tallas" = "
      ID SERIAL PRIMARY KEY,
        Faena_ID INTEGER NOT NULL,
        Especie_ID VARCHAR(10) NOT NULL,
        Tipo_Medida VARCHAR(50) NOT NULL CHECK (Tipo_Medida IN ('Longitud Total', 'Longitud Estándar', 'Longitud Horquilla', 'Longitud Cefalotórax', 'Longitud Cola', 'Longitud Concha')),
        Talla DECIMAL NOT NULL CHECK (Talla > 0),
        Frecuencia INTEGER NOT NULL CHECK (Frecuencia > 0),
        Peso DECIMAL CHECK (Peso IS NULL OR Peso > 0),
        Sexo VARCHAR(10) CHECK (Sexo IS NULL OR Sexo IN ('H Hembra', 'M Macho', 'I Indefinido')),
        Creado_Por VARCHAR(50),
        Fecha_Creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        Modificado_Por VARCHAR(50),
        Fecha_Modificacion TIMESTAMP,
        Sincronizado INTEGER DEFAULT 0,
        CONSTRAINT fk_faena_tallas
          FOREIGN KEY (Faena_ID)
          REFERENCES faena_principal (ID)
          ON DELETE CASCADE,
        CONSTRAINT fk_especie_tallas
          FOREIGN KEY (Especie_ID)
          REFERENCES especies (CODESP)
          ON DELETE RESTRICT
      )",
    # Tabla para almacenar reportes de estadísticas
    "reporte_estadisticas" = "
      CREATE TABLE IF NOT EXISTS reporte_estadisticas (
        id SERIAL PRIMARY KEY,
      fecha_inicio DATE NOT NULL,
      fecha_fin DATE NOT NULL,
      especie_id VARCHAR(10),
      sitio_id VARCHAR(10),
      especie VARCHAR(100),
      num_registros INTEGER,
      total_individuos INTEGER,
      total_peso_kg NUMERIC,
      sitio VARCHAR(100),
      nombre_sitio VARCHAR(100),
      num_faenas INTEGER,
      creado_por VARCHAR(50),
      fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )",
    # Tabla para almacenar reportes de estimaciones
    "reporte_estimaciones" = "
      CREATE TABLE IF NOT EXISTS reporte_estimaciones (
      id SERIAL PRIMARY KEY,
      fecha_inicio DATE NOT NULL,
      fecha_fin DATE NOT NULL,
      especie_id VARCHAR(10),
      sitio_id VARCHAR(10),
      fecha DATE,
      sitio VARCHAR(100),
      nombre_sitio VARCHAR(100),
      especie VARCHAR(100),
      num_embarcaciones_activas INTEGER,
      num_embarcaciones_muestreadas INTEGER,
      indv_muestreados INTEGER,
      peso_muestreados_kg NUMERIC,
      indv_estimados NUMERIC,
      peso_estimados_kg NUMERIC,
      creado_por VARCHAR(50),
      fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )"
  )
  
  # Función para extraer columnas de una definición SQL
  extract_columns <- function(sql_def) {
    sql_def <- gsub("CREATE TABLE IF NOT EXISTS [a-zA-Z_]+ \\((.*)\\)", "\\1", sql_def, perl = TRUE)
    columns <- unlist(strsplit(trimws(sql_def), ",\\s*"))
    column_names <- sapply(columns, function(col) {
      col <- trimws(col)
      first_word <- unlist(strsplit(col, "\\s+"))[1]
      return(first_word)
    })
    return(column_names)
  }
  
  # Extraer las columnas de cada tabla y almacenarlas en table_definitions
  for (table_name in names(tables)) {
    columns <- extract_columns(tables[[table_name]])
    table_definitions[[table_name]] <<- columns
    message("Columnas extraídas para ", table_name, ": ", paste(columns, collapse = ", "))
  }
  
  # Ejecutar las creaciones de tablas
  for (table_name in names(tables)) {
    tryCatch({
      dbExecute(conn, tables[[table_name]])
      message(paste("Tabla", table_name, "creada o ya existente."))
    }, error = function(e) {
      warning(paste("Error al crear la tabla", table_name, ":", e$message))
    })
  }
  
  # Añadir claves foráneas para la tabla especies
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_clase_medida' AND conrelid = 'especies'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE especies
        ADD CONSTRAINT fk_clase_medida
        FOREIGN KEY (Clase_Medida)
        REFERENCES clases_medida (CODCLAMED)
        ON DELETE RESTRICT;
      ")
      message("Clave foránea para Clase_Medida añadida en la tabla especies.")
    } else {
      message("La clave foránea fk_clase_medida ya existe en la tabla especies, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Clase_Medida: ", e$message)
  })
  
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_subgrupo' AND conrelid = 'especies'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE especies
        ADD CONSTRAINT fk_subgrupo
        FOREIGN KEY (Subgrupo_ID)
        REFERENCES subgrupo (CODSUBGRU)
        ON DELETE SET NULL;
      ")
      message("Clave foránea para Subgrupo_ID añadida en la tabla especies.")
    } else {
      message("La clave foránea fk_subgrupo ya existe en la tabla especies, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Subgrupo_ID: ", e$message)
  })
  
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_clasificacion' AND conrelid = 'especies'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE especies
        ADD CONSTRAINT fk_clasificacion
        FOREIGN KEY (Clasificacion_ID)
        REFERENCES clasifica (CODCLA)
        ON DELETE SET NULL;
      ")
      message("Clave foránea para Clasificacion_ID añadida en la tabla especies.")
    } else {
      message("La clave foránea fk_clasificacion ya existe en la tabla especies, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Clasificacion_ID: ", e$message)
  })
  
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_grupo' AND conrelid = 'especies'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE especies
        ADD CONSTRAINT fk_grupo
        FOREIGN KEY (Grupo)
        REFERENCES grupos (CODGRU)
        ON DELETE SET NULL;
      ")
      message("Clave foránea para Grupo añadida en la tabla especies.")
    } else {
      message("La clave foránea fk_grupo ya existe en la tabla especies, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Grupo: ", e$message)
  })
  
  # Añadir claves foráneas para la tabla detalles_captura
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_detalles_faena' AND conrelid = 'detalles_captura'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE detalles_captura
        ADD CONSTRAINT fk_detalles_faena
        FOREIGN KEY (Faena_ID)
        REFERENCES faena_principal (ID)
        ON DELETE CASCADE;
      ")
      message("Clave foránea para Faena_ID añadida en la tabla detalles_captura.")
    } else {
      message("La clave foránea fk_detalles_faena ya existe en la tabla detalles_captura, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Faena_ID en detalles_captura: ", e$message)
  })
  
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_detalles_especie' AND conrelid = 'detalles_captura'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE detalles_captura
        ADD CONSTRAINT fk_detalles_especie
        FOREIGN KEY (Especie_ID)
        REFERENCES especies (CODESP)
        ON DELETE RESTRICT;
      ")
      message("Clave foránea para Especie_ID añadida en la tabla detalles_captura.")
    } else {
      message("La clave foránea fk_detalles_especie ya existe en la tabla detalles_captura, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Especie_ID en detalles_captura: ", e$message)
  })
  
  # Añadir claves foráneas para la tabla costos_operacion
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_costos_faena' AND conrelid = 'costos_operacion'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE costos_operacion
        ADD CONSTRAINT fk_costos_faena
        FOREIGN KEY (Faena_ID)
        REFERENCES faena_principal (ID)
        ON DELETE CASCADE;
      ")
      message("Clave foránea para Faena_ID añadida en la tabla costos_operacion.")
    } else {
      message("La clave foránea fk_costos_faena ya existe en la tabla costos_operacion, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Faena_ID en costos_operacion: ", e$message)
  })
  
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_costos_gasto' AND conrelid = 'costos_operacion'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE costos_operacion
        ADD CONSTRAINT fk_costos_gasto
        FOREIGN KEY (Gasto_ID)
        REFERENCES gastos (CODGAS)
        ON DELETE RESTRICT;
      ")
      message("Clave foránea para Gasto_ID añadida en la tabla costos_operacion.")
    } else {
      message("La clave foránea fk_costos_gasto ya existe en la tabla costos_operacion, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Gasto_ID en costos_operacion: ", e$message)
  })
  
  # Añadir claves foráneas para la tabla frecuencia_tallas
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_tallas_faena' AND conrelid = 'frecuencia_tallas'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE frecuencia_tallas
        ADD CONSTRAINT fk_tallas_faena
        FOREIGN KEY (Faena_ID)
        REFERENCES faena_principal (ID)
        ON DELETE CASCADE;
      ")
      message("Clave foránea para Faena_ID añadida en la tabla frecuencia_tallas.")
    } else {
      message("La clave foránea fk_tallas_faena ya existe en la tabla frecuencia_tallas, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Faena_ID en frecuencia_tallas: ", e$message)
  })
  
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_tallas_especie' AND conrelid = 'frecuencia_tallas'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE frecuencia_tallas
        ADD CONSTRAINT fk_tallas_especie
        FOREIGN KEY (Especie_ID)
        REFERENCES especies (CODESP)
        ON DELETE RESTRICT;
      ")
      message("Clave foránea para Especie_ID añadida en la tabla frecuencia_tallas.")
    } else {
      message("La clave foránea fk_tallas_especie ya existe en la tabla frecuencia_tallas, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Especie_ID en frecuencia_tallas: ", e$message)
  })
  
  # Añadir claves foráneas para la tabla precios
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_precios_faena' AND conrelid = 'precios'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE precios
        ADD CONSTRAINT fk_precios_faena
        FOREIGN KEY (Faena_ID)
        REFERENCES faena_principal (ID)
        ON DELETE CASCADE;
      ")
      message("Clave foránea para Faena_ID añadida en la tabla precios.")
    } else {
      message("La clave foránea fk_precios_faena ya existe en la tabla precios, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Faena_ID en precios: ", e$message)
  })
  
  tryCatch({
    fk_exists <- dbGetQuery(conn, "
      SELECT 1
      FROM pg_constraint
      WHERE conname = 'fk_precios_especie' AND conrelid = 'precios'::regclass
    ")
    if (nrow(fk_exists) == 0) {
      dbExecute(conn, "
        ALTER TABLE precios
        ADD CONSTRAINT fk_precios_especie
        FOREIGN KEY (Especie_ID)
        REFERENCES especies (CODESP)
        ON DELETE RESTRICT;
      ")
      message("Clave foránea para Especie_ID añadida en la tabla precios.")
    } else {
      message("La clave foránea fk_precios_especie ya existe en la tabla precios, omitiendo creación.")
    }
  }, error = function(e) {
    warning("Error al añadir clave foránea para Especie_ID en precios: ", e$message)
  })
}

# Función para obtener las definiciones de las tablas (para uso externo)
get_table_definitions <- function() {
  return(table_definitions)
}