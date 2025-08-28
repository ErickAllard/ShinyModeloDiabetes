# Module UI
mapModuleUI <- function(id) {
  ns <- NS(id)
  tagList(
    leafletOutput(ns("map"), height = "100%")
  )
}


# Module server
mapModuleServer <- function(input, output, session, data_leaflet,
                            stateInput, genderInput, ageInput, 
                            zoomInput,applyFilters, shared) {
  ns <- session$ns
  
  # Reactive values
  r <- reactiveValues(selected = NULL,
                      quantile_col = NULL,
                      state_data = NULL,
                      data = data_leaflet)
  
  # First render
  
  output$map <- renderLeaflet({

    leaflet() %>%
      addProviderTiles(providers$Esri.NatGeoWorldMap) %>% 
      setView(lng = -102.5528, lat = 23.6345, zoom = 5) %>%
    #   onRender("
    #   function(el, x) {
    #     var map = this;
    #     map.zoomControl.setPosition('topright');  // Mover el control de zoom a la esquina superior derecha
    #   }
    # ") %>% 
     add_Spinner()
  })
  
  
  
  # Map behavior
  observeEvent(applyFilters(),{
    req(genderInput(), ageInput()) # Verificar que los filtros estén seleccionados
    
    
    r$selected <- paste0("mn", str_extract(str_remove(ageInput(), "-"), '\\d+'), 
                         str_extract(genderInput(), "H|M"))
    r$quantile_col <- paste0(r$selected, "_quantile")
    
    print(r$selected)
    
    # Preparar los datos filtrados
    data_filtered <- r$data %>%
      select(ent_mun, rr_value = !!sym(r$selected), 
             mean_quantile = !!sym(r$quantile_col),
             nom_mun, nom_ent)
    
    print(data_filtered)
    
    tryCatch({
    pal <- colorBin(
      palette = got_palette,
      bins = final_quantiles,
      domain = data_filtered$rr_value,
      na.color = "transparent"
    )}, error = function(e) {
      print(paste("Error:", e$message))
    })
    
    # Activa el spinner
    # runjs("$('#map-spinner').show();")
    
    
    # Actualizar dinámicamente el mapa
    tryCatch({
    leafletProxy(ns("map"), data = data_filtered) %>%
      start_Spinner(list("lines" = 7, "length" = 40,
                        "width" = 20, "radius" = 10)) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~pal(rr_value),
        fillOpacity = .75,
        color = "black",
        weight = 0.5,
        popup = ~paste0(
          "<b>Municipio:</b> ", nom_mun, "<br>",
          "<b>Riesgo Relativo:</b> ", sprintf("%.2f", rr_value)
        )
      ) %>% 
      clearControls() %>% 
      addLegend(
          pal = pal,
          values = data_filtered$rr_value,
          title = "Riesgo relativo",
          position = "bottomright",
          opacity = .75,
          labFormat = labelFormat(digits = 2)
        ) %>% 
      stop_Spinner()
    }, error = function(e) {
      print(paste("Error:", e$message))
    })
    
    # runjs("$('#map-spinner').hide();")
    
  })
  
  # Zoom dinámico al estado seleccionado
  observe({

    req(applyFilters())
  
    # Generar el nombre de la columna dinámica
    selected_column <- paste0("mn", str_extract(str_remove(isolate(ageInput()),
                                                           "-"), '\\d+'), 
                              str_extract(genderInput(), "H|M"))
    quantile_column <- paste0(selected_column, "_quantile")

    if (isTRUE(zoomInput())) {
      req(stateInput()) # Asegurarse de que se haya seleccionado un estado

      # Filtrar el estado seleccionado y calcular su centroide
      r$state_data <- r$data %>%
        dplyr::filter(nom_ent == stateInput()) %>%
        select(ent_mun, rr_value = !!sym(selected_column),
               mean_quantile = !!sym(quantile_column),
               nom_mun, 
               nom_ent,
               idh,
               defunciones)
      
      
      shared$data_table <- r$state_data
      
      print(shared$data_table)

      # Validar que el estado existe en los datos
      req(nrow(r$state_data) > 0)

      # Calcular el centroide del estado
      state_centroid <- sf::st_centroid(r$state_data$geometry)

      # Extraer las coordenadas del centroide y convertirlas en lista nombrada
      coords <- as.list(sf::st_coordinates(state_centroid)[1, ])
      names(coords) <- c("lng", "lat")

      # Hacer zoom en el estado seleccionado
      pal <- colorBin(
        palette = got_palette,
        bins = final_quantiles,
        domain = r$state_data$rr_value,
        na.color = "transparent"
      )
      
      
      #print(municipality_labels)

      # Dibujar solo el estado seleccionado
      leafletProxy(ns("map")) %>%
        clearShapes() %>%
        addPolygons(
          layerId = ~nom_mun,
          data = r$state_data,
          fillColor = ~pal(rr_value),
          fillOpacity = .75,
          color = "black",
          weight = 0.5,
          popup = ~paste0(
            "<b>Municipio:</b> ", nom_mun, "<br>",
            "<b>Riesgo Relativo:</b> ", sprintf("%.2f", rr_value)
          )
        )  %>%
        setView(lng = coords$lng, lat = coords$lat, zoom = 8)

    } else {
      
      # runjs("$('#map-spinner').show();")
      # Volver a la vista completa del país
      leafletProxy(ns("map")) %>%
        start_Spinner(list("lines" = 7, "length" = 40,
                          "width" = 20, "radius" = 10)) %>%
        addPolygons(
          data = r$data %>%
            select(ent_mun, rr_value = !!sym(selected_column),
                   mean_quantile = !!sym(quantile_column),
                   nom_mun, nom_ent),
          fillColor = ~colorBin(got_palette, final_quantiles,
                                domain = r$data[[selected_column]])(rr_value),
          fillOpacity = .75,
          color = "black",
          weight = 0.5,
          popup = ~paste0(
            "<b>Municipio:</b> ", nom_mun, "<br>",
            "<b>Riesgo Relativo:</b> ", sprintf("%.2f", rr_value)
          )
        )  %>%
        setView(lng = -102.5528, lat = 23.6345, zoom = 5) %>% 
        stop_Spinner()
      
      # runjs("$('#map-spinner').hide();")
    }
    
  })
  
  observeEvent(input$map_shape_click, {
    click <- input$map_shape_click
    if (!is.null(click$id)) {
      r$selected_municipio <- click$id  # Actualizar el municipio seleccionado
      shared$selected_municipio <- click$id  # Compartir con otros módulos
      print(paste("Municipio clicado:", click$id))  # Debugging
    }
  })


  
  
}

