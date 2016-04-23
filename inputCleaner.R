## Data Science Capstone Project

suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(tm),
  library(stringr),
  library(markdown),
  library(stylo)))

F4D <- readRDS(file="./data/4.RData")
F3D <- readRDS(file="./data/3.RData")
F2D <- readRDS(file="./data/2.RData")

dataCleaner<- function(text){
  cleanText <- tolower(text)
  cleanText <- removePunctuation(cleanText)
  cleanText <- removeNumbers(cleanText)
  cleanText <- str_replace_all(cleanText, "[^[:alnum:]]", " ")
  cleanText <- stripWhitespace(cleanText)
  return(cleanText)
}

cleanInput <- function(text){
  textInput <- dataCleaner(text)
  textInput <- txt.to.words.ext(textInput, 
                                language="English.all", 
                                preserve.case = TRUE)
  return(textInput)
}


nextWordPrediction <- function(wordCount,textInput){
  if (wordCount>=3) {
    textInput <- textInput[(wordCount-2):wordCount] 
  }
  else if(wordCount==2) {
    textInput <- c(NA,textInput)   
  }
  else {
    textInput <- c(NA,NA,textInput)
  }
  
wordPrediction <- as.character(F4D[F4D$unigram==textInput[1] & 
                                              F4D$bigram==textInput[2] & 
                                              F4D$trigram==textInput[3],][1,]$quadgram)
  if(is.na(wordPrediction)) {
    wordPrediction <- as.character(F3D[F3D$unigram==textInput[2] & 
                                                 F3D$bigram==textInput[3],][1,]$trigram)
  if(is.na(wordPrediction)) {
      wordPrediction <- as.character(F2D[F2D$unigram==textInput[3],][1,]$bigram)
    }
  }
  cat(wordPrediction)
}