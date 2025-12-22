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
# [185] "see City of Pittsburgh under Local Census Tract Numbers"

#  conmpare with
dim(tracts_with_towns)
#[1] 739   9
dim(tractsLemery)   #### so we have many more tracts than lemery does.
#[1] 279   2
intersect(tractsLemery$tract, gsub('Census Tract ', '', tracts_with_towns$tracts) )
###  only 8 ???
str(tractsLemery$tract)
str(gsub('Census Tract ', '', tracts_with_towns$tracts))
head(sort(tractsLemery$tract))
head(sort(gsub('Census Tract ', '', tracts_with_towns$tracts)) )
head(sort(PAtowndata$NAMELSAD))
lemeryTowns = tractsLemery$town[
  match(tractsLemery$tract,
        gsub('Census Tract ', '', tracts_with_towns$tracts)
)]
cbind(lemeryTowns, tracts_with_towns$towns, tractsLemery$tract)
