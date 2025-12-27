##   compare two sets
setcompare = function(x,y, countsonly=TRUE) {
  both=intersect(x,y)
  x_not_y = setdiff(x,y)
  y_not_x = setdiff(y,x)
  if(countsonly)
    return(c(both=length(both), x_not_y=length(x_not_y), y_not_x=length(y_not_x)))
  else return(list(both=(both), x_not_y=(x_not_y), y_not_x=(y_not_x)))
}
