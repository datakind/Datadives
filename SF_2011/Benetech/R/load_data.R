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

# Load data
data.file <- '../data/martus-bullacct-4datadive-2011-11-03.csv'
benetech <- read.csv(data.file, stringsAsFactors=FALSE)

# Format the dates
benetech$Build.Date <- as.POSIXlt(benetech$Build.Date, format='%m/%d/%Y')
benetech$date.uploaded <- as.POSIXlt(benetech$date.uploaded, format='%m/%d/%Y')
benetech$date.last.saved <- as.POSIXlt(benetech$date.last.saved, format='%m/%d/%Y')
benetech$date.authorized <- as.POSIXlt(benetech$date.authorized, format='%m/%d/%Y')
benetech$date.created <- as.POSIXlt(benetech$date.created, format='%m/%d/%Y')
benetech$event.date <- as.POSIXlt(benetech$event.date, format='%m/%d/%Y')

# Set dummy variables
benetech$final.version <- ifelse(benetech$final.version == 0, FALSE, TRUE)
benetech$test.bulletin <- ifelse(benetech$test.bulletin == 0, FALSE, TRUE)
benetech$all.private <- ifelse(benetech$all.private == 0, FALSE, TRUE)
benetech$has.custom.fields <- ifelse(benetech$has.custom.fields == 0, FALSE, TRUE)
benetech$original.server[which(benetech$original.server == 'Error: missing BUR')] <- NA
benetech$original.server[which(benetech$original.server == '0')] <- FALSE
benetech$original.server[which(benetech$original.server == '1')] <- TRUE
benetech$tester <- ifelse(benetech$tester == 0, FALSE, TRUE)

# Set factors
benetech$Build.Number[which(benetech$Build.Number == '?')] <- NA
benetech$Build.Number <- factor(benetech$Build.Number, ordered=TRUE, exclude='')
benetech$version.number <- factor(benetech$version.number, ordered=TRUE, exclude='')
benetech$type <- factor(benetech$type, exclude='')
benetech$group <- factor(benetech$group, exclude='')

