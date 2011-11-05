# File-Name:       load_data.R
# Date:            2011-11-05
# Author:          Drew Conway
# Email:           drew.conway@nyu.edu                                      
# Purpose:         Load and cloean the Benetech data
# Data Used:       ../data/martus-bullacct-4datadive-2011-11-03.csv
# Machine:         Drew Conway's MacBook Pro

# Copyright (c) 2011, under the Simplified BSD License.  
# For more information on FreeBSD see: http://www.opensource.org/licenses/bsd-license.php
# All rights reserved.

# Load libraries
library(ggplot2)
library(RJSONIO)
library(RCurl)

# Load data
data.file <- '../data/martus-bullacct-4datadive-2011-11-03.csv'
benetech.full <- read.csv(data.file, stringsAsFactors=FALSE)

# Format the dates
benetech.full$Build.Date <- as.POSIXlt(benetech.full$Build.Date, format='%m/%d/%Y')
benetech.full$date.uploaded <- as.POSIXlt(benetech.full$date.uploaded, format='%m/%d/%Y')
benetech.full$date.uploaded[which(benetech.full$date.uploaded <= as.POSIXlt("2002-10-30"))] <- NA
benetech.full$date.last.saved <- as.POSIXlt(benetech.full$date.last.saved, format='%m/%d/%Y')
benetech.full$date.authorized <- as.POSIXlt(benetech.full$date.authorized, format='%m/%d/%Y')
benetech.full$date.created <- as.POSIXlt(benetech.full$date.created, format='%m/%d/%Y')
benetech.full$event.date <- as.POSIXlt(benetech.full$event.date, format='%m/%d/%Y')

# Set dummy variables
benetech.full$final.version <- ifelse(benetech.full$final.version == 0, FALSE, TRUE)
benetech.full$test.bulletin <- ifelse(benetech.full$test.bulletin == 0, FALSE, TRUE)
benetech.full$all.private <- ifelse(benetech.full$all.private == 0, FALSE, TRUE)
benetech.full$has.custom.fields <- ifelse(benetech.full$has.custom.fields == 0, FALSE, TRUE)
benetech.full$original.server[which(benetech.full$original.server == 'Error: missing BUR')] <- NA
benetech.full$original.server[which(benetech.full$original.server == '0')] <- FALSE
benetech.full$original.server[which(benetech.full$original.server == '1')] <- TRUE
benetech.full$original.server <- as.logical(benetech.full$original.server)
benetech.full$tester <- ifelse(benetech.full$tester == 0, FALSE, TRUE)

# Set factors
benetech.full$Build.Number[which(benetech.full$Build.Number == '?')] <- NA
benetech.full$Build.Number <- factor(benetech.full$Build.Number, ordered=TRUE, exclude='')
benetech.full$version.number <- factor(benetech.full$version.number, ordered=TRUE, exclude='')
benetech.full$type <- factor(benetech.full$type, exclude='')
benetech.full$group <- factor(benetech.full$group, exclude='')

# Add geo coding

# A function to query the Google Geo API. Get a lat/lon value for each address
geocode.addr <- function(addr, sleep=TRUE) {
    if(sleep) {
        Sys.sleep(runif(1))
    }
    geo.url <- "http://maps.googleapis.com/maps/api/geocode/json?address="
    geo.text <- getURL(paste(geo.url, URLencode(paste(addr, collapse="+")), "&sensor=false", sep=""))
    geo.json <- fromJSON(geo.text)
    if(geo.json$status == "OK"){
        return(c(addr, geo.json$results[[1]]$geometry$location))
    }
    else{
        if(geo.json$status == "OVER_QUERY_LIMIT") {
                stop("Hit rate limit")
        }
        else {
            return(c(addr, NA, NA))
        }
    }
}


# Subset to remove duplicates
benetech <- subset(benetech.full, !test.bulletin & original.server & !tester)
