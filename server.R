server <- function(input, output, session) {
  # Llamada al servidor del módulo de tablas de referencia
  ref_tables_server("ref_tables", central_conn)
  
  # Llamada al servidor del módulo de ingreso de datos de faena principal
  ingreso_datos_faena_server("ingreso_datos_faena", central_conn)
  
  # Observador para actualizar la tabla de referencia seleccionada
  observeEvent(input$sidebar, {
    selected_tab <- input$sidebar
    session$userData$current_ref_table <- selected_tab
    print(paste("Valor de input$sidebar:", selected_tab)) # Para depuración
    print(paste("Valor de session$userData$current_ref_table DESPUÉS de actualizar:", session$userData$current_ref_table)) # Para depuración
  })
  
  # Puedes añadir más lógica del servidor aquí para otros módulos o funcionalidades
}