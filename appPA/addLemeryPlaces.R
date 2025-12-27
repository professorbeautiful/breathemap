##### addLemeryPlaces
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
tt1.sw.l %>% filter(tracts=='42003090100')
#### note 2 places:  Millvale and Pittsburgh. ####
#### How many "Pittsburgh" places also have a neighborhood name?
####  But Millvale is NOT part of Pittsburgh.
table(is.na(tt1.sw$places))
# FALSE  TRUE
# 1912   25    #### but why now suddenly 1911    31 ?
tt1.sw$tracts[is.na(tt1.sw$places)]

table(is.na(tt1.sw.l$places), is.na(tt1.sw.l$lem.towns) , dnn = c('places', 'lem.towns'))
#          lem.towns
# places  FALSE TRUE
#   FALSE   878  1034
#   TRUE     10   15
##   so of the 25 that tt1 did not have places(town names) for,
##   10 are provided by Lemery
##   15 both are still missing!
cq = function(s, split=' ') strsplit(split=split, s)[[1]]
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
tt1.sw.l$lem.neighborhood = (1:nrow(tt1.sw.l)) %in% grep("(Pittsburgh)", tt1.sw.l$lem.towns)

#### Time for sensible var names
tt1.sw.l$towns.tt1 = tt1.sw.l$towns  ### to safekeeping.
table( is.na(tt1.sw.l$towns))    #25 missing names, so..
### use lem.towns to replace the missing.
tt1.sw.l$towns[ is.na(tt1.sw.l$towns.tt1) ] =
  tt1.sw.l$lem.towns[ is.na(tt1.sw.l$towns.tt1) ]
table( is.na(tt1.sw.l$towns))
# just 15 missing names, now.

tt1.sw.l = moveColumn(
  tt1.sw.l,
  c('towns', 'lem.towns', 'lem.neighborhood', 'towns.tt1', 'names_are_different', 'GEOID.x', 'tracts', 'lem.tracts', )
)
# head(tt1.sw.l[1:8])
# table( ! is.na(tt1.sw.l$towns))
