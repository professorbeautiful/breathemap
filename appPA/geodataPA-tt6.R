# Install needed packages if not already installed
if (!requireNamespace("tigris")) install.packages("tigris")
if (!requireNamespace("sf")) install.packages("sf")
if (!requireNamespace("dplyr")) install.packages("dplyr")

library(tigris)
library(sf)
library(dplyr)

options(tigris_use_cache = TRUE)

# Download Pennsylvania census tracts
pa_tracts <- tigris::tracts(state = "PA", year = 2020, class = "sf")   ###  '.x'
dim(pa_tracts)    # 3446 rows
names(pa_tracts)
# Download Pennsylvania towns/places (cities, boroughs, etc.)
pa_places <- tigris::places(state = "PA", year = 2020, class = "sf")   ### '.y'
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

# this has been superseded by tt5... see below
#     st_contains
tt1 =  st_join(pa_tracts[ , c('lat', 'lon','latlon', 'tracts')],
                             pa_places[ , c('lat', 'lon','latlon', 'towns')],
                              join=st_intersects
 )
### write out for input into the app.
#save(tracts_with_towns, file='tracts_with_towns.Rd')

#### vastly faster computation than copilot's join.
# plot(tracts_with_towns$lat.x, tracts_with_towns$lat.y)
# plot(tracts_with_towns$lon.x, tracts_with_towns$lon.y)
#### OK.  close, NOT exact.  No wonder copilot code broke.




#https://github.com/r-spatial/sf/issues/578
require(tidytable)
require(tidyfast)
require(purrr)

# st_intersects_most <- function(x, y){
#   ints <- st_intersects(x,y)
#
#   tibble(
#     ROW_ID = imap(ints, ~rep(.y, times = length(.x))) %>% flatten_chr(),
#     INTERSECT_DF = flatten_int(ints) %>% map(~y[.x,] %>% st_drop_geometry), # note: see the reprex for st_drop_geometry's definition
#     INTERSECT_AREA = st_intersection(x,y) %>% st_area %>% map_dbl(1)
#   ) %>%
#     unnest %>%
#     mutate(geometry = st_geometry(x[ROW_ID,])) %>%
#     st_as_sf
# }
# pa_intersects_most = st_intersects_most(pa_tracts, pa_places)
# Error: Can't coerce from an integer to a string.
# Called from: flatten_chr(.)

tt4=st_join(pa_places ,pa_tracts, ### order matters!
            join=st_contains
)
names(tt4)
dim(tt4)
grep('Pitts',tt4$towns)  #  89 hits
tt5 = tt4[tt4$COUNTYFP %in% countymap$COUNTYFP, ]
dim(tt5)   ###  156
tt5$county = countymap$county[match(tt5$COUNTYFP, countymap$COUNTYFP)]
table (tt5$county)
head(tt5)
### includes no tracts without towns
#### sourced in the app.
grep('Kane', tt5$towns)   ### tract 4211
grep('4211', PAtown$NAME)   ### 433
grep('4211', tt5$tracts)   ### not there.

save(tt5, file='tracts_with_towns.Rd')

#3139855 Nov 13 17:23 PAtown.Rd
dim(PAtown)   ## 739
names(PAtown)

#####################################################################
# DEAD END.  crap from copilot.  SEE ABOVE
# Spatial join: assign each tract to the town it intersects most with

## this takes several minutes.
tt6 <- tracts_with_towns <- st_join(pa_tracts, pa_places, join = st_intersects, largest = TRUE)
dim(tt6)
names(tt6)
tt6.allPA = tt6

###   GEOID.x is for tract (long form, 42051261200),
#     GEOID.y is for town.
#     NAME.y is the town name.
#     NAME.x is the 4-number tract... too small!
### You can only have one geometry.    it must be tracts.

# For tract name, use paste(COUNTYFP, GEOID.x/100
table(tt6$COUNTYFP)
tt6.sw = tt6 %>% subset(GEOID.x %in% PAtown$GEOID)
dim(tt6.sw)  #683!
tracts_with_towns = tt6.sw
save(tracts_with_towns, file='tracts_with_towns.Rd')

tt6.sw$GEOID.x[ which(tt6.sw$NAME.y=='Murrysville')]

tt6.sw$GEOID.x[ which(tt6.sw$NAME.y=='Brownsville')]

leaflet::leaflet() %>% addTiles() %>%
  addPolygons(
              data=tt6.sw,
              label = ~NAME.y )

tt6$NAME.y[ tt6$GEOID.x=='42003271600']   ###  Pittsburgh
#but...
tt6.sw$NAME.y[ tt6.sw$GEOID.x=='42003271600']
which(PAtown$GEOID=='42003271600')
which(PAtowndata$GEOID=='42003271600')
### So no data for this empty tract along the ohio.

# ## RD code correction... copilot doesn't know about the .x .y copies maintained.

#####  add Lemery information
tt6.sw.l = tt6.sw
dim(tt6.sw)

tt6.sw.l$lem.towns = tractsLemery$towns[
  match(tt6.sw.l$GEOID.x, tractsLemery$tracts)]

tt6.sw.l$lem.tracts = tractsLemery$tracts[
  match(tt6.sw.l$GEOID.x, tractsLemery$tracts)]
tt6.sw.l.comparison = as.data.frame(tt6.sw.l[c('lem.towns', 'NAME.y', 'GEOID.x')])
tt6.sw.l.comparison = tt6.sw.l.comparison[ !is.na(tt6.sw.l.comparison$lem.towns ), ]
head(tt6.sw.l.comparison)
table(is.na(tt6.sw$NAME.y))
# FALSE  TRUE
# 543   140
table(is.na(tt6.sw.l$NAME.y), is.na(tt6.sw.l$lem.towns) )
#       FALSE TRUE
# FALSE   283  260    543
# TRUE     77   63    140
##   so of the 140 that tt6 did not have town names for, 77 are provided by Lemery!

table(tt6.sw.l$NAME.y == tt6.sw.l$lem.towns, exclude=NULL)
# FALSE  TRUE  <NA>
#   145   138   400
## what are the differences?
names_are_different = which(
  (tt6.sw.l$NAME.y != tt6.sw.l$lem.towns) &
 (tt6.sw.l$NAME.y!='Pittsburgh') &
 (!is.na(tt6.sw.l$NAME.y) ) )
cbind(tt6.sw.l$NAME.y, tt6.sw.l$lem.towns) [names_are_different, ]
tt6.sw.l.different_names =
  tt6.sw.l.comparison [names_are_different, ]
dim(tt6.sw.l.different_names)   ## 37
# spot check looks ok, e.g. West Deer Twp contains  Curtisville  on google maps.

tt6.sw.l$names_are_different = names_are_different
tt6.sw.l$lem.nb = grep("(Pittsburgh)", tt6.sw.l$lem.towns)

#### Time for sensible var names
tt6.sw.l$towns.tt6 = tt6.sw.l$towns  ### to safekeeping.
table( is.na(tt6.sw.l$towns.tt6))    #140 missing names, so..
### use lem.towns to replace the missing.
tt6.sw.l$towns[ is.na(tt6.sw.l$towns.tt6) ] =
  tt6.sw.l$lem.towns[ is.na(tt6.sw.l$towns.tt6) ]
table( is.na(tt6.sw.l$towns))    #63 missing names, still. 10%

moveColumn = function(d, col, wh=1) {
  if(is.character(col))
    col = match(col, names(d))
  return(
      d [names(d) [ c(col, (1:length(d))[-col]  ) ] ]
  )
}
tt6.sw.l = moveColumn(
  tt6.sw.l,
  c('towns', 'lem.towns', 'lem.nb', 'towns.tt6', 'GEOID.y', 'tracts', 'lem.tracts', 'GEOID.x')
  )
head(tt6.sw.l[1:8])


