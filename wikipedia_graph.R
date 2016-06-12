# Author: Konstantin (Konze) Lübeck

library(igraph)

source("wiki_page_obj.R")
source("investigate_wiki_page.R")
source("set_wiki_page_title.R")
source("queue.R")

# important for unicode characters
Sys.setlocale("LC_ALL", 'en_US.UTF-8')

# last part of the URL of the wikipedia page you would like to start from (english wikipedia only)
start.url.title <- "Sm%C3%A5lands_nation%2C_Uppsala"

# Number of wikipedia pages that should be investigated 
number.of.pages.to.investigate <- 40



url.front <- "https://en.wikipedia.org/wiki/"
queue <- Queue$new()

# initialize start page
start.wiki.page <- wiki.page.obj$new()
start.wiki.page$url.title <- start.url.title

queue$push(start.wiki.page)

for(i in 1:number.of.pages.to.investigate) {
    
    temp.wiki.page <- queue$pop()
    investigate.wiki.page(temp.wiki.page)

    #print(length(temp.wiki.page$links))
    
    for(j in 1:length(temp.wiki.page$links)) {
        # aviod reinvestigation
        if(length(temp.wiki.page$links[[j]]) != 0) {
            queue$push(temp.wiki.page$links[[j]])
        }
    }
}

# retrieve names for page which were not investigated
map.url.title.to.title <- new.env(hash=T, parent=emptyenv())

while(queue$size() != 0) {
    temp.wiki.page <- queue$pop()
    print(paste(queue$size(), " pages to go"))
    # check if title was retrieved before
    temp.title <- map.url.title.to.title[[temp.wiki.page$url.title]]
    if(is.null(temp.title)) {
        set.wiki.page.title(temp.wiki.page) 
        map.url.title.to.title[[temp.wiki.page$url.title]] <- temp.wiki.page$title
    } else {
        temp.wiki.page$title <- temp.title
    }
}

# construct graph
queue$push(start.wiki.page)
queue$size()

wiki.page.titles <- c(start.wiki.page$title)
from <- vector()
to <- vector()

while(queue$size() != 0) {
    temp.wiki.page <- queue$pop() 
    
    for(j in 1:length(temp.wiki.page$links)) {
        if(!is.null(temp.wiki.page$links[[j]]$title)) {
            if(!(temp.wiki.page$links[[j]]$title %in% wiki.page.titles)) {
                wiki.page.titles <- c(wiki.page.titles, temp.wiki.page$links[[j]]$title)
                
                from <- c(from, temp.wiki.page$title)
                to <- c(to, temp.wiki.page$links[[j]]$title)
                
                queue$push(temp.wiki.page$links[[j]])
            }
        }
    }   
}

vertices <- data.frame(name=wiki.page.titles)
edges <- data.frame(from=from, to=to)

save(vertices, file="vertices.Rda")
save(edges, file="edges.Rda")


g <- graph.data.frame(edges, directed=TRUE, vertices=vertices)

# print graph
degree.g <- degree(g)
diameter.g <- diameter(g)
num.vertices.g <- vcount(g)
width <- diameter.g*0.1*num.vertices.g

g.color <- colorRampPalette(c("blue", "cyan", "yellow", "red"))(length(degree.g))[rank(degree.g)]

co <- layout.lgl(g)

pdf("graph.pdf", height = width, width = width)
op <- par(oma=c(0,0,0,0))
plot(0, type="n", ann=FALSE, axes=FALSE, xlim=extendrange(co[,1]), ylim=extendrange(co[,2]))
    par(new=T)
plot(g, layout=co,
     vertex.color = g.color,
     vertex.size = strheight("I"),
     vertex.label.color= "black",
     edge.arrow.size=width/1000)
par(op)
dev.off()
