# doesn't work.
showTownsInLeaflet = function(towns, tt=tt1.sw,
                     townsField = c('towns', 'towns.intersects', 'towns.intersects.first')
                     [1], perfect=TRUE, zoom=9) {
  if(is.numeric(towns))
    tt = tt[towns, ]
  if(is.numeric(townsField))
    townsField = c('towns', 'towns.intersects', 'towns.intersects.first')[townsField]
  tt$towns = tt[[townsField]]
  if(is.character(towns) & !perfect)
    towns = grep(towns, tt$towns, v=T)

  tt = tt[tt$towns %in% towns, ]
  tt$label = paste(tt$towns, tt$tracts)
  lng = mean(as.numeric(tt$lon.places), na.rm=T)
  lat = mean(as.numeric(tt$lat.places), na.rm=T)
  leaflet() %>%
  addProviderTiles("CartoDB.PositronNoLabels",
                   options = tileOptions(minZoom = 5, maxZoom = 13)) %>%
  setView(lng = lng, lat = lat, zoom=zoom)  %>%
  addPolygons(data = tt,
              weight = 1,
              color = "Black",
              fillColor = "blue",
              fillOpacity = 0.3,
              # label is the label shown
              #label = ~areaField, #works ok. PAtown[['NAME']] = PAtown[['areaField']]
              label = ~label, #PAtown[['NAME']] = PAtown[['areaField']]
              #layerId = ~towntractName, ## initially.
              highlight = highlightOptions(
                fillColor = "green",
                color = "red",
                weight = 2,
                fillOpacity = 1,
                bringToFront = T))
}
