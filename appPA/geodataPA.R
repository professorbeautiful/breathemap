# Install needed packages if not already installed
if (!requireNamespace("tigris")) install.packages("tigris")
if (!requireNamespace("sf")) install.packages("sf")
if (!requireNamespace("dplyr")) install.packages("dplyr")

library(tigris)
library(sf)
library(dplyr)

options(tigris_use_cache = TRUE)

# Download Pennsylvania census tracts
pa.tracts <- pa.tracts.original <- tracts(state = "PA", year = 2020, class = "sf")   ###  '.x'
dim(pa.tracts)    # 3446 rows
head(pa.tracts,1)
# The names are confusing.  Especially "NAME"!
# DONE pa.tracts_original = pa.tracts
pa.tracts = pa.tracts %>% dplyr::rename(tractNumber = NAME)
pa.tracts = pa.tracts %>% dplyr::rename(CT_tractNumber = NAMELSAD)
# GEOID = paste0(STATEFP,COUNTYFP,TRACTCE)
# TRACTCE = as.character(tractNumber*100)
with(pa.tracts, cbind(as.numeric(TRACTCE)/100, tractNumber,
                      as.numeric(TRACTCE)/100 ==tractNumber
                       ) )     ### OK.
# NAMELSAD = paste('Census Tract', tractNumber)
# drop unneeded fields
pa.tracts = pa.tracts %>% dplyr::select( ! GEOID)
pa.tracts = pa.tracts %>% dplyr::select( ! MTFCC)
pa.tracts = pa.tracts %>% dplyr::select( ! FUNCSTAT)  ## all = "S"
pa.tracts = pa.tracts %>% dplyr::select( ! ALAND)
pa.tracts = pa.tracts %>% dplyr::select( ! AWATER)
pa.tracts = pa.tracts %>% dplyr::select( ! STATEFP)
names(pa.tracts)
# "COUNTYFP"       "TRACTCE"        "tractNumber"    "CT_tractNumber" "INTPTLAT"       "INTPTLON"       "geometry"

## 67 COUNTIES originally.  We only need those in countymap (8).
# table(PAtown$COUNTYFP)
dim(pa.tracts)
dim(pa.tracts %>% dplyr::filter(COUNTYFP %in% countymap[[1]]) )
pa.tracts = pa.tracts %>% dplyr::filter(COUNTYFP %in% countymap[[1]])
head(pa.tracts, 1)
dim(pa.tracts)    #### 752 7

# Download Pennsylvania towns/places (cities, boroughs, etc.)
pa.places <- pa.places.original <- places(state = "PA", year = 2020, class = "sf")   ### '.y'
dim(pa.places)  ## 1888
head(pa.places, 1)  #Only 1888 rows
# The names are confusing.  Especially "NAME"!
pa.places = pa.places %>% dplyr::rename(townName = NAME)
pa.places = pa.places %>% dplyr::rename(townNamePlus = NAMELSAD)  ### includes "city", "borough" etc
table(gsub(".* ", "", pa.places$townNamePlus))
# this GEOID is the same as pa.tracts$TRACTCE ????
pa.places = pa.places %>% dplyr::rename(TRACTCE = GEOID)
pa.places = pa.places %>% dplyr::select(
  strsplit(split=' ',
           'PLACEFP PLACENS TRACTCE townName townNamePlus INTPTLAT INTPTLON geometry')[[1]])


pa.tracts = pa.tracts %>% dplyr::rename(lat = INTPTLAT)
pa.tracts = pa.tracts %>% dplyr::rename(lon = INTPTLON)
pa.places = pa.places %>% dplyr::rename(lat = INTPTLAT)
pa.places = pa.places %>% dplyr::rename(lon = INTPTLON)

pa.tracts$latlon = pa.tracts_latlon = apply(X = cbind(pa.tracts$lat,pa.tracts$lon),
                         MARGIN = 1, paste, collapse=',')
pa.places$latlon = pa.places_latlon = apply(X = cbind(pa.places$lat,pa.places$lon),
                         MARGIN = 1, paste, collapse=',')
head(sort(pa.tracts_latlon),3)
head(sort(pa.places_latlon),3)
intersect(y=pa.tracts_latlon , pa.places_latlon)  ### only 74 identical
intersect(y=pa.tracts$latlon , pa.places$latlon)  ### only 74 the same.
table(pa.places$geometry %in% pa.tracts$geometry) # only 65
table(pa.places$latlon %in% pa.tracts$latlon) # only 74
pa.places
st_join()

intersect(names(pa.tracts), names(pa.places))  #"TRACTCE"  "lat" "lon" "geometry" "latlon"
setdiff(names(pa.tracts), names(pa.places)) #"COUNTYFP"       "tractNumber"    "CT_tractNumber"
setdiff( names(pa.places), names(pa.tracts)) # "PLACEFP"      "PLACENS"      "townName"     "townNamePlus"
dim(pa.tracts)
dim(pa.places)


tracts_with_towns =  st_join(pa.tracts %>% select(c('lat', 'lon','latlon', 'TRACTCE')),
                             pa.places %>% select(c('lat', 'lon','latlon', 'towns', 'TRACTCE')),
                                                 join=st_intersects
)
tracts_with_towns =  st_join(pa.tracts, pa.places, join=st_intersects)
dim(pa.tracts)
dim(pa.places)
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
# tracts_with_towns <- st_join(pa.tracts, pa.places, join = st_intersects, largest = TRUE)
# ### this does not work correctly.
# tracts_with_towns <- st_join(pa.tracts, pa.places, join = "geometry", largest = TRUE)
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
