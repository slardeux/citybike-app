library(shiny)
library(leaflet)
library(ShinyDash)
library(markdown)

shinyUI(navbarPage(title = "City Bike NYC",
  collapsible = TRUE,
  windowTitle <- 'CityBike',

  tabPanel("About",
    fluidRow(
      column(6,offset = 3,
        includeMarkdown("doc/about.md"))
    )),  
    tabPanel("Map",
               column(3,
                      wellPanel(
                        dateInput('date', label = 'Select a date'),

                        selectInput('hour', label = 'Select an hour',
                                    choices = c('1','2',"3",'4','5',"6",'7','8','9','10','11','12','13','14','15','16','17','18','19',"20",'21','22','23', '0'),
                                    selected = '12', width = '100%'),

                        sliderInput('time',  label = 'Select a time range',
                                    min = 0, max = 60, value = c(0,10), step = 10)
                                )
                      ),
               column(9, 
                      leafletMap(
                        "map", "100%", 800,
                        initialTileLayer = "//{s}.tiles.mapbox.com/v3/slardeux.lda667h9/{z}/{x}/{y}.png",
                        initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
                        options=list(center = c(40.736, -73.99), zoom = 14)
                                )
                      )   

    ) #end tabPanel
  
  )
)