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
df <- read.csv("fy2022pa-4.csv") %>%
  mutate(ZIPCODE = str_pad(ZIPCODE, 5, side = "left", "0")) %>% 
  mutate(lat = geocode_zip(df$ZIPCODE)$lat) %>% 
  mutate(lng = geocode_zip(df$ZIPCODE)$lng)

lat <- geocode_zip(df$ZIPCODE)$lat
lng <- geocode_zip(df$ZIPCODE)$lng
final_df <- cbind(df,lat,lng)

city <- c("EAST BOSTON","BOSTON","CHARLESTOWN","ROXBURY",
          "SOUTH BOSTON","ROXBURY CROSSIN","DORCHESTER",
          "JAMAICA PLAIN","ROSLINDALE","MATTAPAN",
          "HYDE PARK","READVILLE","BRIGHTON","WEST ROXBURY",
          "CHESTNUT HILL","DEDHAM","ALLSTON","BROOKLINE","NEWTON")
N_bedroom<- c()
condition <- c("Average","Good","Fair","Poor","Excellent")
#######################################
roads <- roads("MA","Suffolk")

ggplot(roads) + 
  geom_sf() + 
  theme_void()
##################################
# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("PROPERTY ASSESSMENT"),
    
    selectInput("City","which City are you interest in?",city),
    checkboxGroupInput("condition","what condition are you looking for",condition),
     
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
