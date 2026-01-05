function(input, output, session) {
  includeScript('KeyHandler.js')
  observeEvent(input$ctrlDpressed, {}) # just to flush the ctrl-D press.
  shinyDebuggingPanel::makeDebuggingPanelOutput(
       session, toolsInitialState = FALSE,
       condition='ctrlDpressed === true'
      )

  zoomLevel = 10
  verbose=1

  print(paste('server: twt unspecified ', length(grep('unspec', twt$twt))))


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


    # to speed app up and lower RAM
  #townreac <- reactive(PAtown[PAtown$NAME==input$areaSelectorId,])
  # townreac <- reactive({
  #   areaFieldName = get_areaFieldName()
  #   print(paste('townreac: get_areaFieldName = ', areaFieldName))
  #   result = PAtown[which(PAtown[[areaFieldName]]==TARGETstring()),]
  #   if(nrow(result) > 1) {
  #     cat('==== townreac   --  duplicates ===== \n')
  #     print(result)
  #     result = result[result$COUNTYFP == '003', ]  ### select Allegheny
  #     print(result)
  #   }
  #   result   ###  it should return one row of PAtown.
  #   })
  #needs Town, lat, lon

  # This is ok, because only used for centering map at the start.
  medianLON= median(as.numeric(twt$lon.tracts), na.rm=T)
  medianLAT= median(as.numeric(twt$lat.tracts), na.rm=T)

  savedclick = NULL
 #### clicking updates selectInput ####
  observe({
    click <- input$map_shape_click
    if(verbose>0) print(paste('input$map_shape_click$id', click$id))
    ### TODO  Seems ok but keep an eye on this.
    ### If "towns", click becomes null.
    if(is.null(click) & is.null(savedclick) )
      #updateSelectInput(session, "areaSelectorId", selected = PAtown[['areaField']] [1])
      updateSelectInput(session, "areaSelectorId", selected = twt[['areaField']] [1])
    else {
      if(is.null(click) &     !  is.null(savedclick) )  {
        if(verbose>0)
          print(paste('Copying savedclick to click:  ', savedclick$id))
        click = savedclick
      }
      leafletProxy("map", session) %>%
        clearGroup("selectedTract") %>%
        clearGroup("selectedTown")
      ### so that you can 're-click', i.e. select a different town?  doesn't work probably
      updateSelectInput(session, "areaSelectorId", selected = NULL)
      if(verbose>0) print(paste('click$id', click$id))
      updateSelectInput(session, "areaSelectorId", selected = click$id)
      if(verbose>0) print(paste('Updating areaSelectorId:' ,
                                input$areaSelectorId, '   click$id', click$id))
    }
  })

  #### default before area is selected ####
  observe({
  if (input$areaSelectorId %in% c(" ","") | is.na(input$areaSelectorId))
    updateSelectInput(inputId='areaSelectorId', selected = 1)
  })
  #### NOT USED  observeEvent   input$townToggleId ####
  # observeEvent(input$townToggleId, {
  #   twt$areaField = twt$towns
  #   updateSelectInput(inputId='areaSelectorId',
  #                     choices = twt[[input$townToggleId]])
  #
  # })

  areaFieldName = 'twt'  ## towns with tracts

  #### get_areaFieldName ####
  get_areaFieldName = function(){

    ### simplify! no.  breaks "towns".
    ##   return('twt')

    if(length(input$townToggleId) == 1)
      areaFieldName = input$townToggleId
    else
      areaFieldName = 'twt'
    if(verbose>1)
      print(paste('get_areaFieldName: areaFieldName=', (areaFieldName)))
    twt[['areaField']] <<-twt[[areaFieldName]]
    return(areaFieldName)   ## get_areaFieldName
    # updateSelectInput(session, "areaSelectorId", choices = PAtown)
  }

  TARGETstring = reactive({
    return(input$areaSelectorId)
  })
  #### SELECTEDstring reactive  ####
  SELECTEDstring = reactive( {
    if(verbose>0) print( paste('SELECTEDstring: TARGETstring: ',  TARGETstring(),
                 '\nSELECTEDstring:  get_areaFieldName: ',input$townToggleId
           ,
           '\nSELECTEDstring:  townToggleId: ',input$townToggleId) )
  if(get_areaFieldName() == 'towns')
      return(   getATownFromThisTract(TARGETstring()))#
    else
      return(TARGETstring())
  })

  #### getTownsForThisTract ####
  getTownsForThisTract = function(twtTractString=TARGETstring())
    strsplit(split = ',',
             gsub(' 42.*', '',  #### 42 = Pennsylvania
                  twtTractString ) ) [[1]]

  #### townsForAllTracts ####
  townsForAllTracts = lapply(twt$twt, getTownsForThisTract)  ### inefficient, so what.

  rV = reactiveValues(showingModal = FALSE)

  ####   getATownFromThisTract  observeEvent TARGETstring -> rV$selectedTown ####
  getATownFromThisTract = function(target = TARGETstring())  {
    townsForThisTract = getTownsForThisTract(target)
    isolate({
      if(verbose>1) print(paste('getATownFromThisTract: townsForThisTract:',
                paste(collapse='+', townsForThisTract)))
    ### for now, pick the first town.  Later, pop up to pick a town.
    if(length(townsForThisTract) == 1 ){
      rV$selectedTown = townsForThisTract[1]
      if(verbose>0) print(paste('selectedTown (1): ', rV$selectedTown))
    }
    else {
      if(rV$showingModal == FALSE) {
        rV$savedTract = input$areaSelectorId
        townsForThisTract = getTownsForThisTract()
        townsString = paste(collapse="+", townsForThisTract)
        if(verbose>0) print(paste('showModal: townsForThisTract:', townsString))
        showModal(  modalDialog(  # cannot test in shinyDebuggingPanel -- modal!
          title = span(rV$savedTract, ' select one town:', townsString),
          selectInput(inputId = "modalId", label = "select a town ",
                      choices = townsForThisTract
          ),
          footer=actionButton("ok", "OK")
        ))
        rV$showingModal = TRUE
      }
      #print(paste('selectedTown (modal): ', rV$selectedTown))
      #rV$selectedTown = townsForThisTract[1]
    }
    if(!is.null(rV$selectedTownModal)) {
      rV$selectedTown = rV$selectedTownModal
      rV$selectedTownModal = NULL
    }
      if(verbose>0) print(paste('selectedTown return: ', rV$selectedTown))
    })
    return(rV$selectedTown)
  }

  #### modal OK ####
  observeEvent(input$ok, {
    rV$selectedTownModal = (input$modalId)
    print(paste('OK, selectedTownModal: ', rV$selectedTownModal))
    isolate({rV$selectedTown = rV$selectedTownModal})
    removeModal()
  })

  isPittsburgh = function(town) {
    value1 = grep('\\(Pittsburgh\\)', town, perl=T)
    value1 = (length(value1)>0)
    value2 = grep('^Pittsburgh.*unspecified', town)
    value2 = (length(value2)>0)
    value  = (value1 | value2)
    # print(paste('isPittsburgh', town))
    # print(paste('isPittsburgh', value1, value2,  value))
    return(value)
  }
  #### getRownumbersForTown  observeEvent( rV$selectedTown   ####
  getRownumbersForTown = function( town, nbhd=FALSE) {
    if(verbose>0) print(paste('getRownumbersForTown  selectedTown: ', town))
    rV$showingPittsburgh =
      (isPittsburgh(town) & (! input$IdNbhds) & (input$townToggleId == 'towns'))
    if(rV$showingPittsburgh) {
      ## all the tracts which are part of Pittsburgh.
      PittsburghRows = which(sapply(twt$twt, isPittsburgh))
      if(verbose>0) print(paste('getRownumbersForTown: ALL Pittsburgh',
                               paste(collapse=',', PittsburghRows) ))
      return(PittsburghRows)
    }

    rownumbersForTown =
      which(sapply(  townsForAllTracts, function(t) identical(town, t)))
    #### ah, but what if there aren't any???
    # if (length(rownumbersForTown) == 0)
       # showModal(modalDialog(paste("There are no tracts with ONLY ", town)))
    if (length(rownumbersForTown) == 0 | input$townSharedToggleId == TRUE)
      rownumbersForTown =
        which(sapply(  townsForAllTracts, function(t) town %in% t))
    if(verbose>0) print(paste('getRownumbersForTown: selectedTown: ',
                town, paste(collapse='+', rownumbersForTown)))
    rV$TARGETrownumbers = rownumbersForTown
    return(rownumbersForTown)
  }

  #### TARGETrownumbers TARGETstring() ->rV$TARGETrownumbers  ####
  TARGETrownumbers = function(target){
    if(missing(target))
      target = SELECTEDstring()
    areaFieldName = get_areaFieldName()
    if(verbose>1) print(paste('TARGETrownumbers:  areaFieldName :', areaFieldName))
    if(verbose>1) print(paste('TARGETrownumbers:  target (in):', target))
    if(areaFieldName == 'towns')
      rownumbers = getRownumbersForTown(getATownFromThisTract())
    else if(areaFieldName == 'twt')   # towns with tracts
      rownumbers = grep(gsub('.* 42', '42', target), twt$twt) ## should be a tract
    else {
      if(verbose>1) print(paste('areaFieldName? ', areaFieldName))
    }
    if(verbose>1) print(paste('TARGETrownumbers', 'TARGET (out):', paste(collapse = '+', rownumbers)))
    return(rownumbers)
  }

  #### TARGETdatarows ####
  TARGETdatarows = function(target=TARGETstring()){
    twt[TARGETrownumbers(target), ]
  }

  #### fixNbhds ####
  #twt$twtSaved = twt$twt
  # twt$twt = twt$twt.for.tracts = twt$twt.for.towns =
  #   gsub( '^Pittsburgh', 'Pittsburgh (unspecified)',
  #                                        twt$twtSaved )
  #    grep('\\(P', twt$twt,perl=T)
  observeEvent(input$IdNbhds, {
    if (isTRUE(input$IdNbhds)) {
      # WHY ERROR? updateRadioButtons(session=session, inputId = 'townToggleId', selected = 'towns')
      if(verbose>1) print('Going Pittsburgh nbhd')
      twt$twt = twt$twt.for.tracts = twt$twt.for.towns = twt$areaField = twt$twtSaved
        #gsub( '^Pittsburgh', 'Pittsburgh (unspecified)',
                                 # twt$twtSaved )
      twt$twt = twt$twt.for.tracts = twt$twt.for.towns = twt$areaField =
        twt$twtSaved
    }
    else {
      if(verbose>1) print('Going Pittsburgh all in one')
      twt$twt = twt$twt.for.towns = twt$twt.for.tracts = gsub(
        '.* \\(Pittsburgh\\)', 'Pittsburgh',
        gsub( '^Pittsburgh \\(unspecified\\)', 'Pittsburgh',
                                                twt$twtSaved ) )
    }
    # TESTING in shinyDebuggingPanel:
    #   c(twt$twt[grep('0317', twt$tracts)], twt$twt[grep('3192', twt$tracts)])
    ## refresh the maps
    #click
    leafletProxy("map", session) %>%
      clearGroup("selectedTract") %>%
      clearGroup("selectedTown")
    ### so that you can 're-click', i.e. select a different town?  doesn't work probably
    updateSelectInput(session, "areaSelectorId", selected = NULL)
    if(!is.null(input$map_shape_click))
      updateSelectInput(session, "areaSelectorId", selected = input$map_shape_click$id)
  })
  #### leaflet output$map ####
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.PositronNoLabels", options = tileOptions(minZoom = 5, maxZoom = 13)) %>%
      setView(lng = medianLON, lat = medianLAT, zoom = zoomLevel)  %>%
      addPolygons(data = twt,
                  weight = 1,
                  color = "Black",
                  fillColor = "blue",
                  fillOpacity = 0.3,
                  # label is the label shown
                  #label = ~areaField, #works ok. PAtown[['NAME']] = PAtown[['areaField']]
                  label = ~twt,
                  layerId = ~twt, ## initially.
                  highlight = highlightOptions(
                    fillColor = "green",
                    color = "red",
                    weight = 2,
                    fillOpacity = 1,
                    bringToFront = T))
  })

  ##### newTractObserver:  leafletProxy: Map animation  ####
  newTractObserver = observeEvent(c(input$map_shape_click,
                                    rV$showingPittsburgh,
                                    rV$TARGETrownumbers, input$areaSelectorId), {
    if(verbose>1) print(paste('newTractObserver: input$areaSelectorId', input$areaSelectorId) )
    if(verbose>1) print(paste('newTractObserver: input$townToggleId', input$townToggleId) )
    if(verbose>1) print(paste('newTractObserver: SELECTEDstring', SELECTEDstring() ) )

    tractRowNumber = TARGETrownumbers() #rV$TARGETrownumbers  fails at first.

    if(verbose>1) print(paste('newTractObserver: tractRowNumber',
                paste(collapse=',', tractRowNumber)))
    #### leafletProxy - tracts ####
    leafletProxy("map", session) %>%
      flyTo(lng = TARGETdatarows()$lon.places[1],
            lat = TARGETdatarows()$lat.places[1], zoom=zoomLevel) %>%
      clearGroup("selectedTract") %>%
      addPolygons(data=twt[tractRowNumber,], weight = 1,
                  color="Red", fillColor="yellow",
                  label= ~twt,
                  #layerId = ~twt,
                  fillOpacity = 1, group="selectedTract")  #%>%
      # addPolygons(data=twt[areaRowNumbers,], weight = 1,
      #           #  color="Red", fillColor="yellow",
      #             label= ~twt,
      #             layerId = ~twt,
      #             fillOpacity = 1, group="showIds")
  })

  ##### newTownsObserver:  leafletProxy: Map animation  ####

  newTownsObserver = observeEvent(c(rV$selectedTown, input$areaSelectorId,
                                    input$IdNbhds), {
    if(verbose>1) print(paste('newTownsObserver: input$areaSelectorId', input$areaSelectorId) )
    if(verbose>1) print(paste('newTownsObserver: input$townToggleId', input$townToggleId) )
    if(verbose>1) print(paste('newTownsObserver: SELECTEDstring', SELECTEDstring() ) )
    if(input$areaSelectorId != 'towns')
      leafletProxy("map", session) %>%
        clearGroup("selectedTowns")
    else {
      townRowNumbers = getRownumbersForTown(rV$selectedTown, input$IdNbhds)

      leafletProxy("map", session) %>%
        flyTo(lng = TARGETdatarows()$lon.places[1],
              lat = TARGETdatarows()$lat.places[1], zoom=zoomLevel) %>%
        clearGroup("selectedTown") %>%
        addPolygons(data=twt[townRowNumbers,], weight = 1,
                    color="purple", fillColor="grey",
                    label= ~twt.for.towns,
                    #layerId = ~twt,
                    fillOpacity = 0.5, group="selectedTown")  #%>%
    }
  }
  )

  # export button
  output$downloadData <- downloadHandler(
    filename = "Air-Pollution-PA.csv",
    content = function(file) {
      write.csv(twt, file)
    }
  )

  # Reactive storage of comparative tool inputs. Speeds up app
  # secondpageinput <- reactive(c(input$areaSelectorIdleft, input$areaSelectorIdright))

  # datatables for comparison tool
  # output$tabledemogleft <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[1],c(1,4,5)]),
  #                                              caption = demogcaption,
  #                                              options = list(dom="t",
  #                                                             columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                             headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tablepoprateleft <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[1],c(19:20,17:18)]),
  #                                            caption = popratecaption,
  #                                            options = list(dom="t",
  #                                                           columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                           headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tableIQleft <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[1],c(15:16)]),
  #                                           caption = IQcaption,
  #                                           options = list(dom="t",
  #                                                          columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                          headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tabledemogright <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[2],c(1,4,5)]),
  #                                               caption = demogcaption,
  #                                               options = list(dom="t",
  #                                                              columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                              headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tablepoprateright <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[2],c(19:20,17:18)]),
  #                                             caption = popratecaption,
  #                                             options = list(dom="t",
  #                                                            columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                            headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))
  #
  # output$tableIQright <- DT::renderDataTable(t(PAtown[PAtown$NAME==secondpageinput()[2],c(15:16)]),
  #                                               caption = IQcaption,
  #                                               options = list(dom="t",
  #                                                              columnDefs = list(list(className = 'dt-right', targets = 1)),
  #                                                              headerCallback = JS("function(thead, data, start, end, display){$(thead).remove();}")))

  # column plot for comparison tool (hidden for small devices)
  reactivedata <- reactive({
    if(exists(x = 'columnchartdata'))
      columnchartdata[columnchartdata$Town == secondpageinput()[1] | columnchartdata$Town ==secondpageinput()[2],]
  })
  # output$comptable <- renderPlot({
  #   if(exists(x = 'columnchartdata'))
  #     ggplot(data=melt(data.table(reactivedata()), id=1), aes(x=variable, y=value, fill=Town)) +
  #                                 geom_bar(stat="identity", position=position_dodge(), colour="black") +
  #                                 theme_classic() + xlab("Incidence Rates") + ylab("") +
  #                                 scale_fill_manual(values = c("#8a100b", "#b29d6c")) +
  #                                 scale_x_discrete(labels= c("CancerDeaths_IR"="Cancer Deaths per 10,000 Population", "IHDDeaths_IR"="Heart Disease Deaths per 10,000 Population",
  #                                                             "**PIQ points lost per child"="PIQ Points Lost per child"))
  # else
  #   "WARNING: columnchartdata is not available"
  # })


  #### featureList  functions ####
  #feat.countsPerPerson presumes that feature is in counts of people.
  safe.sum = function(x) sum(x, na.rm=T)
  feat.countsPerPerson = function()
    safe.sum(getThisAreaFeature()) / safe.sum(getThisAreaPopulation())
  #feat.weightedRate presumes that feature is a rate.
  feat.weightedRate = function()
    safe.sum(getThisAreaFeature()*getThisAreaPopulation()) /
    safe.sum(getThisAreaPopulation())
  feat.sum = function() safe.sum(getThisAreaFeature())
  # feat.mean = function() mean(getThisAreaFeature(), na.rm=T)  # raw mean, not pop-weighted.
  featureSummaryFunctionTable = data.frame(
    feature=featureList,
    func= c(
      'feat.countsPerPerson', #"Myocardial Infarctions",
      'feat.countsPerPerson', #"COPD Deaths",
      'feat.countsPerPerson', #"Ischemic Heart Disease Deaths",
      'feat.countsPerPerson', # "All-cause deaths", # (avg Krewski, Laden)
      'feat.countsPerPerson', # "Low Birth Weight Babies",
      'feat.countsPerPerson', # "Preterm Births",
      'feat.countsPerPerson', # "Stillbirths",
      'feat.sum', # "Total Population (2019)",
      'feat.countsPerPerson' # "PM2.5 average"
    ))
  rownames(featureSummaryFunctionTable) = featureSummaryFunctionTable[['feature']]

  #### Bring in featureList.  Careful: renamed PM_avg  ##
  getThisAreaFeature = reactive({
    thisFeature = as.numeric(twt[[input$idFeature]])
    return(thisFeature[TARGETrownumbers(TARGETstring())])
  })
  getThisAreaPopulation = reactive({
    thisFeature = as.numeric(twt[["Total Population (2019)"]])
    return(thisFeature[TARGETrownumbers(TARGETstring())])
  })
  thisAreaFeatureSummary = reactive({
    featureName = input$idFeature
    featureSummaryFunctionName = featureSummaryFunctionTable[featureName, 'func']
    featureSummaryFunction = get(featureSummaryFunctionName)
    if(verbose>1) print(paste("featureSummaryFunctionName", featureSummaryFunctionName))
    ### for now.  May also be popWeightedMean or sum
    return(featureSummaryFunction())
  })

  addSpaces = function(n) rep('&nbsp;', n)
  output$histTitle = renderUI( {
    # print(paste('histTitle:', 'get_areaFieldName()=', get_areaFieldName()))
    # print(paste('histTitle:', 'input$idFeature=', input$idFeature))

    thisFeature = as.numeric(twt[[input$idFeature]])

    # print(paste('histTitle:', 'feature values',
    #             paste(collapse=',', thisAreaFeature())))
    # print(paste('histTitle:', 'feature summary',
    #             paste(collapse=',', thisAreaFeatureSummary())))

    div(hr(),
        span(strong(
          switch(isTRUE(rV$showingPittsburgh),
                 'Selected all Pittsburgh from',
                 switch(get_areaFieldName(),
                 towns="Selected town:",
                 twt="Selected town/tract:"))),
             span(
          style='color:green',
          paste(SELECTEDstring()))),
        br(),
        span(strong("Selected feature: "),
             span(
               style='color:green', input$idFeature, ' = ',
             signif(digits=3,
                    thisAreaFeatureSummary() ) )
             #### TODO: which features do we sum, which do we mean?
             ### population is char for some reason.
        ),
        br(),
        span('--------------------',
             '(summarized by ', strong(gsub('^feat.', '', featureSummaryFunctionTable[input$idFeature, 'func'])), ')'
        ),
        br(),
        span(strong("Compared with entire region: "),
          span(style='color:green', 'proportion smaller = ',
          textOutput('proportion_smaller')
          )))
  })
  output$proportion_smaller <- renderText({
    #print(paste('proportion_smaller:', 'distribution of idFeature'))
    #print(capture.output(summary(twt[[input$idFeature]])))
    howManyLess = try({
      twt[[input$idFeature]] < thisAreaFeatureSummary()
#        PAtown[[input$idFeature]] [PAtown$areaField==input$areaSelectorId]
    })
    if (class(howManyLess) == 'try-error')
      howManyLess = 0
    signif(digits=2, mean(na.rm = TRUE, howManyLess ) )
  })

  output$featurePlot <- renderPlot({
    thisFeature = as.numeric(twt[[input$idFeature]])
    thisAreaFeature = thisAreaFeatureSummary()
    xlab = gsub('All-cause deaths', 'All-cause deaths: avg Krewski & Laden',
                input$idFeature)
    hist(thisFeature,
         xlab=xlab, ylab = 'count',
         main = '')
    abline(v=thisAreaFeatureSummary(),
                        lwd=3, col='green')
    arrows(x0 = thisAreaFeatureSummary(), y0 = 0,
           x1 = thisAreaFeatureSummary(), y1= par('usr')[4]*1.2, xpd=NA,
           col='green', lwd=3)

  })
  ### popovers--  popify or tipify work, but these don't.
  # addPopover(session, id='IdNbhds',title = 'Pittsburgh Neighborhood toggle',
  #            content = '...in progress.', placement='top', trigger='hover')
  # addPopover(session, id='areaSelectorId',title = 'census tracts',
  #            content = 'with town names when available', placement='top', trigger='hover')
  #source('popovers.R')
}


