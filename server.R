library(dplyr)
library(shiny)

runescape.data <- read.csv("~/Google Drive/College/Sophomore/Fall/INFO 201/Runescape_Market_Data.csv", stringsAsFactors = FALSE)
View(runescape.data)

shinyServer(function(input, output) {
  
})