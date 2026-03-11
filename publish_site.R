
# rearrange these appName lines:
# the last one is deployed when source'ing this file

####  It would be bette to include appName as arg in hideIfDesired.
appName = 'BreatheMap-noIQ'  #16630494
appName = 'BreatheMap-test-with-IQ-no-popify'  #16827732
appName = 'BreatheMap'  #16404137       The toggles are hidden
appName = 'BreatheMap-full'  #16842009
appName = 'BreatheMap-test'  # 16730739    The toggles are hidden

extraFiles =   c( 'www/IQ-faq.html',
                  'gitbranch.txt',
                  'Tool Revisions - FAQ.html',
                  'www/article-results-on-IQ.html')
removeFiles = 'FAQ.Rmd'
### (also the appName file; see below)

##### no edits needed below this line ####

#For showAppLog only
appNumbers = c('BreatheMap-noIQ'='16630494',
               'BreatheMap' ='16404137',
               'BreatheMap-full'= '16842009',
               'BreatheMap-test-with-IQ-no-popify' ='16827732',
               'BreatheMap-test' = '16730739')

showAppLog = function(app=appName) {
  browseURL(paste0('https://www.shinyapps.io/admin/#/application/',
                   appNumbers[app], '/logs'))
}
runSelectedApp = function(app=appName) {
  browseURL(paste0('https://trials.shinyapps.io/',
                   app))
}

appTitle = 'BreatheMap for southwestern Pennsylvania'

#  review appFileManifestKept.R   to assure all needed files are there.

### you may need shinyDebuggingPanel installed fresh
devtools::install_github('professorbeautiful/shinyDebuggingPanel')
# Note: this app is a package!  devtools::install_github('professorbeautiful/BreatheMap')


gitbranch.latest =  system(" git branch -v|grep '^*'",  intern = T)
gitbranch.recentlog = system(" git log @{5}..HEAD --shortstat ",  intern = T)
gitbranch.txt = paste("Deployed: \n",
  gitbranch.latest, '\n=-=-=-=-=-\nRecent:\n',
                      paste(collapse='\n', gitbranch.recentlog) )

cat(gitbranch.txt)


write(file = 'appPA/gitbranch.txt',
      gitbranch.txt )


### Read by server. We can use shinyDebuggingPanel to view it.


logLevel = c("normal", "quiet", "verbose") [3]

## Use file.exists(grep('deployBreatheMap-noIQ', dir() , v=T)
#  etc to detect the version in ui and server.
##
source('appPA/appFileManifestKept.R')
appFiles = c(unique(appFileManifestKept),
             extraFiles,
             paste0('deploying', appName))
appFiles = setdiff(appFiles, removeFiles)
##  Adding the correct 'deploying' file
#  to the manifest will signal the app code, in hideIfDesired().


### 2026-02-18  I removed appPAtest from
# '/Users/rogerday/Library/Mobile Documents/com~apple~CloudDocs/Fireman backup/appPA/rsconnect/shinyapps.io/trials/BreatheMap.dcf'

# launch.browser.bad = getOption("rsconnect.launch.browser",
#                            is_interactive())
###----- Deployment error -----
# Error in is_interactive() : could not find function "is_interactive"

rsconnect::deployApp(
  appDir = ifelse(basename(getwd()) == 'appPA', '.', 'appPA'),
  appFiles = appFiles,
  appFileManifest = NULL,
  appPrimaryDoc = NULL,
  appName = appName,
  appTitle = appTitle,
  envVars = NULL,
  appId = NULL,
  appMode = 'shiny',
  contentCategory = NULL,
  account = NULL,
  server = 'shinyapps.io',
  upload = TRUE,
  recordDir = NULL,
  # launch.browser = launch.browsergetOption("rsconnect.launch.browser", is_interactive()),
  on.failure = NULL,
  logLevel = logLevel,
  lint = TRUE,
  metadata = list(),
  forceUpdate = NULL,
  python = NULL,
  #forceGeneratePythonEnvironment = FALSE,
  quarto = NA,
  appVisibility = NULL, #NULL, "private", or "public". NULL= no change
  image = NULL,
  envManagement = NULL,
  envManagementR = NULL,
  envManagementPy = NULL,
  space = NULL
)
print(appName)
print('  showAppLog() ;  runSelectedApp()   ')
