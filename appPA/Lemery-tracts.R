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
### 279, but some duplicate tracts. No duplicated names.  See below.

# FAIL  grep(v=T,'Spring ', tractsLemery$towns)
tractsLemery[343,]  #cheating...
tractsLemery[343, 'towns']  ### you can print it but nothing else. "Spring Hill \x96 City View"
tractsLemery[343, 'towns']  =
'Spring Hill City View'  ## a stray character \x96

match(  "see City of Pittsburgh under Local Census Tract Numbers",
  tractsLemery$tracts)   #185
tractsLemery = tractsLemery [
  - match(
    "see City of Pittsburgh under Local Census Tract Numbers",
    tractsLemery$tracts) , ]

tractsLemery$tracts =
  as.character(as.numeric(tractsLemery$tracts) * 100
               + 42003000000)

##   compare two sets
setcompare = function(x,y, countsonly=TRUE) {
  both=intersect(x,y)
  x_not_y = setdiff(x,y)
  y_not_x = setdiff(y,x)
  if(countsonly)
    return(c(both=length(both), x_not_y=length(x_not_y), y_not_x=length(y_not_x)))
  else return(list(both=(both), x_not_y=(x_not_y), y_not_x=(y_not_x)))
}
table((!duplicated(tractsLemery$tracts)))   ## 13 duplicated
duplicatedTracts = which(duplicated(tractsLemery$tracts))   ## 13 duplicated
tractsDuplicated = tractsLemery$tracts[which(duplicated(tractsLemery$tracts))]
tractsDuplicatedData = tractsLemery[tractsLemery$tracts %in% tractsDuplicated, ]
dim(tractsDuplicatedData)  ### 21 duplicated tracts. No duplicated town names.
table(tractsDuplicatedData$tracts)   #just 2 except 7 for 5638.

#### let's back-burner for now.
#### remove all duplicates. only the 1st will appear. (alternative wd be to string them along.)
dim(tractsLemery)   #### so we have many more tracts than lemery does.
#[1] 279   2
#### remove duplicated, so just one ber tracts
tractsLemery =  tractsLemery [ - duplicatedTracts, ]
dim(tractsLemery)   #### so we have many more tracts than lemery does.
#[1] 266   2

setcompare(tractsLemery$tracts, tt6.sw$GEOID.x )
###     both x_not_y y_not_x
#        252      13     431
missing_towns = tractsLemery[which(! (tractsLemery$tracts %in% PAtown$GEOID)), ]
dim(missing_towns)  ### 13 missing towns. No data in PAtown.  That's ok.

####  tractsLemeryPgh  #############
tractsLemeryPgh = read.csv(header = F, '/Users/rogerday/Google Drive/Documents/Fireman Breathe Project/appPA/Pittsburgh_Census_Tracts_1940-2020.csv')
names(tractsLemeryPgh) = c('towns', 'year', 'tracts')
tractsLemeryPgh = tractsLemeryPgh %>% subset(year=='2020')
tractsLemeryPgh = tractsLemeryPgh[c('towns', 'tracts')]
tractsLemeryPgh$tracts =
  as.character(as.numeric(tractsLemeryPgh$tracts) * 100
               + 42003000000)
dim(tractsLemeryPgh) #  146
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
setcompare(tractsLemeryPgh$tracts, PAtown$GEOID)  # 108, 17  Missing data for 17
# both x_not_y
# 108      17
# Pittsburgh boroughs:
setcompare(tractsLemeryPgh$tracts, PAtown$GEOID, countsonly = F) [1:2]
# names of overlapping boroughs:
tractsLemeryPgh$towns[which(tractsLemeryPgh$tracts %in% PAtown$GEOID)] #118
##Aha.  a few tracts are duplicated in tractsLemeryPgh
#  East Allegheny and North Shore.
# solution: just select the first name... doesn't matter.  As above, 'back burner'.
tractsLemeryPgh = tractsLemeryPgh[which(!duplicated(tractsLemeryPgh$tracts)), ]
### OK, 125 distinct tracts in Pittsburgh.  109 of them are in PAtown.

# names of missing boroughs:  (17)
missing_boroughs = tractsLemeryPgh[which(! (tractsLemeryPgh$tracts %in% PAtown$GEOID)), ]
match(missing_boroughs$tracts, pa_tracts$GEOID)
###Aha!  In pa_tracts but not PAtown.  We remove them later.
pmatch(missing_boroughs$towns, pa_places$NAME)  # only 2 partial matches.
missing_boroughs$towns[!is.na(pmatch(missing_boroughs$towns, pa_places$NAME)  )]
#[1] "Arlington" "Hays"

tractsLemeryPgh$towns = paste(tractsLemeryPgh$towns, '(Pittsburgh)')
intersect(tractsLemery$tracts, tractsLemeryPgh$tracts)  ## no intersection!?

tractsLemery = rbind(tractsLemery, tractsLemeryPgh)

setcompare(tractsLemery$tracts, tt6.sw$GEOID.x)  ### 360 in both
# both x_not_y y_not_x
# 360      30     323
# for the 30, we will not have geometry.  So drop them.
tractsLemery = tractsLemery[tractsLemery$tracts %in% tt6.sw$GEOID.x , ]
setcompare(tractsLemeryPgh$tracts, tt6.sw$GEOID.x)  ### 108 in both

