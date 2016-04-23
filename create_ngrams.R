## Loading the original data set
ts <- Sys.time()
path1 <- "./final/en_US/en_US.blogs.txt"
path2 <- "./final/en_US/en_US.news.txt"
path3 <- "./final/en_US/en_US.twitter.txt"

# Read blogs data in binary mode
conn <- file(path1, open="rb")
blogs <- readLines(conn, encoding="UTF-8", skipNul=TRUE)
close(conn)
# Read news data in binary mode
conn <- file(path2, open="rb")
news <- readLines(conn, encoding="UTF-8", skipNul=TRUE)
close(conn)
# Read twitter data in binary mode
conn <- file(path3, open="rb")
twitter <- readLines(conn, encoding="UTF-8", skipNul=TRUE)
close(conn)
# Remove temporary variable
rm(conn, path1, path2, path3)

## Generating a random sapmle of all sources
N_t <- 0.25
N_n <- 0.25
N_b <- 0.25
sampleTwitter <- sample(twitter, length(twitter)*N_t)
sampleNews <- sample(news, length(twitter)*N_n)
sampleBlogs <- sample(blogs, length(twitter)*N_b)
textSample <- c(sampleTwitter,sampleNews,sampleBlogs)
rm(twitter, blogs, news)
rm(sampleTwitter, sampleNews, sampleBlogs)

## Save sample
writeLines(textSample, "newTextSample.txt")
rm(textSample)

suppressPackageStartupMessages(c(
library(RWekajars),
library(qdapDictionaries),
library(qdapRegex),
library(qdapTools),
library(RColorBrewer),
library(qdap),
library(NLP),
library(tm),
library(SnowballC),
library(slam),
library(RWeka),
library(rJava),
.jinit(parameters="-Xmx128g"),
library(dplyr)))

## Building a clean corpus

theSampleCon <- file("./newTextSample.txt")
theSample <- readLines(theSampleCon)
close(theSampleCon)
rm(theSampleCon)

## Read bad words document
badwords <- readLines("badwords.txt")

## Build the corpus and specify the source to be character vectors 
cleanSample <- Corpus(VectorSource(theSample))
rm(theSample)

## Make it work with the new tm package
cleanSample <- tm_map(cleanSample,
                      content_transformer(function(x) 
                        iconv(x, to="UTF-8", sub="byte")),
                      mc.cores=1)

## Convert to lower case
cleanSample <- tm_map(cleanSample, content_transformer(tolower), lazy = TRUE)

## remove punction, numbers, URLs, stop, profanity and stem words
cleanSample <- tm_map(cleanSample, content_transformer(removePunctuation))
cleanSample <- tm_map(cleanSample, content_transformer(removeNumbers))
removeURL <- function(x) gsub("http[[:alnum:]]*", "", x) 
cleanSample <- tm_map(cleanSample, content_transformer(removeURL))
cleanSample <- tm_map(cleanSample, stripWhitespace)
t1 <- Sys.time()
cleanSample <- tm_map(cleanSample, removeWords, stopwords("english"))
t2 <- Sys.time()
t2 - t1
cleanSample <- tm_map(cleanSample, removeWords, badwords)
t3 <- Sys.time()
t3 - t2
cleanSample <- tm_map(cleanSample, stemDocument)
t4 <- Sys.time()
t4 - t3
cleanSample <- tm_map(cleanSample, stripWhitespace)
rm(badwords)
## Saving the final Corpus
saveRDS(cleanSample, file = "finalCorpus.RData")
rm(cleanSample)


## Budilding the n-grams

## Load the final Corpus
finalCorpus <- readRDS("finalCorpus.RData")
finalCorpusDF <-data.frame(text=unlist(sapply(finalCorpus,`[`, "content")), 
                           stringsAsFactors = FALSE)

## Building the tokenization function for the n-grams
ngramTokenizer <- function(theCorpus, ngramCount) {
  if (ngramCount == 2) {M <- 148200}
  if (ngramCount == 3) {M <- 448988}
  if (ngramCount == 4) {M <- 430911}
  ngramFunction <- RWeka::NGramTokenizer(theCorpus, 
                                         RWeka::Weka_control(min = ngramCount, max = ngramCount, 
                                                             delimiters = " \\r\\n\\t.,;:\"()?!"))
  ngramFunction <- data.frame(table(ngramFunction))
  ngramFunction <- ngramFunction[order(ngramFunction$Freq, 
                                       decreasing = TRUE),][1:M,]
  colnames(ngramFunction) <- c("String","Count")
  ngramFunction
}

t5 <- Sys.time()
bigram <- ngramTokenizer(finalCorpusDF, 2)
saveRDS(bigram, file = "./test/bigram.RDS") 
bg <- readRDS("./test/bigram.RDS")
BX <- data.frame()
for (i in 1:nrow(bg)) {
  b1 <- stylo::txt.to.words.ext(bg$String[i], language="English.all", preserve.case = TRUE)
  b11 <- b1[1]; b12 <- b1[2]
  bx <- data.frame(  "unigram" = b11, 
                      "bigram" = b12, 
                   "frequency" = bg$Count[i])
  BX <- rbind(BX, bx)
}
saveRDS(BX, file = "./test/DX2.RDS")
t6 <- Sys.time()
t6 - t5

trigram <- ngramTokenizer(finalCorpusDF, 3)
saveRDS(trigram, file = "./test/trigram.RDS") 
tg <- readRDS("./test/trigram.RDS")
CX <- data.frame()
for (i in 1:nrow(tg)) {
  b1 <- stylo::txt.to.words.ext(tg$String[i], language="English.all", preserve.case = TRUE)
  b11 <- b1[1]; b12 <- b1[2]; b13 <- b1[3]
  bx <- data.frame(    "unigram" = b11, 
                        "bigram" = b12,
                       "trigram" = b13,
                     "frequency" = tg$Count[i])
  CX <- rbind(CX, bx)
}
saveRDS(CX, file = "./test/DX3.RDS")
t7 <- Sys.time()
t7 - t6

quadgram <- ngramTokenizer(finalCorpusDF, 4)
saveRDS(quadgram, file = "./test/quadgram.RDS")
qg <- readRDS("./test/quadgram.RDS")
DX <- data.frame()
for (i in 1:nrow(qg)) {
  b1 <- stylo::txt.to.words.ext(qg$String[i], language="English.all", preserve.case = TRUE)
  b11 <- b1[1]; b12 <- b1[2]; b13 <- b1[3]; b14 <- b1[4]
  bx <- data.frame(  "unigram" = b11, 
                      "bigram" = b12, 
                     "trigram" = b13,
                    "quadgram" = b14,
                   "frequency" = qg$Count[i])
  DX <- rbind(DX, bx)
}
saveRDS(DX, file = "./test/DX4.RDS")
t8 <- Sys.time()
t8 - t7
t8 - ts