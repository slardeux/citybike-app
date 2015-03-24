library(shiny)
library(maps)
library(lubridate)
library(gbm)

#load(paste0('data/', 'station'))
station <- read.csv('data/station.csv')
station <- apply(station, 2, as.numeric)
station <- as.data.frame(station)
#load('data/monthFit')
load('data/march')
shinyServer(function(input, output, session) {


  ##################################################################################
  ## check the boundaries of the map and return the lat lon only of the point in the map
  ####################################################################################
  inBounds <- reactive({
    #if (is.null(input$map_bounds))
      #return(station[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(station,
          lat >= latRng[1] & lat <= latRng[2] &
          lon >= lngRng[1] & lon <= lngRng[2])
  })
  
  #########################################################################################
  # input date and time and create dataframe to be tested with the gbmFit
  #########################################################################################
  get_bin.f <- function(x){
    newd <- data.frame(month = month(input$date), hour = as.numeric(input$hour), dayofweek = format(input$date, '%a'), min_block = x)
    newd$weekend <- ifelse(newd$dayofweek %in% c('Sat', 'Sun'), 1, 0)
    newd$rush <- ifelse(newd$hour %in% c(7,8,9, 17, 18, 19) & newd$weekend == 0, 1, 0)
    newd$night <- ifelse(newd$hour %in% c(21:23,0:6), 1, 0)
    newd <- newd[,c(1:3,6:7,5,4)]
    newdata <- data.frame(endid = inBounds()$id, newd)
    return(newdata)
  }
  get_all.f <- function(x, len){
      s <- seq(input$time[1], input$time[2], 10)
      l <- list()
    for(i in 1:len){
      r <- paste0('X', s[i], '.', s[i+1])
      l[[i]] <- get_bin.f(r)
    }
    df <- data.frame(do.call(rbind, l))
    return(df)
  }
  
  nbin <- reactive({nbin <- (input$time[2] - input$time[1])/10})
  rng <- reactive({rng <- paste0('X',input$time[1], '.', input$time[2])})
  newdf <- reactive({
    if(nbin() == 1){
    newdf <- get_bin.f(rng())
  }else{
    newdf <- get_all.f(rng(), nbin())
  }
})

  ##################################################################################
  # get the prediction
  #####################################################################################

  pred <- reactive({
    fit <- march#monthFit[[newdf()$month[1]]]
    p <- predict(fit, newdata = newdf(), n.trees = 500, type = "response")
    pred <- ifelse(p > .5, 1, 0)
  })

  inBoundsPred <- reactive({
     data.frame(inBounds(), p = pred())
  })
# output$data <- renderTable({
#   newdf()
# })
# output$data <- renderText({
#   pred()
# })
  ####################################################################################
  ## create map
  #####################################################################################
  
  map <- createLeafletMap(session, 'map')
  add_circle.f <- function(df, col){
    map$addCircle(
      df$lat,
      df$lon,
      50,
      row.names(df),
      list(
        weight=1.2,
        fill=TRUE,
        color= col,
        fillOpacity = 0.5
      )
    )
  }

  observe({
    map$clearShapes()
    stat <- inBoundsPred()
    
    if (nrow(stat) == 0)
      return()
    #add circle on the map
      stat1 <- stat[which(stat$p == 1),]
      add_circle.f(stat1, '#00FCA0')
    
      stat0 <- stat[which(stat$p == 0),]
      add_circle.f(stat0, '#FC0000')

  })
  
})