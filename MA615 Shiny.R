library(shiny)

ui <- fluidPage(
  
  titlePanel("Boston Employee Earnings Report in 2021"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput("file1", "Choose your CSV File",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv")
      ),
      h6("*Make sure your CSV contains columns named 'lat' and 'lon' and a numerical column to size the dots", align = "left"),
      tags$hr(),
      textAreaInput("title", "Map title"), 
      numericInput("titlesize", "Title font size:", value = 19, min = 12, max = 50),  
      textAreaInput("family", "Choose font family name", "Arial"),  
      hr(),
      textAreaInput("color", "Choose dot color using hex code", "#1e90ff"),
      radioButtons("radio", label = h5("Choose dot shape"), 
                   choices = list("Circle" = 1, "Square" = 0, "Triangle" = 2, "Filled circle" = 16, "Filled square" = 15,"Filled triangle" = 17),
                   selected = 16),
      uiOutput("column"),
      numericInput("low", "A minimum dot size:", value = 1, min = 0, max = 5),  
      numericInput("high", "A maximum dot size:", value = 15, min = 5, max = 30),  
      textAreaInput("legend", "Legend title"),
      numericInput("legendsize", "Title font size:", value = 12, min = 12, max = 50),
      hr(),
     ),
    mainPanel(
      plotOutput("stateMap"),
      h4("My data", align = "left"),
      tableOutput("contents")
    )
  )
)


server <- function(input, output, session){
  filedata <- reactive({
    infile <- input$file1
    if (is.null(infile)){
      return(NULL)      
    }
    read.csv(infile$datapath)
  })
  
  library(dplyr)
  library(tidyverse)
  library(ggplot2)
  library(fiftystater)
  
  output$column <- renderUI({
    df <- filedata()
    if (is.null(df)) return(NULL)
    #  items=names(df) # add back in if you want all columns
    nums <- sapply(df, is.numeric) # keep only number columns
    items=names(nums[nums]) # keep only number columns
    names(items)=items
    selectInput("bubble", "Choose column to map to dot size", items)
  })
  
  output$color <- renderUI({
    df <- filedata()
    if (is.null(df)) return(NULL)
    #  items=names(df) # add back in if you want all columns
    nums <- sapply(df, is.numeric) # keep only number columns
    items=names(nums[nums]) # keep only number columns
    names(items)=items
    selectInput("color", "Choose column for color",items)
  })
  
  output$contents = renderTable({
    df <- filedata()
    return(df)
  })
  
  output$stateMap <- renderPlot({
    
    df <- filedata()
    
    #install.packages("devtools")
    #devtools::install_github("wmurphyrd/fiftystater")
    Boston <- filter(fifty_states, group == 'Massachusetts.1')
    
    p3 <- ggplot() + geom_polygon(data=Boston, aes(x=long, y=lat, group = group),color="blue", fill= "grey92") +
      geom_point(data = df, aes_string(x=df$lon, y=df$lat, size=input$bubble), color = input$color, shape = as.numeric(input$radio)) +
      scale_size(name="", range = c(input$low, input$high)) +
      ggtitle(input$title) + 
      guides(size=guide_legend(input$legend)) +
      theme_void() +
      theme(aspect.ratio=1.62/3, 
            plot.title = element_text(size = input$titlesize),
            legend.title=element_text(size= input$legendsize),
            text=element_text(family=input$family))
    p3
    
  })
  
  output$downloadPlot <- downloadHandler(
    filename = function() {paste('map-', Sys.Date(), '.png', sep='')},
    content = function(file) { 
      png(file, type='cairo')
      ggsave("storybench-mapmaker.png", width=14.4,height=7.43,units="in")
    },
    contentType = 'image/png'
  )
}

shinyApp(ui, server)