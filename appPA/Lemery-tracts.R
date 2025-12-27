####  CONCLUSION:  only 8 tracts in common!  Dead end.

# https://pitt.libguides.com/uscensus/alleghenycotracts
# clemery@pitt.edu Christopher Lemery
tractsLemery.csv = read.csv('Allegheny_County_Municipalities_Census_Tracts_2000-2020.csv')
## for fun... how did the tracts change over decades?
table(tractsLemery.csv$X2000.Census.Tracts == tractsLemery.csv$X2010.Census.Tracts) #27 changed
table(tractsLemery.csv$X2020.Census.Tracts == tractsLemery.csv$X2010.Census.Tracts) #7 changed
## we use 2020

#grep(',  ', tractsLemery.csv$X2020.Census.Tracts)
#grep(', [45]', tractsLemery.csv$X2020.Census.Tracts)
tractsLemerySplit = strsplit(tractsLemery.csv$X2020.Census.Tracts, split=', *')
tractsLemery = data.frame(towns=unlist(sapply(1:nrow(tractsLemery.csv),
                                              function(n)rep(tractsLemery.csv$Municipality[n],
                                                             each=length(tractsLemerySplit[[n]])))),
                          tracts=unlist(tractsLemerySplit)
)
dim(tractsLemery)
### 279, but some duplicate tracts. No duplicated names.  See below.

### Hmm, Spring Hill not there anymore. Ah, it was in tractsLemeryPgh
# FAIL if \x96 still there grep(v=T,'Spring ', tractsLemery$towns)
# tractsLemery[343,]  #cheating...  BUT 343 is out of scope?!
# tractsLemery[343, 'towns']  ### you can print it but nothing else. "Spring Hill \x96 City View"
# tractsLemery[343, 'towns']  =
# 'Spring Hill City View'  ## a stray character \x96

match(  "see City of Pittsburgh under Local Census Tract Numbers",
  tractsLemery$tracts)   #185
tractsLemery = tractsLemery [
  - match(
    "see City of Pittsburgh under Local Census Tract Numbers",
    tractsLemery$tracts) , ]

tractsLemery$tracts =
  as.character(as.numeric(tractsLemery$tracts) * 100
               + 42003000000)

table((!duplicated(tractsLemery$towns)))   ## 148 duplicated, 130 not
table(table(tractsLemery$towns))  ##
sort(table(tractsLemery$towns))  ### Penn Hills has 10 tracts
# of course, some towns have multiple tracts.  Not a problem.

table((!duplicated(tractsLemery$tracts)))   ## 13 duplicated
tractsDuplicated = tractsLemery$tracts[which(duplicated(tractsLemery$tracts))]
tractsDuplicatedData = tractsLemery[tractsLemery$tracts %in% tractsDuplicated, ]
dim(tractsDuplicatedData)  ### 21 duplicated tracts. No duplicated town names.
table(tractsDuplicatedData$tracts)   #just 2 except 7 for 5638.
tractsLemery$towns[tractsLemery$tracts=='42003563800']   # 2 of the 7 are Osborne
tractsLemery$towns[tractsLemery$tracts %in% names(table(tractsDuplicatedData$tracts))]   # 2 of the 7 are Osborne

#### let's back-burner for now.
#### remove all duplicates. only the 1st town name will appear.
#(alternative wd be to string the place names together.)
dim(tractsLemery)   #### tt1.sw has many more tracts  (808) than lemery does.
#[1] 278   2
#### remove duplicated, what's left is just one per tract
tractsLemery =  tractsLemery [ - which(duplicated(tractsLemery$tracts)), ]
dim(tractsLemery)   #### so we have many more tracts than lemery does.
#[1] 265   2

setcompare(tractsLemery$tracts, tt1.sw$tracts )
###     both x_not_y y_not_x
#        252      13     431
missing_towns = tractsLemery[which(! (tractsLemery$tracts %in% PAtown$GEOID)), ]
dim(missing_towns)  ### 13 Lemery towns have no data in PAtown.  That's ok.

####  tractsLemeryPgh  #############
tractsLemeryPgh = read.csv(header = F, 'appPA/Pittsburgh_Census_Tracts_1940-2020.csv')
names(tractsLemeryPgh) = c('towns', 'year', 'tracts')
tractsLemeryPgh = tractsLemeryPgh %>% subset(year=='2020')
tractsLemeryPgh = tractsLemeryPgh[c('towns', 'tracts')]
#### 90 rows, but some multiple
dim(tractsLemeryPgh)
### fix for Spring Hill   (2620)
tractsLemeryPgh = tractsLemeryPgh[ - match('2620', tractsLemeryPgh$tracts) , ]
dim(tractsLemeryPgh)  #89
#

longtracts = (strsplit(split=', ', tractsLemeryPgh$tracts))  #146
tractsLemeryPgh = data.frame(
  towns= unlist(
    sapply(seq(along=tractsLemeryPgh$towns),
           function(t) rep(tractsLemeryPgh$towns[t],
                           length(longtracts[[t]])))),
  tracts=unlist(longtracts))   ##OK
tractsLemeryPgh$tracts =
  as.character(as.numeric(tractsLemeryPgh$tracts) * 100
               + 42003000000)
dim(tractsLemeryPgh)
#145 in Pittsburgh

setcompare(tractsLemeryPgh$tracts, PAtown$GEOID)
# 107 in both, 17 in lemery not PAtown, so they will be blank on map- no geometry.
# both x_not_y
# 107      17
# Before saving, we will take them out, since no geometry available:
 #####   tractsLemeryPgh  = tractsLemeryPgh[tractsLemeryPgh$tracts %in% PAtown$GEOID, ]
dim(tractsLemeryPgh[tractsLemeryPgh$tracts %in% PAtown$GEOID, ])
## 117 though some duplicate tracts.  See below.
# Pittsburgh boroughs:
# setcompare(tractsLemeryPgh$tracts, PAtown$GEOID, countsonly = F) [1:2]

# names of overlapping boroughs:
tractsLemeryPgh$towns[which(tractsLemeryPgh$tracts %in% PAtown$GEOID)]
#117   but the intersection is only 107 .   Ten tracts appear more than once
##Aha.  a few tracts are duplicated in tractsLemeryPgh
which(duplicated(tractsLemeryPgh$tracts))

temp = tractsLemeryPgh[tractsLemeryPgh$tracts %in%
                  tractsLemeryPgh$tracts[duplicated(tractsLemeryPgh$tracts)], ]
temp[order(temp$tracts),]
length(unique(temp$tracts))  ## 18 tracts have multiple names.
#  East Allegheny and North Shore.
# solution: just select the first name... doesn't matter.  As above, 'back burner'.
tractsLemeryPgh = tractsLemeryPgh[which(!duplicated(tractsLemeryPgh$tracts)), ]
### OK, 124 distinct tracts in Pittsburgh.  109 of them are in PAtown.
### Down from 145 to 124.

### keep only rows with a tract match in PAtown? but may be in pa_places
# names of missing boroughs:  (17)
table(! (tractsLemeryPgh$tracts %in% PAtown$GEOID))
### 107 hits.  17 missing from PAtown.
table(! (tractsLemeryPgh$tracts %in% PAtowndata$GEOID))  # also 17 missing
missing_boroughs =   tractsLemeryPgh[which(! (tractsLemeryPgh$tracts %in% PAtown$GEOID)), ]
#### should we remove them later?  yes if no other source for geometry.
pmatch(missing_boroughs$towns, pa_places$NAME)  # only 2 partial matches.
missing_boroughs$towns[!is.na(pmatch(missing_boroughs$towns, pa_places$NAME)  )]
#[1] "Arlington" "Hays"

### command to remove the missing boroughs
tractsLemeryPgh  = tractsLemeryPgh[tractsLemeryPgh$tracts %in% PAtown$GEOID, ]
dim(tractsLemeryPgh)
###  finally, 107 rows.

## This (Pittsburgh) tag will signal when it's a Pittsburgh neighborhood name.
tractsLemeryPgh$towns = paste(tractsLemeryPgh$towns, '(Pittsburgh)')

save(tractsLemeryPgh, file='tractsLemeryPgh.Rd')
# In terminal, appPA,    ln ../tractsLemeryPgh.Rd .    into appPA.

### combine with tractsLemery
tractsLemery = rbind(tractsLemery, tractsLemeryPgh)

setcompare(tractsLemery$tracts, tt6.sw$GEOID.x)  ### 359 in both
# both x_not_y y_not_x
# 359      13     323   ### we have removed dup names sharing tracts.
# for the 13, we will not have geometry.  So drop them.
tractsLemery = tractsLemery[tractsLemery$tracts %in% tt6.sw$GEOID.x , ]
setcompare(tractsLemeryPgh$tracts, tt6.sw$GEOID.x)  ### 107 in both

save(tractsLemery, file='tractsLemery.Rd')
# In terminal, appPA,    ln ../tractsLemery.Rd .    into appPA.
