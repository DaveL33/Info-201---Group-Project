library(dplyr)
library(shiny)
library(rsconnect)
library(plotly)

#Import Runescape data from split files and turn to tables
files <- list.files(path = "data/", full.names = TRUE)
tables <- lapply(files, read.csv)

#Merge 8 data files into one data frame
runescape.data <- do.call(rbind, tables)

#Fix PriceDate to make it readable and neat
runescape.data <- runescape.data %>% mutate(PriceDate = as.POSIXct(as.numeric(as.character({runescape.data$PriceDate})), origin='1970-01-01', tz='GMT'))

#Fix DateAdded to make it readable and neat
runescape.data <- runescape.data %>% mutate(DateAdded = as.POSIXct(as.numeric(as.character({runescape.data$DateAdded})), origin='1970-01-01', tz='GMT'))
  
shinyServer(function(input, output) {
  
})