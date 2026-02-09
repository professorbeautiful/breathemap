
### you may need shinyDebuggingPanel installed fresh
#  devtools::install_github('professorbeautiful/shinyDebuggingPanel')
# Not a package!  devtools::install_github('professorbeautiful/BreatheMap')


#  git push --set-upstream origin BreatheMap
#### gitbranch.txt  Nice idea, needs work.

gitbranch.txt = readLines('appPA/gitbranch.txt')

gitbranch.latest =  system(" git branch -v|grep '^*'",  intern = T)

gitbranch.txt = paste(gitbranch.latest,
                             collapse='\n', gitbranch.txt)
cat(gitbranch.txt)


write(file = 'appPA/gitbranch.txt',
      gitbranch.txt )


### Read by server. We can use shinyDebuggingPanel to view it.

# appName = 'appPA_deployApp'
# appTitle = 'appPA_deployApp'
# appName = 'appPA'
# appTitle = 'appPA'
appName = 'BreatheMap'
appTitle = 'BreatheMap for southwestern Pennsylvania'
logLevel = c("normal", "quiet", "verbose") [3]

# launch.browser.bad = getOption("rsconnect.launch.browser",
#                            is_interactive())
###----- Deployment error -----
# Error in is_interactive() : could not find function "is_interactive"

rsconnect::deployApp(
  appDir = ifelse(basename(getwd()) == 'appPA', '.', 'appPA'),
  appFiles = NULL,
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

