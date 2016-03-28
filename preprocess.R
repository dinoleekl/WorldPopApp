library(plyr)

# This script download the population statistics data 
# from United Nation Population Division
# (http://esa.un.org/unpd/wpp/Download/Standard/ASCII/)
# It will subsequently perform preprocessing so that it can be used in our Shiny app

# Download the raw data as zip file
zip.filename <-"raw.zip"
if(!file.exists(zip.filename)){
  file.URL <- paste("http://esa.un.org/unpd/wpp/DVD/Files/",
                    "1_Indicators%20(Standard)/ASCII_FILES/",
                    "WPP2015_DB02_Populations_Annual.zip",sep="")
  download.file(file.URL, zip.filename,method="curl")
}

# unzip the raw data file
csv.filename <-"WPP2015_DB02_Populations_Annual.csv"
if(!file.exists(csv.filename)){
  unzip(zip.filename)
}

# rename important variables for the data to be human-readable
df <- read.csv("WPP2015_DB02_Populations_Annual.csv",header=TRUE)
dfname <- names(df)
dfname[2] <- "Country"
dfname[5] <- "Year"
dfname[7] <- "Male.population"
dfname[8] <- "Female.population"
dfname[9] <- "Total.population"
dfname[11] <- "Population.density"
names(df) <- dfname

# rename some country names. This avoids 
# * error in non-standard text coding (a warning raised by shinyapps.io)
# * slow plotting of data in gvisGeoChart because of the need to search for names
df$Country <- revalue(df$Country, c("C\364te d'Ivoire"="Cote d'Ivory",
                                    "Russian Federation"="Russia",
                                    "United States of America"="United States",
                                    "Iran (Islamic Republic of)"="Iran",
                                    "United Republic of Tanzania"="Tanzania",
                                    "Cura\347ao"="Curacao",
                                    "R\351union"="Reunion",
                                    "Venezuela (Bolivarian Republic of)"="Venezuela"
                                    ))

# write only the necessary columns to data file to be used in app
# also, we only ouput data from every 1 in 5 year to reduce the data file size
write.csv(df[df$LocID < 900 & df$Year%%5==0,c(2,3,5,7:9,11)],
          "subpopulation.csv",row.names = FALSE)
