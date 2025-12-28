moveColumns = function(d, col, wh=1) {
  if(is.character(col))
    col = match(col, names(d))
  if(any(is.na(col))) {
    print(paste('moveColumns: ', sys.call()))
    print(str(col))
    return(d)
  }
  return(
    d [names(d) [ c(col, (1:length(d))[-col]  ) ] ]
  )
}

