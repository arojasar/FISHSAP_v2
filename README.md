# FISHAP - Sistema de Información Pesquera (Aplicación Shiny)

## Descripción

Esta aplicación Shiny está diseñada para gestionar y procesar información relacionada con la actividad pesquera. Permite a los usuarios:

*   Consultar y mantener **Tablas de Referencia** (Sitios de Desembarque, Especies Comerciales, Categorías de Estado, etc.).
*   **Ingresar Datos** de faenas de pesca (actualmente, solo "Faena Principal").
*   *(Futuro)* Realizar verificaciones de datos.
*   *(Futuro)* Realizar procesamiento de datos y análisis estadísticos.
*   *(Futuro)* Generar informes.
*   *(Futuro)* Realizar tareas de utilidad.

La aplicación se conecta a una base de datos PostgreSQL (en Neon, en este caso, pero configurable) para almacenar los datos.  *Actualmente*, la aplicación funciona en modo *conectado*, requiriendo una conexión activa a la base de datos.  Está *preparada* para una futura implementación de funcionalidad offline (usando IndexedDB), pero esa funcionalidad *no* está implementada en este momento.

## Estructura del Proyecto

El proyecto está organizado de la siguiente manera:

FISHAP/
├── global.R          <- Configuraciones globales, conexión a la BD.
├── ui.R              <- Interfaz de usuario (UI) principal (shinydashboard).
├── server.R          <- Lógica del servidor principal.
├── utils/           <- Funciones de utilidad.
│   └── db_setup.R    <- Script para crear las tablas en PostgreSQL.
└── modules/         <- Módulos de la aplicación.
├── ref_tables_ui.R       <- UI genérica para tablas de referencia.
├── ref_tables_server.R   <- Server genérico para tablas de referencia.
├── ref_tables_fields.R   <- Definición de los campos de las tablas de referencia.
└── ingreso_datos/        <- Submódulo para ingreso de datos.
├── ingreso_datos_faena_ui.R    <- UI para Faena Principal.
└── ingreso_datos_faena_server.R  <- Server para Faena Principal.


**Descripción de los Archivos:**

- **`global.R`:**
  - Carga las librerías necesarias (`shiny`, `shinydashboard`, `DT`, `RPostgres`, `DBI`, `jsonlite`).
  - Define la configuración de la base de datos (usando variables de entorno).
  - Establece la conexión a la base de datos PostgreSQL.
  - Carga el script `utils/db_setup.R`.
  - Ejecuta `setup_databases()` para crear las tablas (si no existen y si hay conexión).
  - Carga los módulos de la aplicación.

- **`ui.R`:**
  - Define la estructura general de la interfaz de usuario usando `shinydashboard`.
  - Usa `dashboardPage`, `dashboardHeader`, `dashboardSidebar`, y `dashboardBody`.
  - Dentro de `dashboardSidebar`, usa `sidebarMenu`, `menuItem`, y `menuSubItem` para crear el menú de navegación.
  - Dentro de `dashboardBody`, usa `tabItems` y `tabItem` para definir el contenido de cada sección, *llamando a las funciones de UI de los módulos correspondientes*.
    - Para "Tablas de Referencia", llama a `ref_tables_ui("ref_tables_XXX")` para cada tabla de referencia (`sitios`, `especies`, `estados`, etc.), asegurando que cada módulo tenga su propio ID.
    - Para "Faena Principal", llama a `ingreso_datos_faena_ui("ingreso_datos_faena")`.

- **`server.R`:**
  - Define la función `server` principal de la aplicación Shiny.
  - Utiliza un `reactiveVal` (`current_ref_table`) para rastrear la tabla de referencia actualmente seleccionada.
  - Usa un `observeEvent(input$sidebar, ...)` para *actualizar* `current_ref_table` cuando el usuario selecciona una tabla de referencia en el menú.
  - Llama a `moduleServer` de *todos* los módulos del servidor:
    - `ref_tables_server("ref_tables_XXX", central_conn, current_ref_table)` para cada tabla de referencia (`sitios`, `especies`, `estados`, etc.), pasando la conexión a la base de datos y el valor reactivo `current_ref_table`.
    - `ingreso_datos_faena_server("ingreso_datos_faena", central_conn)`: El módulo *específico* para Faena Principal.

- **`modules/ref_tables_ui.R`:**
  - Define la UI *genérica* para *todas* las tablas de referencia.
  - Contiene un *único* `DTOutput(ns("ref_table_output"))` para mostrar la tabla.
  - Contiene un *único* `uiOutput(ns("ref_form"))` para mostrar el formulario.

- **`modules/ref_tables_server.R`:**
  - Define la lógica del servidor *genérica* para *todas* las tablas de referencia.
  - Recibe el `id` del módulo, la conexión a la base de datos (`central_conn`), y el valor reactivo `current_ref_table`.
  - Define `current_table` como un *reactivo* que depende de `current_ref_table()`.
  - Tiene funciones:
    - `get_table_data(conn, table_name)`: Obtiene los datos de la tabla especificada.
    - `get_reference_values(conn, table_name, value_field, display_field)`: Obtiene los valores de una tabla de referencia para las listas desplegables.
  - Contiene un *único* `renderDT` que se actualiza según el valor de `current_table()`.
  - Contiene un *único* `renderUI` que genera el formulario según el valor de `current_table()`.
  - Contiene un `observeEvent(input$save_button, ...)` que maneja el guardado de datos (usando `current_table()` para saber qué tabla actualizar).
  - Utiliza consultas parametrizadas para evitar la inyección SQL.
  - Actualiza la tabla automáticamente después de guardar un registro mediante un re-renderizado completo con `renderDT`.
  - Limpia los campos del formulario después de guardar y muestra notificaciones de éxito o error.

- **`modules/ref_tables_fields.R`:**
  - Define la función `get_table_fields(table_name)` que devuelve la definición de los campos del formulario para cada tabla de referencia.
  - Incluye los campos de todas las tablas (`sitios`, `especies`, `estados`, etc.), especificando el tipo de input (`text`, `number`, `select`, etc.) y las tablas de referencia para los campos de tipo `select`.

- **`modules/ingreso_datos/ingreso_datos_faena_ui.R`:**  
  Define la UI *específica* para el formulario de Faena Principal.

- **`modules/ingreso_datos/ingreso_datos_faena_server.R`:**  
  Define la lógica del servidor *específica* para el formulario de Faena Principal.

- **`utils/db_setup.R`:**  
  Contiene la función `setup_databases(conn)` que crea las tablas en la base de datos PostgreSQL (usando `CREATE TABLE IF NOT EXISTS`). *Incluye la definición de claves foráneas e índices*.


## Cómo Ejecutar la Aplicación

1.  **Variables de Entorno:** Asegúrate de tener las siguientes variables de entorno definidas en tu sistema:
    *   `DB_NAME`: El nombre de tu base de datos PostgreSQL.
    *   `DB_HOST`: El host de tu base de datos (por ejemplo, `localhost` si es local, o la dirección del servidor de Neon).
    *   `DB_PORT`: El puerto de tu base de datos (normalmente 5432 para PostgreSQL).
    *   `DB_USER`: Tu nombre de usuario de PostgreSQL.
    *   `DB_PASSWORD`: Tu contraseña de PostgreSQL.

2.  **Instalar Paquetes:** Asegúrate de tener todos los paquetes necesarios instalados:

    ```R
    install.packages(c("shiny", "shinydashboard", "DT", "RPostgres", "DBI"))
    ```

3.  **Estructura de Archivos:** Verifica que la estructura de archivos de tu proyecto coincida *exactamente* con la estructura descrita anteriormente.

4.  **Ejecutar:**
    *   **Opción 1 (Recomendada - Usando `app.R`):**
        1.  Crea un archivo llamado `app.R` en la carpeta raíz de tu proyecto (`SIPEIN/`) con el siguiente contenido:

            ```R
            # app.R
            library(shiny)

            ui <- source("ui.R")$value
            server <- source("server.R")$value

            shinyApp(ui = ui, server = server)
            ```

        2.  Abre `app.R` en RStudio y haz clic en el botón "Run App".

    *   **Opción 2 (Sin `app.R`):**
        1.  Abre un nuevo script de R (o usa la consola de RStudio).
        2.  Ejecuta las siguientes líneas:

            ```R
            library(shiny)
            source("ui.R")       # ¡Asegúrate de que la ruta es correcta!
            source("server.R")     # ¡Asegúrate de que la ruta es correcta!
            shinyApp(ui = ui, server = server)
            ```
5. **Verificar en el navegador**

## Próximos Pasos (Después de que la Aplicación Funcione):**

1. **Revisar el buen funcionamiento de las tablas de referencias** 
Verificar el Boton Guardar funcione en cada tabla de referencia,  depliegue de las diferentes opciones en la tabla de especie comercial  y crear una tabla de referencia que se llame Nombre del pescador

2. **Agregar el Módulo de "Captura y Esfuerzo":**
Si planeas tener un módulo separado para "Captura y Esfuerzo", crea los archivos modules/ingreso_datos/ingreso_datos_captura_ui.R e ingreso_datos/ingreso_datos_captura_server.R e impleméntalos.

3. **Implementar la Sincronización (Offline):**
Una vez que todo lo demás funcione, podrás empezar a implementar la funcionalidad offline (usando IndexedDB, utils/sync.R, y una API).

4. **Agregar las Demás Secciones:**
Crea los módulos para "Verificación de Datos", "Procesamiento de Datos", "Informes" y "Utilidades del Sistema".

5. **Agregar Validaciones:**
Agregar validaciones adicionales a los formularios, como verificar formatos específicos (por ejemplo, fechas, números) o evitar duplicados en campos clave.

6.  **Manejo de Errores:**
Implementar un manejo de errores más robusto (por ejemplo, mostrar mensajes de error más descriptivos al usuario si falla la conexión a la base de datos).
   
9. **Estilos (CSS):**
si se desea, personalizar el aspecto de la aplicación usando CSS.

Este `README.md` proporciona una descripción completa de tu aplicación, su estructura y cómo ejecutarla.  También incluye una hoja de ruta clara para los próximos pasos. Recuerda que este archivo debe guardarse como `README.md` (sin extensión `.R`) en la raíz de tu proyecto.# FISHSAP_v2
