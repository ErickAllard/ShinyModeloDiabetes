# UI
ui <- fluidPage(
  tags$head(
    tags$style(
    HTML("
      .full-page-map {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 1;
      }
      .filter-box {
        position: absolute;
        top: 20px;
        left: 20px;
        width: 300px; /* Ajusta el tamaño de la caja */
        background-color: rgba(255, 255, 255, 0.5); /* Transparencia ajustada */
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
        z-index: 999;
      }
      .table-box {
        position: absolute;
        top: 475px; /* Espacio debajo de los filtros */
        left: 20px;
        width: 400px;
        background-color: rgba(255, 255, 255, 0.5);
        padding: 15px;
        border-radius: 8px;
        box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
        z-index: 998;
        overflow-y: auto; /* Habilitar scroll si el contenido excede la altura */
        height: calc(100% - (400px)); /* Altura dinámica */
      }
      #apply_filters {
        color: black !important; /* Color del texto */
      }
      #apply_filters:hover {
        background-color: lavender !important; /* Fondo al pasar el mouse */
      }
      
        ")
               )
  ),
  # Mapa de fondo
  div(
    class = "full-page-map",
    mapModuleUI("mapmodule")
  ),
  # Caja de filtros
  div(
    class = "filter-box",
    pickerInput(inputId = "gender", 
                label = "Selecciona género:", 
                choices = sex_cat,
                selected = "Hombre",
                options = pickerOptions(container = "body"), 
                width = "100%"),
    pickerInput(inputId = "age", 
                label = "Selecciona grupo de edad:", 
                choices = age_cat,
                selected = "20-30",
                options = pickerOptions(container = "body"), 
                width = "100%"),
    actionBttn(inputId = "apply_filters", 
               label = "Aplicar", 
               style = "minimal", 
               # color = "royal", 
               size = "sm", 
               block = TRUE),
    br(),
    materialSwitch(inputId = "zoom",
                   label = "Realizar zoom en un estado",
                   value = FALSE,
                   status = "success",
                   right = TRUE),  
    conditionalPanel(
      condition = "input.zoom == true",
      virtualSelectInput(inputId = "state", 
                         label = "Selecciona un estado:",
                         choices = state_cat,
                         selected = NULL,
                         markSearchResults = TRUE, 
                         width = "100%",
                         dropboxWrapper = "body",
                         search = TRUE,
                         optionsCount = 2)
    )
  ),
  # Caja de tabla
  tableModuleUI("tablemodule")
)

