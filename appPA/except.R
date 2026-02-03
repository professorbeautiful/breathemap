`%except%`  = function(x,y) {
  if(is.null(y)) return(x)
  if(length(y) == 0) return(x)
  return (x[-which(x %in% y)])
}
