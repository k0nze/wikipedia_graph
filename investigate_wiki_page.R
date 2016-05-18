library("RCurl")
library("XML")
library("stringr")

# retrieves title of wiki.page and adds all wiki links to 'links' 
# in the wiki.page object with their url.title
investigate.wiki.page <- function(wiki.page) {
   
    # construct complete URL from url title and url front 
    wiki.page.url <- paste(url.front, wiki.page$url.title, sep="")
   
    # check if the constructed URL exists 
    wiki.page.exists <- url.exists(wiki.page.url)
 
    url.titles <- NULL 
     
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
        
        # extract links
        body <- html[["body"]]
        
        # extract content wrapper
        content.wrapper <- ""
        for(i in 1:length(body)) {
            if("id" %in% names(xmlAttrs(body[[i]]))) {
                if(xmlAttrs(body[[i]])[["id"]] == "content") {
                    content.wrapper <- body[[i]]
                    break
                }
            }
        }
        
        
        # extract content
        content <- ""
        for(i in 1:length(content.wrapper)) {
            if("id" %in% names(xmlAttrs(content.wrapper[[i]]))) {
                if(xmlAttrs(content.wrapper[[i]])[["id"]] == "bodyContent") {
                    content <- content.wrapper[[i]]
                    break
                }
            }
        }
        
        # extract content text
        content.text <- ""
        for(i in 1:length(content)) {
            if("id" %in% names(xmlAttrs(content[[i]]))) {
                if(xmlAttrs(content[[i]])[["id"]] == "mw-content-text") {
                    content.text <- content[[i]]
                    break
                }
            }
        }
        
        # extract links
        url.all.titles <- as.data.frame(str_match_all(toString(content.text), "<a.*href=\"/wiki/(.*?)\".*>.*</a>"))
        url.all.titles <- url.all.titles$X2 
        
        for(i in 1:length(url.all.titles)) {
            if(!grepl("^(Special|Book|Category|Portal|Help|Template|Wikipedia):", as.character(url.all.titles[[i]]))) {
                temp.wiki.page.obj <- wiki.page.obj$new(url.title = as.character(url.all.titles[[i]]))
                wiki.page$add.link(temp.wiki.page.obj)
            }
        }
    }
}