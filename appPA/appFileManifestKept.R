###The output in Deploy does not help...
# Bundling 188 files:
#appFileList = _site.yml, .claude.install.sh.swp, acknowledgements.R, addLemeryPlaces.R, addLukeTracts.R, appData (1).Rdata, appData (2).Rdata, appData.Rdata, appdatafiles_MA/appData.Rdata, appdatafilesforbreathemap/appData.Rdata, appdatafilesforbreathemap/massachusetts_columnchartdata.Rdata, appFrame.html, bun.zip, buttons.css, claude.install.sh, cohort.births.plus.Rd, cohort.births.Rd, cohort.earnings.lost.Rd, …, _site/tractsLemeryPgh.Rd, and _site/www/KeyHandler.js
#appFileManifest = "/var/folders/y1/7kk7_q3961gfg_ytn8jg335m0000gn/T/f735-1bea-88a6-c3b6",

# BUT this works great.
appFileManifest = rsconnect::listBundleFiles(appDir = 'appPA')
# see also listDeploymentFiles()
appFileManifestContents = appFileManifest$contents

appFileManifestKeepThese =
  regexpr(pattern = '(\\.)(R|js|Rd|Rmd|css|Rhtml)$',
          text = appFileManifestContents,
          perl = T)
appFileManifestKept =
  appFileManifestContents[appFileManifestKeepThese > 0]

appFileManifestKept =c('inclRmd.R', 'FAQ.Rmd', appFileManifestKept )

excludedFiles = setdiff(appFileManifestContents, appFileManifestKept)
