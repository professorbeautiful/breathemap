# Install needed packages if not already installed
if (!requireNamespace("tigris")) install.packages("tigris")
if (!requireNamespace("sf")) install.packages("sf")
if (!requireNamespace("dplyr")) install.packages("dplyr")

library(tigris)
library(sf)
library(dplyr)

### assuming in project folder.  This should NOT be done by the app, so that's ok.

options(tigris_use_cache = TRUE)
source('appPA/moveColumns.R', local = T)
source('appPA/cq.R', local = T)
countymap = data.frame(COUNTYFP =
                         strsplit(split=' ', '003 005 007 019 051 073 125 129 ')[[1]],
                       county=
                         strsplit(split=' ', 'Allegheny Armstrong Beaver Butler Fayette Lawrence Washington Westmoreland')[[1]]
)
#### Download Pennsylvania census tracts ####
source('appPA/get_pa_tracts_sw.R', local = T)
# Creates pa_tracts_sw.   752 rows.  Tracts are unique.
length(unique(pa_tracts_sw$tracts))
st_crs(pa_tracts_sw) #NAD83

#### Add Luke tracts ####
pa_tracts_sw.pre_luke <- pa_tracts_sw  #752
source('appPA/addLukeTracts.R', local = T)
# Creates pa_tracts_sw.luke_extended,  adds 56 new tracts.  Now 808.
pa_tracts_sw <- pa_tracts_sw.luke_extended
table(pa_tracts_sw$onlyLuke)
dim(pa_tracts_sw)  #808 tracts.   added 56
table(is.na(tt1.sw$towns))
table(is.na(tt1.sw$towns), tt1.sw$onlyLuke, dnn = cq('no_town onlyluke'))
#         onlyluke
# no_town FALSE TRUE
# FALSE   397   24
# TRUE    355   32
#   So 32 new names were found.

#### Download Pennsylvania towns/places (cities, boroughs, etc.) ####
source('appPA/get_pa_places.R', local = T)
# Creates pa_places.


####  STRICT st_join ####
tt1.sw.covered_by = st_join(pa_tracts_sw, pa_places, join=st_covered_by, left=TRUE)
dim(tt1.sw.covered_by) #  #  808.  One per tract.
table(is.na(tt1.sw.covered_by$towns))  #  421 matched.  387 still missing holes.

####  GENEROUS (sloppy; default) st_join ####
tt1.sw.intersect = st_join(pa_tracts_sw, pa_places, join=st_intersects, left=TRUE)
dim(tt1.sw.intersect) #  2082 The mapping is many to many
tt1.sw.default = st_join(pa_tracts_sw, pa_places, left=TRUE)
dim(tt1.sw.default) #2082
identical(tt1.sw.intersect, tt1.sw.default)
# tt1.sw.intersection = st_join(pa_tracts_sw, pa_places, join=st_intersection, left=TRUE)
# dim(tt1.sw.intersection) #  #  takes a long time!!!  Then FAILS.

#### Use tt1.sw.intersect (generous) to fill in the holes.  ####
tt1.sw = tt1.sw.covered_by
tt1.sw.towns.pasted = towns.pasted(tt1.sw.intersect)
tt1.sw$towns.intersects = tt1.sw.towns.pasted$towns[
  match(tt1.sw.towns.pasted$tracts,  tt1.sw$tracts)]
tt1.sw$towns.intersects.first = gsub(',.*', '', tt1.sw$towns.intersects)

#### Use town string or first town to fill holes ####

townHoles = is.na(tt1.sw$towns)
tt1.sw$towns[townHoles] = tt1.sw$towns.intersects[townHoles]
#  Use firsttown:    tt1.sw$towns[townHoles] = tt1.sw$towns.intersects.first[townHoles]
## We leave "places" untouched.
View(tt1.sw)
table(is.na(tt1.sw$towns))   ##  25 still missing. None in Luke
table( is.na(tt1.sw$towns), tt1.sw$onlyLuke, dnn = cq('townsNA luke'))
table( is.na(tt1.sw$places), tt1.sw$onlyLuke, dnn = cq('placesNA luke'))
### We leave "places" alone.

#### TODO - ONLY if needed: latitudes and longitudes ####
# Add latitudes and longitudes for Luke tracts
# Add latitudes and longitudes for town from towns.intersects.first
tt1.sw$lat.places.x = pa_places$lat.places[
  match(tt1.sw$towns.intersects.first, pa_places$places)]
tt1.sw$lon.places.x = pa_places$lon.places[
  match(tt1.sw$towns.intersects.first, pa_places$places)]
table(tt1.sw$lon.places.x == tt1.sw$lon.places)
View(cbind(tt1.sw$lat.places.x, tt1.sw$lat.places) ) ## not total agreement, 244 yes, 152 no
names(tt1.sw)

tt1.sw.names = c("tracts", "towns", "towns.intersects"
                 , "towns.intersects.first", "places", "county.tracts",  "tracts.short",
                 "onlyLuke",
                 "lat.tracts", "lon.tracts", "lat.places", "lon.places",
                 "geometry")
tt1.sw = moveColumns(tt1.sw, tt1.sw.names)
table(tt1.sw$county.tracts)
tt1.sw.save = tt1.sw   ## SAVE a copy

#### Keep only the 739 tracts. Both data and 'towns' for each. ####
table(tt1.sw.save$tracts %in% PAtown$GEOID, tt1.sw.save$onlyLuke,
      dnn=cq('we_have_data onlyLuke'))   ###739  are in our  data
#  739 tracts out of 808 are in our PAdata. 69 we have no data to show.
tt1.sw = tt1.sw.save[tt1.sw.save$tracts %in% PAtown$GEOID, ]
table(is.na(tt1.sw$towns))  ## 25 HOLES.

####   addLemeryPlaces  ####
#  Pick up better names from Lemery
sum(is.na(tt1.sw$towns))
source('appPA/addLemeryPlaces.R', local = T)

#####  add Lemery information
tt1.sw.l = tt1.sw
dim(tt1.sw.l)

tt1.sw.l$lem.towns = tractsLemery$towns[
  match(tt1.sw.l$tracts, tractsLemery$tracts)]

tt1.sw.l$lem.tracts = tractsLemery$tracts[
  match(tt1.sw.l$tracts, tractsLemery$tracts)]  ### found for 909 out of 1797
tt1.sw.l.comparison = as.data.frame(tt1.sw.l[c('lem.towns', 'places', 'tracts')])
tt1.sw.l.comparison = tt1.sw.l.comparison[ !is.na(tt1.sw.l.comparison$lem.towns ), ]
head(tt1.sw.l.comparison)
table(is.na(tt1.sw$places))
# FALSE  TRUE
# 1912   25
table(is.na(tt1.sw.l$places), is.na(tt1.sw.l$lem.towns) , dnn = c('places', 'lem.towns'))
#          lem.towns
# places  FALSE TRUE
#   FALSE   878  1034
#   TRUE     10   15
##   so of the 25 that tt1 did not have places(town names) for,
##   10 are provided by Lemery
##   15 both are still missing!
as.data.frame(
  tt1.sw.l[is.na(tt1.sw.l$places), ] %>%
    select(cq('tracts places county.tracts lem.towns'))
)   ### these are the 10 new names from Lemery

table(tt1.sw.l$places == tt1.sw.l$lem.towns, exclude=NULL)
# FALSE  TRUE  <NA>
#   738   140   1059

theDifferentNames = cbind(tt1.sw.l$places, tt1.sw.l$lem.towns
                          ) [which(tt1.sw.l$places != tt1.sw.l$lem.towns), ]
dim(theDifferentNames)   ## 37,  plus 43 say 'Pittsburgh'
# spot check looks ok, e.g. West Deer Twp contains  Curtisville  on google maps.
#  and "Bakerstown"   "Richland Twp"   are the same.

tt1.sw.l$names_are_different = TRUE
tt1.sw.l$names_are_different[ - names_are_same] = FALSE
tt1.sw.l$lem.neighborhood = (1:nrow(tt1.sw.l)) %in% grep("\\(Pitt", tt1.sw.l$lem.towns, perl=T)

#### Time for sensible var names
tt1.sw.l$towns.tt1 = tt1.sw.l$towns  ### to safekeeping.
table( is.na(tt1.sw.l$towns))    #25 missing names, so..
### use lem.towns to replace the missing.
tt1.sw.l$towns[ is.na(tt1.sw.l$towns.tt1) ] =
  tt1.sw.l$lem.towns[ is.na(tt1.sw.l$towns.tt1) ]
table( is.na(tt1.sw.l$towns))
# just 15 missing names, now.

### See 'Shaler Twp.docx'.  Conclusion: used lem.towns even when not missing.
tt1.sw.l$towns[ !is.na(tt1.sw.l$lem.towns) ] =
  tt1.sw.l$lem.towns[ !is.na(tt1.sw.l$lem.towns) ]

tt1.sw.l = moveColumns(
  tt1.sw.l,
  c('towns', 'lem.towns', 'lem.nb', 'towns.tt1', 'names_are_different', 'GEOID.x', 'tracts', 'lem.tracts')
  )
head(tt1.sw.l[1:8])
table( ! is.na(tt1.sw.l$towns))  ### 15 missing town names.

save(tt1.sw.l, file='tt1.sw.l.Rd')
tracts_with_towns =  tt1.sw.l

tracts_with_towns$twtSaved = tracts_with_towns$twt
tracts_with_towns$twt = tracts_with_towns$twt.for.tracts = tracts_with_towns$twt.for.towns =
  gsub( '^Pittsburgh 42', 'Pittsburgh (unspecified) 42',
        tracts_with_towns$twtSaved )
save(tracts_with_towns, file='tracts_with_towns.Rd')


