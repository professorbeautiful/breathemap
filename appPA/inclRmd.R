# Alternative solution:
# ```{r child = 'DrWho.Rmd'}
# ```
require("magrittr")
inclRmd <- function(path, wd, openMe=FALSE) {
  if(!missing(wd)) {
    savedwd = getwd()
    setwd(wd)
  }
  tee = function(x, outputpath) {
    writeLines(capture.output(x), con=outputpath)
    return(x)
  }
  if(!file.exists(path)) {
    path2 = paste0('T15lumpsplit/', path)
    path3 = paste0('inst/T15lumpsplit/', path)
    if(file.exists(path2)) path = path2
    else if(file.exists(path3)) path = path3
  }
  if(!file.exists(path))
      return(paste("inclRmd: file ", path, " not found in ", getwd()))
  knitrOutput = paste(readLines(path, warn = FALSE), collapse = '\n') %>%
    knitr::knit2html(quiet=TRUE,
                     text = ., #fragment.only = TRUE, unused argument?
                     #we should use knit2html(..., template = FALSE) instead of fragment.only = TRUE now. I just adjusted the shiny example.
                     template=FALSE,
                     options = ""
                     #,stylesheet=file.path(r_path,"../www/empty.css"
        # rmarkdown::render(quiet=TRUE,output_format = 'html_document',
                      # input = path, runtime='shiny'
    ) %>%
    gsub("&lt;!--/html_preserve--&gt;","",.) %>%
    gsub("&lt;!--html_preserve--&gt;","",.) %>%
    HTML %>%
      withMathJax %>%
    tee(., paste0(path, '.inclOutput.Rmd'))
  #if(openMe)
  #  browseURL(paste0(path, '.inclOutput.Rmd'))
  if(!missing(wd))
    setwd(savedwd)
  return(invisible(knitrOutput))
}
