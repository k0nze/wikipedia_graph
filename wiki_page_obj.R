# Author: Konstantin (Konze) Lübeck

# object definition for a wikipedia page
wiki.page.obj <- setRefClass(
    Class = "wiki.page",
    fields = list(
        title = "character",
        url.title = "character",
        links = "vector"
    ),
    methods = list(
        add.link = function(link.wiki.page) {
            links <<- c(links, link.wiki.page)
        }
    )
)
