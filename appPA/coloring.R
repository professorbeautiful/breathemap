breatheGreen.previous = '#7E0023';   # dark red!
breatheGreen = '#63a60b';
mypickwas = '#75C443'
referenceColor = breatheGreen.previous;
referenceColorStyle = paste0('color:', referenceColor, ';')
breatheLabelColoring = paste0('background-color:', breatheGreen, '; color:white')
leftSideButtonStyle = breatheLabelColoring
rightSideButtonStyle = paste(breatheLabelColoring,
                             '; border-radius: 15px;
                             height: 50% !important;
                             padding:4px; font-size:10px; font-weight:bold')
