library(dplyr)
library(shiny)
library(rsconnect)
library(plotly)


#Function that sets up runescape data from csv files
initData <- function() {

  #Import Runescape data from split files and turn to tables
  files <- list.files(path = "data/", full.names = TRUE)
  tables <- lapply(files, read.csv, stringsAsFactors = FALSE)
  
  #Merge 8 data files into one data frame
  runescape.data <- do.call(rbind, tables)
  
  #Delete some columns for efficiency
  runescape.data$X.1 <- NULL
  runescape.data$X <- NULL
  runescape.data$DateAdded <- NULL
  
  #Fix PriceDate to make it readable and neat
  runescape.data <- runescape.data %>% mutate(PriceDate = as.Date(as.POSIXct(as.POSIXct(runescape.data$PriceDate, origin = "1970-01-01"), origin = "1970-01-01")))
  
  #return data for scope
  return (runescape.data)
}

#Initialize data
#runescape.data <- initData()

#Vector containing unique categories of items
unique.category <- sort(as.vector(unique(runescape.data$Category)))

shinyServer(function(input, output) {
  
  #Set category dataframe to be later modified and scoped
  selected.category <- runescape.data
  
  #Set item dataframe to be later modified and scoped
  selected.item <- runescape.data 
  
  #Render itemSelect ui
  output$itemSelect <- renderUI({ 
    
    #dataframe with filtered category is the category the user selected
    selected.category <- filter(runescape.data, Category == input$category)
    
    #Vector containing unique items for selected category 
    unique.item <- sort(as.vector(unique(selected.category$ItemName)))
    
    #drop down to select item from category list
    selectInput("item", "Item:", unique.item, selected = unique.item[1], multiple = FALSE)
  })
  
  #Render dateSelect ui
  output$dateSelect <- renderUI({
    
    #set up selected.item dataframe and get min and max values
    selected.item <- selected.category %>% filter(ItemName == input$item)
    min.date <- min(selected.item$PriceDate, na.rm = TRUE)
    max.date <- max(selected.item$PriceDate, na.rm = TRUE)
    
    sliderInput("dateSelect", 
                "Choose Date Range:", 
                min = min.date, max = max.date, 
                timeFormat = "%F", 
                value = c(min.date, max.date)
    )
  })
  
  #Render plot
  output$graphic <- renderPlotly({
    
    #Dates, min and max, taken from the above input slider.
    min.date <- min(input$dateSelect)
    max.date <- max(input$dateSelect)
    
    plot.data <- runescape.data %>% filter(ItemName == input$item, PriceDate > min.date & PriceDate < max.date) %>% group_by(PriceDate) %>% summarize(Gold = mean(Price))
    
    plot_ly(plot.data, x = ~PriceDate, y = ~Gold, name = "Price (GP)", type = "scatter", mode = 'lines') %>% 
      layout(plot_bgcolor= 'rgba(193, 205, 205, 0.8)',
             paper_bgcolor= 'rgba(193, 205, 205, 0.8)')
  })
  
  #Render table under date slider
  output$ItemInfo <- renderTable({
    tabel.data <- runescape.data %>% filter(ItemName == input$item)
    Info <- c('Members Only', 'Low Alch', 'High Alch')
    Data <- c(tabel.data$MembersOnly[[1]], tabel.data$LowAlch[[1]], 
              tabel.data$HighAlch[[1]])
    
    #Display Both columns
    return(data.frame(Info, Data))
  })
})
