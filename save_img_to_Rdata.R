## CLEAN UP ALL (ALL!) OBJECT IN MEMORY FORST
## To Generate "ngrams_and_badwords.RData" for the shinyapp
n5 <- read.csv("C:/Example_NLP/n5.csv", stringsAsFactors=FALSE)
n4 <- read.csv("C:/Example_NLP/n4.csv", stringsAsFactors=FALSE)
n3 <- read.csv("C:/Example_NLP/n3.csv", stringsAsFactors=FALSE)
n2 <- read.csv("C:/Example_NLP/n2.csv", stringsAsFactors=FALSE)
profanities <- readLines("C:/Example_NLP/BADWORDS.txt", encoding="UTF-8")
save.image(file = "C:/Example_NLP/ngrams_and_badwords.RData")