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

# WARNING: This may take a very long time...you have been warned.

### NOTE: To update the geocoding, uncomment the lines below

# geo.coded <- lapply(unique(benetech.full$location), function(l), geocode.addr(l)))
# geo.data <- data.frame(do.call(rbind, geo.coded))

# write.csv(geo.data, '../data/geo_data.csv', row.names=FALSE)

geo.data <- read.csv('../data/geo_data.csv', stringsAsFactors=FALSE)
names(geo.data) <- c('location', 'lng', 'lat')

geo.frequency <- ddply(geo.data, .(lng, lat), summarise, count=length(location))
names(geo.frequency) <- c('lng', 'lat', 'count')

globe <- data.frame(map(plot=FALSE)[c('x','y')])
map.plot <- ggplot(globe, aes(x=x, y=y))+geom_path(aes(alpha=0.25))+coord_map(projection='lagrange', ylim=c(-48,52))
map.plot <- map.plot + geom_point(data=subset(geo.frequency, !is.na(lng)), 
    aes(x=lat, y=lng, alpha=0.75, size=count, color=count))+scale_size(to=c(2,5), name='Martus Use')+
    scale_color_gradient(low='orange', high='darkred', name='Martus Use')+theme_bw()+
    scale_alpha(to=c(0.25,0.75), legend=FALSE)+xlab('')+ylab('')+
    opts(panel.grid.major=theme_blank(), panel.grid.minor=theme_blank(), 
        axis.text.x=theme_blank(), axis.text.y=theme_blank(), axis.ticks=theme_blank())
ggsave(plot=map.plot, filename='benetech_report-map_plot.pdf', width=8, height=5)