# Author: Konstantin (Konze) Lübeck

library("RCurl")
library("XML")
library("stringr")

set.wiki.page.title <- function(wiki.page) {
    # retrieves the title of a wiki page
    #
    # Args:
    #   wiki.page: wikipedia page object

    # construct complete URL from url title and url front 
    wiki.page.url <- paste(url.front, wiki.page$url.title, sep="")
    
    # check if the constructed URL exists 
    wiki.page.exists <- url.exists(wiki.page.url)
    
    if(wiki.page.exists) {
        
        data <- getURL(wiki.page.url, .encoding = "UTF-8")
        wiki.page.html <- htmlTreeParse(data, asText = TRUE, encoding = "UTF-8")
        
        html <- xmlRoot(wiki.page.html)
        
        # extract title
        head <- html[["head"]]
        title.node <- head[["title"]]
        title <- str_match(toString(title.node), "<title>(.*?) - Wikipedia, the free encyclopedia</title>")
        title <- title[1,2]
        wiki.page$title <- title
    }
}
