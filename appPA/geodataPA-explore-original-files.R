pa.tracts.original <- tracts(state = "PA", year = 2020, class = "sf")   ###  '.x'
pa.places.original <- places(state = "PA", year = 2020, class = "sf")   ### '.y'
names(pa.places.original)
names(pa.tracts.original)
dim(pa.places.original)  #1888
dim(pa.tracts.original)   #3446
head(pa.places.original)
head(pa.tracts.original)

head(pa.tracts.original$GEOID)              #11 digits
head(sort(pa.tracts.original$GEOID) )             #11 digits
table(substr(pa.tracts.original$GEOID, 1,2))  ### all start with 42 (PA)

head(pa.places.original$GEOID)              # 7 digits
table(substr(pa.places.original$GEOID, 1,2))  ### all start with 42 (PA)
head(sort(pa.places.original$GEOID))              # 7 digits

head(pa.tracts.original$TRACTCE)              # 6 digits
head(sort(pa.tracts.original$TRACTCE) )             # lots of 000100
summary(as.numeric(pa.tracts.original$TRACTCE))

#Sharon in pa.places.original
grep('69720', pa.tracts.original$GEOID)

head(pa.tracts.original$TRACTCE)
head(pa.places.original$GEOID)
head(pa.tracts.original$GEOID)

hits.where = (sapply(substr(pa.places.original$GEOID, 3, 1000)  ,
                     grep, pa.tracts.original$TRACTCE))
length(hits.where)  ###  334    out of 1888
hits.lengths = sapply(hits.where, length)
(hits.match.table = table(hits.lengths))
hits.match = sapply(substr(pa.places.original$GEOID, 3, 1000) ,
                     grep, v=T, pa.tracts.original$TRACTCE)
head(hits.match)
which(hits.lengths==2)
hits.where.2 = hits.where[which(hits.lengths==2)]
c(names(hits.where.2)[1], pa.tracts.original$TRACTCE[hits.where.2[[1]]] )
sapply(hits.where[which(hits.lengths==2)],
       function(x) (pa.tracts.original$TRACTCE[[hits.match[x]]] ) )

sapply(1:length(hits.where.2), function(x)c(names(hits.where.2)[x],
                                            pa.tracts.original$TRACTCE[hits.where.2[[x]]] ) )
#  sigh.   doesn't provide a mapping.
sapply(pa.places.original$GEOID,function(x) {
  pa.tracts.original$TRACTCE[hits.where]
})


