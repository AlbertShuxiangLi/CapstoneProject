## Data Science Capstone Project

suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(tm),
  library(stringr),
  library(markdown),
  library(stylo)))

source("./inputCleaner.R")

shinyServer(function(input, output) {
  
  wordPrediction <- reactive({
    text <- input$text
    textInput <- cleanInput(text)
    wordCount <- length(textInput)
    wordPrediction <- nextWordPrediction(wordCount,textInput)})
  
  output$predictedWord <- renderPrint(wordPrediction())
  output$enteredWords <- renderText({ input$text }, quoted = FALSE)
})
