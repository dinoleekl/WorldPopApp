library(shiny)
library(googleVis)

# Computation / extraction data based on 3 pieces of information from the user
# * Year
# * population statistics the user is interested in
# * the projection method for future year

# read in data file to be used
mydf <- read.csv("subpopulation.csv")

# compute two more extra information
# * the sex ratio
mydf$male.over.female <- mydf$Male.population/mydf$Female.population
# * put the population density into log form to show the spatial variability
mydf$Population.density <-log(mydf$Population.density)

shinyServer(
  function(input,output){
    # reactive input from the user
    
    # year
    myYear <- reactive({
      input$Year
    })
    
    # population statistics
    myType <- reactive({
      input$type
    })
    
    # projection method
    myProj <- reactive({
      input$proj
    })
    
    # prepare the informative text to be shown to the user
    typeText <- reactive({
      if(myYear() > 2016){
        switch(myType(), Total.population = "Estimated total population (in thounsands)",
                         Male.population = "Estimated male population (in thounsands)",
                         Female.population = "Estimated female population (in thounsands)", 
                         male.over.female = "Estimated male over female ratio",
                         Population.density = "Log of estimated population density (persons per square km)"
        )        
      }else{
        switch(myType(), Total.population = "Total population (in thounsands)",
                         Male.population = "Male population (in thounsands)",
                         Female.population = "Female population (in thounsands)",                         
                         male.over.female = "Male over female ratio",
                         Population.density = "Log of population density (persons per square km)"
        )        
      }    
    })      
    
    # prepare the data subset for plotting and computing
    myData <- reactive({
      subset(mydf, VarID==myProj() & Year==myYear())
    })
    
    # mean of the population statistics
    mn <- reactive({
      mean(x=myData()[,myType()],na.rm=TRUE)
    })
    
    # standard deviation of the population statistics
    std <- reactive({
      sd(x=myData()[,myType()],na.rm=TRUE)
    })
    
    # title of histogram
    hist.title <- reactive({
      sprintf("Histogram of %s, mean=%.0f,sd=%.1f",typeText(),mn(),std())
    })
    
    # x-axis label of histogram
    hist.xlabel <- reactive({
      sprintf("%s of a country",typeText())
    })
    
    # Main information for output panel
    output$info <- renderText({
      paste(typeText()," in", myYear())
    })
    
    # plot the geo-spatial distribution of the population statistics
    output$gvis<-renderGvis({
      gvisGeoChart(na.omit(myData()), "Country", colorvar = myType(),
                   options=list(displayMode="regions",
                                legend="{numberFormat:'#,###,###.#'}",
                                width=500, height=400))
    })
    
    # plot the histogram of the population statistics
    # include mean and standard deviation in the histogram title
    output$histogram<-renderPlot(
      hist(myData()[,myType()],breaks=50,
           xlab=hist.xlabel(),
           ylab="Number of countries",
           main=hist.title())
    )
  }
)