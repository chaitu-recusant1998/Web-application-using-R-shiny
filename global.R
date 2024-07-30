# loading packages ---------------
library(shiny) # required to create shiny apps
library(shinydashboard) # required to create dashboards
library(shinyWidgets) # provides different input options
library(readxl) # provides functions to read excel files
library(dplyr) # provides functions for data manipulation
library(stringr) # provides functions for string manipulation
library(rmarkdown) # needed for parsing rmarkdown files
library(knitr) # needed to create pdf files from rmarkdown
library(shinycssloaders) # provides loading animations
library(DTedit) # creates editable data tables
library(ggplot2) # creates graphs and charts
library(shinybusy) # provides busy indicators
library(kableExtra) # extra customization for rmarkdown tables

# pre-defined values --------------
coordinators <- c("Adele H Marshall", "David Welkins", "Deepak Padmanabhan", "Felicity Lamrock", "Gary McKeown", "Hui Wang", "Laura Boyle", "Matthew Streeter")
