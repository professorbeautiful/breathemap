function(input, output, session) {
  source('coloring.R')
  source('popovers.R', local = T)

  includeScript('KeyHandler.js')
  observeEvent(input$ctrlDpressed, {}) # just to flush the ctrl-D press.
  shinyDebuggingPanel::makeDebuggingPanelOutput(
    session, toolsInitialState = FALSE,
    condition='ctrlDpressed === true'
  )
  includeCSS('highlight.css')
  includeCSS('buttons.css')

  if(file.exists('gitbranch.txt'))
    gitbranch = readLines('gitbranch.txt')

  areaFieldName = 'twt'  ## towns with tracts
  #### get_areaFieldName ####
  get_areaFieldName = function(){
    if(length(input$Id_ToggleTownTract) == 1)
      areaFieldName = input$Id_ToggleTownTract
    else
      areaFieldName = 'twt'
    if(verbose>2)
      print(paste('get_areaFieldName: areaFieldName=', (areaFieldName)))
    twt[['areaField']] <<-twt[[areaFieldName]]
    return(areaFieldName)   ## get_areaFieldName
  }


  zoomLevel = 10
  verbose = 1
  rV = reactiveValues(featureToPlot='IQ points lost',
                      selectedTown = NULL,
                      savedTract = 'Clairton 42003492700',
                      savedclick = NULL, showingModal = FALSE)
  # savedTract can be either numeric or a character entry in areaSelectorId

  print(paste('======== BEGIN server: #unspecified=',
              length(grep('unspec', twt$twt)), '======'))
  source('acknowledgements.R')
  observeEvent(input$IdAck, {
    showModal(modalDialog(#footer = NULL,
      acknowledgements
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

  #
  # clickATract = function(tractNumber) {   #NEVER CALLED!!!
  #   if(verbose>0)
  #     print(paste('clickATract: ', tractNumber))
  #   if(is.character(tractNumber))
  #     tractNumber = match(tractNumber, twt$twt)
  #   if(verbose>0)
  #     print(paste('clickATract: ', tractNumber))
  #   leafletProxy("map", session) %>%
  #     clearGroup("selectedTractGroup") %>%
  #     addPolygons(data=twt[tractNumber,], weight = 1,  #  twt has the geom data
  #                 color="Red", fillColor="darkgreen",
  #                 label= ~twt,
  #                 #layerId = ~twt,
  #                 fillOpacity = 1, group="selectedTractGroup")
  #   updateSelectInput(session, "areaSelectorId",
  #                     selected = twt[['areaField']] [tractNumber])
  #   if(verbose>0)
  #     print(paste('clickATract: areaSelectorId: ', input$areaSelectorId))
  # }

  areaSelectorObserver = observeEvent(input$areaSelectorId, {
    print(paste('0 areaSelectorObserver: rV$savedTract' , rV$savedTract,
                'input$areaSelectorId' , input$areaSelectorId))
    if (input$areaSelectorId %in% c(" ","") | is.na(input$areaSelectorId)) {
      rV$savedTract = 'Clairton 42003492700'
      updateSelectInput(inputId='areaSelectorId',
                        selected = 'Clairton 42003492700')      #### default before area is selected ####
      printpaste('1 Clairton areaSelectorObserver, input$areaSelectorId' ,input$areaSelectorId)
    }
    print(paste('1  areaSelectorObserver, input$areaSelectorId' ,input$areaSelectorId))
    #if(input$areaSelectorId != rV$savedTract)
    rV$savedTract = input$areaSelectorId
    if(verbose>0) {
      print(paste('2 areaSelectorObserver: ',
                  'input$areaSelectorId', input$areaSelectorId))
    }
    tractIsChanged('areaSelectorObserver')
  })
  savedTractObserver = observeEvent(rV$savedTract, {
    if(verbose> 0 )
      printpaste('savedTractObserver:  rV$savedTract: ', rV$savedTract)
    if(input$areaSelectorId != rV$savedTract)
      updateSelectInput(session, inputId = input$areaSelectorId, selected = rV$savedTract)
    tractIsChanged('savedTractObserver')
  })

  isTowns = function() { input$Id_ToggleTownTract == 'towns'}
  isTracts = function() { input$Id_ToggleTownTract == 'twt'}

  getLonLat = function(tract) {
    twtNoGeom = data.frame(twt)
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
  tractIsChanged = function(whoCalled='unknown'){
    printpaste('tractIsChanged: whoCalled', whoCalled)
    locateMe = getLonLat(rV$savedTract)

    if(verbose > 0) print(paste('tractIsChanged: ',
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
      updateSelectInput(session, "areaSelectorId", selected = 'Clairton 42003492700')

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
        rV$savedTract = 'Clairton 42003492700'
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
      if(verbose>0)
        print(paste( 'Showing all Pittsburgh as one: # tracts = ', length(rownumbersForTown)))
    }
    showTheseTracts(rownumbersForTown)
  }

  showAllTractsWithOnly = function(town=rV$selectedTown){
    if(input$Id_ToggleTownTract != 'towns')
      simpleError('showAllTractsWithOnly only if Id_ToggleTownTract = towns')
    rownumbersForTown =
      which(sapply(  townsForAllTracts, function(t) identical(town, t)))
    if(verbose>0)
      print(paste( 'showAllTractsWithOnly: # tracts = ', length(rownumbersForTown),
                   '   town=', rV$selectedTown))

    if(showingPittsburgh())   {
      rownumbersForTown = as.vector(which(sapply(twt$twt, isPittsburgh)) )
      if(verbose>0)
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

    if(verbose > 0)
      print(paste('showTheseTracts: ',
                  'input$areaSelectorId', input$areaSelectorId,
                  'rV$savedTract', rV$savedTract,
                  '   datarow', locateMe$datarow,
                  locateMe$lon, locateMe$lat, locateMe$zoom))

    if(verbose > 0)
      print(paste('showTheseTracts:  rownumbers = ', paste(collapse='+', rownumbers),
                  'dim rV$TARGETdatarows',
                  paste(collapse=',', dim(rV$TARGETdatarows ))))
    if(length(rownumbers) == 0) {
      simpleError(paste(
        'showTheseTracts:  length(rownumbers) == 0,  rV$savedTract = ', rV$savedTract))
      return()
    }

    rV$TARGETrownumbers = rownumbers
    rV$TARGETdatarows = twt[rownumbers, ]  # must be twt not PAtowndata
    if(verbose>2)
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
      write.csv(twt.df, file)
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
      strong(class='reference',
             actionButton('IdMakeReferenceCommunity',
                          label =
                            span(span(style=referenceColorStyle, "Set"),
                                 span(style='color:darkgreen',"currently selected"),
                                 span(style=referenceColorStyle, "as reference community? (Red lozenge)"
                                 ))
             )),
      br(),
      fluidRow( style=referenceColorStyle,  class='reference',  column(3, strong( "Current reference:")),
                column(9, textOutput(outputId = 'IdReferenceCommunity')
                ))
    )
  })

  #### featureList  functions ####
  #feat.countsPer1000 presumes that feature is in counts of people.
  safe.sum = function(x) sum(as.numeric(x), na.rm=T)

  feat.countsPer1000 = function(rows=rV$TARGETrownumbers)
    1000 * safe.sum(getThisAreaFeature(
      rows=rows, rV$featureToPlot,
      whoCalled='feat.countsPer1000') /
        safe.sum(getThisAreaPopulation(rows=rows)) )

  #feat.pop.weightedAverage presumes that feature is a rate.
  feat.pop.weightedAverage = function(rows=rV$TARGETrownumbers) { ## used only for PM2.5.
    safe.sum(getThisAreaFeature(rows,whoCalled = 'feat.pop.weightedAverage')*
               getThisAreaPopulation(rows)) /
      safe.sum(getThisAreaPopulation(rows))
  }
  feat.sum = function(rows=rV$TARGETrownumbers){
    if(verbose>2)
      print(paste('feat.sum: rows=' ,  rows))
    #print(sys.call())
    safe.sum(getThisAreaFeature(rows, whoCalled='feat.sum'))
  }
  # feat.mean = function() mean(getThisAreaFeature(), na.rm=T)  # raw mean, not pop-weighted.

  cq = function(s, split=',') strsplit(split=split, s)[[1]]

  makeItARate = function(){
    (rV$featureToPlot %in% featureList) &
      (input$IdTotalOrRate == '...rate per 1000') &
      (rV$featureToPlot != "PM2.5 average")
  }

  popIsZero = function()
    which(twt[["Population in 2019"]] == 0)  ##  ok.

  thisAreaFeatureDistribution = function() {  ### ALL rows
    distribution = data.frame(twt)[[toDots(rV$featureToPlot)]]   ### values for all tracts
    if(makeItARate() ) {
      distribution = sapply(1:nrow(twt),
                            function(row)
                              feat.countsPer1000(row)
      )
      # you can't have a rate with no population.
      distribution = distribution[ - popIsZero()  ]

      # 126 323 459 490 518 529 603 607 624
    }
    return(distribution)
  }

  # total.communities()

  thisAreaFeatureList = function(var = rV$featureToPlot,
                                 applyTo= rV$TARGETrownumbers,
                                 verbose=T) {
    featureName = toDots(rV$featureToPlot)
    data = data.frame(twt)[[featureName]] [applyTo]
    if(makeItARate()){
      if(verbose>1)
        print(paste('feat.countsPer1000:', str(feat.countsPer1000())) )
      pops = data.frame(twt)[[toDots("Population in 2019")]][applyTo]

      data = ( 1000 * (data) / (pops) )
      data = data[ - popIsZero()]
    }
    if(verbose> 2){
      print(paste('thisAreaFeatureList:  ', input$IdTotalOrRate,
                  ' applyTo',  paste(collapse=',', applyTo),
                  'var: ', var, ' data: ', paste(data, collapse=',')))
    }
    return(data)
  }
  thisAreaFeatureSummary = function(var = rV$featureToPlot,
                                    applyTo= rV$TARGETrownumbers,
                                    verbose=T) {
    #### Combines the numbers from thisAreaFeatureList into a single number.
    data = thisAreaFeatureList(var, applyTo, verbose)
    if(var %in% "PM2.5 average")
      return(feat.pop.weightedAverage(applyTo))
    else if(var %in% infoList)
      return(feat.sum(rows = applyTo))   # people;  babies; but not PM2.5
    if(input$IdTotalOrRate == '...total'){
      return(feat.sum(rows = applyTo))  # uses safe.sum
    } else if(makeItARate()){
      if(verbose>1)
        print(paste('feat.countsPer1000:', str(feat.countsPer1000())) )
      pops = data.frame(twt)[[toDots("Population in 2019")]][applyTo]
      pops =  pops [- popIsZero()]
      # data are already rates per 1000,
      #  and pops is already cleaned in thisAreaFeatureList, so...
      #  return( safe.sum(data * pops) / safe.sum(pops) )
      return( sum(data * pops) / sum(pops) )
    }
    else stop('ERROR in thisAreaFeatureSummary')
  }


  getThisAreaFeature = function(rows=rV$TARGETrownumbers,
                                feature=rV$featureToPlot,
                                whoCalled='unknown'){
    ### total, not rate
    ### length of TARGETrownumbers
    # thisFeature = as.numeric(twt[[input$idFeature]])
    if(verbose>1)
      print(paste('whoCalled: ', whoCalled))
    if(verbose>2)
      print(paste('getThisAreaFeature: with twt', feature, ' rows:',
                  paste(collapse = ',',  rows)))

    feature = toDots(feature)   #### yikes!
    #print(toDots(feature))
    returnValue = as.numeric(data.frame(twt)[[feature]][rows])
    if(verbose>2)
      print(paste('getThisAreaFeature: with twt', feature, ' rows:',
                  paste(collapse = ',',  rows),
                  '  returnValue: ', paste(collapse = ',', returnValue)
      ) )
    return(returnValue)
  }

  getThisAreaFeatureOK = function(rows=rV$TARGETrownumbers,
                                  feature=rV$featureToPlot){
    return((as.numeric(twt[[feature]] [rows])))
  }

  getThisAreaPopulation = function(rows=rV$TARGETrownumbers){
    ### we can call with rows=rV$referenceRow
    ### length of TARGETrownumbers
    ### NOT safe.sum  here.
    return((as.numeric(twt[["Population in 2019"]] [rows])))
  }


  addSpaces = function(n) rep('&nbsp;', n)


  observeEvent(input$IdMakeReferenceCommunity, {
    rvIdMakeReferenceCommunity$referenceCommunity =
      input$areaSelectorId
    tractNumber = which(input$areaSelectorId == twt$twt)
    leafletProxy('map', session) %>%
      clearGroup("referenceTractGroup") %>%
      addPolygons(data=twt[tractNumber,], weight = 1,
                  color=referenceColor, fillColor=referenceColor,
                  label= ~twt,
                  #layerId = ~twt,
                  fillOpacity = 1, group="referenceTractGroup")

  })
  output$IdReferenceCommunity = renderText( {
    rvIdMakeReferenceCommunity$referenceCommunity
  })
  #### makeFeatureActionButtonObserver####
  makeFeatureActionButtonObserver = function(feat) {
    thisId = paste0('idFeature', gsub(' ', '_', feat))
    observerName = paste('featureActionButtonObserver_', thisId)
    if(verbose>2)
      print(paste('makeFeatureActionButtonObserver: \nthisId=', thisId,
                  '\nobserverName=', observerName))
    assign(observerName,  inherits=TRUE,
           observeEvent(input[[ thisId ]],
                        {
                          if(verbose>2)
                            print(paste('updating rV$featureToPlot: '))
                          rV$featureToPlot = feat
                          shinyjs::addCssClass(thisId, class='buttonPressed')
                        }
           )
    )
    if(verbose>2)
      print(paste('find observerName:', find(observerName)))
  }

  sapply(featureList, makeFeatureActionButtonObserver)

  #### makeFeatureActionButton ####
  makeFeatureActionButton = function(feat) {
    inputId = paste0('idFeature', gsub(' ', '_', feat))
    size='sm'  # no effect.
    #    feat = gsub('Childbirth', '', feat)
    if(feat %in% c("Ischemic Heart Disease Deaths",
                   "Myocardial Infarctions"))
      ButtonStyle =
      paste(rightSideButtonStyle, '; font-size:8px')
    else if(feat %in% c("All-cause deaths",
                        "Lung Cancer Deaths"))
      ButtonStyle =
      paste(rightSideButtonStyle, '; font-size:10px')
    else ButtonStyle = rightSideButtonStyle
    feat = gsub('[dD]eaths', '', feat)
    actionButton(style=ButtonStyle,
                 inputId = inputId,
                 label=feat)
  }

  #### uiFeatureList button panel ####
  output$uiFeatureList = renderUI({
    buttons = lapply(featureList, function(feat) {
      makeFeatureActionButton(feat)
    })
    buttonsFixed =
      div(
        div(style='text-align: center; margin:auto',
            "Birth cohort", buttons[1:2]),
        div(style='text-align: center; margin:auto',
            "Perinatal:" , buttons[7:9]),
        div(style='text-align: center; margin:auto; ',
            "Death, disease:", buttons[3:6])

      )

    # style=' border-radius: 0px; margin:0px;
    #       justify-content: space-between;',

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
    if(  total.communities()  & length(thisAreaFeatureList() > 1) )
      return('proportion_smaller would not make sense ')
    #### proportion_smaller would not make sense
    howManyLess = try({
      thisAreaFeatureDistribution() < thisAreaFeatureSummary()
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
    if(verbose > 1)
      print(paste('input$IdTotalOrRate', length(input$IdTotalOrRate)))
    needIdTotalOrRate <<- NULL
    try(silent = TRUE, {
      needIdTotalOrRate <<- is.null(input$IdTotalOrRate) |
        is.na(input$IdTotalOrRate) |
        length(input$IdTotalOrRate) == 0
      if(length(needIdTotalOrRate) == 0 )
        needIdTotalOrRate <<- TRUE
      if(isTRUE(needIdTotalOrRate) ) {
        updateRadioButtons(session, 'IdTotalOrRate',
                           selected = '...total')
        if(verbose>0)
          printpaste('needIdTotalOrRate is TRUE, setting IdTotalOrRate',
                     input$IdTotalOrRate, '- done' )
      }
    })
    if(isTRUE(needIdTotalOrRate) )
      paste(f, '(estimated total)')
    else  if(input$IdTotalOrRate == '...total')
      paste(f, '(estimated total)')
    else
      paste(f, '(rate per 1000)')
  }
  #
  # observeEvent(input$idFeature, {
  #   # print(paste('updating rV$featureToPlot: '))
  #   rV$featureToPlot = input$idFeature
  # })


  observeEvent(input$`IdShowPM2.5`, {
    print('changing rV$featureToPlot via IdShowPM2.5'   )
    rV$featureToPlot = infoListIds$var[which(infoListIds$id == 'IdShowPM2.5')]
  })
  observeEvent(input$`IdShowPop`, {
    print('changing rV$featureToPlot via IdShowPop'   )
    rV$featureToPlot = infoListIds$var[which(infoListIds$id == 'IdShowPop')]
  })
  observeEvent(input$`IdShowCohort`, {
    # Birth Cohort in 2019
    print('changing rV$featureToPlot via IdShowCohort'   )
    rV$featureToPlot = infoListIds$var[which(infoListIds$id == 'IdShowCohort')]
  })

  toDots = function(s) gsub('[ -]', '.', s)

  rV$removeOutliersQuantile =  0.999

  observeEvent(input$IdQuantile,handlerExpr = {
    rV$removeOutliersQuantile = eval(input$IdQuantile) }
  )

  outlierModal = reactive(
    {
      showModal(modalDialog(
        title="outlier quantile",
        numericInput(inputId = 'IdQuantile',
                     label='outlier quantile (e.g. blank (NA), 0.99, 0.999...',
                     value = rV$removeOutliersQuantile
        ),
        tableOutput('theOutlierRowsOutput')
      ))
    })

  observeEvent(input$keys, {
    ### great!  you can type in NA also.  Instant response.
    switch (input$keys,
            'O' = {
              rV$removeOutliersQuantile = NA
              outlierModal()
            },
            '9' = {
              rV$removeOutliersQuantile = 0.999
              outlierModal()
            },
            'H' = eval({rV$do.hist = !rV$do.hist})
            # NOT NEEDED    'B' = eval({rV$disableOutliersIsBirth = !rV$disableOutliersIsBirth})
    )
  })
  output$theOutlierRowsOutput = renderTable({
    theOutlierInfo()[order(decreasing = TRUE, theOutlierInfo()$outlierValues), ]

  })
  theOutlierValues = function(x=thisAreaFeatureDistribution(), quantile =  rV$removeOutliersQuantile) {
    theValues = sort(decreasing = TRUE,
                     x[ theOutlierRows(x, quantile)]
    )
    signif(digits=3, theValues)

  }
  theOutlierTracts = function(x=thisAreaFeatureDistribution(), quantile =  rV$removeOutliersQuantile) {
    theOutlierInfo$tracts
  }

  theOutlierRows = function(x=thisAreaFeatureDistribution(),
                            quantile =  rV$removeOutliersQuantile) {
    if(is.na(rV$removeOutliersQuantile))
      return(numeric(0))
    if(verbose > 2)
      print(paste('call to theOutlierRows: rV$removeOutliersQuantile=',
                rV$removeOutliersQuantile))
    outlierRows = which(pnorm((x - mean(x, na.rm=T)) /sd(x, na.rm=T) ) > quantile)
    if(verbose > 2)
      print(data.frame(outlierRows = outlierRows,
                     outlierValues=x[outlierRows],
                     tracts = twt$twt[outlierRows]))   #### OK
    return(outlierRows)
  }

  theOutlierInfo = function(x=thisAreaFeatureDistribution(),
                            quantile =  rV$removeOutliersQuantile) {
    if(is.na(rV$removeOutliersQuantile))
      return(numeric(0))
    if(verbose > 2)
      print(paste('call to theOutlierRows: rV$removeOutliersQuantile=',
                rV$removeOutliersQuantile))
    outlierRows = which(pnorm((x - mean(x, na.rm=T)) /sd(x, na.rm=T) ) > quantile)
    return(data.frame(outlierRows = outlierRows,
                     outlierValues=x[outlierRows],
                     tracts = twt$twt[outlierRows]))   #### OK
  }

  printpaste = function(intro, ..., ppverbose=1, ppcollapse=', ') {
    #if(verbose>ppverbose)
      print(paste(intro, paste(collapse=ppcollapse, ...)))
  }

  rV$do.hist = TRUE

  total.communities = reactive((input$IdTotalOrRate == '...total')
                               & (input$Id_ToggleTownTract == 'communities'))

  #### featurePlot histogram arrow ####
  output$featurePlot <- renderPlot({
    xlab = decorateFeatureName()

    if( total.communities()) {
      thisAreaFeature = thisAreaFeatureList()
    }  #### display all individual towns in this area

    else   #### for rates or tracts, just the one.
      thisAreaFeature = thisAreaFeatureSummary()

    referenceDistribution = thisAreaFeatureDistribution()
    initialreferenceDistribution = referenceDistribution
    #as.numeric(twt[[(rV$featureToPlot)]])
    if(verbose>2)print(paste('featurePlot: referenceDistribution:'))
    if(verbose>2)print('before:')

    if(verbose>2)print(summary(referenceDistribution))
    if(verbose>2)print(length(referenceDistribution))
    if(is.na(rV$removeOutliersQuantile) ) {
      outliers = numeric(0)
    } else {
      outlierRows = theOutlierRows(referenceDistribution,
                                   rV$removeOutliersQuantile)
      if(verbose>0)
        print(paste('initial outlier rows ', paste(collapse=',', outlierRows)))
      outliers = referenceDistribution[outlierRows]
      if(verbose>0)
        print(paste('initial outliers ',
                    paste(collapse=',',
                          signif(digits=3, outliers))) )
      #   rowsToDrop = which(outliers <= max(thisAreaFeature, na.rm=T) )
      #     # These outliers are smaller than thisAreaFeature !
      #     ### thisAreaFeature should appear on the plot, so drop smaller ones.
      #   if(verbose>0)
      #     print(paste('rowsToDrop ', paste(collapse=', ', rowsToDrop),
      #               'Removing these outliers if any',
      #               outliers[rowsToDrop]))
      # print((rowsToDrop))
      # print(length(rowsToDrop))
      # print(length(rowsToDrop) > 0)
      #
      #   if(length(rowsToDrop) >0 ) {
      #     print("SHOULD NOT BE HERE")
      #     outliers = outliers[-rowsToDrop]   ## take out the ones too small.
      #   }
      # print(paste('intersection:',
      #             paste(collapse=',',
      #                   intersect(referenceDistribution, outliers))))
      referenceDistribution = #setdiff(referenceDistribution, outliers) #WRONG
        referenceDistribution [ - match( outliers, referenceDistribution )]
      #  equivalently, referenceDistribution %except% outliers
      if(verbose>1)
        print(paste('final outliers ', paste(collapse=', ',
                                             signif(digits=3,outliers))))
    }
    if(verbose>2) print('after:')
    if(verbose>2) print(summary(referenceDistribution))
    if(verbose>2) print(length(referenceDistribution))



    if(rV$do.hist) {
      #### histogram ####H
      histReturn = hist(referenceDistribution[!is.na(referenceDistribution)], plot=F)
      save('referenceDistribution', file='referenceDistribution.saved.Rd')
      dump('referenceDistribution', file='referenceDistribution.dumped.Rd')
      save('histReturn', file='histReturn.saved.Rd')
      dump('histReturn', file='histReturn.dumped.Rd')
      if(verbose>2)
        print(histReturn)
      if(verbose>2)
        print(paste('max(histReturn$counts)', max(histReturn$counts)))
      plot(histReturn, #ylim=c(0, max(histReturn$counts, na.rm=T)*1.05),
           #xlim=c(0, max(referenceDistribution*1.05, na.rm=T)),
           xlab=xlab, ylab = 'number of census tracts',
           main = '',
           cex.lab=1.5)
      if(verbose>2)
        print(histReturn)
      highestPlotValue = max(histReturn$counts)
    }
    else {
      densityReturn = density(referenceDistribution[!is.na(referenceDistribution)]
      )
      plot(densityReturn, main='', axes=F,
           xlab=xlab, ylab='', xlim=c(0,max(densityReturn$x)))
      axis(1, labels=T)
      highestPlotValue = max(densityReturn$y)
    }
    for(feature in thisAreaFeature) {
      #### arrows ####
      print(paste('arrows: ', paste(thisAreaFeature, collapse=',')))
      # abline(v=thisAreaFeature,
      #        lwd=3, col='darkgreen')
      arrows(x0 = feature, y0 = 0,
             x1 = feature, y1= par('usr')[4]*1.2, xpd=NA,
             col='darkgreen', lwd=3)
      text(x = feature, y=par('usr')[4]*(1.2 + 0.06), xpd=NA,
           label = signif(digits=3, feature),
           col='darkgreen', cex=1.5)
    }
    if(! is.null(rvIdMakeReferenceCommunity$referenceCommunity)) {
      rV$REFERENCEdatarows =   ### now just the ref tract.
        which(twt$twt ==
                rvIdMakeReferenceCommunity$referenceCommunity)
      print(paste('REFERENCE Community:  datarows', rV$REFERENCEdatarows,
                  '', rvIdMakeReferenceCommunity$referenceCommunity))
      refValue = thisAreaFeatureSummary(applyTo = rV$REFERENCEdatarows)
      print(paste(' so red shd stay at ', refValue))
      ### thisAreaFeatureSummary accommodates makeItARate()
      points( refValue, 0, cex=2, col=referenceColor, pch='⬧', xpd=NA)
    }

    if(length(outliers) > 0 ) {  #### prepare table of outliers ####
      pars = par()$usr  ### 0 1 0 1  for histogram!?  Not useful.
      nToShow = 4
      biggestOutliers = sort(outliers, decreasing = T)
      biggestOutliers = as.character(
        signif(digits=3,
               biggestOutliers[1:min(length(outliers),nToShow)] ))
      if(length(outliers) > nToShow)
        biggestOutliers = c(biggestOutliers, '...')

      outlierLabel = paste0('#outliers\n  = ', length(outliers), '  ➡\n',
                            paste(biggestOutliers, collapse='\n'
                            ))
      print(paste(outlierLabel))
      text.default(x = max(referenceDistribution), y = highestPlotValue,
                   xpd=NA, adj=c(0,0.5),
                   labels = outlierLabel)

    }

  })

  ### popovers--  popify or tipify work, but these don't.
  # addPopover(session, id='IdNbhds',title = 'Pittsburgh Neighborhood toggle',
  #            content = '...in progress.', placement='top', trigger='hover')
  # addPopover(session, id='areaSelectorId',title = 'census tracts',
  #            content = 'with town names when available', placement='top', trigger='hover')
  #source('popovers.R')
}


