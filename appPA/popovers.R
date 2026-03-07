#### popovers using shinyBS

### doesn't work as popify, or with id=IdfeaturePlotforpopover on the div().
indentMe = function(...)
  fluidRow(column(12, offset=1,
                  ...)
  )

### make IQ  html
### To change text, edit the file IQ-faq.Rmd?  NO.  Using the html.
#knitr::knit2html(input = 'IQ-faq.Rmd', output = 'www/IQ-faq.html')
content_IQdiscussion = readLines('www/IQ-faq.html')
#### clunky but necessary to avoid the artifacts!
#### Before this cleanup,
### without HTML() no diag line problem, but not HTML.
### with HTML() looks good but diag line problem
### Claude had added in complete web page header info!

content_IQdiscussion = content_IQdiscussion[
  (grep('<body>', content_IQdiscussion) + 1)
  : (grep('</body>', content_IQdiscussion) - 1)
]








