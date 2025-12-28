##### addLemeryPlaces.R

#####  add Lemery information, after running Lemery-tracts.R to produce tractsLemery

tt1.sw.l = tt1.sw
dim(tt1.sw.l)

tt1.sw.l$lem.towns = NA
tt1.sw.l$lem.towns = tractsLemery$towns[
  match(tt1.sw.l$tracts, tractsLemery$tracts)]

tt1.sw.l$lem.tracts = NA
tt1.sw.l$lem.tracts = tractsLemery$tracts[
  match(tt1.sw.l$tracts, tractsLemery$tracts)]

tt1.sw.l.comparison = as.data.frame(tt1.sw.l[c('lem.towns', 'towns', 'tracts')])
tt1.sw.l.comparison = tt1.sw.l.comparison[ !is.na(tt1.sw.l.comparison$lem.towns ), ]
head(tt1.sw.l.comparison)
###  Kennedy, towns=NA,  tracts=42003460001
#### confused me because I hadn't fixed the "NA" problem in towns.pasted() yet.

table(is.na(tt1.sw.l$towns), is.na(tt1.sw.l$lem.towns) ,
      dnn = c('towns', 'lem.towns'))
#          lem.towns
# towns   FALSE TRUE
#   FALSE   350  364
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
#   116   133   559

names_are_different = (tt1.sw.l$places != tt1.sw.l$lem.towns)
table(names_are_different, exclude=NULL)
# FALSE  TRUE  <NA>
#   133   116   559
theDifferentNames = cbind(tt1.sw.l$places, tt1.sw.l$lem.towns
) [which(names_are_different), ]
dim(theDifferentNames)
## 8 are for "borough"   length(grep("\\(Pittsburgh\\)", tt1.sw.l$lem.towns))
#  108 :   Lemery gives finegrain name.
#  STET  tt1.sw.l$lem.towns = gsub(' Borough$', '', tt1.sw.l$lem.towns)
# spot check looks ok, e.g. West Deer Twp contains  Curtisville  on google maps.
#  and "Bakerstown"   "Richland Twp"   are the same.
tt1.sw.l$lem.neighborhood = (1:nrow(tt1.sw.l)) %in%
  grep("\\(Pittsburgh\\)", tt1.sw.l$lem.towns)
###
#### Time for sensible var names
tt1.sw.l$towns.tt1 = tt1.sw.l$towns  ### to safekeeping.
table( is.na(tt1.sw.l$towns))    #276 missing names,
### use lem.towns to replace the missing.
tt1.sw.l$towns[ is.na(tt1.sw.l$towns.tt1) ] =
  tt1.sw.l$lem.towns[ is.na(tt1.sw.l$towns.tt1) ]
names(tt1.sw.l)
tt1.sw.l = moveColumn(
  tt1.sw.l,
  c('towns', 'lem.towns', 'lem.neighborhood', 'towns.tt1', 'names_are_different',
    'tracts', 'lem.tracts', 'onlyLuke' )
)
# head(tt1.sw.l[1:8])
 table( ! is.na(tt1.sw.l$towns))  ### 276 are still missing.
