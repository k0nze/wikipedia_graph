# Wikipedia Graph

This little R script starts with an URL for a Wikipedia page (English Wikipedia), extracts internal Wikipedia URLs from this page and recursively investigates those Wikipedia pages. With this information a graph is constructed.

## Usage
### Libraries

 * `RCurl`
 * `XML`
 * `stringr`
 * `igraph`

 (The `Queue` was developed by [Andrew Collier](http://www.exegetic.biz/blog/2013/11/implementing-a-queue-as-a-reference-class/))

### How to Run

Before running the script one has to set the following variable in `wikipedia_graph.R`

 * `start.url.title` this should be set to the title of a page which is shown in its URL (the part after the last slash `/`).
 * `number.of.pages.to.investigate` this indicates how many page should be investigates.

To finally run the program one has to execute the following command:

`Rscript wikipedia_graph.R`

The graph will be stored in the two files `vertices.Rda` and `edges.Rda`
