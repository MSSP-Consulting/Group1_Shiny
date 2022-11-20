library(shiny)
library(tidyverse)
library(tigris)
library(ggplot2)
library(ggmap)
library(zipcodeR)
library(dplyr)
library(ggplot2)
library(stringr)
library(rgdal) 
library(maptools) 
library(leaflet)
library(tidygeocoder)
library(tibble)

raw_data <- read.csv("fy2022pa-4.csv")
#############################
raw_data <- na.omit(raw_data)
###############################
df<-raw_data%>%
  mutate(ZIPCODE = str_pad(ZIPCODE, 5, side = "left", "0"))%>%
  select(ZIPCODE,CITY,OVERALL_COND,TOTAL_VALUE,LAND_SF,MAIL_ADDRESS) 

lat<-c()
lng<-c()
for(i in 1:length(df$MAIL_ADDRESS)){
  address_single<-tibble(singlelineaddress=c(paste(df$MAIL_ADDRESS[i],df$CITY[i],"MA")))
  census<-address_single%>%geocode(address = singlelineaddress,method="census",verbose=TRUE)
  lat<-append(lat,census$lat)
  lng<-append(lng,census$long)
}
df$lat<-lat
df$lng<-lng
################
df <- na.omit(df)
#################
city <- unique(df$CITY)
condition <- unique(df$OVERALL_COND)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("PROPERTY ASSESSMENT"),
  
  selectInput("City","which City are you interest in?",city),
  checkboxGroupInput("condition","what condition are you looking for",condition),
  
  mainPanel(
    plotOutput("map"),
    tableOutput("table")
  )
)


server <- function(input, output) {
  newdf <- reactive({
    req(input$condition)
    df[df$conditon %in% input$condition, ]
  })
 output$map <- renderLeaflet({
   leaflet() %>% 
     addTiles() %>%
     addMarkers(lat = newdf$lat, lng = newdf$lng,
                popup="Boston, my hometown")
 })
 output$table <- renderDataTable(newdf$TOTAL_VALUE,newdf$LAND_SF,newdf$MAIL_ADDRESS)
   
}

shinyApp(ui = ui, server = server)
