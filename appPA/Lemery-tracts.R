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
setcompare(tractsLemery$tracts,  PAtown$GEOID)
missing_tracts = tractsLemery[which(! (tractsLemery$tracts %in% PAtown$GEOID)), ]
dim(missing_tracts)
### 13 Lemery tracts have no data in PAtown (& PAtowndata).
# Before saving, we will take them out, since no geometry available:
tractsLemery = tractsLemery[which( tractsLemery$tracts %in% PAtown$GEOID), ]

####  tractsLemeryPgh  #############
tractsLemeryPgh = read.csv(header = F, 'appPA/Pittsburgh_Census_Tracts_1940-2020.csv')
names(tractsLemeryPgh) = c('towns', 'year', 'tracts')
tractsLemeryPgh = tractsLemeryPgh %>% subset(year=='2020')
tractsLemeryPgh = tractsLemeryPgh[c('towns', 'tracts')]
#### 90 rows, but some multiple
dim(tractsLemeryPgh)
### fix for Spring Hill   (2620)  NOT needed anymore;  fixed in spreadsheet
# tractsLemeryPgh = tractsLemeryPgh[ - match('2620', tractsLemeryPgh$tracts) , ]
dim(tractsLemeryPgh)  #90
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
#   146 'towns' in Pittsburgh, 125 tracts
setcompare(tractsLemeryPgh$tracts, tractsLemery$tracts)  ### no overlap!

setcompare(tractsLemeryPgh$tracts, PAtown$GEOID)
# 108 tracts are in both
#  17 tracts in Lemery not PAtown, so they will be blank on map- no geometry.
# both x_not_y
# 108      17
# Before saving, we will take them out, since no geometry available:
dim(tractsLemeryPgh[tractsLemeryPgh$tracts %in% PAtown$GEOID, ])
## 118 though some duplicate tracts.  See below.
tractsLemeryPgh  = tractsLemeryPgh[tractsLemeryPgh$tracts %in% PAtown$GEOID, ]
setcompare(tractsLemeryPgh$tracts, PAtown$GEOID)
# Pittsburgh boroughs:
# setcompare(tractsLemeryPgh$tracts, PAtown$GEOID, countsonly = F) [1:2]

# names of overlapping boroughs:
tractsLemeryPgh$towns[which(tractsLemeryPgh$tracts %in% PAtown$GEOID)]
#118  towns,  108 tracts.   Ten tracts appear more than once
##Aha.  a few tracts are duplicated in tractsLemeryPgh
which(duplicated(tractsLemeryPgh$tracts))
table(table(tractsLemeryPgh$tracts))
#  8 have 2 towns, one has 3 towns.

temp = tractsLemeryPgh[tractsLemeryPgh$tracts %in%
                  tractsLemeryPgh$tracts[duplicated(tractsLemeryPgh$tracts)], ]
temp[order(temp$tracts),]
length((temp$tracts))  ## 19  names sharing tracts.
length(unique(temp$tracts))  ## 9 tracts have multiple towns

#  We can use towns.pasted()  later if desired.
# OR: just select the first name...
#tractsLemeryPgh = tractsLemeryPgh[which(!duplicated(tractsLemeryPgh$tracts)), ]
#  doesn't matter which.  As above, 'back burner'.
dim(tractsLemeryPgh)


#sanity check
oakland = tractsLemeryPgh[grep('Oakland', tractsLemeryPgh$towns) , ]
leaflet::leaflet() %>% addTiles() %>%
  addPolygons(
    data=PAtown[PAtown$GEOID %in% oakland$tracts, ],
    label = ~GEOID )
### looks ok.

## This (Pittsburgh) tag will signal when it's a Pittsburgh neighborhood name.
tractsLemeryPgh$towns = paste(tractsLemeryPgh$towns, '(Pittsburgh)')
table(table(tractsLemeryPgh$towns))
#  1  2  3  4  5
# 37 13  6  3  3

save(tractsLemeryPgh, file='tractsLemeryPgh.Rd')
# In terminal, appPA,    ln ../tractsLemeryPgh.Rd .    into appPA.

### combine with tractsLemery
tractsLemery = rbind(tractsLemery, tractsLemeryPgh)

setcompare(tractsLemery$tracts, tt1.sw$tracts)  ### 360 in both
# both x_not_y y_not_x
# 360       0     448   ### we have removed dup names sharing tracts.
notIn_tt1 = setcompare(tractsLemery$tracts, tt1.sw$tracts, countsonly = F) [[2]]
PAtown %>% subset(tracts %in% notIn_tt1)

save(tractsLemery, file='tractsLemery.Rd')
# In terminal, appPA,    ln ../tractsLemery.Rd .    into appPA.
