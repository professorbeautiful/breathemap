function(input, output, session) {

  includeScript('KeyHandler.js')
  observeEvent(input$ctrlDpressed, {}) # just to flush the ctrl-D press.
  shinyDebuggingPanel::makeDebuggingPanelOutput(
       session, toolsInitialState = FALSE,
       condition='ctrlDpressed === true'
      )
  includeCSS('highlight.css')
  if(file.exists('gitbranch.txt'))
    gitbranch = readLines('gitbranch.txt')

  areaFieldName = 'twt'  ## towns with tracts
  #### get_areaFieldName ####
  get_areaFieldName = function(){
    if(length(input$Id_ToggleTownTract) == 1)
      areaFieldName = input$Id_ToggleTownTract
    else
      areaFieldName = 'twt'
    print(paste('get_areaFieldName: areaFieldName=', (areaFieldName)))
    twt[['areaField']] <<-twt[[areaFieldName]]
    return(areaFieldName)   ## get_areaFieldName
    # updateSelectInput(session, "areaSelectorId", choices = PAtown)
  }


  zoomLevel = 10
  verbose = 2
  rV = reactiveValues(featureToPlot='IQ points lost',
    selectedTown = NULL, savedTract = 1, savedclick = NULL, showingModal = FALSE)
  # savedTract can be either numeric or a character entry in areaSelectorId

  print(paste('======== BEGIN server: #unspecified=',
              length(grep('unspec', twt$twt)), '======'))

  observeEvent(input$IdAck, {
    showModal(modalDialog(#footer = NULL,
      div(HTML(paste(
        'Professor Philip Landrigan, Boston College',
        '<br>Paul Fireman of Fireman Creative',
        '<br>Matt Mehalik of The Breathe Project',
        '<br>Page design&implementation: Luke Bryan, Boston College and Roger Day, U. Pittsburgh',
        '<br> Volodymyr Agafonkin, creator of the "<a href=https://leafletjs.com/>leaflet</a>" Javascript package.',
        '<br>Creators of the "<a href=	https://github.com/rstudio/leaflet>leaflet</a>" R package.',
        '<br>Creators of the "<a href=	https://www.rdocumentation.org/packages/tigris>tigris</a>" R package.',
        '<br>Supplemental census tract information:',
        '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=',
        '"https://pitt.libguides.com/pghcensus/pghcensustracts">U. Pitt Pittsburgh Census Information</a> (Christopher Lemery)'

      )))
    ))
  })
  observeEvent(input$IdMapAdvice, {
    showModal(modalDialog(#footer = NULL,
      div(HTML(paste(
        'To zoom the map, scroll over the map',
        '<br>or use the buttons at top left.',
        '<br><br>To move around,  click and drag.')
      # el="Hover to see tips for the map"
    ))))
  })

  # for centering map at the start.
  medianLON= median(as.numeric(twt$lon.tracts), na.rm=T)
  medianLAT= median(as.numeric(twt$lat.tracts), na.rm=T)

  #### fixNbhds ####
  twt$twtSaved = twt$twt
  twt$twt = twt$twt.for.tracts = twt$twt.for.towns =
    gsub( '^Pittsburgh 42', 'Pittsburgh (unspecified) 42',
          twt$twtSaved )
  updateSelectInput(session, inputId = 'areaSelectorId', choices = twt$twt)


  #### getTownsForThisTract ####
  getTownsForThisTract = function(twtTractString=rV$savedTract)
    strsplit(split = ',',
             gsub(' 42.*', '',  #### 42 = Pennsylvania
                  twtTractString ) ) [[1]]

  #### townsForAllTracts ####
  townsForAllTracts = lapply(twt$twt, getTownsForThisTract)


  clickATract = function(tractNumber) {
    if(is.character(tractNumber))
      tractNumber = match(tractNumber, twt$twt)
    if(verbose>0)
      print(paste('clickATract: ', tractNumber))
    leafletProxy("map", session) %>%
      clearGroup("selectedTractGroup") %>%
      addPolygons(data=twt[tractNumber,], weight = 1,
                  color="Red", fillColor="darkgreen",
                  label= ~twt,
                  #layerId = ~twt,
                  fillOpacity = 1, group="selectedTractGroup")
    updateSelectInput(session, "areaSelectorId",
                      selected = twt[['areaField']] [tractNumber])
    if(verbose>0)
      print(paste('clickATract: areaSelectorId: ', input$areaSelectorId))
  }

  areaSelectorObserver = observeEvent(input$areaSelectorId, {
    if (input$areaSelectorId %in% c(" ","") | is.na(input$areaSelectorId))
      updateSelectInput(inputId='areaSelectorId', selected = 1)     #### default before area is selected ####
    #if(input$areaSelectorId != rV$savedTract)
    rV$savedTract = input$areaSelectorId
    print(paste('areaSelectorObserver: ',
                'input$areaSelectorId', input$areaSelectorId))
    tractIsChanged()
  })
  savedTractObserver = observeEvent(rV$savedTract, {
    if(input$areaSelectorId != rV$savedTract)
      updateSelectInput(session, inputId = input$areaSelectorId, selected = rV$savedTract)
    tractIsChanged()
  })

  isTowns = function() { input$Id_ToggleTownTract == 'towns'}
  isTracts = function() { input$Id_ToggleTownTract == 'twt'}

  getLonLat = function(tract) {
    twtNoGeom = as.data.frame(twt)
    tract = tract[1]
    if(is.character(tract))
      datarow = which(tract == twtNoGeom$twt)
    else
      datarow = tract

    zoom = 10
    lon = twtNoGeom$lon.tracts[datarow]
    lat = twtNoGeom$lat.tracts[datarow]
    if(verbose > 1) cat('=====getLonLat:\n')
    whenceLon = 'twt$lon.tracts'
    if(verbose > 1)   print(tract)

    lonBad = function(lon){
      if(length(lon)==0) return(TRUE)
      if(is.na(lon)) return(TRUE)
      return(FALSE)
    }
    if(lonBad(lon)) {
      lon = twtNoGeom$lon.places[datarow]
      lat = twtNoGeom$lat.places[datarow]
      whenceLon = 'twt$lon.places'
      if(verbose > 1) cat("lonBad: Trying lon.places\n")
    }
    if(lonBad(lon)) {   # still missing
      if(verbose > 1) cat("lonBad: Trying lon.places.x\n")
      lon = twtNoGeom$lon.places.x[datarow]
      lat = twtNoGeom$lat.places.x[datarow]
      whenceLon = 'twt$lon.places.x'
    }
    if(lonBad(lon)) {  # if  STILL missing
      if(verbose > 1) cat("lonBad: Using medianLON, zoom = 7\n")
      lon = medianLON
      lat = medianLAT
      whenceLon = 'no LON'
      zoom=7  ## lost;  go full out.
    }
    if(verbose > 1) print(paste( datarow, 'whence=', whenceLon, tract, '\nlon.tracts', 'lon.places', 'lon.places.x\n',
                 twtNoGeom[datarow, c('lon.tracts', 'lon.places', 'lon.places.x')]))
    returnVal = (list(lon=lon, lat=lat, zoom=zoom, datarow=datarow))
    return(returnVal)
  }
  tractIsChanged = function(){
    locateMe = getLonLat(rV$savedTract)

    if(verbose > 1) print(paste('tractIsChanged: ',
                'input$areaSelectorId', input$areaSelectorId,
                'rV$savedTract', rV$savedTract,
                '   datarow', locateMe$datarow,
                locateMe$lon, locateMe$lat, locateMe$zoom))

    # removing this flyTo does not help the highlight problem
    leafletProxy("map", session) %>%
      clearGroup("selectedTractGroup") %>%
      flyTo(lng = locateMe$lon,
            lat = locateMe$lat, zoom=locateMe$zoom)

    if(isTowns()) {
      rV$selectedTown = NULL
      theseTowns = getTownsForThisTract(rV$savedTract)
      getATownFromThisTract(theseTowns)
    }
    else if(isTracts())
      showTheseTracts(rV$savedTract)

  }

 #### clicking updates selectInput ####
  observeMapClick = observeEvent(c(input$map_shape_click), {
    click = input$map_shape_click
    ### TODO  Seems ok but keep an eye on this.
    if(is.null(click))
      #updateSelectInput(session, "areaSelectorId", selected = PAtown[['areaField']] [1])
      updateSelectInput(session, "areaSelectorId", selected = twt[['areaField']] [1])

    rV$click = input$map_shape_click
    updateSelectInput(session, "areaSelectorId", selected = click$id)
    rV$savedTract = click$id
    if(verbose>1)  print(paste('copying click$id to rV$savedTract', rV$savedTract))

    showTheseTracts(rV$savedTract)
  })

  #### havetownObserver:  ok we have our town ####
  havetownObserver  = observeEvent(rV$selectedTown, {
    if(is.null(rV$selectedTown))
      return()
    if(input$Id_ToggleTownTract != 'twt') {
      if(isTRUE(input$Id_townSharesCheckbox))   ## Town share changed to  ON
        showAllTractsContaining(rV$selectedTown)
      else
        showAllTractsWithOnly(rV$selectedTown)  ## Town share changed to  OFF
    }
  })

  #### switched from twt to towns  ####
  ##same thing if clicking a new tract.
  Id_ToggleTownTractObserver_towns = observeEvent(input$Id_ToggleTownTract, {
    if(input$Id_ToggleTownTract == 'towns') {
      print(paste('input$Id_ToggleTownTract:  switched from twt to towns '))
      rV$selectedTown = NULL
      if(is.null(rV$savedTract))
        rV$savedTract = 1
      theseTowns = getTownsForThisTract(rV$savedTract)
      getATownFromThisTract(theseTowns)
    }
      # Because of the towns Modal, rely on rV$selectedTown, not a return value.
      # Now rV$selectedTown = NULL is no longer NULL, I hope.
      ### use haveTownObserver to continue  ###
  })

  #### townSharesCheckbox_Observer ####
  townSharesCheckbox_Observer = observeEvent(input$Id_townSharesCheckbox, {
    if(input$Id_ToggleTownTract != 'twt') {
      print(paste('townSharesCheckbox_Observer', rV$selectedTown,
                  '  input$Id_townSharesCheckbox', input$Id_townSharesCheckbox))
      if(isTRUE(input$Id_townSharesCheckbox))   ## Town share changed to  ON
        showAllTractsContaining(rV$selectedTown)
      else
        showAllTractsWithOnly(rV$selectedTown)  ## Town share changed to  OFF
    }
  })

  showingPittsburgh = function() #### townSharesCheckbox_Observer should be irrelevant
    (isPittsburgh(rV$savedTract) & (! input$IdNbhds) & (input$Id_ToggleTownTract == 'towns'))

  PittsburghObserver = observeEvent(#suspended = TRUE, # PittsburghObserver$resume()
    eventExpr = c(rV$savedTract, input$IdNbhds, input$Id_ToggleTownTract), {
      if(verbose > 1)
        print(paste('PittsburghObserver: showingPittsburgh()=', showingPittsburgh()))
      if(showingPittsburgh()){
        rownumbersForPittsburgh = as.vector(which(sapply(twt$twt, isPittsburgh)) )
        showTheseTracts(rownumbersForPittsburgh)
      }
      else {
        showTheseTracts(rV$savedTract)
      }
    })

  showAllTractsContaining = function(town=rV$selectedTown){
    if(input$Id_ToggleTownTract != 'towns')
      simpleError('showAllTractsContaining only if Id_ToggleTownTract = towns')
    rownumbersForTown =
      which(sapply(  townsForAllTracts, function(t) town %in% t))
    if(showingPittsburgh())   {
      rownumbersForTown = as.vector(which(sapply(twt$twt, isPittsburgh)) )
      print(paste( 'Showing all Pittsburgh as one: # tracts = ', length(rownumbersForTown)))
    }
    showTheseTracts(rownumbersForTown)
  }

  showAllTractsWithOnly = function(town=rV$selectedTown){
    if(input$Id_ToggleTownTract != 'towns')
      simpleError('showAllTractsWithOnly only if Id_ToggleTownTract = towns')
    rownumbersForTown =
      which(sapply(  townsForAllTracts, function(t) identical(town, t)))
    print(paste( 'showAllTractsWithOnly: # tracts = ', length(rownumbersForTown),
                 '   town=', rV$selectedTown))

    if(showingPittsburgh())   {
      rownumbersForTown = as.vector(which(sapply(twt$twt, isPittsburgh)) )
      print(paste( 'showingPittsburgh: # tracts = ', length(rownumbersForTown)))
    }
    if(length(rownumbersForTown) > 0)
      showTheseTracts(rownumbersForTown)
    else {
      showModal(modalDialog(title = paste('There are NO tracts where the town ', town, ' is the sole occupant. '),
                            'Turning "Town shares?" back to YES.',
                            br(),
                            "(Try 'Murrysville' for an example.)"))
      updateCheckboxInput(session = session, inputId = 'Id_townSharesCheckbox', value = TRUE)
    }
  }

  showTheseTracts = function(rownumbers) {
    if(is.character(rownumbers))  ## might be a twt (tract), or several tracts
      rownumbers = which(twt$twt %in% rownumbers)  ### notice the order!!
    locateMe = getLonLat(rV$savedTract)

    print(paste('tractIsChanged: ',
                'input$areaSelectorId', input$areaSelectorId,
                'rV$savedTract', rV$savedTract,
                '   datarow', locateMe$datarow,
                locateMe$lon, locateMe$lat, locateMe$zoom))

    print(paste('showTheseTracts:  rownumbers = ', paste(collapse='+', rownumbers),
                'dim rV$TARGETdatarows',
                paste(collapse=',', dim(rV$TARGETdatarows ))))
    if(length(rownumbers) == 0) {
      simpleError(paste(
        'showTheseTracts:  length(rownumbers) == 0,  rV$savedTract = ', rV$savedTract))
      return()
    }

    rV$TARGETrownumbers = rownumbers
    rV$TARGETdatarows = twt[rownumbers, ]
    print(paste('showTheseTracts:  rownumbers = ', paste(collapse='+', rownumbers),
                'dim rV$TARGETdatarows',
                paste(collapse=',', dim(rV$TARGETdatarows )),
                ' lat lon: ', locateMe$lat, locateMe$lon))
    leafletProxy("map", session) %>%
      clearGroup("selectedTractGroup") %>%
      flyTo(lng = locateMe$lon,
            lat = locateMe$lat, zoom=locateMe$zoom) %>%
      clearGroup("selectedTractGroup") %>%
      addPolygons(data=rV$TARGETdatarows, weight = 1,
                  color="Red", fillColor="darkgreen",
                  label= ~twt,
                  #layerId = ~twt,
                  fillOpacity = 1, group="selectedTractGroup")
  }

  #### switched from towns to twt  ####
  Id_ToggleTownTractObserver_tracts = observeEvent(input$Id_ToggleTownTract, {
    if(input$Id_ToggleTownTract == 'twt') {
      rV$selectedTown = NULL
      print(paste('input$Id_ToggleTownTract:  switched from towns to twt'))
      showTheseTracts(rV$savedTract)
    }
  })



  ####   getATownFromThisTract  observeEvent  townsForThisTract -> rV$selectedTown ####
  getATownFromThisTract = function(townsForThisTract)  {
    if(! is.null(rV$selectedTown)) {
      print(paste('getATownFromThisTract: rV$selectedTown should be NULL. ',
                  rV$selectedTown, '  tract:', rV$selectedTract))
      #print(sys.calls())  ### Error
      return(rV$selectedTown)
    }
    print(paste('getATownFromThisTract: townsForThisTract:',
                paste(collapse='+', townsForThisTract)))
    ### for now, pick the first town.  Later, pop up to pick a town.
    if(length(townsForThisTract) == 1 ){
      rV$selectedTown = townsForThisTract[1]


      print(paste('selectedTown (1): ', rV$selectedTown))
    }
    else {
        townsString = paste(collapse="+", townsForThisTract)
        print(paste('showModal: townsForThisTract:', townsString))
        showModal(  modalDialog(  # cannot test in shinyDebuggingPanel -- modal!
          title = div(span('From the tract ', rV$savedTract),  br(), span('select one town:', townsString)),
          selectInput(inputId = "modalId", label = "select a town ",
                      choices = townsForThisTract
          ),
          footer=actionButton("ok", "OK")
        ))
      }
    }

  #### modal OK ####
  observeEvent(input$ok, handlerExpr = {
    #rV$showingModal = FALSE  <== troublemaker! but why?
    rV$selectedTown = (input$modalId)
    print(paste('OK, selectedTown from Modal: ', rV$selectedTown))
    removeModal()
  })

  isPittsburgh = function(town) {
    value1 = grep('\\(Pittsburgh\\)', town, perl=T)
    value1 = (length(value1)>0)
    value2 = grep('^Pittsburgh.*unspecified', town)
    value2 = (length(value2)>0)
    value  = (value1 | value2)
    if(value) {
      # print(paste('isPittsburgh', town, value))
      # print(paste('isPittsburgh ', value1, value2,  value))
    }
    return(value)
  }


  #### leaflet output$map ####
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.PositronNoLabels", options = tileOptions(minZoom = 5, maxZoom = 13)) %>%
      setView(lng = medianLON, lat = medianLAT, zoom = 10)  %>%
      addPolygons(data = twt,
                  weight = 1,
                  color = "Black",
                  fillColor = "lightblue",
                  fillOpacity = 0.3,
                  # label is the label shown
                  #label = ~areaField, #works ok. PAtown[['NAME']] = PAtown[['areaField']]
                  label = ~twt,
                  layerId = ~twt, ## initially.
                  highlight = highlightOptions(
                    fillColor = '#224488',
                    color = "blue",
                    weight = 2,
                    fillOpacity = 0.1,
                    bringToFront = T))
  })


  # export button
  output$downloadData <- downloadHandler(
    filename = "Air-Pollution-PA.csv",
    content = function(file) {
      write.csv(twt, file)
    }
  )

  output$UITotalOrRates = renderUI( {
    fluidRow(
      column(5, strong( "As total or as rate?")),
      column(7,
             radioButtons(inputId='IdTotalOrRate',
                          label=NULL,
                          choices=c('...total', '...rate per 1000'),
                          selected='...total',
                          inline=TRUE)
      )
    )
  })

  rvIdMakeReferenceCommunity = reactiveValues(referenceCommunity=NULL)

  output$IdUiForReferenceCommunity = renderUI( {
    if(is.null(rvIdMakeReferenceCommunity$referenceCommunity)) {
      rvIdMakeReferenceCommunity$referenceCommunity =
        input$areaSelectorId
    }
    div(
    strong(style='color:red',
           actionButton('IdMakeReferenceCommunity',
                        label =
                          span(span(style='color:red', "Set"),
                               span(style='color:darkgreen',"currently selected"),
                               span(style='color:red', "as reference community? (Red lozenge)"
                          ))
           )),
    br(),
    fluidRow(  style='color:red',  column(3, strong( "Current reference:")),
                        column(9, textOutput(outputId = 'IdReferenceCommunity')
                        ))
    )
  # else return(
  #     fluidRow(style='color:red',
  #       column(6, strong("Current reference community", br(), strong("(red lozenge):"))),
  #       column(6,   textOutput(outputId = 'IdReferenceCommunity')
  #   )))
  })

  #### featureList  functions ####
  #feat.countsPer1000 presumes that feature is in counts of people.
  safe.sum = function(x) sum(as.numeric(x), na.rm=T)
  feat.countsPer1000 = function(rows=rV$TARGETrownumbers)
    1000 * safe.sum(getThisAreaFeature(rows)) /
    safe.sum(getThisAreaPopulation(rows))

  #feat.pop.weightedAverage presumes that feature is a rate.
  feat.pop.weightedAverage = function(rows=rV$TARGETrownumbers) { ## used only for PM2.5.
    safe.sum(getThisAreaFeature(rows)*getThisAreaPopulation(rows)) /
    safe.sum(getThisAreaPopulation(rows))
  }
  feat.sum = function() safe.sum(getThisAreaFeature(rows=rV$TARGETrownumbers))
  # feat.mean = function() mean(getThisAreaFeature(), na.rm=T)  # raw mean, not pop-weighted.

  cq = function(s, split=',') strsplit(split=split, s)[[1]]

  makeItARate = function(){
    (rV$featureToPlot %in% featureList) &
      (input$IdTotalOrRate == '...rate per 1000') &
      (rV$featureToPlot != "PM2.5 average")
  }

  popIsZero = function()
    which(twt[["Total Population (2019)"]] == 0)

  thisAreaFeatureDistribution = function() {  ### ALL rows
    distribution = twt[[rV$featureToPlot]]   ### values for all tracts
    if(makeItARate() ) {
      distribution = distribution * 1000 / twt[["Total Population (2019)"]]
      distribution = distribution[ - c(378, 140, popIsZero() )  ]
      # 126 323 459 490 518 529 603 607 624
         ### Also 2 outliers, see 1/29 entries in  NOTES 2026-01-28

    }
    # if(! length(distribution) == nrow(twt))
    #   stop("error in thisAreaFeatureDistribution")
    return(distribution)
  }

  thisAreaFeatureSummary = function(var = rV$featureToPlot,
                                    applyTo= rV$TARGETrownumbers,
                                    verbose=T) {
    featureName = rV$featureToPlot
    data = twt[[featureName]] [applyTo]
    if(verbose){
      print(paste('thisAreaFeatureSummary: input$IdTotalOrRate: ', input$IdTotalOrRate))
      print(paste('thisAreaFeatureSummary: var: ', var, ' data: ', paste(data, collapse=',')))
    }
    if(var %in% "PM2.5 average")
      return(feat.pop.weightedAverage())
    else if(var %in% infoList)
      return(feat.sum())   # people;  babies; but not PM2.5
    if(input$IdTotalOrRate == '...total'){
        return(feat.sum())  # uses safe.sum
    } else if(makeItARate()){
      print(paste('feat.countsPer1000:', str(feat.countsPer1000())) )
      return( data * 1000 / twt[["Total Population (2019)"]][applyTo])

    }
    else stop('ERROR in thisAreaFeatureSummary')
  }

  getThisAreaFeature = function(rows=rV$TARGETrownumbers){    ### length of TARGETrownumbers
    # thisFeature = as.numeric(twt[[input$idFeature]])
    print(paste('getThisAreaFeature:', input$idFeature, ' rows:',
                paste(collapse = ',',  rows)) )
    return(as.numeric(twt[rows, rV$featureToPlot]))
  }

  getThisAreaPopulation = function(rows=rV$TARGETrownumbers){
    ### we can call with rows=rV$referenceRow
    ### length of TARGETrownumbers
    ### NOT safe.sum  here.
    return((as.numeric(twt[rows, "Total Population (2019)"])))
  }


  addSpaces = function(n) rep('&nbsp;', n)


  observeEvent(input$IdMakeReferenceCommunity, {
    rvIdMakeReferenceCommunity$referenceCommunity =
      input$areaSelectorId
    tractNumber = which(input$areaSelectorId == twt$twt)
    leafletProxy('map', session) %>%
      clearGroup("referenceTractGroup") %>%
      addPolygons(data=twt[tractNumber,], weight = 1,
                  color="Red", fillColor="red",
                  label= ~twt,
                  #layerId = ~twt,
                  fillOpacity = 1, group="referenceTractGroup")

  })
  output$IdReferenceCommunity = renderText( {
    rvIdMakeReferenceCommunity$referenceCommunity
  })

  output$communityShown = renderUI({

    if(get_areaFieldName()=='towns') {
      if(isTRUE(rV$showingPittsburgh))
        firstLine = 'Selected all Pittsburgh from selecting...'
      else
        firstLine = "Selected community:"
    }
    else firstLine = "Selected community/tract:"

    div(
      span(
        strong(firstLine
        ),
        span(
          style='color:green',
          paste(switch(get_areaFieldName(),
                       towns=rV$selectedTown,
                       twt=rV$savedTract))))

    )
  })

  output$histTitle = renderUI( {  #### histTitle ####
    # thisFeature = (twt[[rV$featureToPlot]])
    div(
        span(strong("Selected feature: "),  #### selected feature ####
             span(
               style='color:green', decorateFeatureName(), ' = ',
             signif(digits=3,
                    thisAreaFeatureSummary() ) )
             #### TODO: which features do we sum, which do we mean?
             ### population is char for some reason.
        ),
        br(),
        # span('--------------------',
        #      '(summarized by ', strong(gsub('^feat.', '', featureSummaryFunctionTable[input$idFeature, 'func'])), ')'
        # ),
        # br(),
        uiOutput('proportion_smaller')
    )
  })



  output$proportion_smaller <- renderUI({
    howManyLess = try({
      thisAreaFeatureDistribution() < thisAreaFeatureSummary()
#        PAtown[[input$idFeature]] [PAtown$areaField==input$areaSelectorId]
    })
    if (class(howManyLess) == 'try-error')
      howManyLess = 0
#    paste("Ranking among tracts:",
    percentile = round(mean(na.rm = TRUE, howManyLess * 100))
    percentile = paste0(percentile,
           switch(paste0('x',
                         percentile %% 10), x1 = 'st', x2='nd', 'th')
    )
    span(strong("Compared with entire region: "),
         span(style='color:green', percentile, 'percentile'
               ) )
  })


  decorateFeatureName = function() {
    f = rV$featureToPlot
    if(f=='All-cause deaths')
      f = 'All-cause deaths: avg Lepeule & Laden'
    if(f %in% infoList) return(f)
    if(input$IdTotalOrRate == '...total')
      paste(f, '(estimated total)')
    else
      paste(f, '(rate per 1000)')
  }

  observeEvent(input$idFeature, {
    print(paste('updating rV$featureToPlot: '))
    rV$featureToPlot = input$idFeature
  })


  observeEvent(input$`IdShowPM2.5`, {
    print('changing rV$featureToPlot via IdShowPM2.5'   )
    rV$featureToPlot = infoListIds$var[which(infoListIds$id == 'IdShowPM2.5')]
  })
  observeEvent(input$`IdShowPop`, {
    print('changing rV$featureToPlot via IdShowPop'   )
    rV$featureToPlot = infoListIds$var[which(infoListIds$id == 'IdShowPop')]
  })
  observeEvent(input$`IdShowCohort`, {
    # Total Population (2019)
    print('changing rV$featureToPlot via IdShowCohort'   )
    rV$featureToPlot = infoListIds$var[which(infoListIds$id == 'IdShowCohort')]
  })

  output$featurePlot <- renderPlot({

    thisFeature = as.numeric(twt[[rV$featureToPlot]])
    thisAreaFeature = thisAreaFeatureSummary()

    xlab = decorateFeatureName()
    hist(thisAreaFeatureDistribution(),
         xlab=xlab, ylab = 'number of census tracts',
         main = '',
         cex.lab=1.5)
    abline(v=thisAreaFeatureSummary(),
                        lwd=3, col='darkgreen')
    arrows(x0 = thisAreaFeatureSummary(), y0 = 0,
           x1 = thisAreaFeatureSummary(), y1= par('usr')[4]*1.2, xpd=NA,
           col='darkgreen', lwd=3)
    text(x = thisAreaFeatureSummary(), y=par('usr')[4]*(1.2 + 0.06), xpd=NA,
         label = signif(digits=3, thisAreaFeatureSummary()),
         col='darkgreen', cex=1.5)
    if(! is.null(rvIdMakeReferenceCommunity$referenceCommunity)) {
      REFERENCEdatarows =   ### now just the ref tract.
        which(twt$twt ==
                rvIdMakeReferenceCommunity$referenceCommunity)
      print(paste('REFERENCEdatarows', REFERENCEdatarows))
      refValue = as.numeric(
        twt[[input$idFeature]]  [REFERENCEdatarows])
      if(makeItARate() )
        refValue = 1000 * refValue
      points( refValue, 0, cex=2, col='red', pch='⬧', xpd=NA)
    }
  })

  ### popovers--  popify or tipify work, but these don't.
  # addPopover(session, id='IdNbhds',title = 'Pittsburgh Neighborhood toggle',
  #            content = '...in progress.', placement='top', trigger='hover')
  # addPopover(session, id='areaSelectorId',title = 'census tracts',
  #            content = 'with town names when available', placement='top', trigger='hover')
  #source('popovers.R')
}


