####  CONCLUSION:  only 8 tracts in common!  Dead end.

# https://pitt.libguides.com/uscensus/alleghenycotracts
# clemery@pitt.edu Christopher Lemery
tractsLemery.csv = read.csv('Allegheny_County_Municipalities_Census_Tracts_2000-2020.csv')
tractsLemerySplit = strsplit(tractsLemery.csv$X2020.Census.Tracts, split=', *')
tractsLemery = data.frame(towns=unlist(sapply(1:nrow(tractsLemery.csv),
                                              function(n)rep(tractsLemery.csv$Municipality[n],
                                                             each=length(tractsLemerySplit[[n]])))),
                          tracts=unlist(tractsLemerySplit)
)
### 279, but some duplicate tracts. No duplicated names.
##   compare the sets of tracts
setcompare = function(x,y, countsonly=TRUE) {
  both=intersect(x,y)
  x_not_y = setdiff(x,y)
  y_not_x = setdiff(y,x)
  if(countsonly)
    return(c(both=length(both), x_not_y=length(x_not_y), y_not_x=length(y_not_x)))
  else return(list(both=(both), x_not_y=(x_not_y), y_not_x=(y_not_x)))
}
table((!duplicated(tractsLemery$tracts)))   ## 13 duplicated
duplicatedTracks = which(duplicated(tractsLemery$tracts))   ## 13 duplicated
tractsDuplicated = tractsLemery$tracts[which(duplicated(tractsLemery$tracts))]
tractsDuplicatedData = tractsLemery[tractsLemery$tracts %in% tractsDuplicated, ]
tractsDuplicatedData = tractsDuplicatedData[order(tractsDuplicatedData$tracts), ]
dim(tractsDuplicatedData)  ### 21 duplicated tracts. No duplicated town names.

dim(tracts_with_towns)
#[1] 739   9
dim(tractsLemery)   #### so we have many more tracts than lemery does.
#[1] 279   2
setcompare(tractsLemery$tracts, gsub('Census Tract ', '', tracts_with_towns$NAMELSAD) )
###     both x_not_y y_not_x
#        253      13     479
missing_towns = tractsLemery[which(! (tractsLemery$tracts %in% PAtown$NAME)), ]

head(sort(tractsLemery$tract))
head(sort(gsub('Census Tract ', '', tracts_with_towns$tracts)) )
head(sort(PAtowndata$NAMELSAD))
lemeryTowns = tractsLemery$town[
  match(tractsLemery$tract,
        gsub('Census Tract ', '', tracts_with_towns$tracts)
  )]
cbind(lemeryTowns, tracts_with_towns$towns, tractsLemery$tract)

#### "see City of Pittsburgh under Local Census Tract Numbers"
#### We will replace this entry by our tractsLemeryPgh
tractsLemeryPgh = read.csv(header = F, '/Users/rogerday/Google Drive/Documents/Fireman Breathe Project/appPA/Pittsburgh_Census_Tracts_1940-2020.csv')
names(tractsLemeryPgh) = c('towns', 'year', 'tracts')
tractsLemeryPgh = tractsLemeryPgh %>% subset(year=='2020')
tractsLemeryPgh = tractsLemeryPgh[c('towns', 'tracts')]
dim(tractsLemeryPgh) # only 90
longtracts = (strsplit(split=', ', tractsLemeryPgh$tracts))  #146
tractsLemeryPgh = data.frame(
  towns= unlist(
    sapply(seq(along=tractsLemeryPgh$towns),
           function(t) rep(tractsLemeryPgh$towns[t],
                           length(longtracts[[t]])))),
  tracts=unlist(longtracts))   ##OK
save(tractsLemeryPgh, file='tractsLemeryPgh.Rd')
dim(tractsLemeryPgh)   #146 in Pittsburgh
# ln ../tractsLemeryPgh.Rd .    into appPA.
setcompare(tractsLemeryPgh$tracts, PAtown$NAME)  # 109, 16
# both x_not_y
# 109      16
# Pittsburgh boroughs:
setcompare(tractsLemeryPgh$tracts, PAtown$NAME, countsonly = F) [1:2]
# names of overlapping boroughs:
tractsLemeryPgh$towns[which(tractsLemeryPgh$tracts %in% PAtown$NAME)] #120
##Aha.  a few tracts are duplicated in tractsLemeryPgh
#  East Allegheny and North Shore.
# solution: just select the first name... doesn't matter.

tractsLemeryPgh = tractsLemeryPgh[which(!duplicated(tractsLemeryPgh$tracts)), ]
tractsLemeryPgh$towns[tractsLemeryPgh$tracts=='2620'] =
  'Spring Hill City View'  ## a stray character \x96
### OK, 125 distinct tracts in Pittsburgh.  109 of them are in PAtown.

# names of missing boroughs:  (16)
missing_boroughs = tractsLemeryPgh[which(! (tractsLemeryPgh$tracts %in% PAtown$NAME)), ]
match(missing_boroughs$tracts, pa_tracts$NAME)
###Aha!  In pa_tracts but not PAtown.
pmatch(missing_boroughs$towns, pa_places$NAME)  # only 2 partial matches.
missing_boroughs$towns[!is.na(pmatch(missing_boroughs$towns, pa_places$NAME)  )]
#[1] "Arlington" "Hays"

tractsLemery[
  (match(
              "see City of Pittsburgh under Local Census Tract Numbers",
              tractsLemery$tracts)) #185
, ]
tractsLemery = tractsLemery [
  - match(
    "see City of Pittsburgh under Local Census Tract Numbers",
    tractsLemery$tracts) , ]
tractsLemeryPgh$towns = paste(tractsLemeryPgh$towns, '(Pittsburgh)')
tractsLemery = rbind(tractsLemery, tractsLemeryPgh)


