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

df<-read.csv("clean.csv")


city<-unique(df$CITY)
condition<-unique(df$OVERALL_CON)
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("PROPERTY ASSESSMENT"),
  
  selectInput("City","which City are you interest in?",city),
  checkboxGroupInput("condition","what condition are you looking for",condition),
  
  mainPanel(
    leafletOutput("map"),
    tableOutput("table")
  )
)


server <- function(input, output) {
  newdf <- reactive({
    req(input$condition, input$City)
    df%>%filter(OVERALL_COND%in%input$condition)%>%filter(CITY==input$City)
  })
 output$map <- renderLeaflet({
   leaflet() %>%
     addTiles() %>%
     addMarkers(lat = newdf()$lat, lng = newdf()$lng,
                popup= newdf()$TOTAL_VALUE)
 })
 output$table <- renderTable(newdf()$lat)
   
}

shinyApp(ui = ui, server = server)
