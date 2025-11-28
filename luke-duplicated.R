library(leaflet)
library(sf)
duplicatedNAMELSAD = PAtown$NAMELSAD [
  which(duplicated(PAtown$NAMELSAD))]
duplicatedNAMELSAD
leaflet::leaflet() %>% addTiles() %>%
  addPolygons(data=PAtown[which(PAtown$NAMELSAD %in% duplicatedNAMELSAD)[2], ],
              label = ~NAMELSAD)
