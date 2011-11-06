# File-Name:       drew_reports.R
# Date:            2011-11-05
# Author:          Drew Conway
# Email:           drew.conway@nyu.edu                                      
# Purpose:         Generates a map of of where in the world Martus is being used
# Data Used:       data/*.csv
# Packages Used:   RCurl, RJSONIO, ggplot2
# Machine:         Drew Conway's MacBook Pro

# Copyright (c) 2011, under the Simplified BSD License.  
# For more information on FreeBSD see: http://www.opensource.org/licenses/bsd-license.php
# All rights reserved.

library(maps)

# WARNING: This takes a very long time...you have been warned.

# geo.coded <- lapply(unique(benetech.full$location), function(l), geocode.addr(l)))
#     
# geo.data <- data.frame(do.call(rbind, geo.coded))

# write.csv(geo.data, 'geo_data.csv', row.names=FALSE)
# write.csv(geo.frequency, 'geo_frequency.csv', row.names=FALSE)

geo.data <- read.csv('../data/geo_data.csv', stringsAsFactors=FALSE)
names(geo.data) <- c('location', 'lng', 'lat')

geo.frequency <- ddply(geo.data, .(lng, lat), summarise, count=length(location))
names(geo.frequency) <- c('lng', 'lat', 'count')

globe <- data.frame(map(plot=FALSE)[c('x','y')])
map.plot <- ggplot(globe, aes(x=x, y=y))+geom_path(aes(alpha=0.25))
map.plot <- map.plot + geom_point(data=geo.frequency, aes(x=lng, y=lat, alpha=0.86, size=count))