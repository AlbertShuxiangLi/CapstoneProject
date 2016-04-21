Cousera Capstone Project
========================================================
author: Albert Shuxiang Li
date: 20 April 2016

OBJECTIVES
- Build a shiny application to predict the next word.  
- A corpus has been created from this [{Corpus Data Source}](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip). 
- Multiple R packages (such as tm, stringr, stringi, qdap, RWeka, dplyr, rJava) have been used for text mining and [{NLP}](https://en.wikipedia.org/wiki/Natural_language_processing).


APPLIED METHODS & MODELS (1)
========================================================
##### After a corpus generated, then clean up processes performed.  
  
  * Convert to ASCII to remove any funny characters
  * Convert all words to lowercase
  * Eliminate punctuation / Eliminate numbers
  * Strip whitespace
  * Eliminate profan words / Eliminate English stop words
  * Stemming (Using Porter's Stemming Algorithm)
  * Create Plain Text Format

##### This sampled corpus was then used to creat unigram, bigram, trigram and quadgram [{See wikipedia *N-Grams*}](http://en.wikipedia.org/wiki/N-gram). 

APPLIED METHODS & MODELS (2)
========================================================

- When an user input text, the resulting data frames are used to predict the next word accroding to the frequencies of the underlying *N-Grams*. 
- If the next word can not be found under current *N-Grams*, following **Stupid Backoff Algorithm** has been use to pick up the most-likely next wrod:

$$Total_{prob}=1.0*Q+0.4*T+0.16*B+0.064*U$$

#### Note1: **$Total_{prob}$** is not normalized; $Q=QuadGrams_{prob}; T=TriGrams_{prob};$
#### $B=BiGrams_{prob}; U=UniGram_{prob}$.  
#### Note2: For this project __Stupid Backoff Algorithm__ is faster than Kneser-Ney smoothing.

HOW TO USE
========================================================

- Mobile users are targeted by this light-weighted application. 
- While entering the text, the predicted next word will be shown instantaneously.
- What the user has entered will be displayed for verification purpose.

![Shiny Screenshot](screen.png)


NOTES
========================================================

Following reference has been used
  - Nature Language Processing - Smoothing Models
  [{Bill MacCartney}](http://nlp.stanford.edu/~wcmac/papers/20050421-smoothing-tutorial.pdf)  
  - Nature Language Processing - About N-Gram
  [{Daniel Jurafsky & James H. Martin}](https://lagunita.stanford.edu/c4x/Engineering/CS-224N/asset/slp4.pdf)

My project on github
  - The scripts related to this shiny application, as well as the milestone report and the presentation can be found in [{this GitHub repository}](https://github.com/AlbertShuxiangLi/CapstoneProject).
