library(dplyr)
library(shiny)
library(rsconnect)
library(plotly)

#Function that sets up runescape data from csv files
initData <- function() {
  
  #Import Runescape data from split files and turn to tables
  files <- list.files(path = "data/", full.names = TRUE)
  tables <- lapply(files, read.csv)
  
  #Merge 8 data files into one data frame
  runescape.data <- do.call(rbind, tables)
  
  #Fix PriceDate to make it readable and neat
  runescape.data <- runescape.data %>% mutate(PriceDate = as.Date(as.POSIXct(as.POSIXct(runescape.data$PriceDate, origin="1970-01-01"), origin="1970-01-01")))
  
  #Fix DateAdded to make it readable and neat
  runescape.data <- runescape.data %>% mutate(DateAdded = as.Date(as.POSIXct(as.POSIXct(runescape.data$DateAdded, origin="1970-01-01"), origin="1970-01-01")))
  
  #return data for scope
  return (runescape.data)
}

#Initialize data
runescape.data <- initData()

#Vector containing unique categories of items
unique.category <- sort(as.vector(unique(runescape.data$Category)))

shinyServer(function(input, output) {
  #
  selected.category <- runescape.data
  
  #
  selected.item <- runescape.data 
  
  output$itemSelect <- renderUI({ 
    
    #dataframe with filtered category is the category the user selected
    selected.category <- selected.category %>% filter(Category == input$category)
    
    #Vector containing unique items for selected category 
    unique.item <- sort(as.vector(unique(selected.category$ItemName)))
    
    #drop down to select item from category list
    selectInput("item", "Item:", unique.item, selected = unique.item[1], multiple = FALSE)
  })
  
  output$dateSelect <- renderUI({
    selected.item <- selected.category %>% filter(ItemName == input$item)
    min.date <- min(selected.item$PriceDate, na.rm = TRUE)
    max.date <- max(selected.item$PriceDate, na.rm = TRUE)
    
    sliderInput("date_range", 
                "Choose Date Range:", 
                min = min.date, max = max.date, 
                timeFormat = "%F", 
                value = c(min.date, max.date)
    )
  })
})
