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

not_envNames =  names(
  which(
    sapply(ls(),
           FUN = function(o)
            ! is.environment(get(o,pos = 1))
    )
  )
)
sapply(ls(),
       FUN = function(o)
         if( ! is.environment(get(o))) {
           assign(x = o, value = get(o),
                  envir=env.2025_12_29)
         }
)
ls(envir = env.2025_12_29)
rm(list = not_envNames)
ls()  #### only environments left
rm(thisSession)
