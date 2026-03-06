#### popovers using shinyBS

### doesn't work as popify, or with id=IdfeaturePlotforpopover on the div().
indentMe = function(...)
  fluidRow(column(12, offset=1,
                  ...)
  )



### make IQ popup html
### To change text, edit the file IQ-faq.Rmd
knitr::knit2html(input = 'IQ-faq.Rmd', output = 'IQ-faq.html')
content_IQdiscussion = readLines('IQ-faq.html')
#### clunky but necessary to avoid the artifacts!
#### Before this cleanup,
### without HTML() no diag line problem, but not HTML.
### with HTML() looks good but diag line problem

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
  Details are in <a href=https://annalsofglobalhealth.org/articles/10.5334/aogh.5145 target=_blank>
  Whitman et al.</a>
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
      For details extracted from the article,
      <a href="article-results-on-IQ.html" target=_blank> click here . </a>

    '

content_LifetimeHarm_Information = div(
  HTML(paste(collapse=' ',
             content_LifetimeHarm_Information.html
             )
  )
)


#  this did not work well!!
# addPopover(session = session, trigger = 'focus',  #### not used.
#            placement = 'bottom',
#            id="IQ points lost" ,
#            title = 'Using IQ to measure harm',
#            content=div('TODO')
# )

content_FeaturePlot_Information =
  div( style= 'width: 120% !important;',
     "NOTE: ",
     br(),
     "The values plotted are for all ", strong("TRACTS"), "not communities.",
     br(),
     br(),
     indentMe(
       "The toggle '...total'/'...rescaled to 1000 people'  ",
       br(),
       "is in effect for the nine ", strong("'harm'"),
       "features at the top.",
       br(),
       "but irrelevant for the three ",
       br(),
       strong("'information'"),
       "features along the bottom.)"
     ),
     h5("If '...total' is selected:"),
     indentMe(
       "Yearly EXCESS harm estimates are totalled ",
       br(),
       "for the selected tract or community.",
       br(),
       "If 'communities/tracts' is set to 'communities',",
       br(),
       "this total is the sum",
       br(),
       "across the communities currently selected."
     ),
     h5("If '......rescaled to 1000 people' is selected:"),
     indentMe(
       "Yearly estimates are rescaled to per 1000 people.",
       br(),
       "If 'communities/tracts' is set to 'communities',",
       br(),
       "the rescaling is done combining  ",
       br(),
       "across the communities currently selected."

     ),
     h6("Outlier handling:"),
     indentMe(
       indentMe(
         "Outliers not on the graph ",
         br(),
         "are listed on the right side of the graph,",
         br(),
         " and in a quantile popover",
         br(),
         "To remove outlier handling, ",
         br(),
         "click in 'outlier quantile' box and delete."
       ),
       h6("Special KEYS for the outlier handling:"),
       indentMe(
         "Type  ", strong('9'), " for a popover to open the outlier quantile dialog",
         br(),  ' while setting the outlier quantile to 0.999. ',
         br(),
         "Type capital ", strong('O'), " for a popover to open the outlier quantile dialog",
         br(),  ' while setting the outlier quantile (no  outlier handling). ',
         br()

       ),
       "Type capital ", strong('H'), " to toggle between ",
       "histogram and density plot.",
     ),
     HTML(paste(rep('-', 50)) )
)

content_TotalOrRates_Information = HTML(paste(collapse=' ',

  '•	<strong> Totals versus rates</strong> .
<br>
  Totals give a sense of actual people harmed (and sum over tracts when appropriate).
<br>
  Rates allow for comparisons among different regions.
<br>So Totals and Rates (rescaled to 1000) are each useful in different ways.
<br>Hover over the histogram\'s information button to see an explanation of
           "...total" versus "...rescaled to 1000 people".
           <br>
             <br>
             <strong>NOTE</strong> that the three quantities are not affected by this toggle.
           <br>
             &nbsp;&nbsp;&nbsp;&nbsp;•	<strong>PM2.5 </strong>always shows the <strong>average</strong> over tracts.
           <br>
             &nbsp;&nbsp;&nbsp;&nbsp;•	<strong>Total # of people </strong>  and <strong># in the birth cohort</strong> always show the <strong>sum</strong> over tracts.

           <hr>'
))
# addPopover(session = session, trigger = 'click',
#            placement = 'left',
#            id='Id_TotalOrRates_popover',
#            title = 'About Totals and Rates:',
#            content=content_TotalOrRates_popover
# )

###  Changing to button click event.
addPopover(session = session,
           placement = 'left',
           id='IdfeaturePlotforpopover',
           title = 'About this graph:',
           content=div( style= 'width: 120% !important;',
             "NOTE: ",
             br(),
             "The values plotted are for all ", strong("TRACTS"), "not communities.",
             br(),
             br(),
             indentMe(
             "The toggle '...total'/'...rescaled to 1000 people'  ",
             br(),
             "is in effect for the nine ", strong("'harm'"),
             "features at the top.",
             br(),
             "but irrelevant for the three ",
             br(),
             strong("'information'"),
             "features along the bottom.)"
             ),
             h5("If '...total' is selected:"),
             indentMe(
               "Yearly EXCESS harm estimates are totalled ",
               br(),
               "for the selected tract or community.",
               br(),
               "If 'communities/tracts' is set to 'communities',",
               br(),
               "this total is the sum",
               br(),
               "across the communities currently selected."
             ),
             h5("If '......rescaled to 1000 people' is selected:"),
             indentMe(
               "Yearly estimates are rescaled to per 1000 people.",
               br(),
               "If 'communities/tracts' is set to 'communities',",
               br(),
               "the rescaling is done combining  ",
               br(),
               "across the communities currently selected."

             ),
             h6("Outlier handling:"),
             indentMe(
               indentMe(
                 "Outliers not on the graph ",
                 br(),
                 "are listed on the right side of the graph,",
                 br(),
                 " and in a quantile popover",
                 br(),
                 "To remove outlier handling, ",
                 br(),
                 "click in 'outlier quantile' box and delete."
             ),
             h6("Special KEYS for the outlier handling:"),
             indentMe(
               "Type  ", strong('9'), " for a popover to open the outlier quantile dialog",
               br(),  ' while setting the outlier quantile to 0.999. ',
               br(),
               "Type capital ", strong('O'), " for a popover to open the outlier quantile dialog",
               br(),  ' while setting the outlier quantile (no  outlier handling). ',
               br()

               ),
             "Type capital ", strong('H'), " to toggle between ",
             "histogram and density plot.",
             ),
             HTML(paste(rep('-', 50)) )
           ), trigger='hover'
)


