library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "SIPEIN"),
  dashboardSidebar(
    sidebarMenu(id = "sidebar",
                menuItem("Inicio", tabName = "principal", icon = icon("home")),
                menuItem("Tablas de Referencia", icon = icon("table"),
                         menuSubItem("Sitios de Desembarque", tabName = "sitios"),
                         menuSubItem("Especies Comerciales", tabName = "especies"),
                         menuSubItem("Categorias de Estado", tabName = "estados"),
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
                         menuSubItem("Gastos de Faena", tabName = "gastos"),
                         menuSubItem("Valor Mensual Gastos", tabName = "valor_mensual_gastos"),
                         menuSubItem("TRM Dólar", tabName = "trm_dolar")
                ),
                menuItem("Ingreso de Datos", icon = icon("upload"),
                         menuSubItem("Faena Principal", tabName = "faena_principal")
                )
                # Aquí puedes añadir más menuItem si tienes otras secciones
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "inicio",
              h2("Sistema de Información Pesquera - SIPEIN"),
              p("Bienvenido al SIPEIN. Esta aplicación permite gestionar información sobre la actividad pesquera."),
              p("Seleccione una opción en el menú lateral para comenzar.")
      ),
      tabItem(tabName = "sitios",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "especies",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "estados",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "clasifica",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "grupos",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "subgrupo",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "arte",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "metodo",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "propulsion",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "area",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "subarea",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "registrador",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "embarcaciones",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "gastos",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "valor_mensual_gastos",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "trm_dolar",
              ref_tables_ui("ref_tables")
      ),
      tabItem(tabName = "ingreso_faena",
              h2("Ingreso de Datos de Faena Principal"),
              ingreso_datos_faena_ui("ingreso_datos_faena")
      )
    )
  )
)