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

tt1.sw = st_join(pa_tracts_sw, pa_places, left=TRUE) # 1942
dim(tt1.sw) # many more places than tracts!  but map is many to many.
View(tt1.sw)
paste0(collapse=', ', names(tt1.sw))
tt1.sw.names = c("tracts", "tracts.short", "lat.tracts", "lon.tracts", "county.tracts", "places", "towns", "lat.places", "lon.places", "geometry")
tt1.sw.names = c("tracts", "places", "towns", "county.tracts",  "tracts.short", "lat.tracts", "lon.tracts", "lat.places", "lon.places", "geometry")
tt1.sw = moveColumns(tt1.sw, tt1.sw.names)
tract_counts = table(tt1.sw$tracts)
tract_counts_table = table(tract_counts)
sum(tract_counts_table)  #752
sum(tract_counts_table * as.numeric(names(tract_counts_table)))  #1942

tt1.sw.save = tt1.sw
tt1.sw.save$tract_count = tract_counts[match(tt1.sw.save$tracts, names(tract_counts))]
tt1.sw.save %>% subset(tract_count ==13) %>% select(places)
(tt1.sw.save %>% subset(tract_count ==13) %>% select(tracts)  ) [1,1]
#wow  13 places for 42125784000
tt1.sw.save.1.1 = tt1.sw.save[tt1.sw.save$tract_count == 1 , ]

place_counts = table(tt1.sw.save$places)
place_counts_table = table(place_counts)
sum(place_counts_table)  #398
sum(place_counts_table * as.numeric(names(place_counts_table)))  #1911
tt1.sw.save$place_count = place_counts[match(tt1.sw.save$places, names(place_counts))]
(tt1.sw.save %>% subset(place_count == max(as.numeric(names(place_counts_table)))) %>% select(places)
  )   ### 180 Pittsburgh.  correct.

#### since our feature data is based on tracts, we need the tract geometry.
### When there are multiple towns for a tract, pick the first one, or else paste.
### When there are multiple tracts for a  town... not our problem.
table(tt1.sw.save$tracts %in% PAtowndata.lukedata$GEOID) # 1797
table(unique(tt1.sw.save$tracts) %in% PAtowndata.lukedata$GEOID) # we have data for 683 tracts
table(PAtowndata.lukedata$GEOID %in% unique(tt1.sw.save$tracts)) # also 683.
## therefore, restrict tt1.sw to the 683 tracts.
tt1.sw = tt1.sw.save[tt1.sw.save$tracts %in% PAtowndata.lukedata$GEOID, ]
dim(tt1.sw)   ### 1797
place_counts = table(tt1.sw$places, exclude=NULL)  ### 25 missing places
place_counts_table = table(place_counts)
sum(place_counts_table)  #391
sum(place_counts_table * as.numeric(names(place_counts_table)))  #1772 + 25
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

## this takes several minutes. NOT NEEDED

# tt6.sw <-  st_join(pa_tracts_sw, pa_places_sw, join = st_intersects, largest = TRUE)
# dim(tt6)
# names(tt6)
#tt6.allPA = tt6

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
              data=tt1.sw,
              label = ~tracts )

tt6$NAME.y[ tt6$GEOID.x=='42003271600']   ###  Pittsburgh
#but...
tt6.sw$NAME.y[ tt6.sw$GEOID.x=='42003271600']
which(PAtown$GEOID=='42003271600')
which(PAtowndata$GEOID=='42003271600')
### So no data for this empty tract along the ohio.

# ## RD code correction... copilot doesn't know about the .x .y copies maintained.

#####  add Lemery information
tt6.sw.l = tt6.sw
dim(tt6.sw.l)

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
##   so of the 140 that tt6 did not have town names for, 77 are provided by Lemery
## 283 both are not missing!

names_are_Pittsburgh = which(    # 111
  #(tt6.sw.l$NAME.y == tt6.sw.l$lem.towns) &
      (tt6.sw.l$NAME.y == 'Pittsburgh') )

table(tt6.sw.l$NAME.y == tt6.sw.l$lem.towns, exclude=NULL)
# FALSE  TRUE  <NA>
#   145   138   400
names_are_same = which(
  (tt6.sw.l$NAME.y == tt6.sw.l$lem.towns) &
    #  (tt6.sw.l$NAME.y!='Pittsburgh') &
    (!is.na(tt6.sw.l$NAME.y) ) )
## what are the differences? when not Pittsburgh, &  not NA.
names_are_different = which(
  (tt6.sw.l$NAME.y != tt6.sw.l$lem.towns) &
 #  (tt6.sw.l$NAME.y!='Pittsburgh') &  # leave Pittsburgh out of this part.
 (!is.na(tt6.sw.l$NAME.y) ) )
theDifferentNames = cbind(tt6.sw.l$NAME.y, tt6.sw.l$lem.towns
                          ) [names_are_different, ]
dim(theDifferentNames)   ## 37,  plus 43 say 'Pittsburgh'
# spot check looks ok, e.g. West Deer Twp contains  Curtisville  on google maps.
#  and "Bakerstown"   "Richland Twp"   are the same.

tt6.sw.l$names_are_different = TRUE
tt6.sw.l$names_are_different[ - names_are_same] = FALSE
tt6.sw.l$lem.nb = (1:nrow(tt6.sw.l)) %in% grep("(Pittsburgh)", tt6.sw.l$lem.towns)

#### Time for sensible var names
tt6.sw.l$towns.tt6 = tt6.sw.l$towns  ### to safekeeping.
table( is.na(tt6.sw.l$towns.tt6))    #140 missing names, so..
### use lem.towns to replace the missing.
tt6.sw.l$towns[ is.na(tt6.sw.l$towns.tt6) ] =
  tt6.sw.l$lem.towns[ is.na(tt6.sw.l$towns.tt6) ]
table( is.na(tt6.sw.l$towns))    #63 missing names, still. 10%


tt6.sw.l = moveColumn(
  tt6.sw.l,
  c('towns', 'lem.towns', 'lem.nb', 'towns.tt6', 'names_are_different', 'GEOID.x', 'tracts', 'lem.tracts', 'GEOID.x')
  )
head(tt6.sw.l[1:8])
table( ! is.na(tt6.sw.l$towns))  ###yes, 63 missing town names.
save(tt6.sw.l, file='tt6.sw.l.Rd')
tracts_with_towns =  tt6.sw.l
save(tracts_with_towns, file='tracts_with_towns.Rd')


