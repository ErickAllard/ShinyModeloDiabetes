tableModuleUI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("table_container"))  # Salida para la tabla
  )
}

tableModuleServer <- function(input, output, session, shared, zoomInput) {
  ns <- session$ns
  
  # print(shared$data_table)
  
  output$table_container <- renderUI({
    if (isTRUE(zoomInput())) {
      div(class = "table-box",
      tagList(
        h4("Estimación del RR a nivel municipal", 
           style = "text-align: center; margin-bottom: 13px;"),  # Título de la tabla
        reactableOutput(ns("filtered_table"))
      )
      )
    } else {
      NULL  # No mostrar nada si no hay zoom
    }
  })
  
  output$filtered_table <- renderReactable({
    # browser()
    req(shared$data_table)   # Asegurar que los datos estén disponibles como función reactiva

    data_table  <- shared$data_table %>% 
      st_drop_geometry() %>% 
      select(nom_mun, rr_value, idh, defunciones) %>% 
      arrange(-rr_value) 
    
    pal <- colorBin(
      palette = got_palette,
      domain = data_table$rr_value,
      bins = final_quantiles,
      na.color = "transparent"
    )
    
    
    reactable(
      data_table,  # Convertir la función reactiva en datos y eliminar la geometría
      fullWidth = TRUE,
      bordered = FALSE,
      showPageInfo = FALSE,
      rowStyle = function(index) {
        # Resaltar la fila del municipio seleccionado
        municipio <- shared$selected_municipio
        if (!is.null(municipio) && shared$data_table$nom_mun[index] == municipio) {
          list(backgroundColor = "lavender", fontWeight = "bold")
        } else {
          list()
        }
      },
      columns = list(
        nom_mun = colDef(name = "Municipio"),
        rr_value = colDef(
          name = "Riesgo Relativo",
          format = colFormat(digits = 2),
          style = function(value) {
            list(
              background = pal(value),
              color = 'white')
          }
        ),
        idh = colDef(name = "IDH", format = colFormat(digits = 2)),
        defunciones = colDef(name = "Defunciones (#)")
      ),
      theme = reactableTheme(
        style = list(fontFamily = "sans-serif", fontSize = "12px"),
        borderColor = "rgba(0, 0, 0, 0.2)",  # Divisores internos con un negro sutil
        borderWidth = "1px",  # Grosor de los divisores
        backgroundColor = "transparent",  # Fondo de toda la tabla
        cellPadding = "8px",  # Reducir padding entre celdas
        headerStyle = list(
          backgroundColor = "transparent",  # Fondo del encabezado con transparencia
          fontWeight = "bold",
          fontSize = "12px",
          borderBottom = "1px solid rgba(0, 0, 0, 0.2)" # Tamaño del texto del encabezado
        )
      ),
      defaultColDef = colDef(
        vAlign = "center",
        align = "center",
        headerVAlign = "center",
        headerStyle = list(fontFamily = "sans-serif"),
        width = 90
      )
      
    )
  })
}
