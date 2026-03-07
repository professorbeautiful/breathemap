#### popovers using shinyBS

### doesn't work as popify, or with id=IdfeaturePlotforpopover on the div().
indentMe = function(...)
  fluidRow(column(12, offset=1,
                  ...)
  )



### make IQ popup html
### To change text, edit the file IQ-faq.Rmd
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

content_LifetimeHarm_Information.html =
'<br><h4> Lifetime harms</h4>
      •	Lifetime earnings lost.
      <br>
    •	IQ points lost
  <hr>
  These estimates are calculate from externally validated models
  using our birth cohort counts for 2019.
  <br>
  "Birth cohort" refers to the number of babies born in a tract or community in 2019.
  <br>
  (The estimates are not obtained by fitting IQ or earnings data over our region.)
  <br>
  Details are in the research article
  <a href=https://annalsofglobalhealth.org/articles/10.5334/aogh.5145 target=_blank>
  <br>
  Particulate Air Pollution, Disease, and Death in the Cities and Towns of Southwestern Pennsylvania,
  <br>
  <strong>
E. M. Whitman,
L. Bryan,
S. Sehdev,
P. J. Landrigan
</strong></a>
  <br><br>
  <h3>Using IQ as an indicator of environmental harms</h3>
  IQ has a history of being abused to advance racist doctrines.
  <br> For an extensive discussion of the ethical issues,
      <a href="IQ-faq.html" target=_blank> click here . </a>
      <br>
      The conclusion of the study concerning IQ are, in brief:
      <br>
      <blockquote>
      Among the 24,604 children born in the Pittsburgh MSA in 2019,
      PM2.5 pollution was linked to the loss of 60,668 full‑scale IQ points,
      resulting in estimated lifetime economic losses of $2.7 billion.
      </blockquote>
      <br>
      For details extracted from the Whitman et al article,
      <a href="article-results-on-IQ.html" target=_blank> click here . </a>

    '

content_LifetimeHarm_Information = div(
  HTML(paste(collapse=' ',
             content_LifetimeHarm_Information.html
             )
  )
)







