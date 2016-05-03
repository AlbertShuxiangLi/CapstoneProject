## Download the datasets, unzip into parent directory
if (!file.exists("C:/Example_NLP/final/en_US/en_US.blogs.txt")) {
  fileUrl <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
  download.file(fileUrl, destfile = "C:/Example_NLP/swiftkey.zip")
  unzip("C:/Example_NLP/swiftkey.zip")
}

## Function to create samples of txt files
SampleTxt <- function(infile, outfile, seed, inlines, percent, readmode) {
  conn.in <- file(infile, readmode)  # readmode = "r" or "rb"
  conn.out <- file(outfile,"w")
  # for each line, flip a coin to decide whether to put it in sample
  set.seed(seed)
  in.sample <- rbinom(n=inlines, size=1, prob=percent)
  i <- 0  # have to use for-loop, not while-loop, bec of in.sample array
  num.out <- 0
  for (i in 1:(inlines+1)) {
    # read in one line at a time
    currLine <- readLines(conn.in, n=1, encoding="UTF-8", skipNul=TRUE)
    # if reached end of file, close all connections
    if (length(currLine) == 0) {
      close(conn.out)
      close(conn.in)
      return(num.out)
    }
    # while not end of file, write out the selected line to file
    if (in.sample[i] == 1) {
      writeLines(currLine, conn.out)
      num.out <- num.out + 1
    }
  }
}

## Make Samples
datalist <- c("C:/Example_NLP/final/en_US/en_US.blogs.txt",
              "C:/Example_NLP/final/en_US/en_US.news.txt",
              "C:/Example_NLP/final/en_US/en_US.twitter.txt")
# Used 1% for code-testing, Used 2% for fast-but-not-so-accurate version
mypercent <- 0.02
myseed <- 3606
setwd("C:/Example_NLP/final/en_US")
blog.numlines <- as.numeric(gsub('[^0-9]', '', system("wc -l en_US.blogs.txt", intern=TRUE)))
news.numlines <- as.numeric(gsub('[^0-9]', '', system("wc -l en_US.news.txt", intern=TRUE)))
twit.numlines <- as.numeric(gsub('[^0-9]', '', system("wc -l en_US.twitter.txt", intern=TRUE)))
setwd("C:/Example_NLP")
## Read three corpus txt
blog.sample.numlines <- SampleTxt(datalist[1], "blog.sample.txt",
                                    myseed, blog.numlines, mypercent, "r")
# must use readmode "rb" here, otherwise it breaks on a special char
news.sample.numlines <- SampleTxt(datalist[2], "news.sample.txt",
                                    myseed, news.numlines, mypercent, "rb")
twit.sample.numlines <- SampleTxt(datalist[3], "twit.sample.txt",
                                    myseed, twit.numlines, mypercent, "r")

## Get the number of lines in sample by use of system(wc -l) word counter
blog.sample.numlines <- as.numeric(gsub('[^0-9]', '',
                                        system("wc -l blog.sample.txt", intern=TRUE)))
news.sample.numlines <- as.numeric(gsub('[^0-9]', '',
                                        system("wc -l news.sample.txt", intern=TRUE)))
twit.sample.numlines <- as.numeric(gsub('[^0-9]', '',
                                        system("wc -l twit.sample.txt", intern=TRUE)))

## Import training sets. Combine into one
blog.train <- readLines("C:/Example_NLP/blog.sample.txt")
news.train <- readLines("C:/Example_NLP/news.sample.txt")
twit.train <- readLines("C:/Example_NLP/twit.sample.txt")
comb.train <- c(blog.train, news.train, twit.train)
rm(blog.train, news.train, twit.train)
writeLines(comb.train, "C:/Example_NLP/comb.train.txt")

## Make sure files exist
if (!file.exists("C:/Example_NLP/comb.train.txt")) {
  stop("error: please make sure dir has C:/Example_NLP/comb.train.txt")
}

library(tm)
## Self-defined functions to clean up corpus
removeURL <- function(x) {
    gsub("http.*?( |$)", "", x)
}
convertSpecial <- function(x) {
    # replace any <U+0092> with single straight quote, remove all other <>
    x <- gsub("<U.0092>","'",x)  # actually unnecessary, but just in case
    x <- gsub("’","'",x)
    gsub("<.+?>"," ",x)
}
myRemoveNumbers <- function(x) {
    # remove any word containing numbers
    gsub("\\S*[0-9]+\\S*", " ", x)
}
myRemovePunct <- function(x) {
    # custom function to remove most punctuation
    # replace everything that isn't alphanumeric, space, ', -, *
    gsub("[^[:alnum:][:space:]'*-]", " ", x)
}
myDashApos <- function(x) {
    # deal with dashes, apostrophes within words.
    # preserve intra-word apostrophes, remove all else
    x <- gsub("--+", " ", x)
    x <- gsub("(\\w['-]\\w)|[[:punct:]]", "\\1", x)
    gsub("-", " ", x)
}
trim <- function(x) {
    # Trim leading and trailing whitespace
    gsub("^\\s+|\\s+$", "", x)
}
  
CleanCorpus <- function(x) {  ## x be a corpus object
    x <- tm_map(x, content_transformer(tolower))
    x <- tm_map(x, content_transformer(removeURL))
    x <- tm_map(x, content_transformer(convertSpecial))
    x <- tm_map(x, content_transformer(myRemoveNumbers))
    x <- tm_map(x, content_transformer(myRemovePunct))
    x <- tm_map(x, content_transformer(myDashApos))
    # x <- tm_map(x, removeWords, stopwords("english"))
    x <- tm_map(x, content_transformer(stripWhitespace))
    x <- tm_map(x, content_transformer(trim))
    return(x)
}
  
## Clean combined training set and save to disk
t1 <- Sys.time()  
comb.train <- readLines("C:/Example_NLP/comb.train.txt")
corpus.raw <- Corpus(VectorSource(comb.train))
corpus.clean <- CleanCorpus(corpus.raw)
rm(comb.train)
rm(corpus.raw)
t2 <- Sys.time()
t2 - t1
  
## tm::tm_map running extremely slow, so converting corpus to df
cleandf <- data.frame(text=unlist(sapply(corpus.clean,
                                           `[`, "content")), stringsAsFactors=F)
clean.text <- cleandf$text
writeLines(clean.text, "C:/Example_NLP/train.clean.txt")
rm(corpus.clean)
rm(clean.text)
cat("made clean train data at C:/Example_NLP/train.clean.txt")

rm(blog.numlines, blog.sample.numlines, datalist)
rm(mypercent, news.numlines, news.sample.numlines)
rm(twit.numlines, twit.sample.numlines)
train.clean <- readLines("C:/Example_NLP/train.clean.txt")

## Create n1.csv - unigram of corpus
library(slam)
corpus.clean <- Corpus(VectorSource(train.clean))
## From clean corpus, make 1-gram TDM and then dataframe.
comb.tdm1 <- TermDocumentMatrix(corpus.clean)
n1 <- data.frame(row_sums(comb.tdm1))
rm(comb.tdm1)
n1$word1 <- rownames(n1)
rownames(n1) <- NULL
colnames(n1) <- c("freq", "word1")
write.csv(n1, "C:/Example_NLP/n1.csv", row.names=FALSE)
rm(corpus.clean)
cat("wrote n1 csv at C:/Example_NLP/n1.csv")
## Replace all rare words in corpus with "UNK"
n1 <- read.csv("C:/Example_NLP/n1.csv", stringsAsFactors=FALSE)
rare <- subset(n1, freq < 3) #consider those freq=1 or freq=2 as rare
rm(n1)
file.remove("C:/Example_NLP/n1.csv")
rare <- rare$word1  # character vector
train.clean <- readLines("C:/Example_NLP/train.clean.txt")

## Replace rare words with "UNK" for each line in train.clean
library(parallel)
processInput <- function(x, rare) {
  words <- unlist(strsplit(x, " "))
  funk <- function(x, matches) {
    if (x %in% matches) {
      x <- "UNK"
    } else {
      x
    }
  }
  rv <- lapply(words, funk, matches=rare)
  paste(unlist(rv), collapse=" ")
}
t3 <- Sys.time()
# time-consuming process - to replace rare words with "UNK"
numCores <- detectCores()
cl <- makeCluster(numCores)
results <- parLapply(cl, train.clean, processInput, rare=rare)
stopCluster(cl)
t4 <- Sys.time()
t4 - t3 ## Time difference of 1.74422 days if mypercent=0.2
results <- unlist(results)
writeLines(results, "C:/Example_NLP/train.unk.txt")
cat("wrote unk-ed text to disk at C:/Example_NLP/train.unk.txt")

if (!file.exists("C:/Example_NLP/train.unk.txt")) {
  stop("error: please make sure C:/Example_NLP/train.unk.txt exists")
}

# convert text (character vector) to corpus
library(tm)
train.unk <- readLines("C:/Example_NLP/train.unk.txt")
corpus.unk <- Corpus(VectorSource(train.unk))
rm(train.unk)

library(RWeka)
delim <- ' \r\n\t.,;:"()?!'
library(slam)
library(stringr)

# Make bigram in csv format
cat("MAKING BIGRAMS NOW")
BigramTokenizer <- function(x) {
    NGramTokenizer(x, Weka_control(min=2, max=2, delimiters=delim))
}
BigramTDM <- function(x) {
    tdm <- TermDocumentMatrix(x, control=list(tokenize=BigramTokenizer))
   return(tdm)
}
comb.tdm2 <- BigramTDM(corpus.unk)
rm(BigramTokenizer); rm(BigramTDM)
n2 <- data.frame(row_sums(comb.tdm2))
rm(comb.tdm2)
n2$term <- rownames(n2)
rownames(n2) <- NULL
words <- str_split_fixed(n2$term, " ", 2)  # split col2 by space into 2 words
n2 <- cbind(n2[ ,1], words)
rm(words)
colnames(n2) <- c("freq", "word1", "word2")
write.csv(n2, "C:/Example_NLP/n2.csv", row.names=FALSE)
rm(n2)
cat("wrote BIGRAMS at C:/Example_NLP/n2.csv")

# Make trigram in csv format
cat("MAKING TRIGRAMS NOW")
TrigramTokenizer <- function(x) {
    NGramTokenizer(x, Weka_control(min=3, max=3, delimiters=delim))
}
  # TrigramTokenizer <- ngram_tokenizer(3)
TrigramTDM <- function(x) {
    tdm <- TermDocumentMatrix(x, control=list(tokenize=TrigramTokenizer))
    return(tdm)
}
comb.tdm3 <- TrigramTDM(corpus.unk)
rm(TrigramTokenizer); rm(TrigramTDM)
n3 <- data.frame(row_sums(comb.tdm3))
rm(comb.tdm3)
n3$term <- rownames(n3)
rownames(n3) <- NULL
colnames(n3) <- c("freq","term")
n3 <- subset(n3, n3$freq > 1)
words <- str_split_fixed(n3$term, " ", 3)  # split col2 by space into 3 words
n3 <- cbind(n3$freq, words)
rm(words)
colnames(n3) <- c("freq", "word1", "word2", "word3")
write.csv(n3, "C:/Example_NLP/n3.csv", row.names=FALSE)
rm(n3)
cat("wrote TRIGRAMS at C:/Example_NLP/n3.csv")


# Make quadgram in csv format 
cat("MAKING QUADGRAMS NOW")
QuadgramTokenizer <- function(x) {
    NGramTokenizer(x, Weka_control(min=4, max=4, delimiters=delim))
}
QuadgramTDM <- function(x) {
    tdm <- TermDocumentMatrix(x, control=list(tokenize=QuadgramTokenizer))
    return(tdm)
}
comb.tdm4 <- QuadgramTDM(corpus.unk)
rm(QuadgramTokenizer); rm(QuadgramTDM)
n4 <- data.frame(row_sums(comb.tdm4))
rm(comb.tdm4)
n4$term <- rownames(n4)
rownames(n4) <- NULL
colnames(n4) <- c("freq", "term")
n4 <- subset(n4, n4$freq > 1)  # remove singles
words <- str_split_fixed(n4$term, " ", 4)  # split col2 by space into 4 words
n4 <- cbind(n4$freq, words)
rm(words)
colnames(n4) <- c("freq", "word1", "word2", "word3", "word4")
write.csv(n4, "C:/Example_NLP/n4.csv", row.names=FALSE)
rm(n4)
cat("wrote QUADGRAMS at C:/Example_NLP/n4.csv")


# Make Quintgram in csv format
cat("MAKING QUINTGRAMS NOW")
QuintgramTokenizer <- function(x) {
    NGramTokenizer(x, Weka_control(min=5, max=5, delimiters=delim))
}
QuintgramTDM <- function(x) {
    tdm <- TermDocumentMatrix(x, control=list(tokenize=QuintgramTokenizer))
    return(tdm)
}
comb.tdm5 <- QuintgramTDM(corpus.unk)
rm(QuintgramTokenizer); rm(QuintgramTDM)
n5 <- data.frame(row_sums(comb.tdm5))
rm(comb.tdm5)
n5$term <- rownames(n5)
rownames(n5) <- NULL
colnames(n5) <- c("freq", "term")
n5k <- subset(n5, n5$freq > 1)
words <- str_split_fixed(n5k$term, " ", 5) # split col2 by space into 5 words
n5k <- cbind(n5k$freq, words)
rm(words)
colnames(n5k) <- c("freq", "word1", "word2", "word3", "word4", "word5")
write.csv(n5k, "C:/Example_NLP/n5.csv", row.names=FALSE)
rm(n5k)
cat("wrote QUINTGRAMS to C:/Example_NLP/n5.csv")

cat("All N-Grams have been created in csv format!")