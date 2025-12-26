# Install needed packages if not already installed
if (!requireNamespace("tigris")) install.packages("tigris")
if (!requireNamespace("sf")) install.packages("sf")
if (!requireNamespace("dplyr")) install.packages("dplyr")

library(tigris)
library(sf)
library(dplyr)

options(tigris_use_cache = TRUE)
moveColumns = function(d, col, wh=1) {
  if(is.character(col))
    col = match(col, names(d))
  return(
      d [names(d) [ c(col, (1:length(d))[-col]  ) ] ]
  )
}
# Download Pennsylvania census tracts
pa_tracts <- tigris::tracts(state = "PA", year = 2020, class = "sf")   ###  '.x'
dim(pa_tracts)    # 3446 rows
names(pa_tracts)
View(pa_tracts)
pa_tracts$tracts = pa_tracts$GEOID
pa_tracts$tracts.short = pa_tracts$NAME
pa_tracts$county.tracts = pa_tracts$COUNTYFP
pa_tracts$lat.tracts = pa_tracts$INTPTLAT
pa_tracts$lon.tracts = pa_tracts$INTPTLON
pa_tracts.names = c('tracts', 'tracts.short', 'lat.tracts', 'lon.tracts', 'county.tracts')
pa_tracts = moveColumns(pa_tracts, pa_tracts.names)
pa_tracts = pa_tracts %>% dplyr::select(all_of(pa_tracts.names))
    #  "all_of" suggested in warning if omitted.

# Download Pennsylvania towns/places (cities, boroughs, etc.)
pa_places <- tigris::places(state = "PA", year = 2020, class = "sf")   ### '.y'
dim(pa_places)
names(pa_places)  #Only 1888 rows
View(pa_places)
pa_places$towns = pa_places$NAME
pa_places$places = pa_places$NAME
pa_places$lat.places = pa_places$INTPTLAT
pa_places$lon.places = pa_places$INTPTLON
### no county info.
pa_places.names = c('places', 'towns', 'lat.places', 'lon.places')
pa_places = moveColumns(pa_places, pa_places.names)
pa_places = pa_places %>% dplyr::select(all_of(pa_places.names))

pa_tracts_sw = pa_tracts[pa_tracts$county.tracts %in% countymap$COUNTYFP, ]  # 752
source("~/Google Drive/Documents/Fireman Breathe Project/appPA/fixing missing fields - towns, geom.R")
pa_tracts_sw = pa_tracts_sw.new

tt1.sw = st_join(pa_tracts_sw, pa_places, left=TRUE) # 2082... was 1942
dim(tt1.sw) # many more places than tracts!  but map is many to many.
View(tt1.sw)
paste0(collapse=', ', names(tt1.sw))
tt1.sw.names = c("tracts", "places", "towns", "county.tracts",  "tracts.short",
                 "lat.tracts", "lon.tracts", "lat.places", "lon.places", "geometry")
tt1.sw = moveColumns(tt1.sw, tt1.sw.names)
tract_counts = table(tt1.sw$tracts)
tract_counts_table = table(tract_counts)
sum(tract_counts_table)  #808, was 752
sum(tract_counts_table * as.numeric(names(tract_counts_table)))  #2082, was 1942

tt1.sw.save = tt1.sw
tt1.sw.save$tract_count = tract_counts[match(tt1.sw.save$tracts, names(tract_counts))]
mostPlacesForATract = max(as.numeric(names(tract_counts_table)))   #13
tt1.sw.save %>% subset(tract_count == mostPlacesForATract) %>% select(places)
(tt1.sw.save %>% subset(tract_count == mostPlacesForATract) %>% select(tracts)  ) [1,1]
#wow  13 places for 42125784000
tt1.sw.save.1.1 = tt1.sw.save[tt1.sw.save$tract_count == 1 , ]

place_counts = table(tt1.sw.save$places)
place_counts_table = table(place_counts)
sum(place_counts_table)  #398
sum(place_counts_table * as.numeric(names(place_counts_table)))  #2051 was 1911
tt1.sw.save$place_count = place_counts[match(tt1.sw.save$places, names(place_counts))]
dim(tt1.sw.save %>% subset(place_count == max(as.numeric(names(place_counts_table)))) %>% select(places)
  )   ### 208 rows now  Pittsburgh.  Was 180.  correct.

#### since our feature data is based on tracts, we need the tract geometry.

### When there are multiple towns for a tract, pick the first one, or else paste.
### When there are multiple tracts for a  town... not our problem.
table(tt1.sw.save$tracts %in% PAtowndata.lukedata$GEOID) # 1937 was 1797
table(unique(tt1.sw.save$tracts) %in% PAtowndata.lukedata$GEOID) # we have data for 739, was 683 tracts
table(PAtowndata.lukedata$GEOID %in% unique(tt1.sw.save$tracts)) # also 739.
## therefore, restrict tt1.sw to the 739 tracts.
tt1.sw = tt1.sw.save[tt1.sw.save$tracts %in% PAtowndata.lukedata$GEOID, ]
dim(tt1.sw)   ### 1937

place_counts = table(tt1.sw$places, exclude=NULL)  ### still 25 missing places
place_counts_table = table(place_counts)
sum(place_counts_table)  #399
sum(place_counts_table * as.numeric(names(place_counts_table)))  #1937, was 1772 + 25
tt1.sw$place_count = place_counts[match(tt1.sw$places, names(place_counts))]
# don't worry about tract count. tt1.sw$tract_count = tract_counts[match(tt1.sw$tracts, names(tract_counts))]
tt1.sw %>% subset(tract_count ==13 ) %>% select(places)  ### still 13
(tt1.sw %>% subset(tract_count ==13) %>% select(tracts)  ) [1,1] #42125784000

# Check geometry:  Greensburg has 9 tracts.  Check the geom places vs tracts
tt1.sw[1, ]
st_area(print(tt1.sw[1, 'geometry']))  ### 1013591
st_area(print(pa_places [ pa_places$places=='Greensburg', 'geometry'])) #10491674
# so the area of Greensburg is bigger...  should the tracts add? This is about 1/10.
1013591/10491674
#  tracts could intersect multiple places, so we don't know for sure.
sum(st_area(print(tt1.sw[tt1.sw$places=='Greensburg', 'geometry']))  ### 1013591
) # 74843515.   No the tracts must overlap other places.  Probably ok.

10491674/74843515  ## 14% all Greensburg still smaller than the union of all the tracts.

tt_intersections = st_intersects(pa_tracts_sw$geometry, pa_tracts_sw$geometry)
View(as.data.frame(tt_intersections))
# (tt_intersections)   list 1752 × 7521 (S3: sgbp, list List of length 752

tt1.sw.reverse = st_join(pa_places, pa_tracts_sw, left=TRUE) # 3401
tt1.sw.reverse.tt = tt1.sw.reverse[c('places', 'tracts')]
tt1.sw.tt = tt1.sw[c('places', 'tracts')]
#do they at least agree on the 1 to 1 cases?  Probably not.



#     st_contains
# tt1 =  st_join(pa_tracts[ , c('lat', 'lon','latlon', 'tracts')],
#                              pa_places[ , c('lat', 'lon','latlon', 'towns')],
#                               join=st_intersects
#  )
### this was garbage.  Here' where phildelphia jumped in.
### write out for input into the app.

#### vastly faster computation than copilot's join.
# plot(tracts_with_towns$lat.x, tracts_with_towns$lat.y)
# plot(tracts_with_towns$lon.x, tracts_with_towns$lon.y)
#### OK.  close, NOT exact.  No wonder copilot code broke.


# pa_intersects_most = st_intersects_most(pa_tracts, pa_places)
# Error: Can't coerce from an integer to a string.
# Called from: flatten_chr(.)

#3139855 Nov 13 17:23 PAtown.Rd
dim(PAtown)   ## 739
names(PAtown)

#####################################################################
# DEAD END.  crap from copilot.  SEE ABOVE
# Spatial join: assign each tract to the town it intersects most with

## this takes several minutes. NOT NEEDED

# tt6.sw <-  st_join(pa_tracts_sw, pa_places_sw, join = st_intersects, largest = TRUE)
# dim(tt6)
# names(tt6)
#tt6.allPA = tt6

leaflet::leaflet() %>% addTiles() %>%
  addPolygons(
              data=tt1.sw,
              label = ~tracts )

PAtowndata.lukedata %>% filter(GEOID == '42003010300')  # it's there, but not in map
pa_tracts %>% filter(tracts == '42003010300')  ## missing.
tt1.sw %>% filter(tracts == '42003010300')  ## missing.
tractsLemeryPgh %>% filter(tracts == '42003010300')  ## missing.
grep('420030103', tractsLemeryPgh$tracts)  ## missing.
### so, we have no geometry for these tracts!

# ## RD code correction... copilot doesn't know about the .x .y copies maintained.

#####  add Lemery information
tt1.sw.l = tt1.sw
dim(tt1.sw.l)

tt1.sw.l$lem.towns = NA
tt1.sw.l$lem.towns = tractsLemery$towns[
  match(tt1.sw.l$tracts, tractsLemery$tracts)]

tt1.sw.l$lem.tracts = tractsLemery$tracts[
  match(tt1.sw.l$tracts, tractsLemery$tracts)]  ### found for 909 out of 1797
tt1.sw.l.comparison = as.data.frame(tt1.sw.l[c('lem.towns', 'places', 'tracts')])
tt1.sw.l.comparison = tt1.sw.l.comparison[ !is.na(tt1.sw.l.comparison$lem.towns ), ]
head(tt1.sw.l.comparison)
table(is.na(tt1.sw$places))
# FALSE  TRUE
# 1772   25
table(is.na(tt1.sw.l$places), is.na(tt1.sw.l$lem.towns) , dnn = c('places', 'lem.towns'))
#          lem.towns
# places  FALSE TRUE
#   FALSE   878  894
#   TRUE     10   15
##   so of the 25 that tt1 did not have places(town names) for,
##   10 are provided by Lemery
##   15 both are still missing!
cq = function(s, split=' ') strsplit(split=split, s)[[1]]
as.data.frame(
  tt1.sw.l[is.na(tt1.sw.l$places), ] %>%
    select(cq('tracts places county.tracts lem.towns'))
)   ### these are the 10 new names from Lemery

names_are_Pittsburgh = which(    # 162
      (tt1.sw.l$places == 'Pittsburgh') )

table(tt1.sw.l$places == tt1.sw.l$lem.towns, exclude=NULL)
# FALSE  TRUE  <NA>
#   738   140   919
names_are_same = which(
  (tt1.sw.l$NAME.y == tt1.sw.l$lem.towns) &
    #  (tt1.sw.l$NAME.y!='Pittsburgh') &
    (!is.na(tt1.sw.l$NAME.y) ) )
## what are the differences? when not Pittsburgh, &  not NA.
names_are_different = which(
  (tt1.sw.l$NAME.y != tt1.sw.l$lem.towns) &
 #  (tt1.sw.l$NAME.y!='Pittsburgh') &  # leave Pittsburgh out of this part.
 (!is.na(tt1.sw.l$NAME.y) ) )
theDifferentNames = cbind(tt1.sw.l$NAME.y, tt1.sw.l$lem.towns
                          ) [names_are_different, ]
dim(theDifferentNames)   ## 37,  plus 43 say 'Pittsburgh'
# spot check looks ok, e.g. West Deer Twp contains  Curtisville  on google maps.
#  and "Bakerstown"   "Richland Twp"   are the same.

tt1.sw.l$names_are_different = TRUE
tt1.sw.l$names_are_different[ - names_are_same] = FALSE
tt1.sw.l$lem.nb = (1:nrow(tt1.sw.l)) %in% grep("(Pittsburgh)", tt1.sw.l$lem.towns)

#### Time for sensible var names
tt1.sw.l$towns.tt1 = tt1.sw.l$towns  ### to safekeeping.
table( is.na(tt1.sw.l$towns))    #140 missing names, so..
### use lem.towns to replace the missing.
tt1.sw.l$towns[ is.na(tt1.sw.l$towns.tt1) ] =
  tt1.sw.l$lem.towns[ is.na(tt1.sw.l$towns.tt1) ]
table( is.na(tt1.sw.l$towns))    #25 missing names, still


tt1.sw.l = moveColumn(
  tt1.sw.l,
  c('towns', 'lem.towns', 'lem.nb', 'towns.tt1', 'names_are_different', 'GEOID.x', 'tracts', 'lem.tracts', 'GEOID.x')
  )
head(tt1.sw.l[1:8])
table( ! is.na(tt1.sw.l$towns))  ###yes, 25 missing town names.
save(tt1.sw.l, file='tt1.sw.l.Rd')
tracts_with_towns =  tt1.sw.l
save(tracts_with_towns, file='tracts_with_towns.Rd')


