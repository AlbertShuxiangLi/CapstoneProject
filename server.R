## Data Science Capstone Project

suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(tm),
  library(stringr),
  library(markdown),
  library(stylo)))

source("./inputCleaner.R")
final4Data <- readRDS(file="./data/4.RData")
final3Data <- readRDS(file="./data/3.RData")
final2Data <- readRDS(file="./data/2.RData")


shinyServer(function(input, output) {
  
  wordPrediction <- reactive({
    text <- input$text
    textInput <- cleanInput(text)
    wordCount <- length(textInput)
    wordPrediction <- nextWordPrediction(wordCount,textInput)})
  
  output$predictedWord <- renderPrint(wordPrediction())
  output$enteredWords <- renderText({ input$text }, quoted = FALSE)
})
