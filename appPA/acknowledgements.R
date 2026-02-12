indentMe = function(...)
  fluidRow(column(12, offset=1,
                  ...)
  )

acknowledgements = div(
  # a(href='', "Published article"),
  # br(),
  strong(
    #Journal Articles: Include author(s), title, journal name, year, volume, issue, page range, and DOI. Should DOI be the URL?

    'Annals of Global Health', br(),
         'Particulate Air Pollution, Disease and Death
         in the Cities and Towns of Southwestern Pennsylvania
         ',
         br(),
         indentMe(
           em(HTML('Ella M. Whitman, BA1<br>
         Luke Bryan, BA1<br>
         Sancia Sehdev, BS1<br>
         Philip J. Landrigan, MD, MSc, FAAP1,2<br>

         &nbsp;&nbsp;&nbsp;&nbsp;
         1.	Global Observatory on Planetary Health, Schiller Institute for Integrated Science and Society, Boston College, Chestnut Hill, MA 02467, USA
         <br>&nbsp;&nbsp;&nbsp;&nbsp;
          2.	Centre Scientifique de Monaco, Monaco, MC'))
           ),
      a(target='_blank',
        href='https://annalsofglobalhealth.org/articles/10.5334/aogh.5145',
        "Year: 2026, Volume: 92 Issue: 1, Page/Article: 10, DOI: 10.5334/aogh.5145")
  )
  ,
  br(),br(),
  HTML(paste(
    '
The Breathe Project wishes to thank the people who made this mapping site possible:<br>
<br>
Public Health, Peer-Reviewed Research, DOI:  https://doi.org/10.5334/aogh.5145<br>
Ella Whitman, Luke Bryan, Sancia Sehdev, and Philip Landrigan of Global Observatory on Planetary Health, Boston College
<br>
Site Design:
Paul Fireman of Fireman Creative
    <br>Original page design&implementation: Luke Bryan, Boston College,
    <br>Western PA map page customization and expansion: Roger Day,
    <br> Volodymyr Agafonkin, creator of the "<a href=https://leafletjs.com/>leaflet</a>" Javascript package,
    <br>Creators of the "<a href=	https://github.com/rstudio/leaflet>leaflet</a>" R package,
    <br>Creators of the "<a href=	https://www.rdocumentation.org/packages/tigris>tigris</a>" R package,
    <br>Supplemental census tract information:,
    <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=,
    "https://pitt.libguides.com/pghcensus/pghcensustracts">U. Pitt Pittsburgh Census Information</a> (Christopher Lemery)
    '

  ))
)

