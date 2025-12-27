##  towns.pasted
towns.pasted =  function(D){
    temp = D %>% dplyr::group_by(tracts)
  #temp %>% summarise(townsAll=paste0(towns, collapse=','))
  temp = split(D, D$tracts)
  temp.t = lapply(temp, function(t) paste(t$towns, collapse=','))
  temp.3 = data.frame(tracts = unique(D$tracts))
  temp.3$towns = temp.t[match(temp.3$tracts, names(temp.t))]
  dim(temp.3)  #108
  return(temp.3)
}

#### check ####
# temp = towns.pasted(tractsLemeryPgh)
# temp$towns[temp$tracts=='42003040200']
# tractsLemeryPgh$towns[tractsLemeryPgh$tracts=='42003040200']
#OK
