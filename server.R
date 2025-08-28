# server.R

# Lógica del servidor
server <- function(input, output, session) {
  
  # Comunicación entre módulos
  shared <- reactiveValues(data_table = NULL)
  
  # Llamar a los módulos
  callModule(
    mapModuleServer,
    "mapmodule",
    data = data_leaflet,
    stateInput = reactive(input$state),
    genderInput = reactive(input$gender),
    ageInput = reactive(input$age),
    zoomInput = reactive(input$zoom),
    applyFilters = reactive(input$apply_filters),
    shared = shared 
  )
  
  #Llamar al módulo de la tabla, pasando la salida del mapa como entrada
  callModule(
    tableModuleServer,
    "tablemodule",
    shared = shared,
    zoomInput = reactive(input$zoom)
  )
}
