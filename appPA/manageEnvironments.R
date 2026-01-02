save(list=ls(), file='lsBackup2025-12-29.Rd')
ls(envir=env.2025_12_29)
#envNames = function()
envNames =  names(
    which(
      sapply(ls(),
             FUN = function(o)
               is.environment(get(o,pos = 1))
      )
    )
  )   ### includes thisSession
envNames.f = function() {
  names(
    which(
      sapply(ls(pos=1),
             FUN = function(o)
               is.environment(get(o,pos = 1))
      )
    )
  )
}

not_envNames.f = function() {
  names(
    which(
      sapply(ls(pos=1),
             FUN = function(o)
               ! is.environment(get(o,pos = 1))
      )
    )
  )
}
sapply(ls(),
       FUN = function(o)
         if( ! is.environment(get(o))) {
           assign(x = o, value = get(o),
                  envir=env.2025_12_29)
         }
)
ls(envir = env.2025_12_29)
rmNotEnv = function(){
  toRemove = not_envNames.f()
  toRemove = setdiff(toRemove,
                     c('rmNotEnv', 'not_envNames.f', 'envNames.f',
                       'cq', 'moveColumns', 'showTownsInLeaflet'))
  print(toRemove)
  cat("were removed\n")
  rm(list = toRemove, pos=1)
}
rmNotEnv()
ls()  #### only environments left
rm(thisSession)
