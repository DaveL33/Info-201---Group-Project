library(dplyr)
library(shiny)
library(rsconnect)
library(plotly)
library(jsonlite)
library(purrr)

#Function that sets up runescape data from csv files
initData <- function() {

  #Import Runescape data from split files and turn to tables
  files <- list.files(path = "data/", pattern = "Runescape_Market_Data", full.names = TRUE)
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

# Runescape likes to frequently change the item codes that are used for making
# API calls so this gets the most recent item codes from a 3rd party API
initItemCodesData <- function() {
  l <- RJSONIO::fromJSON('http://mooshe.pw/files/items_rs3.json')
  
  item.codes <- l %>% transpose() %>% map_df(simplify)
  
  item.codes$id <- names(l)
  
  #item.codes.tradeable <- item.codes %>% filter(item.codes$tradeable == "TRUE")
  
  item.codes <- select(item.codes, name, id)
  
  return (item.codes)
}

#Initialize Grand Exchange data from 'data' folder
#runescape.data <- initData()

#Initialize 3rd party item code data
item.codes <- initItemCodesData()

#Load item ID data frame for making API calls
#item.codes <- read.csv('data/item_codes.csv')


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
  
  #Renders the image of the item that the user is searching for information about. Gets
  #the image URL from the Runescape API
  output$ItemImage = renderUI({
    # In case there is more than one item with the same item ID, get the first one
    # (the Runescape API says this is the best practice)
     item.id <- head(item.codes %>% filter(name == input$item), 1)
     image.url = paste0("http://services.runescape.com/m=itemdb_rs/1480946739712_obj_big.gif?id=", item.id$id)
     tags$img(src = image.url)
   })
  
  #Render table under date slider
  output$ItemInfo <- renderTable({
    base <- "http://services.runescape.com/m=itemdb_rs/api/catalogue/detail.json?item="
    # In case there is more than one item with the same item ID, get the first one
    # (the Runescape API says this is the best practice)
    item.id <- head(item.codes %>% filter(name == input$item), 1)
    url <- paste0(base, item.id$id)
    item.data <- fromJSON(url)
    
    if(!is.null(item.data)){
      table.data <- runescape.data %>% filter(ItemName == input$item)
      Info <- c('Description', 'Current Price (GP)', '% Change in Last 30 Days', '% Change in Last 90 Days', '% Change in Last 180 Days', 'Members Only', 'Low Alch', 'High Alch')
      Data <- c(item.data[[1]]$description[[1]], item.data[[1]]$current$price, item.data[[1]]$day30$change, item.data[[1]]$day90$change, item.data[[1]]$day180$change, table.data$MembersOnly[[1]], table.data$LowAlch[[1]], 
                table.data$HighAlch[[1]])
      
      #Display Both columns
      return(data.frame(Info, Data))
    } else {
      print("Could not get data")
    }
  })
})
