library(shiny)
library(leaflet)
library(ShinyDash)
library(markdown)

shinyUI(navbarPage(title = "CityBike",
  collapsible = TRUE,
  windowTitle <- 'CityBike',

  tabPanel("About",
    fluidRow(
      column(6,offset = 3,
        includeMarkdown("doc/about.md"))
    )),  
    tabPanel("Map",
             fluidRow(
               column(3,offset = 1,
                      wellPanel(
                        dateInput('date',
                                    label = 'Select a date',
                                     )
                                 )
                    ),
               column(3,
                      wellPanel(
                        selectInput('hour',
                                    label = 'Select an hour',
                                    choices = c('1','2',"3",'4','5',"6",'7','8','9','10','11','12','13','14','15','16','17','18','19',"20",'21','22','23', '0'),
                                    selected = '8', width = '100%'
                                    )
                                )
                      ),
               column(3,
                      wellPanel(
                        sliderInput('time',
                                    label = 'Select a time range',
                                    min = 0, max = 60, value = c(0,10), step = 10
                                    )
                              )
                      )
                      ),
#              fluidRow(       column(4,
#                                     tableOutput('data')
#              )),
             fluidRow(
               column(10, offset=1,
                      leafletMap(
                        "map", "100%", 800,
                        initialTileLayer = "//{s}.tiles.mapbox.com/v3/slardeux.lda667h9/{z}/{x}/{y}.png",
                        initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
                        options=list(
                          center = c(40.736, -73.958),
                          zoom = 14,
                          maxBounds = list(list(40.704, -74.041), list(40.768, -73.883))
                                    )
                                )
                      )   
                      )
             
    ) #end tabPanel
  
      )
)