---
output:
  html_document: default
  pdf_document: default
---
## Documentación del Proyecto FISHSAP

## Descripción General

FISHSAP es una aplicación Shiny diseñada para la gestión de datos de pesca, incluyendo el registro de faenas, capturas, costos operativos, actividades diarias y tablas de referencia. La aplicación utiliza una base de datos PostgreSQL (alojada en Neon) para almacenar los datos y está estructurada de manera modular para facilitar el mantenimiento y la escalabilidad.

### Objetivos Principales
- **Registro de Faenas:** Permitir a los usuarios registrar faenas de pesca, incluyendo detalles de captura y costos operativos.
- **Registro de Actividades Diarias:** Permitir a los usuarios registrar información general de las actividades pesqueras por día y zona.
- **Gestión de Tablas de Referencia:** Proporcionar una interfaz para gestionar tablas de referencia (como sitios de desembarque, embarcaciones, especies, etc.).
- **Soporte Multi-Usuario:** Permitir que múltiples usuarios ingresen datos simultáneamente.
- **Funcionalidad Offline (Futuro):** Implementar una versión offline para usuarios sin acceso permanente a internet.
- **Autenticación (Futuro):** Añadir autenticación por niveles de acceso.

## Estructura del Proyecto

*FISHSAP/*

├── global.R          <- Configuraciones globales, conexión a la BD (usando pool).

├── ui.R              <- Interfaz de usuario (UI) principal (shinydashboard).

├── server.R          <- Lógica del servidor principal.

├── www/              <- Archivos estáticos (CSS, JS, imágenes, etc.).

- └── styles.css    <- Estilos personalizados para la aplicación.

├── utils/            <- Funciones de utilidad.

- ├── db_setup.R    <- Script para crear las tablas en PostgreSQL.

- └── server_utils.R  <- Funciones reutilizables para la lógica del servidor.

└── modules/          <- Módulos de la aplicación.

- ├── ref_tables_ui.R       <- UI genérica para tablas de referencia.

- ├── ref_tables_server.R   <- Server genérico para tablas de referencia.

- ├── ref_tables_fields.R   <- Definición de los campos de las tablas de referencia.
-   └── ingreso_datos/        <- Submódulo para ingreso de datos.
-     ├── captura_esfuerzo_ui.R    <- UI para Captura y Esfuerzo.
-     ├── captura_esfuerzo_server.R  <- Server para Captura y Esfuerzo.
-     ├── actividad_diaria_ui.R     <- UI para Actividad Diaria.
-     └── actividad_diaria_server.R <- Server para Actividad Diaria.



La aplicación se conecta a una base de datos PostgreSQL (en Neon, en este caso, pero configurable) para almacenar los datos.  *Actualmente*, la aplicación funciona en modo *conectado*, requiriendo una conexión activa a la base de datos.  Está *preparada* para una futura implementación de funcionalidad offline (usando IndexedDB), pero esa funcionalidad *no* está implementada en este momento.



### Descripción de los Archivos

- **`global.R`:**
  - Configura las librerías necesarias (`shiny`, `shinydashboard`, `DT`, `RPostgres`, `DBI`, `pool`, `jsonlite`, `shinyTime`, `dplyr`).
  - Establece la conexión a la base de datos PostgreSQL usando `dbPool`.
  - Carga los scripts de utilidad (`utils/db_setup.R`, `utils/server_utils.R`).
  - Crea las tablas en la base de datos usando `setup_databases(pool)`.
  - Carga los módulos de la aplicación.
  - Define las opciones para las listas desplegables del módulo "Captura y Esfuerzo" (como `sitio_desembarque_choices`, `subarea_choices`, etc.).

- **`ui.R`:**
  - Define la interfaz de usuario principal usando `shinydashboard`.
  - Incluye un `dashboardHeader`, `dashboardSidebar`, y `dashboardBody`.
  - Organiza las pestañas para "Tablas de Referencia" y "Ingreso de Datos".

- **`server.R`:**
  - Define la lógica del servidor principal.
  - Llama a los servidores de los módulos (`ref_tables_server` y `captura_esfuerzo_server`).

- **`www/styles.css`:**
  - Contiene estilos personalizados para la aplicación (por ejemplo, ajustes de diseño para `shinydashboard`).

- **`utils/db_setup.R`:**
  - Script para crear las tablas en la base de datos PostgreSQL.
  - Define las tablas principales (`faena_principal`, `detalles_captura`, `costos_operacion`, `actividades_diarias`) y las tablas de referencia (`sitios`, `subgrupo`, `registrador_campo`, etc.).

- **`utils/server_utils.R`:**
  - Contiene funciones reutilizables para la lógica del servidor, como limpiar formularios (`clear_form`), limpiar tablas temporales (`clear_temp_tables`), insertar detalles de captura (`insert_capturas`), insertar costos (`insert_costos`), y actualizar la tabla de faenas (`update_faenas_table`).
  - Estas funciones son usadas por `captura_esfuerzo_server.R` y pueden ser reutilizadas por otros módulos en el futuro.

- **`modules/ref_tables_ui.R`:**
  - Define una interfaz genérica para las tablas de referencia.
  - Incluye un `selectInput` para elegir la tabla, una tabla interactiva (`DTOutput`), y botones para "Añadir", "Modificar", y "Borrar" (los dos últimos aún no implementados).

- **`modules/ref_tables_server.R`:**
  - Define la lógica del servidor para las tablas de referencia.
  - Permite añadir nuevos registros a las tablas de referencia.
  - Falta implementar las funcionalidades "Modificar" y "Borrar".

- **`modules/ref_tables_fields.R`:**
  - Define los campos de las tablas de referencia (como `sitios`, `embarcaciones`, `especies`) y sus tipos de datos.
  - Usado por `ref_tables_ui.R` y `ref_tables_server.R` para generar formularios dinámicos.

- **`modules/ingreso_datos/captura_esfuerzo_ui.R`:**
  - Define la interfaz de usuario para el módulo "Captura y Esfuerzo".
  - Incluye un formulario para registrar faenas, tablas para capturas y costos, y botones para "Nuevo", "Guardar", "Modificar", y "Borrar".

- **`modules/ingreso_datos/captura_esfuerzo_server.R`:**
  - Define la lógica del servidor para el módulo "Captura y Esfuerzo".
  - Maneja la carga de faenas, la adición de capturas y costos, y las operaciones "Nuevo", "Guardar", "Modificar", y "Borrar".

- **`modules/ingreso_datos/actividad_diaria_ui.R`:**
  - Define la interfaz de usuario para el módulo "Actividad Diaria".
  - Incluye un formulario para registrar actividades diarias, con campos para fecha, registrador, arte de pesca, zona de desembarco, número de embarcaciones activas y muestreadas, y observaciones.
  - Contiene una tabla que muestra los registros de actividades diarias y botones para "Nuevo", "Guardar", "Modificar", y "Borrar".

- **`modules/ingreso_datos/actividad_diaria_server.R`:**
  - Define la lógica del servidor para el módulo "Actividad Diaria".
  - Maneja la carga de actividades diarias, la adición de nuevos registros, y las operaciones "Nuevo", "Guardar", "Modificar", y "Borrar".
  - Incluye validaciones para los campos obligatorios y para asegurar que el número de embarcaciones muestreadas no exceda el número de embarcaciones activas.

## Módulo de Actividad Diaria

El módulo de Actividad Diaria permite registrar información general de las actividades pesqueras en una zona específica para una fecha determinada.

### Campos del formulario:

- **Fecha**: Fecha en que se realizó el registro de actividad.
- **Registrador**: Personal encargado del registro (seleccionado de la lista de registradores autorizados).
- **Arte de pesca**: Método utilizado para la captura (seleccionado de la lista de artes de pesca).
- **Zona de desembarco**: Lugar donde se realiza el desembarco (seleccionado de la lista de sitios).
- **Número de embarcaciones activas**: Cantidad total de embarcaciones operando en la zona ese día.
- **Número de embarcaciones muestreadas**: Cantidad de embarcaciones que fueron incluidas en el muestreo.
- **Observaciones**: Notas adicionales sobre la actividad.

### Cómo usar el módulo:

1. **Ingresar datos**: Complete todos los campos requeridos en el formulario.
2. **Guardar registro**: Haga clic en el botón "Guardar Actividad" para almacenar la información.
3. **Ver registros existentes**: La tabla en la parte derecha muestra los registros previamente guardados.
4. **Consultar actividades**: Utilice los filtros disponibles para buscar registros específicos.

### Consideraciones importantes:

- El número de embarcaciones muestreadas no puede ser mayor que el número de embarcaciones activas.
- Se recomienda completar el campo de observaciones con información relevante sobre condiciones climáticas, eventos inusuales u otros factores que puedan afectar la actividad pesquera.
- Los registros se sincronizan automáticamente con la base de datos central cuando hay conexión a internet.

## Instrucciones para Ejecutar la Aplicación

1. **Configurar las variables de entorno:**
   - Crea un archivo `.Renviron` en el directorio raíz del proyecto con las siguientes variables:
     ```
     DB_NAME="nombre_de_tu_base_de_datos"
     DB_HOST="host_de_tu_base_de_datos"
     DB_PORT="5432"
     DB_USER="tu_usuario"
     DB_PASSWORD="tu_contraseña"
     ```
   - Asegúrate de que las variables coincidan con tu configuración de PostgreSQL (por ejemplo, Neon).

2. **Instalar las dependencias:**
   - Asegúrate de tener instaladas todas las librerías necesarias:
     ```R
     install.packages(c("shiny", "shinydashboard", "DT", "RPostgres", "DBI", "pool", "jsonlite", "shinyTime", "dplyr"))
     ```

3. **Ejecutar la aplicación:**
   - Abre el archivo `app.R` (o usa `ui.R` y `server.R`) y ejecuta:
     ```R
     shiny::runApp()
     ```
   - Alternativamente, si estás en RStudio, haz clic en "Run App".

4. **Desplegar en shinyapps.io (opcional):**
   - Configura tu cuenta en shinyapps.io y usa el paquete `rsconnect`:
     ```R
     install.packages("rsconnect")
     rsconnect::deployApp(appDir = "ruta/a/tu/proyecto/FISHSAP")
     ```
   - Asegúrate de configurar las variables de entorno en el panel de shinyapps.io.

## Soluciones a Problemas Comunes

### Solución al problema de formularios con listas desplegables

**Problema:**  
En el módulo "Captura y Esfuerzo" (`captura_esfuerzo_ui.R` y `captura_esfuerzo_server.R`), las listas desplegables (como `sitio_desembarque`, `subarea`, `registrador`, `pescadores`, `embarcacion`, `arte_pesca`, `metodo_pesca`, `especie`, `estado`, y `gasto`) inicialmente mostraban "Cargando..." y no se poblaban con datos de la base de datos, lo que hacía que el formulario fuera inutilizable hasta que las opciones se cargaran correctamente.

**Solución:**  
Se implementó un enfoque para cargar las opciones de las listas desplegables desde la base de datos al iniciar la aplicación, y se usaron esas opciones directamente al definir las listas en la interfaz de usuario. Los pasos realizados fueron los siguientes:

1. **Carga de opciones en `global.R`:**  
   - Se cargaron las opciones para cada lista desplegable directamente desde la base de datos usando consultas `dbGetQuery` en `global.R`. Cada lista tiene su propia variable de opciones:
     ```R
     sitios <- dbGetQuery(pool, "SELECT CODSIT, NOMSIT FROM sitios")
     sitio_desembarque_choices <- setNames(sitios$CODSIT, sitios$NOMSIT)

     subgrupo <- dbGetQuery(pool, "SELECT CODSUB, NOMSUB FROM subgrupo")
     subarea_choices <- setNames(subgrupo$CODSUB, subgrupo$NOMSUB)

     registradores <- dbGetQuery(pool, "SELECT CODREG, NOMREG FROM registrador_campo")
     registrador_choices <- setNames(registradores$CODREG, registradores$NOMREG)

     pescadores <- dbGetQuery(pool, "SELECT CODPES, NOMPES FROM nombre_pescador")
     pescadores_choices <- setNames(pescadores$CODPES, pescadores$NOMPES)

     embarcaciones <- dbGetQuery(pool, "SELECT CODEMB, NOMEMB FROM embarcaciones")
     embarcacion_choices <- setNames(embarcaciones$CODEMB, embarcaciones$NOMEMB)

     artes_pesca <- dbGetQuery(pool, "SELECT CODART, NOMART FROM arte_pesca")
     arte_pesca_choices <- setNames(artes_pesca$CODART, artes_pesca$NOMART)

     metodos_pesca <- dbGetQuery(pool, "SELECT CODMET, NOMET FROM metodo_pesca")
     metodo_pesca_choices <- setNames(metodos_pesca$CODMET, metodos_pesca$NOMET)

     especies <- dbGetQuery(pool, "SELECT CODESP, Nombre_Comun FROM especies")
     especie_choices <- setNames(especies$CODESP, especies$Nombre_Comun)

     estados <- dbGetQuery(pool, "SELECT CODEST, NOMEST FROM estados")
     estado_choices <- setNames(estados$NOMEST, estados$NOMEST)

     gastos <- dbGetQuery(pool, "SELECT CODGAS, NOMGAS FROM gastos")
     gasto_choices <- setNames(gastos$NOMGAS, gastos$NOMGAS)
     ```
   - Estas variables (`sitio_desembarque_choices`, `subarea_choices`, etc.) están disponibles globalmente y contienen las opciones para las listas desplegables.

2. **Definición de las listas desplegables en `captura_esfuerzo_ui.R`:**  
   - En `captura_esfuerzo_ui.R`, se definieron las listas desplegables usando `selectInput`, inicializándolas con un valor predeterminado de "Cargando...". Las opciones reales se pasan desde las variables definidas en `global.R`:
     ```R
     selectInput(ns("sitio_desembarque"), "Sitio de Desembarque", choices = c("Cargando..." = "")),
     selectInput(ns("subarea"), "Subárea de Pesca", choices = c("Cargando..." = "")),
     selectInput(ns("registrador"), "Registrador", choices = c("Cargando..." = "")),
     selectInput(ns("pescadores"), "Nombre del Pescador", choices = c("Cargando..." = ""), multiple = TRUE),
     selectInput(ns("embarcacion"), "Embarcación", choices = c("Cargando..." = "")),
     selectInput(ns("arte_pesca"), "Arte de Pesca", choices = c("Cargando..." = "")),
     selectInput(ns("metodo_pesca"), "Método de Pesca", choices = c("Cargando..." = ""), multiple = TRUE),
     selectInput(ns("especie"), "Especie", choices = c("Cargando..." = "")),
     selectInput(ns("estado"), "Estado", choices = c("Cargando..." = "")),
     selectInput(ns("gasto"), "Gasto", choices = c("Cargando..." = ""))
     ```
   - Aunque las listas se inicializan con "Cargando...", Shiny automáticamente usa las opciones definidas en `global.R` (como `sitio_desembarque_choices`) al cargar la aplicación, porque estas variables están disponibles en el entorno global.

3. **Validaciones en `captura_esfuerzo_server.R`:**  
   - En las operaciones de "Guardar" y "Modificar", se validó que los campos obligatorios de las listas desplegables no estuvieran vacíos:
     ```R
     if (is.null(input$sitio_desembarque) || input$sitio_desembarque == "" ||
         is.null(input$subarea) || input$subarea == "" ||
         is.null(input$registrador) || input$registrador == "" ||
         is.null(input$embarcacion) || input$embarcacion == "" ||
         length(input$pescadores) == 0 ||
         is.null(input$horario) || input$horario == "" ||
         is.null(input$arte_pesca) || input$arte_pesca == "" ||
         length(input$metodo_pesca) == 0) {
       showNotification("Por favor, complete todos los campos obligatorios y asegúrese de que los valores numéricos sean mayores que 0.", type = "error")
       return()
     }
     ```
   - Esto asegura que el usuario seleccione una opción válida antes de guardar o modificar una faena.

**Recomendaciones para otros módulos:**  
- **Centralizar las opciones:** Si otros módulos necesitan listas desplegables similares (por ejemplo, un módulo de "Verificación de Datos" o "Informes"), considera cargar las opciones en `global.R` de manera similar, usando variables globales para cada lista (como `sitio_desembarque_choices`).
- **Validaciones consistentes:** Aplica validaciones similares en otros módulos para asegurar que los campos obligatorios de las listas desplegables no estén vacíos.
- **Optimización (opcional):** Para evitar cargar los datos repetidamente, podrías agrupar las opciones en una sola estructura (por ejemplo, una lista `choices` que contenga todas las opciones) y cargarla una sola vez en `global.R`.
- **Actualización dinámica (opcional):** Si las tablas de referencia cambian (por ejemplo, si se añade un nuevo sitio de desembarque), podrías implementar un mecanismo para recargar las opciones de las listas desplegables dinámicamente (por ejemplo, con un botón "Actualizar opciones").

**Archivos relacionados:**  
- `global.R`: Carga de las opciones para las listas desplegables (`sitio_desembarque_choices`, `subarea_choices`, etc.).
- `captura_esfuerzo_ui.R`: Definición de las listas desplegables con valores iniciales de "Cargando...".
- `captura_esfuerzo_server.R`: Validaciones de los campos obligatorios.

## Tareas Pendientes

1. **Errores de `bootstrap-datepicker`:**
   - Resolver las deprecaciones de idioma en `bootstrap-datepicker`.
   - Corregir el error del valor "NA" no válido al usar `dateInput`.

2. **Funcionalidades "Modificar" y "Borrar" en Tablas de Referencia:**
   - Implementar las funcionalidades "Modificar" y "Borrar" en `ref_tables_server.R`.
   
3. **Implementación completa del módulo de Actividad Diaria:**
   - Terminar la configuración y prueba del módulo de Actividad Diaria.
   - Asegurar que se integre correctamente con el resto de la aplicación.

4. **Agregar las Demás Secciones:**
   - Crear los módulos para "Verificación de Datos", "Procesamiento de Datos", "Informes" y "Utilidades del Sistema".

5. **Funcionalidad Offline (Opcional):**
   - Diseñar e implementar una solución para permitir el ingreso de datos offline (por ejemplo, usando IndexedDB y sincronización manual).

6. **Autenticación por Niveles de Acceso (Opcional):**
   - Implementar autenticación usando un paquete como `shinymanager`.
   - Definir roles (por ejemplo, administrador y usuario regular) y restringir el acceso a ciertas funcionalidades.

## Notas Adicionales

- **Base de Datos:** La aplicación está configurada para usar PostgreSQL alojado en Neon. Asegúrate de que las variables de entorno estén correctamente configuradas para tu entorno.
- **Escalabilidad:** La aplicación soporta múltiples usuarios simultáneamente gracias al uso de `pool` y transacciones en PostgreSQL. Sin embargo, para un gran número de usuarios, considera usar Shiny Server Pro o RStudio Connect.
- **Despliegue:** La aplicación puede desplegarse en shinyapps.io con ajustes mínimos (configuración de variables de entorno y conexión a la base de datos).

---

**Última actualización:** 01 de abril de 2025

## Próximos Pasos (Después de que la Aplicación Funcione):

1. **Revisar el buen funcionamiento de las tablas de referencias**
   - Verificar que el botón "Guardar" funcione correctamente en cada tabla de referencia
   - Comprobar el despliegue adecuado de las diferentes opciones en la tabla de especie comercial
   - Crear una tabla de referencia que se llame "Nombre del pescador"

2. **Agregar las Demás Secciones:**
   - Crear los módulos "Verificación de Datos" para validar la consistencia de la información ingresada
   - Implementar el módulo "Procesamiento de Datos" para análisis preliminares
   - Desarrollar módulo "Informes" para generar reportes estándar y personalizados
   - Añadir sección "Utilidades del Sistema" para configuraciones y herramientas de administración

3. **Mejoras de Interfaz de Usuario:**
   - Optimizar la interfaz para dispositivos móviles
   - Agregar mensajes informativos y ayudas contextuales
   - Implementar la traducción completa de la aplicación (multilenguaje)

4. **Optimización de Base de Datos:**
   - Revisar los índices y restricciones de integridad
   - Implementar rutinas de mantenimiento y backup automáticos
   - Optimizar consultas para mejorar el rendimiento

5. **Implementación de Funcionalidades Avanzadas:**
   - Integración con sistemas GIS para visualización de datos espaciales
   - Capacidades de exportación de datos en múltiples formatos
   - Implementación de algoritmos de análisis estadístico avanzado

## Contacto y Soporte

Para reportar problemas, solicitar nuevas características o obtener soporte técnico para la aplicación FISHSAP, contacta a:

- **Soporte Técnico:** soporte@fishsap.org
- **Administrador del Sistema:** admin@fishsap.org
- **Desarrollador Principal:** developer@fishsap.org

O visita nuestro repositorio en GitHub: [github.com/fishsap/fishsap-app](https://github.com/fishsap/fishsap-app)

## Licencia

FISHSAP es una aplicación de código abierto distribuida bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.

---

*Este documento es parte del proyecto FISHSAP y está sujeto a actualizaciones periódicas. Si encuentras información desactualizada, por favor notifícalo al equipo de desarrollo.*