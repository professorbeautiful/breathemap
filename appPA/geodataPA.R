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
names(pa_tracts)
# Download Pennsylvania towns/places (cities, boroughs, etc.)
pa_places <- places(state = "PA", year = 2020, class = "sf")   ### '.y'
dim(pa_places)
names(pa_places)  #Only 1888 rows
table(pa_places$NAMELSAD %in% pa_tracts$NAMELSAD )
tail(sort(pa_tracts$NAMELSAD))   ### these are census tracts
tail(sort(pa_places$NAMELSAD))   ### these are town names
pa_tracts$tracts = pa_tracts$NAMELSAD
pa_places$towns = pa_places$NAMELSAD
##### so do NOT merge by them.
pa_places$towns = pa_places$NAME  ### better;  leave out 'borough' etc

tail(sort(pa_tracts$GEOID))   ### "42133024002"
tail(sort(pa_places$GEOID))   ### "4287320"dim
pa_tracts$lat = pa_tracts$INTPTLAT
pa_tracts$lon = pa_tracts$INTPTLON
pa_places$lat = pa_places$INTPTLAT
pa_places$lon = pa_places$INTPTLON

pa_tracts$latlon = pa_tracts_latlon = apply(X = cbind(pa_tracts$INTPTLAT,pa_tracts$INTPTLON),
                         MARGIN = 1, paste, collapse=',')
pa_places$latlon = pa_places_latlon = apply(X = cbind(pa_places$INTPTLAT,pa_places$INTPTLON),
                         MARGIN = 1, paste, collapse=',')
head(sort(pa_tracts_latlon))
head(sort(pa_places_latlon))
intersect(y=pa_tracts_latlon , pa_places_latlon)  ### only 256 the same.
intersect(y=pa_tracts$latlon , pa_places$latlon)  ### only 256 the same.

tracts_with_towns =  st_join(pa_tracts %>% select(c('lat', 'lon','latlon', 'tracts')),
                             pa_places %>% select(c('lat', 'lon','latlon', 'towns')),
                                                 join=st_intersects
)
#### vastly faster computation than copilot's join.
# plot(tracts_with_towns$lat.x, tracts_with_towns$lat.y)
# plot(tracts_with_towns$lon.x, tracts_with_towns$lon.y)
#### OK.  close, NOT exact.  No wonder copilot code broke.

### write out for input into the app.
save(tracts_with_towns, file='tracts_with_towns.Rd')




#####################################################################
# DEAD END.  crap from copilot.  SEE ABOVE
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
