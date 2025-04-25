## Documentación del Proyecto FISHSAP

## Descripción General

FISHSAP es una aplicación Shiny diseñada para la gestión de datos de pesca, incluyendo el registro de faenas, capturas, costos operativos, actividades diarias, frecuencias de tallas, verificación de datos, y tablas de referencia. La aplicación utiliza una base de datos PostgreSQL (alojada en Neon) para almacenar los datos y está estructurada de manera modular para facilitar el mantenimiento y la escalabilidad.

### Objetivos Principales
- **Registro de Faenas:** Permitir a los usuarios registrar faenas de pesca, incluyendo detalles de captura y costos operativos.
- **Registro de Actividades Diarias:** Permitir a los usuarios registrar información general de las actividades pesqueras por día y zona.
- **Registro de Frecuencias de Tallas:** Permitir a los usuarios registrar las frecuencias de tallas de las especies capturadas por faena.
- **Verificación de Datos:** Validar la consistencia de los datos ingresados, identificar datos atípicos, y permitir la corrección de registros.
- **Gestión de Tablas de Referencia:** Proporcionar una interfaz para gestionar tablas de referencia (como sitios de desembarque, embarcaciones, especies, etc.).
- **Soporte Multi-Usuario:** Permitir que múltiples usuarios ingresen datos simultáneamente.
- **Funcionalidad Offline (Futuro):** Implementar una versión offline para usuarios sin acceso permanente a internet.
- **Autenticación (Futuro):** Añadir autenticación por niveles de acceso.

## Cómo será el aplicativo

El aplicativo FISHSAP está organizado en módulos principales, cada uno con submódulos específicos que abordan diferentes aspectos de la gestión de datos de pesca. A continuación, se detalla la estructura actual del aplicativo:

- **Tablas de Referencia:**  
  Este módulo permite la gestión de las tablas de referencia necesarias para el funcionamiento del sistema. Los submódulos (tablas) incluyen:  
  - **Sitios:** Gestión de sitios de desembarque. *(Implementado)*  
  - **Especies:** Gestión de especies capturadas, incluyendo nombres comunes y científicos, constantes para cálculos, y clasificaciones. *(Implementado)*  
  - **Estados:** Gestión de estados de las capturas (por ejemplo, fresco, congelado). *(Implementado)*  
  - **Clasifica:** Gestión de clasificaciones de especies. *(Implementado)*  
  - **Grupos:** Gestión de grupos de especies. *(Implementado)*  
  - **Subgrupo:** Gestión de subgrupos de especies. *(Implementado)*  
  - **Arte:** Gestión de artes de pesca. *(Implementado)*  
  - **Método:** Gestión de métodos de pesca. *(Implementado)*  
  - **Propulsión:** Gestión de tipos de propulsión de embarcaciones. *(Implementado)*  
  - **Área:** Gestión de áreas de pesca. *(Implementado)*  
  - **Subárea:** Gestión de subáreas de pesca. *(Implementado)*  
  - **Registrador:** Gestión de registradores (personal encargado de registrar datos). *(Implementado)*  
  - **Embarcaciones:** Gestión de embarcaciones utilizadas. *(Implementado)*  
  - **Gastos:** Gestión de tipos de gastos operativos. *(Implementado)*  
  - **Valor Mensual Gastos:** Gestión de valores mensuales de los gastos. *(Implementado)*  
  - **TRM Dólar:** Gestión de la tasa de cambio del dólar. *(Implementado)*  
  - **Clases Medida:** Gestión de clases de medida para tallas de especies. *(Implementado)*  
  - **Nombre Pescador:** Gestión de nombres de los pescadores. *(Implementado)*  

- **Ingreso de Datos:**  
  Este módulo permite a los usuarios registrar datos operativos relacionados con las actividades pesqueras. Incluye los siguientes submódulos:  
  - **Captura y Esfuerzo:** Registro de faenas de pesca, incluyendo detalles de captura (especies, cantidades, pesos) y costos operativos. *(Implementado)*  
  - **Actividad Diaria:** Registro de actividades diarias por zona, incluyendo número de embarcaciones activas y muestreadas, registrador, arte de pesca, y observaciones. *(Implementado)*  
  - **Frecuencia de Tallas:** Registro de la frecuencia de tallas de las especies capturadas por faena. *(Implementado)*  
  - **Precios Comerciales:** Registro de precios por unidad y valor total de las especies capturadas por faena. *(Pendiente)*  

- **Verificación de Datos:**  
  Este módulo se enfoca en la validación y limpieza de los datos ingresados. Incluye:  
  - **Verificación de Registros y Faenas:** Validación de la consistencia entre el número de registros y las faenas activas. *(Implementado)*  
  - **Capturas Desproporcionadas:** Identificación de capturas con cantidades inusualmente altas (Indv > 1000 o Peso > 5000 kg), con opción de edición. *(Implementado)*  
  - **Tallas Desproporcionadas:** Identificación de tallas fuera de rangos esperados (por ejemplo, 5-100 cm para Bonito). *(Implementado)*  
  - **Faenas Muy Largas:** Identificación de faenas con duraciones mayores a 30 días. *(Implementado)*  
  - **Depuración de la Base de Datos:** Herramientas para corregir o eliminar datos erróneos, con registro de las modificaciones realizadas. *(Pendiente)*  

- **Procesamiento de Datos:**  
  Este módulo se encargará del análisis de los datos ingresados. Incluye:  
  - **Estadísticas:** Generación de estadísticas descriptivas (por ejemplo, capturas promedio por especie, por zona, o por fecha). *(Pendiente)*  
  - **Estimaciones:** Cálculo de estimaciones basadas en los datos (por ejemplo, biomasa estimada, esfuerzo pesquero). *(Pendiente)*  
  - **Análisis de la Información:** Herramientas para análisis más avanzados, como tendencias temporales o comparaciones entre zonas. *(Pendiente)*  

- **Informes:**  
  Este módulo permitirá generar y descargar reportes basados en los datos procesados. Incluye:  
  - **Informes y Reportes de la Información:** Generación de reportes estándar (por ejemplo, capturas por mes, costos operativos por faena). *(Pendiente)*  
  - **Descarga de Información:** Exportación de datos en formatos como CSV, Excel, o PDF para uso externo. *(Pendiente)*  

- **Utilidades del Sistema:**  
  Este módulo proporcionará herramientas administrativas para la gestión del sistema. Incluye:  
  - **Creación y Administración de Usuarios:** Gestión de usuarios del sistema (creación, edición, eliminación). *(Pendiente)*  
  - **Creación de Roles:** Definición de roles y permisos (por ejemplo, administrador, usuario regular). *(Pendiente)*  
  - **Backup de la Base de Datos:** Herramientas para realizar copias de seguridad automáticas o manuales de la base de datos. *(Pendiente)*  
  - **Manual de Aplicación:** Documentación integrada con instrucciones de uso y guías para los usuarios. *(Pendiente)*  

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
- ├── ingreso_datos/        <- Submódulo para ingreso de datos.  
  - ├── captura_esfuerzo_ui.R    <- UI para Captura y Esfuerzo.  
  - ├── captura_esfuerzo_server.R  <- Server para Captura y Esfuerzo.  
  - ├── actividad_diaria_ui.R     <- UI para Actividad Diaria.  
  - ├── actividad_diaria_server.R <- Server para Actividad Diaria.  
  - ├── frecuencia_tallas_ui.R    <- UI para Frecuencia de Tallas. *(Nuevo)*  
  - ├── frecuencia_tallas_server.R  <- Server para Frecuencia de Tallas. *(Nuevo)*  
- ├── verificacion/         <- Submódulo para verificación de datos. *(Nuevo)*  
  - ├── verificacion_datos_ui.R    <- UI principal para Verificación de Datos.  
  - ├── verificacion_datos_server.R  <- Server principal para Verificación de Datos.  
  - ├── verificacion_registros_faenas_ui.R    <- UI para Verificación de Registros y Faenas.  
  - ├── verificacion_registros_faenas_server.R  <- Server para Verificación de Registros y Faenas.  
  - ├── verificacion_capturas_desproporcionadas_ui.R    <- UI para Capturas Desproporcionadas.  
  - ├── verificacion_capturas_desproporcionadas_server.R  <- Server para Capturas Desproporcionadas.  
  - ├── verificacion_tallas_desproporcionadas_ui.R    <- UI para Tallas Desproporcionadas.  
  - ├── verificacion_tallas_desproporcionadas_server.R  <- Server para Tallas Desproporcionadas.  
  - ├── verificacion_faenas_largas_ui.R    <- UI para Faenas Muy Largas.  
  - ├── verificacion_faenas_largas_server.R  <- Server para Faenas Muy Largas.  

La aplicación se conecta a una base de datos PostgreSQL (en Neon, en este caso, pero configurable) para almacenar los datos. Actualmente, la aplicación funciona en modo *conectado*, requiriendo una conexión activa a la base de datos. Está *preparada* para una futura implementación de funcionalidad offline (usando IndexedDB), pero esa funcionalidad *no* está implementada en este momento.

### Descripción de los Archivos

- **`global.R`:**
  - Configura las librerías necesarias (`shiny`, `shinydashboard`, `DT`, `RPostgres`, `DBI`, `pool`, `jsonlite`, `shinyTime`, `dplyr`, `bslib`, `openxlsx`).
  - Establece la conexión a la base de datos PostgreSQL usando `dbPool`.
  - Carga los scripts de utilidad (`utils/db_setup.R`, `utils/server_utils.R`).
  - Crea las tablas en la base de datos usando `setup_databases(pool)`.
  - Define las opciones para las listas desplegables de los módulos "Captura y Esfuerzo", "Actividad Diaria", y "Frecuencia de Tallas" (como `sitio_desembarque_choices`, `registrador_choices`, `arte_pesca_choices`, `faena_choices`, etc.).
  - Carga los módulos de la aplicación.

- **`ui.R`:**
  - Define la interfaz de usuario principal usando `shinydashboard`.
  - Incluye un `dashboardHeader`, `dashboardSidebar`, y `dashboardBody`.
  - Organiza las pestañas para "Tablas de Referencia", "Ingreso de Datos", y "Verificación de Datos".

- **`server.R`:**
  - Define la lógica del servidor principal.
  - Llama a los servidores de los módulos (`ref_tables_server`, `captura_esfuerzo_server`, `actividad_diaria_server`, `frecuencia_tallas_server`, `verificacion_datos_server`).
  - Define un valor reactivo temporal `usuario` para simular autenticación (`usuario <- reactiveVal("admin")`).

- **`www/styles.css`:**
  - Contiene estilos personalizados para la aplicación (por ejemplo, ajustes de diseño para `shinydashboard`).

- **`utils/db_setup.R`:**
  - Script para crear las tablas en la base de datos PostgreSQL.
  - Define las tablas principales (`faena_principal`, `detalles_captura`, `costos_operacion`, `actividades_diarias`, `frecuencia_tallas`, etc.) y las tablas de referencia (`sitios`, `subgrupo`, `registrador`, etc.).
  - Incluye claves foráneas para mantener la integridad relacional.

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
  - Contiene una tabla que muestra los registros de actividades diarias y botones para "Nuevo", "Guardar", "Modificar", "Borrar", y "Exportar".

- **`modules/ingreso_datos/actividad_diaria_server.R`:**
  - Define la lógica del servidor para el módulo "Actividad Diaria".
  - Maneja la carga de actividades diarias, la adición de nuevos registros, y las operaciones "Nuevo", "Guardar", "Modificar", "Borrar", y "Exportar".
  - Incluye validaciones para los campos obligatorios y para asegurar que el número de embarcaciones muestreadas no exceda el número de embarcaciones activas.
  - Usa un valor reactivo `usuario` para llenar las columnas `creado_por` y `modificado_por` (actualmente configurado como `"admin"` de manera temporal).

- **`modules/ingreso_datos/frecuencia_tallas_ui.R`:**
  - Define la interfaz de usuario para el módulo "Frecuencia de Tallas".
  - Incluye un formulario para registrar frecuencias de tallas por faena, con campos para faena, especie, tipo de medida, talla, y frecuencia.
  - Contiene una tabla que muestra los registros de frecuencias de tallas y botones para "Guardar", "Modificar", "Borrar", y "Exportar".

- **`modules/ingreso_datos/frecuencia_tallas_server.R`:**
  - Define la lógica del servidor para el módulo "Frecuencia de Tallas".
  - Maneja la carga de frecuencias de tallas, la adición de nuevos registros, y las operaciones "Guardar", "Modificar", "Borrar", y "Exportar".
  - Usa un valor reactivo `usuario` para llenar las columnas `creado_por` y `modificado_por`.

- **`modules/verificacion/verificacion_datos_ui.R`:**
  - Define la interfaz de usuario principal para el módulo "Verificación de Datos".
  - Utiliza un `tabsetPanel` para organizar los submódulos en pestañas: "Registros vs. Faenas Activas", "Capturas Desproporcionadas", "Tallas Desproporcionadas", y "Faenas Muy Largas".
  - Incluye un botón "Consultar Datos" para optimizar la carga de datos.

- **`modules/verificacion/verificacion_datos_server.R`:**
  - Define la lógica del servidor principal para el módulo "Verificación de Datos".
  - Inicializa los servidores de los submódulos solo después de que el usuario haga clic en "Consultar Datos".

- **`modules/verificacion/verificacion_registros_faenas_ui.R`:**
  - Define la interfaz de usuario para el submódulo "Verificación de Registros y Faenas".
  - Muestra una tabla con la consistencia entre registros y faenas activas, y un botón para descargar un reporte en Excel.

- **`modules/verificacion/verificacion_registros_faenas_server.R`:**
  - Define la lógica del servidor para el submódulo "Verificación de Registros y Faenas".
  - Compara el número de registros en `detalles_captura` con el número de faenas activas en `faena_principal`.

- **`modules/verificacion/verificacion_capturas_desproporcionadas_ui.R`:**
  - Define la interfaz de usuario para el submódulo "Capturas Desproporcionadas".
  - Muestra una tabla con capturas inusualmente altas (Indv > 1000 o Peso > 5000 kg), y un botón para descargar un reporte en Excel.

- **`modules/verificacion/verificacion_capturas_desproporcionadas_server.R`:**
  - Define la lógica del servidor para el submódulo "Capturas Desproporcionadas".
  - Permite editar registros directamente desde la tabla y descargar un reporte en Excel.

- **`modules/verificacion/verificacion_tallas_desproporcionadas_ui.R`:**
  - Define la interfaz de usuario para el submódulo "Tallas Desproporcionadas".
  - Muestra una tabla con tallas fuera de rangos esperados, y un botón para descargar un reporte en Excel.

- **`modules/verificacion/verificacion_tallas_desproporcionadas_server.R`:**
  - Define la lógica del servidor para el submódulo "Tallas Desproporcionadas".
  - Identifica tallas fuera de rangos predefinidos (por ejemplo, 5-100 cm para Bonito).

- **`modules/verificacion/verificacion_faenas_largas_ui.R`:**
  - Define la interfaz de usuario para el submódulo "Faenas Muy Largas".
  - Muestra una tabla con faenas de duración mayor a 30 días, y un botón para descargar un reporte en Excel.

- **`modules/verificacion/verificacion_faenas_largas_server.R`:**
  - Define la lógica del servidor para el submódulo "Faenas Muy Largas".
  - Calcula la duración de las faenas y filtra las que superan los 30 días.

## Módulo de Actividad Diaria

El módulo de Actividad Diaria permite registrar información general de las actividades pesqueras en una zona específica para una fecha determinada. Este módulo está completamente implementado y funcional, incluyendo las operaciones de "Guardar", "Modificar", "Borrar", y "Exportar".

### Campos del formulario:

- **Fecha**: Fecha en que se realizó el registro de actividad (tipo `dateInput`).
- **Registrador**: Personal encargado del registro (seleccionado de la lista de registradores autorizados, tabla `registrador`).
- **Arte de pesca**: Método utilizado para la captura (seleccionado de la lista de artes de pesca, tabla `arte`).
- **Zona de desembarco**: Lugar donde se realiza el desembarco (seleccionado de la lista de sitios, tabla `sitios`).
- **Número de embarcaciones activas**: Cantidad total de embarcaciones operando en la zona ese día (tipo `numericInput`).
- **Número de embarcaciones muestreadas**: Cantidad de embarcaciones que fueron incluidas en el muestreo (tipo `numericInput`).
- **Observaciones**: Notas adicionales sobre la actividad (tipo `textAreaInput`).

### Cómo usar el módulo:

1. **Ingresar datos**: Complete todos los campos requeridos en el formulario.
2. **Guardar registro**: Haga clic en el botón "Guardar Actividad" para almacenar la información.
3. **Modificar registro**: Seleccione un registro de la tabla, haga clic en "Modificar", edite los campos y guarde los cambios.
4. **Borrar registro**: Seleccione un registro de la tabla, haga clic en "Borrar", y confirme la eliminación.
5. **Exportar datos**: Haga clic en "Exportar" para descargar los registros en formato CSV.
6. **Ver registros existentes**: La tabla en la parte derecha muestra los registros previamente guardados, con columnas para ID, Fecha, Registrador, Arte de Pesca, Zona de Desembarco, Embarcaciones Activas, Embarcaciones Muestreadas, y Observaciones.

### Consideraciones importantes:

- El número de embarcaciones muestreadas no puede ser mayor que el número de embarcaciones activas (validación implementada).
- Los campos numéricos (embarcaciones activas y muestreadas) no pueden ser negativos (validación implementada).
- Se recomienda completar el campo de observaciones con información relevante sobre condiciones climáticas, eventos inusuales u otros factores que puedan afectar la actividad pesquera.
- Los registros se sincronizan automáticamente con la base de datos central cuando hay conexión a internet.
- Actualmente, las columnas `creado_por` y `modificado_por` se llenan con el valor `"admin"` debido a una solución temporal para la autenticación. Esto será reemplazado por un sistema de autenticación en el futuro.

## Módulo de Frecuencia de Tallas

El módulo de Frecuencia de Tallas permite registrar las frecuencias de tallas de las especies capturadas por faena. Este módulo está completamente implementado y funcional, incluyendo las operaciones de "Guardar", "Modificar", "Borrar", y "Exportar".

### Campos del formulario:

- **Faena**: Faena asociada al registro (seleccionada de la lista de faenas, tabla `faena_principal`).
- **Especie**: Especie capturada (seleccionada de la lista de especies, tabla `especies`).
- **Tipo de Medida**: Tipo de medida utilizada (por ejemplo, "Longitud Total", "Longitud Furcal").
- **Talla**: Talla medida en cm (tipo `numericInput`).
- **Frecuencia**: Número de individuos con esa talla (tipo `numericInput`).

### Cómo usar el módulo:

1. **Seleccionar faena**: Elija una faena de la lista desplegable.
2. **Ingresar datos**: Complete los campos de especie, tipo de medida, talla, y frecuencia.
3. **Guardar registro**: Haga clic en el botón "Guardar" para almacenar la información.
4. **Modificar registro**: Seleccione un registro de la tabla, edite los campos y guarde los cambios.
5. **Borrar registro**: Seleccione un registro de la tabla y elimínelo.
6. **Exportar datos**: Haga clic en "Exportar" para descargar los registros en formato CSV.
7. **Ver registros existentes**: La tabla muestra los registros de frecuencias de tallas, con columnas para ID, Faena, Especie, Tipo de Medida, Talla, y Frecuencia.

## Módulo de Verificación de Datos

El módulo de Verificación de Datos permite validar la consistencia de los datos ingresados, identificar datos atípicos, y corregir registros. Este módulo está implementado con los siguientes submódulos:

- **Verificación de Registros y Faenas:** Compara el número de registros en `detalles_captura` con el número de faenas activas en `faena_principal`.
- **Capturas Desproporcionadas:** Identifica capturas con cantidades inusualmente altas (Indv > 1000 o Peso > 5000 kg), con opción de edición.
- **Tallas Desproporcionadas:** Identifica tallas fuera de rangos esperados (por ejemplo, 5-100 cm para Bonito).
- **Faenas Muy Largas:** Identifica faenas con duraciones mayores a 30 días.

### Cómo usar el módulo:

1. **Consultar datos**: Haga clic en el botón "Consultar Datos" para cargar los datos de verificación.
2. **Navegar entre pestañas**: Use las pestañas para ver los diferentes tipos de verificaciones.
3. **Editar registros (Capturas Desproporcionadas)**: Haga clic en un registro en la tabla de "Capturas Desproporcionadas" para editar los valores de Indv y Peso.
4. **Descargar reportes**: Haga clic en "Descargar Reporte en Excel" en cada pestaña para exportar los datos.

### Consideraciones importantes:

- Las consultas se ejecutan solo después de hacer clic en "Consultar Datos", optimizando el uso de recursos.
- Los rangos para "Tallas Desproporcionadas" están predefinidos en el código y pueden ajustarse según las necesidades.
- Actualmente, solo "Capturas Desproporcionadas" permite edición; los otros submódulos son de solo lectura.

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
     install.packages(c("shiny", "shinydashboard", "DT", "RPostgres", "DBI", "pool", "jsonlite", "shinyTime", "dplyr", "bslib", "openxlsx"))
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

     subarea <- dbGetQuery(pool, "SELECT CODSUBARE, NOMSUBARE FROM subarea")
     subarea_choices <- setNames(subarea$CODSUBARE, subarea$NOMSUBARE)

     registradores <- dbGetQuery(pool, "SELECT CODREG, NOMREG FROM registrador")
     registrador_choices <- setNames(registradores$CODREG, registradores$NOMREG)

     pescadores <- dbGetQuery(pool, "SELECT CODPES, NOMPES FROM nombre_pescador")
     pescadores_choices <- setNames(pescadores$CODPES, pescadores$NOMPES)

     embarcaciones <- dbGetQuery(pool, "SELECT CODEMB, NOMEMB FROM embarcaciones")
     embarcacion_choices <- setNames(embarcaciones$CODEMB, embarcaciones$NOMEMB)

     artes_pesca <- dbGetQuery(pool, "SELECT CODART, NOMART FROM arte")
     arte_pesca_choices <- setNames(artes_pesca$CODART, artes_pesca$NOMART)

     metodos_pesca <- dbGetQuery(pool, "SELECT CODMET, NOMMET FROM metodo")
     metodo_pesca_choices <- setNames(metodos_pesca$CODMET, metodos_pesca$NOMMET)

     especies <- dbGetQuery(pool, "SELECT CODESP, Nombre_Comun FROM especies")
     especie_choices <- setNames(especies$CODESP, especies$Nombre_Comun)

     estados <- dbGetQuery(pool, "SELECT CODEST, NOMEST FROM estados")
     estado_choices <- setNames(estados$CODEST, estados$NOMEST)

     gastos <- dbGetQuery(pool, "SELECT CODGAS, NOMGAS FROM gastos")
     gasto_choices <- setNames(gastos$CODGAS, gastos$NOMGAS)

     faenas <- dbGetQuery(pool, "SELECT id, registro FROM faena_principal ORDER BY fecha_zarpe DESC")
     faena_choices <- setNames(faenas$id, paste("Faena", faenas$id, "-", faenas$registro))
     ```
   - Estas variables (`sitio_desembarque_choices`, `subarea_choices`, etc.) están disponibles globalmente y contienen las opciones para las listas desplegables.

2. **Definición de las listas desplegables en `captura_esfuerzo_ui.R`:**  
   - En `captura_esfuerzo_ui.R`, se definieron las listas desplegables usando `selectInput`, inicializándolas con un valor predeterminado de "Cargando...". Las opciones reales se actualizan dinámicamente en `captura_esfuerzo_server.R` usando las variables definidas en `global.R`:
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

3. **Actualización dinámica en `captura_esfuerzo_server.R`:**  
   - En `captura_esfuerzo_server.R`, se actualizan las opciones de las listas desplegables al iniciar el módulo, usando las variables definidas en `global.R`:
     ```R
     observeEvent(session$clientData, {
       updateSelectInput(session, "sitio_desembarque", choices = sitio_desembarque_choices)
       updateSelectInput(session, "subarea", choices = subarea_choices)
       updateSelectInput(session, "registrador", choices = registrador_choices)
       updateSelectInput(session, "pescadores", choices = pescadores_choices)
       updateSelectInput(session, "embarcacion", choices = embarcacion_choices)
       updateSelectInput(session, "arte_pesca", choices = arte_pesca_choices)
       updateSelectInput(session, "metodo_pesca", choices = metodo_pesca_choices)
       updateSelectInput(session, "especie", choices = especie_choices)
       updateSelectInput(session, "estado", choices = estado_choices)
       updateSelectInput(session, "gasto", choices = gasto_choices)
     }, once = TRUE)
     ```

4. **Validaciones en `captura_esfuerzo_server.R`:**  
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
- **Centralizar las opciones:** Si otros módulos necesitan listas desplegables similares (por ejemplo, un módulo de "Verificación de Datos" o "Informes"), las opciones ya están cargadas en `global.R` y pueden ser reutilizadas.
- **Validaciones consistentes:** Aplica validaciones similares en otros módulos para asegurar que los campos obligatorios de las listas desplegables no estén vacíos.
- **Optimización (opcional):** Para evitar cargar los datos repetidamente, las opciones ya están agrupadas en variables globales en `global.R`. Esto es eficiente y puede ser reutilizado por otros módulos.
- **Actualización dinámica (opcional):** Si las tablas de referencia cambian (por ejemplo, si se añade un nuevo sitio de desembarque), podrías implementar un mecanismo para recargar las opciones de las listas desplegables dinámicamente (por ejemplo, con un botón "Actualizar opciones").

**Archivos relacionados:**  
- `global.R`: Carga de las opciones para las listas desplegables (`sitio_desembarque_choices`, `subarea_choices`, etc.).  
- `captura_esfuerzo_ui.R`: Definición de las listas desplegables con valores iniciales de "Cargando...".  
- `captura_esfuerzo_server.R`: Actualización dinámica de las listas y validaciones de los campos obligatorios.

### Solución al problema de guardar registros en el módulo "Actividad Diaria"

**Problema:**  
En el módulo "Actividad Diaria" (`actividad_diaria_server.R`), al intentar guardar un registro, se producían errores relacionados con la estructura de la tabla `actividades_diarias` and la falta de definición del usuario para las columnas de trazabilidad (`creado_por` y `modificado_por`). Los errores específicos fueron:

1. **Inconsistencia en la estructura de la tabla:** La tabla `actividades_diarias` se estaba creando en dos lugares (`global.R` y `db_setup.R`), lo que causaba discrepancias en los nombres de las columnas (por ejemplo, `registrador` vs. `registrador_id`).
2. **Error al guardar: "no se pudo encontrar la función 'usuario'":** El módulo intentaba usar un valor reactivo `usuario()` para llenar las columnas `creado_por` y `modificado_por`, pero `usuario` no estaba definido, ya que no se había implementado un sistema de autenticación.

**Solución:**  
Se realizaron los siguientes pasos para resolver el problema:

1. **Centralización de la creación de tablas en `db_setup.R`:**  
   - Se eliminó la creación directa de la tabla `actividades_diarias` en `global.R`, dejando que `db_setup.R` se encargue de crear todas las tablas de manera consistente.
   - La estructura de la tabla `actividades_diarias` en `db_setup.R` se mantuvo como estaba, asegurando que incluya las columnas de trazabilidad (`creado_por`, `modificado_por`, `fecha_creacion`, `fecha_modificacion`, `sincronizado`) y las claves foráneas (`registrador_id`, `arte_pesca_id`, `zona_desembarco_id`):
     ```sql
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
       CONSTRAINT fk_registrador_act FOREIGN KEY (registrador_id) REFERENCES registrador (CODREG) ON DELETE RESTRICT,
       CONSTRAINT fk_arte_pesca_act FOREIGN KEY (arte_pesca_id) REFERENCES arte (CODART) ON DELETE RESTRICT,
       CONSTRAINT fk_zona_desembarco_act FOREIGN KEY (zona_desembarco_id) REFERENCES sitios (CODSIT) ON DELETE RESTRICT
     )
     ```

2. **Ajuste de `actividad_diaria_server.R` para la estructura correcta:**  
   - Se modificó `actividad_diaria_server.R` para usar los nombres de columnas correctos (`registrador_id`, `arte_pesca_id`, `zona_desembarco_id`, `num_embarcaciones_activas`, `num_embarcaciones_muestreadas`, etc.) en las consultas SQL.
   - Se aseguraron las operaciones de "Guardar", "Modificar", "Borrar", y "Exportar", incluyendo validaciones para los campos obligatorios y las restricciones del número de embarcaciones.

3. **Definición temporal de `usuario` en `server.R`:**  
   - Dado que no se ha implementado un sistema de autenticación, se definió un valor reactivo temporal `usuario` en `server.R`:
     ```R
     usuario <- reactiveVal("admin")  # Valor fijo para pruebas
     ```
   - Este valor se pasa al módulo `actividad_diaria_server` para llenar las columnas `creado_por` y `modificado_por`:
     ```R
     actividad_diaria_server("actividad_diaria", pool, usuario)
     ```
   - En `actividad_diaria_server.R`, se evalúa `usuario()` antes de incluirlo en las consultas SQL, con un valor predeterminado de `"desconocido"` si no está definido:
     ```R
     usuario_actual <- usuario()
     if (is.null(usuario_actual) || usuario_actual == "") {
       usuario_actual <- "desconocido"
       message("Advertencia: usuario() no está definido, usando 'desconocido' como valor predeterminado.")
     }
     ```

4. **Prueba exitosa:**  
   - Con estos cambios, la funcionalidad de guardar registros en el módulo "Actividad Diaria" ahora funciona correctamente. Los registros se guardan en la tabla `actividades_diarias`, y las columnas `creado_por` y `modificado_por` se llenan con el valor `"admin"`.

**Recomendaciones:**  
- **Implementar autenticación:** La solución actual usa un valor temporal (`"admin"`) para `usuario`. Se recomienda implementar un sistema de autenticación (por ejemplo, con `shinymanager`) antes de desplegar la aplicación en un entorno multiusuario, para garantizar una trazabilidad precisa.
- **Revisar otros módulos:** Asegúrate de que otros módulos que usen columnas de trazabilidad (`creado_por`, `modificado_por`) también reciban el valor `usuario`. Por ejemplo, `captura_esfuerzo_server` y `frecuencia_tallas_server` ya están ajustados:
  ```R
  captura_esfuerzo_server("captura_esfuerzo", pool, usuario)
  frecuencia_tallas_server("frecuencia_tallas", pool, usuario)
  ```

- **Validar claves foráneas:**Asegúrate de que las tablas registrador, arte, y sitios tengan datos válidos, ya que actividades_diarias depende de estas tablas a través de claves foráneas.

**Archivos relacionados:**
- global.R: Eliminación de la creación directa de la tabla actividades_diarias.  
- db_setup.R: Definición de la tabla actividades_diarias.  
- server.R: Definición temporal de usuario y ajuste en la llamada a actividad_diaria_server.  
- actividad_diaria_server.R: Ajustes en las consultas SQL y manejo de usuario.


## Tareas Pendientes

1. **Errores de `bootstrap-datepicker`:**
   - Resolver las deprecaciones de idioma en `bootstrap-datepicker`.
   - Corregir el error del valor "NA" no válido al usar `dateInput`.

2. **Funcionalidades "Modificar" y "Borrar" en Tablas de Referencia:**
   - Implementar las funcionalidades "Modificar" y "Borrar" en `ref_tables_server.R`.

3. **Agregar las Demás Secciones:**
   - Completar el módulo "Ingreso de Datos" diseñando los submódulos "Frecuencia de Tallas" y "Precios".
   - Crear los módulos para "Verificación de Datos", "Procesamiento de Datos", "Informes", y "Utilidades del Sistema".

4. **Funcionalidad Offline (Opcional):**
   - Diseñar e implementar una solución para permitir el ingreso de datos offline (por ejemplo, usando IndexedDB y sincronización manual).

5. **Autenticación por Niveles de Acceso:**
   - Implementar autenticación usando un paquete como `shinymanager`.
   - Definir roles (por ejemplo, administrador y usuario regular) y restringir el acceso a ciertas funcionalidades.
   - Crear una tabla `usuarios` en la base de datos para almacenar credenciales (con contraseñas hasheadas).

## Notas Adicionales

- **Base de Datos:** La aplicación está configurada para usar PostgreSQL alojado en Neon. Asegúrate de que las variables de entorno estén correctamente configuradas para tu entorno.
- **Escalabilidad:** La aplicación soporta múltiples usuarios simultáneamente gracias al uso de `pool` y transacciones en PostgreSQL. Sin embargo, para un gran número de usuarios, considera usar Shiny Server Pro o RStudio Connect.
- **Despliegue:** La aplicación puede desplegarse en shinyapps.io con ajustes mínimos (configuración de variables de entorno y conexión a la base de datos).
- **Autenticación Temporal:** Actualmente, se usa un valor temporal `usuario <- reactive("admin")` para las columnas de trazabilidad. Esto debe ser reemplazado por un sistema de autenticación antes de usar la aplicación en un entorno multiusuario.

## Próximos Pasos (Después de que la Aplicación Funcione):

1. **Revisar el buen funcionamiento de las tablas de referencias:**
   - Verificar que el botón "Guardar" funcione correctamente en cada tabla de referencia.
   - Comprobar el despliegue adecuado de las diferentes opciones en la tabla de especie comercial.
   - Crear una tabla de referencia que se llame "Nombre del pescador" (ya implementada, pero verificar su funcionalidad).

2. **Completar el módulo "Ingreso de Datos":**
   - Diseñar e implementar los submódulos "Frecuencia de Tallas" y "Precios".

3. **Implementar los módulos pendientes:**
   - Implementar el módulo "Procesamiento de Datos" para estadísticas, estimaciones, y análisis de la información.
   - Desarrollar el módulo "Informes" para generar reportes estándar y personalizados, y permitir la descarga de información.
   - Añadir el módulo "Utilidades del Sistema" para la creación y administración de usuarios, creación de roles, backup de la base de datos, y manual de aplicación.

4. **Mejoras de Interfaz de Usuario:**
   - Optimizar la interfaz para dispositivos móviles.
   - Agregar mensajes informativos y ayudas contextuales.
   - Implementar la traducción completa de la aplicación (multilenguaje).

5. **Optimización de Base de Datos:**
   - Revisar los índices y restricciones de integridad.
   - Implementar rutinas de mantenimiento y backup automáticos.
   - Optimizar consultas para mejorar el rendimiento.

6. **Implementación de Funcionalidades Avanzadas:**
   - Integración con sistemas GIS para visualización de datos espaciales.
   - Capacidades de exportación de datos en múltiples formatos.
   - Implementación de algoritmos de análisis estadístico avanzado.

## Contacto y Soporte

Para reportar problemas, solicitar nuevas características o obtener soporte técnico para la aplicación FISHSAP, contacta a:

- **Soporte Técnico:** soporte@fishsap.org
- **Administrador del Sistema:** admin@fishsap.org
- **Desarrollador Principal:** developer@fishsap.org

O visita nuestro repositorio en GitHub: [github.com/fishsap/fishsap-app](https://github.com/fishsap/fishsap-app)

## Licencia

FISHSAP es una aplicación de código abierto distribuida bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.

---

**Última actualización:** 04 de abril de 2025

*Este documento es parte del proyecto FISHSAP y está sujeto a actualizaciones periódicas. Si encuentras información desactualizada, por favor notifícalo al equipo de desarrollo.*
