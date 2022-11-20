devtools::install_github("rtelmore/RDSTK")
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
library(RDSTK)

raw_data <- read.csv("fy2022pa-4.csv")
df<-raw_data%>%
  mutate(ZIPCODE = str_pad(ZIPCODE, 5, side = "left", "0"))%>%
  select(ZIPCODE,CITY,OVERALL_COND,TOTAL_VALUE,LAND_SF,MAIL_ADDRESS)
lat<-c()
lng<-c()
for(i in 1:length(df$ZIPCODE)){
  lat<-append(lat,geocode_zip(df$ZIPCODE)[2])
  lng<-append(lng,geocode_zip(df$ZIPCODE)[3])
}
df$lat<-lat
df$lng<-lng

street2coordinates(df$MAIL_ADDRESS)$longitude

unique(clean$ZIPCODE)
lat <- geocode_zip(clean$ZIPCODE)$lat
lng <- geocode_zip(clean$ZIPCODE)$lng


city <- c("EAST BOSTON","BOSTON","CHARLESTOWN","ROXBURY",
          "SOUTH BOSTON","ROXBURY CROSSIN","DORCHESTER",
          "JAMAICA PLAIN","ROSLINDALE","MATTAPAN",
          "HYDE PARK","READVILLE","BRIGHTON","WEST ROXBURY",
          "CHESTNUT HILL","DEDHAM","ALLSTON","BROOKLINE","NEWTON")
condition <- c("Average","Good","Fair","Poor","Excellent")


roads <- roads("MA","Suffolk")

ggplot(roads) +
  geom_sf() +
  theme_void()

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("PROPERTY ASSESSMENT"),
  
  selectInput("City","which City are you interest in?",city),
  checkboxGroupInput("condition","what condition are you looking for",condition),
  
  
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
}

# Run the application 
shinyApp(ui = ui, server = server)
