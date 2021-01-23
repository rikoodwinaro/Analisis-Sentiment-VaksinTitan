#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(Rstem)
library(sentiment)
library(shiny)
library(shinycustomloader)
library(shinythemes)
library(SnowballC)
library(twitteR)
library(tm)
library(NLP)
library(plyr)
library(ggplot2)
library(RColorBrewer)
library(wordcloud)
library(dplyr)
library(tidyr)
library(ROAuth)

source("mainapp.r")

## UI ##
ui <- navbarPage(theme = shinytheme('yeti'),
                 tags$head(
                     tags$style(HTML("@import url('//fonts.googleapis.com/css?family=Poppins:200,300,400,600,700,800');"))
                 ),
                 
                 windowTitle = "Analisis Sentiment Terhadap Vaksin Titan`", fluid = TRUE, inverse = FALSE,
                 
                 tabPanel(strong("Home"),
                          headerPanel(h1('Visualization', 
                                         style = "font-family: 'Poppins', cursive; font-weight: 500; 
                                                 line-height: 1.1; color: #FF5733")),
                          mainPanel(
                              plotOutput("emo_plot"),
                              plotOutput("pola_plot"),
                              plotOutput("plot")
                          )
                 ),
                 tabPanel(strong("Tweets"),
                          mainPanel(tabsetPanel(id = 'dataset',
                                                tabPanel("Old Tweets", dataTableOutput("table_real")),
                                                tabPanel("New Tweets", dataTableOutput("table_cleaned"))))
                 ),
                 tabPanel(strong("Classification"),
                          mainPanel(h4("A table of the sentiment scores across four dictionaries"), withLoader(dataTableOutput("table"),loader="dnaspin")))
                 
)

## SERVER ##

server<-function(input, output, session){
    output$plot <- renderPlot(wordcloud(vaksintitan_clean.text.corpus, min.freq = 10, colors = brewer.pal(8, "Dark2"), random.color = TRUE, max.words = 1000)) 
    
    output$emo_plot <- renderPlot(ggplot(dataframe, aes(x=emotion)) +
                                      geom_bar(aes(y=..count.., fill=emotion)) + scale_fill_brewer(palette="Dark2") +
                                      labs(x="Emotion Categories", y="Number of tweets") + 
                                      labs(title = "Analisis Sentiment Terhadap Vaksin Titan", plot.title = element_text(size=12))) 
    
    
    output$table_real <- renderDataTable(vaksintitan)
    clean_data <- read.csv("clean-data.csv")
    output$table_cleaned <- renderDataTable(clean_data)
    output$table<-renderDataTable(dataframe)
}

# Run the application 
shinyApp(ui = ui, server = server)
