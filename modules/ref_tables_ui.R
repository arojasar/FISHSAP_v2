# modules/ref_tables_ui.R

ref_tables_ui <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(ns("ref_table_output")),  # ¡Un solo DTOutput!
    uiOutput(ns("ref_form"))          # ¡Un solo uiOutput!
  )
}