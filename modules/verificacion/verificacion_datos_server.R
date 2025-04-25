# modules/verificacion/verificacion_datos_server.R

verificacion_datos_server <- function(id, conn) {
  moduleServer(id, function(input, output, session) {
    verificacion_registros_faenas_server("registros_faenas", conn)
    verificacion_capturas_desproporcionadas_server("capturas_desproporcionadas", conn)
    verificacion_tallas_desproporcionadas_server("tallas_desproporcionadas", conn)
    verificacion_faenas_largas_server("faenas_largas", conn)
  })
}