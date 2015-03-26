library(shiny)
library(maps)
library(lubridate)
library(gbm)

#load(paste0('data/', 'station'))
station <- read.csv('data/station.csv')
station <- apply(station, 2, as.numeric)
station <- as.data.frame(station)
load('data/monthFit')
#load('data/march')

###########################################################################################################
## helper function to create the data to predict
#########################################################################################################
get_bin.f <- function(df, date, hour, rng){
  newd <- data.frame(month = month(date), hour = as.numeric(hour), dayofweek = format(date, '%a'), min_block = rng)
  newd$weekend <- ifelse(newd$dayofweek %in% c('Sat', 'Sun'), 1, 0)
  newd$rush <- ifelse(newd$hour %in% c(7,8,9, 17, 18, 19) & newd$weekend == 0, 1, 0)
  newd$night <- ifelse(newd$hour %in% c(21:23,0:6), 1, 0)
  newd <- newd[,c(1:3,6:7,5,4)]
  newdata <- data.frame(endid = df$id, newd)
  return(newdata)
}
get_all.f <- function(df, date, hour, rng, tm, len){
  s <- seq(tm[1], tm[2], 10)
  l <- list()
  for(i in 1:len){
    r <- paste0('X', s[i], '.', s[i+1])
    l[[i]] <- get_bin.f(df, date, hour, r)
  }
  df <- data.frame(do.call(rbind, l))
  return(df)
}

##################################################################################
# main function to get the data to plot
#####################################################################################

get_data.f <- function(df, date, hour, tm){
  nbin <- (tm[2] - tm[1])/10
  rng  <- paste0('X',tm[1], '.', tm[2])
    if(nbin == 1){
      newdf <- get_bin.f(df, date, hour, rng)
    }else{
      newdf <- get_all.f(df, date, hour, rng,tm, nbin)
    }
  mn <- as.numeric(month(date))
  fit <- monthFit[[mn]]
  p <- predict(fit, newdata = newdf, n.trees = 500, type = "response")
  pred <- ifelse(p > .5, 1, 0)
  res <- data.frame(station, p = pred)
  return(res)
}

shinyServer(function(input, output, session) {


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
    stat <- get_data.f(station, input$date, input$hour, input$time)
    
    if (nrow(stat) == 0)
      return()
    #add circle on the map
      stat1 <- stat[which(stat$p == 1),]
      add_circle.f(stat1, '#00FCA0')
    
      stat0 <- stat[which(stat$p == 0),]
      add_circle.f(stat0, '#FC0000')

  })
  
})