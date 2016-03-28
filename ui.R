library(shiny)

# User interface of our Shiny app
# Side panel(left) contains all the user control
# Output calculated based on user input are shown in the main panel (right)

# type runApp() in the directory
shinyUI(pageWithSidebar(
  headerPanel('World population distribution'),
  
  # user control
  sidebarPanel(
    # population statistics
    radioButtons("type", "Population Statistics:",
                 c("Total population" = "Total.population",
                   "Female population" = "Female.population",
                   "Male population" = "Male.population",
                   "Male/Female ratio" = "male.over.female",
                   "Population density" = "Population.density")),
    
    # projection method used to calculate future population statistics. 
    # Visible only if year > 2015
    conditionalPanel(
      condition = "input.Year > 2015",
      selectInput("proj", "Projection type",
                 c("Medium" = 2,
                   "High" = 3,
                   "Low" = 4,
                   "Constant fertility" = 5,
                   "Instant replacement" = 6,
                   "Zero migration"=7,
                   "Constant mortality"=8,
                   "No change"=9))
    ),
    
    # year for which population statistics are extracted
    sliderInput("Year", "Year", 
                min=1950, max=2095, value=2015,  step=5,
                sep='',animate=FALSE)
  ),
  
  # data output panel
  mainPanel(
    h3(textOutput("info")), # information about the type of data displayed
    htmlOutput("gvis"), # geographics distribution of the population statistics
    plotOutput("histogram"), # histogram of population statistics
    "Source: UN Population Division <http://esa.un.org/unpd/wpp/Download/Standard/ASCII/>"
  )
))