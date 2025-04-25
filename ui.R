# ui.R

library(shiny)
library(shinydashboard)
library(bslib)

ui <- dashboardPage(
  dashboardHeader(title = "FISHSAP"),
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      menuItem("Inicio", tabName = "inicio", icon = icon("home"), selected = TRUE),
      menuItem("Tablas de Referencia", tabName = "tablas_referencia", icon = icon("table"),
               menuSubItem("Sitios de Desembarque", tabName = "sitios"),
               menuSubItem("Especies Comerciales", tabName = "especies"),
               menuSubItem("Categorías de Estado", tabName = "estados"),
               menuSubItem("Clasificación", tabName = "clasifica"),
               menuSubItem("Grupos", tabName = "grupos"),
               menuSubItem("Subgrupo", tabName = "subgrupo"),
               menuSubItem("Arte de Pesca", tabName = "arte"),
               menuSubItem("Método de Pesca", tabName = "metodo"),
               menuSubItem("Propulsión", tabName = "propulsion"),
               menuSubItem("Área de Pesca", tabName = "area"),
               menuSubItem("Subárea de Pesca", tabName = "subarea"),
               menuSubItem("Registrador de Campo", tabName = "registrador"),
               menuSubItem("Embarcaciones", tabName = "embarcaciones"),
               menuSubItem("Gastos", tabName = "gastos"),
               menuSubItem("Valor Mensual Gastos", tabName = "valor_mensual_gastos"),
               menuSubItem("TRM Dólar", tabName = "trm_dolar"),
               menuSubItem("Clases de Medida", tabName = "clases_medida"),
               menuSubItem("Nombre del Pescador", tabName = "nombre_pescador")
      ),
      menuItem("Ingreso de Datos", tabName = "principal", icon = icon("edit"),
               menuSubItem("Captura y Esfuerzo", tabName = "captura_esfuerzo"),
               menuSubItem("Actividad Diaria", tabName = "actividad_diaria"),
               menuSubItem("Frecuencia de Tallas", tabName = "frecuencia_tallas")
      ),
      menuItem("Verificación de Datos", tabName = "verificacion_datos", icon = icon("check")),
      menuItem("Procesamiento de Datos", tabName = "procesamiento_datos", icon = icon("chart-bar"))
    )
  ),
  dashboardBody(
    includeCSS("www/styles.css"),
    tabItems(
      tabItem(tabName = "inicio",
              h2("Bienvenido a FISHSAP", class = "welcome-title"),
              div(class = "welcome-container",
                  p("FISHSAP es una aplicación diseñada para la captura, almacenamiento y procesamiento de datos de desembarque pesquero en el Archipiélago de San Andrés. Aquí podrás gestionar información clave sobre especies comerciales, sitios de desembarque, y más, de manera eficiente y organizada."),
                  h3("¿Cómo empezar?"),
                  p("Utiliza el menú lateral para navegar entre las diferentes secciones:"),
                  tags$ul(
                    tags$li("Tablas de Referencia: Gestiona los datos maestros como sitios, especies, y categorías."),
                    tags$li("Ingreso de Datos: Registra la información de las faenas pesqueras y actividades diarias."),
                    tags$li("Verificación de Datos: Revisa y corrige posibles inconsistencias en los datos."),
                    tags$li("Procesamiento de Datos: Genera estadísticas y estimaciones basadas en los datos registrados.")
                  ),
                  h3("Acerca de"),
                  p("Desarrollado para apoyar la gestión pesquera sostenible en el Archipiélago de San Andrés. Si tienes preguntas o necesitas soporte, contacta al equipo de desarrollo.")
              )
      ),
      # Tablas de referencia
      tabItem(tabName = "sitios",
              h2("Sitios de Desembarque"),
              ref_tables_ui("ref_tables_sitios", ref_tables_fields)
      ),
      tabItem(tabName = "especies",
              h2("Especies Comerciales"),
              ref_tables_ui("ref_tables_especies", ref_tables_fields)
      ),
      tabItem(tabName = "estados",
              h2("Categorías de Estado"),
              ref_tables_ui("ref_tables_estados", ref_tables_fields)
      ),
      tabItem(tabName = "clasifica",
              h2("Clasificación"),
              ref_tables_ui("ref_tables_clasifica", ref_tables_fields)
      ),
      tabItem(tabName = "grupos",
              h2("Grupos"),
              ref_tables_ui("ref_tables_grupos", ref_tables_fields)
      ),
      tabItem(tabName = "subgrupo",
              h2("Subgrupo"),
              ref_tables_ui("ref_tables_subgrupo", ref_tables_fields)
      ),
      tabItem(tabName = "arte",
              h2("Arte de Pesca"),
              ref_tables_ui("ref_tables_arte", ref_tables_fields)
      ),
      tabItem(tabName = "metodo",
              h2("Método de Pesca"),
              ref_tables_ui("ref_tables_metodo", ref_tables_fields)
      ),
      tabItem(tabName = "propulsion",
              h2("Propulsión"),
              ref_tables_ui("ref_tables_propulsion", ref_tables_fields)
      ),
      tabItem(tabName = "area",
              h2("Área de Pesca"),
              ref_tables_ui("ref_tables_area", ref_tables_fields)
      ),
      tabItem(tabName = "subarea",
              h2("Subárea de Pesca"),
              ref_tables_ui("ref_tables_subarea", ref_tables_fields)
      ),
      tabItem(tabName = "registrador",
              h2("Registrador de Campo"),
              ref_tables_ui("ref_tables_registrador", ref_tables_fields)
      ),
      tabItem(tabName = "embarcaciones",
              h2("Embarcaciones"),
              ref_tables_ui("ref_tables_embarcaciones", ref_tables_fields)
      ),
      tabItem(tabName = "gastos",
              h2("Gastos"),
              ref_tables_ui("ref_tables_gastos", ref_tables_fields)
      ),
      tabItem(tabName = "valor_mensual_gastos",
              h2("Valor Mensual Gastos"),
              ref_tables_ui("ref_tables_valor_mensual_gastos", ref_tables_fields)
      ),
      tabItem(tabName = "trm_dolar",
              h2("TRM Dólar"),
              ref_tables_ui("ref_tables_trm_dolar", ref_tables_fields)
      ),
      tabItem(tabName = "clases_medida",
              h2("Clases de Medida"),
              ref_tables_ui("ref_tables_clases_medida", ref_tables_fields)
      ),
      tabItem(tabName = "nombre_pescador",
              h2("Nombre del Pescador"),
              ref_tables_ui("ref_tables_nombre_pescador", ref_tables_fields)
      ),
      # Módulos de ingreso de datos
      tabItem(tabName = "captura_esfuerzo",
              h2("Captura y Esfuerzo"),
              captura_esfuerzo_ui("captura_esfuerzo")
      ),
      tabItem(tabName = "actividad_diaria",
              h2("Registro de Actividad Diaria"),
              actividad_diaria_ui("actividad_diaria")
      ),
      tabItem(tabName = "frecuencia_tallas",
              h2("Frecuencia de Tallas"),
              frecuencia_tallas_ui("frecuencia_tallas")
      ),
      # Módulo de verificación de datos
      tabItem(tabName = "verificacion_datos",
              h2("Verificación de Datos"),
              verificacion_datos_ui("verificacion_datos")
      ),
      # Módulo de procesamiento de datos
      tabItem(tabName = "procesamiento_datos",
              h2("Procesamiento de Datos"),
              procesamiento_datos_ui("procesamiento_datos")
      )
    )
  )
)