# Install needed packages if not already installed
if (!requireNamespace("tigris")) install.packages("tigris")
if (!requireNamespace("sf")) install.packages("sf")
if (!requireNamespace("dplyr")) install.packages("dplyr")

library(tigris)
library(sf)
library(dplyr)

options(tigris_use_cache = TRUE)

# Download Pennsylvania census tracts
pa_tracts <- tracts(state = "PA", year = 2020, class = "sf")   ###  '.x'
dim(pa_tracts)    # 3446 rows
head(pa_tracts,1)
# The names are confusing.  Especially "NAME"!
# DONE pa_tracts_original = pa_tracts
pa_tracts = pa_tracts %>% dplyr::rename(tractNumber = NAME)
pa_tracts = pa_tracts %>% dplyr::rename(CT_tractNumber = NAMELSAD)
# GEOID = paste0(STATEFP,COUNTYFP,TRACTCE)
# TRACTCE = as.character(tractNumber*100)
with(pa_tracts, cbind(as.numeric(TRACTCE)/100, tractNumber,
                      as.numeric(TRACTCE)/100 ==tractNumber
                       ) )     ### OK.
# NAMELSAD = paste('Census Tract', tractNumber)
# drop unneeded fields
pa_tracts = pa_tracts %>% dplyr::select( ! GEOID)
pa_tracts = pa_tracts %>% dplyr::select( ! MTFCC)
pa_tracts = pa_tracts %>% dplyr::select( ! FUNCSTAT)  ## all = "S"
pa_tracts = pa_tracts %>% dplyr::select( ! ALAND)
pa_tracts = pa_tracts %>% dplyr::select( ! AWATER)
pa_tracts = pa_tracts %>% dplyr::select( ! STATEFP)
names(pa_tracts)
# "COUNTYFP"       "TRACTCE"        "tractNumber"    "CT_tractNumber" "INTPTLAT"       "INTPTLON"       "geometry"

## 67 COUNTIES originally.  We only need those in countymap (8).
# table(PAtown$COUNTYFP)
dim(pa_tracts)
dim(pa_tracts %>% dplyr::filter(COUNTYFP %in% countymap[[1]]) )
pa_tracts = pa_tracts %>% dplyr::filter(COUNTYFP %in% countymap[[1]])
head(pa_tracts, 1)
dim(pa_tracts)    #### 752 7

# Download Pennsylvania towns/places (cities, boroughs, etc.)
pa_places <- places(state = "PA", year = 2020, class = "sf")   ### '.y'
dim(pa_places)  ## 1888
head(pa_places, 1)  #Only 1888 rows
# The names are confusing.  Especially "NAME"!
pa_places = pa_places %>% dplyr::rename(townName = NAME)
pa_places = pa_places %>% dplyr::rename(townNamePlus = NAMELSAD)  ### includes "city", "borough" etc
table(gsub(".* ", "", pa_places$townNamePlus))
# this GEOID is the same as pa_tracts$TRACTCE .
pa_places = pa_places %>% dplyr::rename(TRACTCE = GEOID)
pa_places = pa_places %>% dplyr::select(
  strsplit(split=' ',
           'PLACEFP PLACENS TRACTCE townName townNamePlus INTPTLAT INTPTLON geometry')[[1]])


pa_tracts = pa_tracts %>% dplyr::rename(lat = INTPTLAT)
pa_tracts = pa_tracts %>% dplyr::rename(lon = INTPTLON)
pa_places = pa_places %>% dplyr::rename(lat = INTPTLAT)
pa_places = pa_places %>% dplyr::rename(lon = INTPTLON)

pa_tracts$latlon = pa_tracts_latlon = apply(X = cbind(pa_tracts$lat,pa_tracts$lon),
                         MARGIN = 1, paste, collapse=',')
pa_places$latlon = pa_places_latlon = apply(X = cbind(pa_places$lat,pa_places$lon),
                         MARGIN = 1, paste, collapse=',')
head(sort(pa_tracts_latlon),3)
head(sort(pa_places_latlon),3)
intersect(y=pa_tracts_latlon , pa_places_latlon)  ### only 74 identical
intersect(y=pa_tracts$latlon , pa_places$latlon)  ### only 74 the same.
table(pa_places$geometry %in% pa_tracts$geometry) # only 65
table(pa_places$latlon %in% pa_tracts$latlon) # only 74
pa_places
st_join()

intersect(names(pa_tracts), names(pa_places))  #"TRACTCE"  "lat" "lon" "geometry" "latlon"
setdiff(names(pa_tracts), names(pa_places)) #"COUNTYFP"       "tractNumber"    "CT_tractNumber"
setdiff( names(pa_places), names(pa_tracts)) # "PLACEFP"      "PLACENS"      "townName"     "townNamePlus"
dim(pa_tracts)
dim(pa_places)


tracts_with_towns =  st_join(pa_tracts %>% select(c('lat', 'lon','latlon', 'TRACTCE')),
                             pa_places %>% select(c('lat', 'lon','latlon', 'towns', 'TRACTCE')),
                                                 join=st_intersects
)
tracts_with_towns =  st_join(pa_tracts, pa_places, join=st_intersects)
dim(pa_tracts)
dim(pa_places)
dim(tracts_with_towns)
head(tracts_with_towns)

#### vastly faster computation than copilot's join.
# plot(tracts_with_towns$lat.x, tracts_with_towns$lat.y)
# plot(tracts_with_towns$lon.x, tracts_with_towns$lon.y)
#### OK.  close, NOT exact.  No wonder copilot code broke.
### we will average them later.


### write out for input into the app.
save(tracts_with_towns, file='tracts_with_towns.Rd')




#######SEE ABOVE.  all good. ##############################################################
#####################################################################
# DEAD END.  crap from copilot.
# Spatial join: assign each tract to the town it intersects most with
# tracts_with_towns <- st_join(pa_tracts, pa_places, join = st_intersects, largest = TRUE)
# ### this does not work correctly.
# tracts_with_towns <- st_join(pa_tracts, pa_places, join = "geometry", largest = TRUE)
# tracts_with_towns.original = tracts_with_towns
#
#
# ## RD code correction... copilot doesn't know about the .x .y copies maintained.
#
# sort(names(tracts_with_towns))
#
# ### sf:::select.sf()  keeps the field geometry apparently.
# tracts_with_towns.x = tracts_with_towns %>% select(ends_with(".x"))
# tracts_with_towns.x = tracts_with_towns.x [order(tracts_with_towns.x$NAMELSAD.x), ]
# dim(tracts_with_towns.x)
# head(tracts_with_towns.x)
# #names(tracts_with_towns.x) = gsub(".x$", '', names(tracts_with_towns.x))
#
# tracts_with_towns.y = tracts_with_towns %>% select(ends_with(".y"))
# tracts_with_towns.y = tracts_with_towns.y [order(tracts_with_towns.y$NAMELSAD.y), ]
# dim(tracts_with_towns.y)
# #names(tracts_with_towns.y) = gsub(".y$", '', names(tracts_with_towns.y))
#
# head(tracts_with_towns[c("GEOID.x", "GEOID.y" )])### no match: must sort.
#
#
# ### to be continued..
#
#
#
# # Select mapping of tract GEOID to town NAME
# mapping <- tracts_with_towns %>%
#   select(TRACT_GEOID = GEOID, TOWN_NAME = NAME) %>%
#   distinct()
#
# # View mapping
# print(mapping)
#
# # Notes:
# #
# #   TRACT_GEOID is the census tract identifier.
# # TOWN_NAME comes from the places layer (cities/boroughs/towns).
# # The result assigns each census tract the town it overlaps with most.
# # This operation uses sf for spatial processing. In practice, some tracts may cross town boundaries, so rules may differ by project (e.g., only assign where overlap is significant).
# # You can export mapping to CSV:
# #   R
# write.csv(mapping, "pa_tract_to_town_mapping.csv", row.names = FALSE)
