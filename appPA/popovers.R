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


content_FeaturePlot_Information =
  div( style= 'width: 120% !important;',
     "NOTE: ",
     br(),
     "The values plotted are for all ", strong("TRACTS"), "not communities.",
     br(),
     br(),
     indentMe(
       "The toggle '...total'/'...adjusted for population'  ",
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
     h5("If '...adjusted for population' is selected:"),
     indentMe(
       "yearly estimates are rescaled to per 1000 people.",
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
  <br>
  Here "rate" means adjusted for population: rescaled to 1000 people.
<br>
So Totals and Rates are each useful in different ways.
           <br>

      <style>
      body {
        font-family: Georgia, serif;
        max-width: 800px;
        margin: 2rem auto;
        padding: 0 1.5rem;
        line-height: 1.7;
        color: #222;
      }
    table {
      border-collapse: collapse;
      margin: 1rem 0;
      width: 100%;
    }
    th, td {
      border: 1px solid #999;
      padding: 0.5rem 1rem;
      text-align: left;
    }
    th { background-color: #f0f0f0; }
        ul { margin-top: 0.5rem; }
      li { margin-bottom: 0.25rem; }
      </style>
        </head>
        <body>

        <p><strong>Total</strong> = estimate of people harmed</p>
        <p><strong>Adjusted for population</strong> = number of people harmed <strong>per 1,000 residents</strong></p>
        <p><strong>For example:</strong></p>

        <table>
        <thead>
        <tr>
        <th></th>
        <th>Clairton</th>
        <th>Plum Borough</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td><strong>Total Deaths</strong></td>
        <td><strong>13.2</strong></td>
        <td><strong>33.82</strong></td>
        </tr>
        <tr>
        <td>Population</td>
        <td>6,620</td>
        <td>27,195</td>
        </tr>
        <tr>
        <td>Adjusted for Population</td>
        <td>1.99</td>
        <td>1.2</td>
        </tr>
        </tbody>
        </table>

        <p>Plum has more <strong>total deaths</strong> but also has over 4x the population of Clairton. When <strong>adjusted for population</strong>, Clairton has a higher rate of harm (1.99 per 1,000 residents) than Plum Borough (1.2 per 1,000). <strong>Larger communities may have more total deaths simply because more people live there. Looking at the rate helps compare communities fairly.</strong></p>



             <br>
             <strong>NOTE</strong> that the  quantities from the three buttons
             <br> under the graph are not affected by this toggle.
           <br>
             &nbsp;&nbsp;&nbsp;&nbsp;•	<strong>PM2.5 </strong>always shows the <strong>average</strong> over tracts.
           <br>
             &nbsp;&nbsp;&nbsp;&nbsp;•	<strong>Total # of people </strong>  and <strong># babies in the birth cohort</strong> always show the <strong>sum</strong> over tracts.

           <hr>'
))



