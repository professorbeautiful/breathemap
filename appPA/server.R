function(input, output, session) {
  includeScript('KeyHandler.js')
  observeEvent(input$ctrlDpressed, {}) # just to flush the ctrl-D press.
  shinyDebuggingPanel::makeDebuggingPanelOutput(
       session, toolsInitialState = FALSE,
       condition='ctrlDpressed === true'
      )


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


 #### clicking updates selectInput ####
  observe({
    click <- input$map_shape_click
    ### TODO  Seems ok but keep an eye on this.
    if(is.null(click))
      #updateSelectInput(session, "areaSelectorId", selected = PAtown[['areaField']] [1])
      updateSelectInput(session, "areaSelectorId", selected = twt[['areaField']] [1])
    else {
      leafletProxy("map", session) %>%
        clearGroup("selectedTract") %>%
        clearGroup("selectedTown")

      ### so that you can 're-click', i.e. select a different town?  doesn't work probably
      updateSelectInput(session, "areaSelectorId", selected = NULL)
      updateSelectInput(session, "areaSelectorId", selected = click$id)
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
    if(length(input$townToggleId) == 1)
      areaFieldName = input$townToggleId
    else
      areaFieldName = 'twt'
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
    print( paste('SELECTEDstring: TARGETstring: ',  TARGETstring(),
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

  rV = reactiveValues()

  ####   getATownFromThisTract  observeEvent TARGETstring -> rV$selectedTown ####
  getATownFromThisTract = function(target = TARGETstring())  {
    townsForThisTract = getTownsForThisTract(target)
    isolate({
      print(paste('getATownFromThisTract: townsForThisTract:',
                paste(collapse='+', townsForThisTract)))
    ### for now, pick the first town.  Later, pop up to pick a town.
    if(length(townsForThisTract) == 1 ){
      rV$selectedTown = townsForThisTract[1]
      print(paste('selectedTown (1): ', rV$selectedTown))
    }
    else {
      townsForThisTract = getTownsForThisTract()
      townsString = paste(collapse="+", townsForThisTract)
      print(paste('showModal: townsForThisTract:', townsString))
      showModal(  modalDialog(  # cannot test in shinyDebuggingPanel -- modal!
        title = span('select one town:', townsString),
        selectInput(inputId = "modalId", label = "select a town ",
                    choices = townsForThisTract
        ),
        footer=actionButton("ok", "OK")
      ))
      #print(paste('selectedTown (modal): ', rV$selectedTown))
      #rV$selectedTown = townsForThisTract[1]
    }
    if(!is.null(rV$selectedTownModal)) {
      rV$selectedTown = rV$selectedTownModal
      rV$selectedTownModal = NULL
    }
    print(paste('selectedTown return: ', rV$selectedTown))
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

  #### getRownumbersForTown  observeEvent( rV$selectedTown   ####
  getRownumbersForTown = function( town) {
    print(paste('getRownumbersForTown  selectedTown: ', town))
    rownumbersForTown =
      which(sapply(  townsForAllTracts, function(t) town %in% t))
    print(paste('getRownumbersForTown: selectedTown: ',
                town, paste(collapse='+', rownumbersForTown)))
    rV$TARGETrownumbers = rownumbersForTown
    return(rownumbersForTown)
  }

  #### TARGETrownumbers TARGETstring() ->rV$TARGETrownumbers  ####
  TARGETrownumbers = function(target){
    if(missing(target))
      target = SELECTEDstring()
    areaFieldName = get_areaFieldName()
    print(paste('TARGETrownumbers:  areaFieldName :', areaFieldName))
    print(paste('TARGETrownumbers:  target (in):', target))
    if(areaFieldName == 'towns')
      rownumbers = getRownumbersForTown(getATownFromThisTract())
    else if(areaFieldName == 'twt')   # towns with tracts
      rownumbers = grep(gsub('.* 42', '42', target), twt$twt) ## should be a tract
    else {
      print(paste('areaFieldName? ', areaFieldName))
      #browser(text = 'what areaFieldName?')
    }
    print(paste('TARGETrownumbers', paste(collapse = '+', 'TARGET (out):', rownumbers)))
    return(rownumbers)
  }

  #### TARGETdatarows ####
  TARGETdatarows = function(target=TARGETstring()){
    twt[TARGETrownumbers(target), ]
  }

  #### fixNbhds ####
  twt$twtSaved = twt$twt
  twt$twt = twt$twt.for.tracts = twt$twt.for.towns =
    gsub( '^Pittsburgh', 'Pittsburgh (unspecified)',
                                         twt$twtSaved )

  reactive({
    if (input$IdNbhds) {
      twt$twt = twt$twt.for.tracts = gsub( '^Pittsburgh', 'Pittsburgh (unspecified)',
                                 twt$twtSaved )
    }
    else {
      twt$twt.for.towns = gsub( '.* \\(Pittsburgh\\)', 'Pittsburgh',
                            twt$twt )
    }
  })
  #### leaflet output$map ####
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.PositronNoLabels", options = tileOptions(minZoom = 5, maxZoom = 13)) %>%
      setView(lng = medianLON, lat = medianLAT, zoom = 10)  %>%
      addPolygons(data = twt,
                  weight = 1,
                  color = "Black",
                  fillColor = "blue",
                  fillOpacity = 0.3,
                  # label is the label shown
                  #label = ~areaField, #works ok. PAtown[['NAME']] = PAtown[['areaField']]
                  label = ~twt.for.tracts,
                  layerId = ~twt.for.tracts, ## initially.
                  highlight = highlightOptions(
                    fillColor = "green",
                    color = "red",
                    weight = 2,
                    fillOpacity = 1,
                    bringToFront = T))
  })

  ##### newTractObserver:  leafletProxy: Map animation  ####
  newTractObserver = observeEvent(c(rV$TARGETrownumbers, input$areaSelectorId), {
    print(paste('newTractObserver: input$areaSelectorId', input$areaSelectorId) )
    print(paste('newTractObserver: input$townToggleId', input$townToggleId) )
    print(paste('newTractObserver: SELECTEDstring', SELECTEDstring() ) )

    tractRowNumber = TARGETrownumbers() #rV$TARGETrownumbers  fails at first.

    print(paste('newTractObserver: tractRowNumber',
                paste(collapse=',', tractRowNumber)))
    #### leafletProxy - tracts ####
    leafletProxy("map", session) %>%
      flyTo(lng = TARGETdatarows()$lon.places[1],
            lat = TARGETdatarows()$lat.places[1], zoom=10) %>%
      clearGroup("selectedTract") %>%
      addPolygons(data=twt[tractRowNumber,], weight = 1,
                  color="Red", fillColor="yellow",
                  label= ~twt.for.tracts,
                  #layerId = ~twt,
                  fillOpacity = 1, group="selectedTract")  #%>%
      # addPolygons(data=twt[areaRowNumbers,], weight = 1,
      #           #  color="Red", fillColor="yellow",
      #             label= ~twt,
      #             layerId = ~twt,
      #             fillOpacity = 1, group="showIds")
  })

  ##### newTownsObserver:  leafletProxy: Map animation  ####

  newTownsObserver = observeEvent(c(rV$selectedTown, input$areaSelectorId), {
    print(paste('newTownsObserver: input$areaSelectorId', input$areaSelectorId) )
    print(paste('newTownsObserver: input$townToggleId', input$townToggleId) )
    print(paste('newTownsObserver: SELECTEDstring', SELECTEDstring() ) )
    if(input$areaSelectorId != 'towns')
      leafletProxy("map", session) %>%
        clearGroup("selectedTowns")
    else {
      townRowNumbers = getRownumbersForTown(rV$selectedTown)

      leafletProxy("map", session) %>%
        flyTo(lng = TARGETdatarows()$lon.places[1],
              lat = TARGETdatarows()$lat.places[1], zoom=10) %>%
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
      write.csv(PAtown, file)
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

  thisAreaFeature = reactive({
    thisFeature = as.numeric(twt[[input$idFeature]])
    return(thisFeature[TARGETrownumbers(TARGETstring())])
  })
  thisAreaFeatureSummary = reactive({
    featureSummaryFunction = mean
    ### for now.  May also be popWeightedMean or sum
    return(featureSummaryFunction(thisAreaFeature(), na.rm=TRUE))
  })

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
          switch(get_areaFieldName(),
                 towns="Selected town:",
                 twt="Selected town/tract:")),
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
}


