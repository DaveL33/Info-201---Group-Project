library(shiny)
library(dplyr)
library(plotly)
library(rsconnect)
library(shinythemes)

#source('server.R')

shinyUI(fluidPage(theme = shinytheme('slate'), style = "font-family: 'Century Gothic';
                                                        font-size: 9pt;
                                                        background-image: url('bg.jpg');
                                                        background-position: center;
                                                        background-size: cover",
  navbarPage("The Grand Exchange!",
                
    tabPanel("Overview",

      
    # Header
    titlePanel(img(src='RunescapeLogo.png', width = '300px', height = '100px')),
    
    # Sidebar if necessary
    sidebarLayout(
      sidebarPanel(
        h3("Group members:"),
        p("Juan Alvarez, Kyle Evans, Jake George, David Lee")
        ),
      mainPanel(
        tabsetPanel(
          tabPanel("Introduction",
          h1("Introduction"),
          p("Runescape is a free to play MMORPG (massively multiplayer online role playing game) that contains its own economy. In the game, players buy and sell virtual items for virtual gold coins through an in-game system called the Grand Exchange. Like a real economy, the price of a given item fluctuates with time and is dependent on a variety of ingame variables. The dataset we will be working with contains approximately three years worth of data that describes the price of all in-game items that are available to players. We got this dataset initially from Reddit, which was under a Github repository. Since Runescape has a low-level API, the user had to scrape the data from a website that had all of the prices for different items over the past years. This took approximately 20 hours using a scraping applications named BeautifulSoup and Requests. Our target audience would be Runescape users who want to get more information on their items, in order to get an edge while playing the game. The users are able to get a plethora of information from the scraped file. Given this 300MB csv file, the users are now able to ask: \"What would the price of a certain item be in the next month?\", \"How did the price change relative to the past three years?\", \"What items fluctuates more or less relative to other items?\", and \"Are there certain economic trends that can be used to predict the price in the distant future?\""),
          br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(), br(), br(), br(), br()),
          tabPanel("Technical Description",
          h1("Technical Description"),
          p("Our final product will be in the form of a Shiny app that allows users to enter the name of a specific in-game item and returns information about the history of that item in the Grand Exchange. We will be reading in a .csv file that contains the known history for all in-game items in Runescape, and what their prices were in the Grand Exchange for a given date, over about three years. We will also be leveraging the Runescape API which will allow us to obtain real time game information, such as the current price of an item in the Grand Exchange. Combining this .csv file and the game's API, we will be able to make comparisons as to how the current price of an item compares to previous prices, and make predictions on the future price of an item. Runescape players would find this information very valuable as it would give them strong insight into making lots of gold coins in the Runescape economy."),
          br(),
          p("We will need to do some data wrangling to our data to make it more usable. The .csv file that we have found contains other information about in-game data that is not relevant to our project, which we will need to scrap to make the data set smaller and decrease load times (as it stands there are approximately 3.5 million rows of data in this data set). Similarly, the data set lists item prices at somewhat arbitrary times; for example, some items will have their price logged several times in one day, but then not have their price logged at all for several days afterwards. We will need to standardize the data such that there are more consistent intervals between times of price logging, so predictions can be more accurate. We will most likely standardize the data to contain an average price for each day that data is available. We will also need to navigate the somewhat dense Runescape API to get the relevant information about item prices from Runescape's huge JSON based API."),
          br(),
          p("For this project, we will be learning to work with the Shiny framework for R. Since there are thousands of different items in Runescape, we will need an interactive web application that allows users to query information about specific in-game items, most likely via text entry. The Shiny app will allow users to ask questions about the data set, and we will also use Plotly to visualize information that we find about our data set, via charts and graphs."),
          br(),
          p("The goal of this project is to use statistical analysis on the Runescape economy that would help players make in-game choices that would help them earn more gold coins. We anticipate that working with Runescape's API will be difficult, as in our research we have found reports that their API is not the easiest to work with. We also expect learning to use Shiny will be a challenge, as it is a new framework for everyone involved in the project."),
          br(),br(),br(),br(),br(),br(),br(),br())
        )
      )
    )
    ),
    
    
    tabPanel("Simple Item Price Chart",
    
    sidebarLayout(
      sidebarPanel(
        
        selectInput("category", label = h5("Category:"), unique.category, selected = unique.category[1], multiple = FALSE),
        
        uiOutput("itemSelect"),

        uiOutput("dateSelect"),
        
        h5("Item Information:"),
        tableOutput('ItemInfo')
        
      ),
      mainPanel(h3("Simple Price Chart"),
        p('Interactive line graph with descriptive stats based on gold, month, and year. Gives a basic overview of a chosen item\'s selling performance on the Grand Exchange over the last few years. Use the date slider to the left to reactively change the data based on a range of dates!'),
        plotlyOutput('graphic'),
        br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),
        br(),br(),br(),br(),br()
      )
    )
    
    ),
    tabPanel("Predictive Price Chart",
    sidebarLayout(
      sidebarPanel(
        
      ),
      mainPanel(h3("Predictive Price Chart"),
        p('Interactive plot that allows you to see real-time information about items and their stats pulled from RuneScape\'s API.'),
        #plotlyOutput('graphic'),
        br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),
        br(),br(),br(),br(),br()
      )
    )
             
    )
    
  )
)
)


    
    