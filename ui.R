## Data Science Capstone Project

suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(tm),
  library(stringr),
  library(markdown),
  library(stylo)))

shinyUI(navbarPage("Coursera Data Science Capstone Project", 
                   theme = shinytheme("flatly"),
                   ## Tab 1 - Prediction
                   tabPanel("NEXT WORD PREDICTION",
                            tags$head(includeScript("./js/ga-shinyapps-io.js")),
                            fluidRow(
                              column(3),
                              column(6,
                                     tags$div(textInput("text", 
                                                        label = h3("Enter Your Text Below:"),
                                                        value = ),
                                              tags$span(style="color:grey",("Please Use English Vocabulary Only.")),
                                              br(),
                                              tags$hr(),
                                              h4("Next Word Predicted As:"),
                                              tags$span(style="color:darkred",
                                                        tags$strong(tags$h3(textOutput("predictedWord")))),
                                              br(),
                                              tags$hr(),
                                              h4("Our Record Shows What You Have Entered:"),
                                              tags$em(tags$h4(textOutput("enteredWords"))),
                                              align="center")
                              ),
                              column(3)
                            )
                   ),
                   ## Tab 2 - About 
                   tabPanel("NOTES FOR APPLICATION",
                            fluidRow(
                              column(2,
                                     p("")),
                              column(8,
                                     includeMarkdown("./about/about.md")),
                              column(2,
                                     p(""))
                            )
                   ),
                   ## Footer
                   tags$hr(),
                   tags$br(),
                   tags$span(style="color:grey", 
                             tags$footer(("CREATED BY"), tags$a(
                                           href="http://www.r-project.org/",
                                           target="_blank",
                                           "R"),
                                         ("AND"), tags$a(
                                           href="http://shiny.rstudio.com",
                                           target="_blank",
                                           "Shiny."),
                                         align = "center"),
                             tags$br()
                   )
)
)