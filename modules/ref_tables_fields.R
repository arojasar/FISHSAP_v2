# ref_tables_fields.R
ref_tables_fields <- list(
  "sitios" = list(
    fields = list(
      list(id = "codsit", label = "Código", type = "text", required = TRUE),
      list(id = "nomsit", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "especies" = list(
    fields = list(
      list(id = "codesp", label = "Código", type = "text", required = TRUE),
      list(id = "nombre_comun", label = "Nombre Común", type = "text", required = TRUE),
      list(id = "nombre_cientifico", label = "Nombre Científico", type = "text", required = TRUE),
      list(id = "subgrupo_id", label = "Subgrupo", type = "select", ref_table = "subgrupo", value_field = "codsubgru", display_field = "nomsubgru", required = FALSE),
      list(id = "clasificacion_id", label = "Clasificación", type = "select", ref_table = "clasifica", value_field = "codcla", display_field = "nomcla", required = FALSE),
      list(id = "constante_a", label = "Constante A", type = "numeric", required = FALSE),
      list(id = "constante_b", label = "Constante B", type = "numeric", required = FALSE),
      list(id = "clase_medida", label = "Clase de Medida", type = "select", ref_table = "clases_medida", value_field = "codclamed", display_field = "nomclamed", required = TRUE),
      list(id = "clasificacion_comercial", label = "Clasificación Comercial", type = "text", required = FALSE),
      list(id = "grupo", label = "Grupo", type = "select", ref_table = "grupos", value_field = "codgru", display_field = "nomgru", required = FALSE)
    )
  ),
  "estados" = list(
    fields = list(
      list(id = "codest", label = "Código", type = "text", required = TRUE),
      list(id = "nomest", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "clasifica" = list(
    fields = list(
      list(id = "codcla", label = "Código", type = "text", required = TRUE),
      list(id = "nomcla", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "grupos" = list(
    fields = list(
      list(id = "codgru", label = "Código", type = "text", required = TRUE),
      list(id = "nomgru", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "subgrupo" = list(
    fields = list(
      list(id = "codsubgru", label = "Código", type = "text", required = TRUE),
      list(id = "nomsubgru", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "arte" = list(
    fields = list(
      list(id = "codart", label = "Código", type = "text", required = TRUE),
      list(id = "nomart", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "metodo" = list(
    fields = list(
      list(id = "codmet", label = "Código", type = "text", required = TRUE),
      list(id = "nommet", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "propulsion" = list(
    fields = list(
      list(id = "codpro", label = "Código", type = "text", required = TRUE),
      list(id = "nompro", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "area" = list(
    fields = list(
      list(id = "codare", label = "Código", type = "text", required = TRUE),
      list(id = "nomare", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "subarea" = list(
    fields = list(
      list(id = "codsubare", label = "Código", type = "text", required = TRUE),
      list(id = "nomsubare", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "registrador" = list(
    fields = list(
      list(id = "codreg", label = "Código", type = "text", required = TRUE),
      list(id = "nomreg", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "embarcaciones" = list(
    fields = list(
      list(id = "codemb", label = "Código", type = "text", required = TRUE),
      list(id = "nomemb", label = "Nombre", type = "text", required = TRUE),
      list(id = "matricula", label = "Matrícula", type = "text", required = TRUE),
      list(id = "potencia", label = "Potencia", type = "numeric", required = FALSE),
      list(id = "propulsion", label = "Propulsión", type = "text", required = FALSE),
      list(id = "numero_motores", label = "Número de Motores", type = "numeric", required = FALSE)
    )
  ),
  "gastos" = list(
    fields = list(
      list(id = "codgas", label = "Código", type = "text", required = TRUE),
      list(id = "nomgas", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "valor_mensual_gastos" = list(
    fields = list(
      list(id = "gasto_id", label = "Gasto", type = "select", ref_table = "gastos", value_field = "codgas", display_field = "nomgas", required = TRUE),
      list(id = "ano", label = "Año", type = "numeric", required = TRUE),
      list(id = "mes", label = "Mes", type = "numeric", required = TRUE),
      list(id = "valor", label = "Valor", type = "numeric", required = TRUE)
    )
  ),
  "trm_dolar" = list(
    fields = list(
      list(id = "fecha", label = "Fecha", type = "date", required = TRUE),
      list(id = "valor", label = "Valor", type = "numeric", required = TRUE)
    )
  ),
  "clases_medida" = list(
    fields = list(
      list(id = "codclamed", label = "Código", type = "text", required = TRUE),
      list(id = "nomclamed", label = "Nombre", type = "text", required = TRUE)
    )
  ),
  "nombre_pescador" = list(
    fields = list(
      list(id = "codpes", label = "Código", type = "text", required = TRUE),
      list(id = "nompes", label = "Nombre", type = "text", required = TRUE)
    )
  )
)