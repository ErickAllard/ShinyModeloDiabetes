library(ggplot2)

# UI del módulo
graphModuleUI <- function(id) {
  ns <- NS(id)
  plotOutput(ns("plots"), height = "600px")
}

# Server del módulo
graphModuleServer <- function(input, output, session, data, stateInput) {
  ns <- session$ns
  
  output$plots <- renderPlot({
    req(stateInput())  # Asegurarse de que haya un estado seleccionado
    state_data <- data %>% dplyr::filter(state == stateInput())
    
    par(mfrow = c(1, 3))  # Dividir el espacio en 3 gráficos
    barplot(state_data$deaths, main = "Decesos", col = "red")
    barplot(state_data$idh, main = "IDH", col = "blue")
    barplot(state_data$gender_ratio, main = "Proporción Hombres/Mujeres", col = "green")
  })
}
