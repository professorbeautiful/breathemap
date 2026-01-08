
gitbranchOutput = grep(v=T, '^\\*', system("git branch -v",  intern = T) )
write(file = 'appPA/gitbranch.txt',
      grep(v=T, '^\\*', system("git branch -v",  intern = T) )
)
### Read by server. We can use shinyDebuggingPanel to view it.

appName = 'appPA_deployApp'
appTitle = 'appPA_deployApp'

deployApp(
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
  launch.browser = getOption("rsconnect.launch.browser", is_interactive()),
  on.failure = NULL,
  logLevel = c("normal", "quiet", "verbose"),
  lint = TRUE,
  metadata = list(),
  forceUpdate = NULL,
  python = NULL,
  #forceGeneratePythonEnvironment = FALSE,
  quarto = NA,
  appVisibility = NULL,
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

