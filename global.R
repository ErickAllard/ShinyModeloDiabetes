library(shiny)
library(leaflet)
library(magrittr)
library(dplyr)
library(stringr)
library(sf)
library(readxl)
library(readr)
library(shinyWidgets)
library(reactable)
library(janitor)
library(htmlwidgets)
library(conflicted)
library(htmltools)


# Cargar módulos
source("modules/map_module.R")
source("modules/table_module.R")
source('helpers.R')
# source("modules/graph_module.R")



# Carga de datos
# data_states <- read_rds('www/data/diab_data.rds')
data_sf <- read_rds('www/data/data_modelo.rds')
cat_municipios <- read_rds('www/docs/cat_municipios.rds') %>% 
  clean_names() %>% 
  dplyr::select(cve_ent:nom_mun)
names_cat <- read_xlsx('www/docs/cve_ent.xlsx')
idh <- read_rds('www/docs/idh.rds') %>% 
  st_drop_geometry()
defunciones <- read_rds('www/docs/defunciones.rds')%>% 
  st_drop_geometry()

# Catálogo para filtros

age_cat <- c(
  '20-30',
  '30-40',
  '40-50',
  '50-60',
  '60 y más'
)

sex_cat <- c('Hombre',
             'Mujer')

state_cat <- names_cat %>% 
  distinct(nom_ent) %>% 
  .$nom_ent


final_labels <- c(
  "0 - 0.01",
  "0.01 - 0.10",
  "0.10 - 0.15",
  "0.15 - 0.20",
  "0.20 - 0.40",
  "0.40 - 0.60",
  "0.60 - 0.80",
  "0.80 - 1.00",
  "1.00 - 5",
  "> 5"
)

final_quantiles <-  c(
  0.0000000000,
  0.01,
  0.10,
  0.15,
  0.20,
  0.40,
  0.60,
  0.80,
  1.00, 
  5.00,
  50.00
)

data_leaflet <- data_sf %>% 
  dplyr::select(-nom_mun) %>% 
  left_join(
    cat_municipios
  ) %>% 
  left_join(
    names_cat
  ) %>% 
  left_join(
    idh
  ) %>% 
  left_join(
    defunciones
  ) %>% 
  dplyr::select(ent_mun, cve_ent, cve_mun, nom_ent, nom_mun, everything()) %>% 
  mutate(across(starts_with("mn"), ~ cut(
    .,
    breaks = final_quantiles,
    labels = final_labels,
    include.lowest = TRUE
  ), .names = "{.col}_quantile")) %>% 
  st_transform(crs = 4326) 

# Cuantiles para mapa

got_palette <- c(
  "#ABA9B3FF",
  "#9593A2FF",
  "#97616DFF",
  "#9A3039FF",
  "#9D0005FF",
  "#820004FF",
  "#680003FF",
  "#4E0002FF", 
  "#340001FF",
  "#1A0000FF",
  "#000000FF"
)
