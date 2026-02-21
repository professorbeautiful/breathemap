
# source'ing this file works.

appName = 'BreatheMap'
appName = 'BreatheMap-noIQ'
appName = 'BreatheMap-test'

appTitle = 'BreatheMap for southwestern Pennsylvania'


### you may need shinyDebuggingPanel installed fresh
devtools::install_github('professorbeautiful/shinyDebuggingPanel')
# Note: this app is a package!  devtools::install_github('professorbeautiful/BreatheMap')



#  git push --set-upstream origin BreatheMap
#### gitbranch.txt  Nice idea, needs work.

# gitbranch.txt = readLines('appPA/gitbranch.txt')

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
appFiles = c(appFileManifestKept,
             paste0('deploying', appName))

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

#_site.yml
# publish_site(
#   site_dir = 'appPA',
#   site_name = 'appPA',  #'appPAtest',
#   method = c("rsconnect"),
#   server = 'shinyapps.io',
#   account = 'trials',
#   render = TRUE,
#   launch_browser = interactive()
# )

