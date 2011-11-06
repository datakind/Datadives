#######################################################################################
#
# Benetech - Martus - Miju
# November 5, 2011
#
#######################################################################################

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
benetech <- read.csv("C:/Users/mhan/Documents/csv/martus-bullacct-4datadive-2011-11-03.csv", header = TRUE, sep = ",")

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

str(benetech)

#######################################################################################
#######################################################################################

################################# 2 - Version Release #################################

# Sort to look at data
#martus <- benetech[order(benetech$build.date.num),]
# subset for non-missing build and date combinations
  # Concat Build.Date and Build.Number together
  martus <- mutate(benetech, build.date.num = paste(Build.Date, Build.Number, sep=""))
  martus <- subset(martus, build.date.num != "NANA")

# Load Version Mappings
versions <- read.csv("C:/Users/mhan/Documents/csv/martus-build-to-version-mapping.csv", header = TRUE, sep = ",")
  # Convert Build.Date to a date format
  versions$release_build_date <- as.POSIXlt(versions$release_build_date, format='%m/%d/%Y')
str(versions)
View(versions)
# Merge Version Number on Release Build Date
martus_date_merge <- merge(martus,versions, by.x="Build.Date", by.y="release_build_date", all=TRUE)
View(martus_date_merge)
str(martus_date_merge)

# Subset the data of non-null client versions
martus_client_versions_from_date <- subset(martus_date_merge, !is.na(martus_client_version))
View(martus_client_versions_from_date)
# Subset the data of null client versions
martus_client_null_versions <- subset(martus_date_merge, is.na(martus_client_version))
  View(martus_client_null_versions)  
  # Take out columns from merge
  drop_vars <- names(martus_client_null_versions) %in% c("build_number","release_build_date","martus_client_version")
  martus_client_null_versions <- martus_client_null_versions[!drop_vars]                                                          

# Merge client version onto Build Number
martus_number_merge <- merge(martus_client_null_versions, versions, by.x="Build.Number", by.y="build_number", all=TRUE)

# Drop if version is missing ### !!! NOTE !!! ### !!! SOME VERSION MAPPINGS ARE MISSING !!! ###
martus_number_merge <- subset(martus_number_merge, !is.na(martus_client_version))

# Append the datasets together
  # REMOVE BUILD_NUMBER FROM DATASET 1
  drop_build_num <- names(martus_client_versions_from_date) %in% c("build_number")
  martus_client_versions_from_date <- martus_client_versions_from_date[!drop_build_num]
  # REMOVE RELEASE BUILD DATE FROM DATASET 2
  drop_release_date <- names(martus_number_merge) %in% c("release_build_date")
  martus_number_merge <- martus_number_merge[!drop_release_date]
martus_client_versions <- rbind(martus_client_versions_from_date, martus_number_merge)

################### PLOTTING VERSION BY BULLETINS AND ACCOUNTS ###################

View(martus_client_versions)
martusClients = data.frame(martus_client_versions)
head(martusClients)
class(martus_client_versions)

sqldf( "select date.authorized from martus_client_versions limit 10" )
test <- subset(martus_client_versions, is.na(date.last.saved)) # looking at where date is NULL

# Take out summary column --> it has values that are too long
drop_summary <- names(martusClients) %in% c("summary","title","keywords")
martusClients <- martusClients[!drop_summary]

# Keep only variables needed for graphing
martusClientNames <- names(martusClients) %in% c("date.uploaded"
                                                , "language"
                                                , "date.last.saved"
                                                , "martus_client_version"
                                                , "type"
                                                , "all.private")
martusClients <- martusClients[martusClientNames]

# Count number of versions by day
versions_summary <- ddply(martusClients, c( "date.uploaded","martus_client_version"), summarize, count=length(date.uploaded) )

View(versions_summary)

# Clean Data: Fix Date Format and Subset to Dates after 2002-10-01
versions_summary$date.uploaded <- as.Date(versions_summary$date.uploaded)
versions_summary <- subset(versions_summary, date.uploaded > as.Date(c("2002-10-01")))
martusClients$date.uploaded <- as.Date(martusClients$date.uploaded)
martusClients <- subset(martusClients, date.uploaded > as.Date(c("2002-10-01")))

################################

# BULLETINS VERSION
                         
ver_bar <- (ggplot(martusClients,
                     aes(as.Date(date.uploaded), fill=martus_client_version))
              + geom_bar()
              + opts(title="Martus Client Version")
              + xlab("Date")
              + ylab("Number of Bulletins")
            )
ver_bar
ggsave("C:/Users/mhan/Documents/graph/Martus Client Versions.png")

# SUBSET THE DATA TO ONLY 2010 - present

martusClientslimited <- subset(martusClients, date.uploaded > as.Date(c("2010-01-01")))

ver_bar_limited <- (ggplot(martusClientslimited,
                     aes(as.Date(date.uploaded), fill=martus_client_version))
              + geom_bar()
              + opts(title="Martus Client Version - 2010 to present")
              + xlab("Date")
              + ylab("Number of Bulletins")
            )
ver_bar_limited
ggsave("C:/Users/mhan/Documents/graph/Martus Client Versions Date Limited.png")

# If feeling ambitions, plot by country


# ACCOUNTS VERSION
                         
# Sum over public.code
#str(martus_client_versions)
#View(martus_client_versions)

#######################################################################################
#######################################################################################
#######################################################################################

# 7 by language

# only keep variables and rows needed
lang <- subset(benetech, !is.na(language))
langNames <- names(lang) %in% c("date.uploaded","language")
lang <- lang[langNames]
lang <- subset(lang, language != '?')
lang <- subset(lang, language != "")
# subset dates past 2002-10-01
lang <- subset(lang, as.Date(date.uploaded) > c("2002-10-01"))

# Recode language variable into standard codes
lang$langAgg[lang$language == "ENGLISH."] <- "en"
lang$langAgg[lang$language == "english"] <- "en"
lang$langAgg[lang$language == "en"] <- "en"
lang$langAgg[lang$language == "Bangla"] <- "bangla"
lang$langAgg[lang$language == "Bangladesh"] <- "bangla"
lang$langAgg[lang$language == "bangla"] <- "bangla"
lang$langAgg[lang$language == "ar"] <- "ar"
lang$langAgg[lang$language == "bur"] <- "bur"
lang$langAgg[lang$language == "es"] <- "es"
lang$langAgg[lang$language == "fa"] <- "fa"
lang$langAgg[lang$language == "fr"] <- "fr"
lang$langAgg[lang$language == "ru"] <- "ru"
lang$langAgg[lang$language == "th"] <- "th"

# Make langAgg a factor
lang$langAgg <- as.factor(lang$langAgg)

# Make month_year variable
lang <- mutate(lang, month = as.POSIXlt(date.uploaded)$mon + 1)
lang <- mutate(lang, year = as.POSIXlt(date.uploaded)$year + 1900)
lang <- mutate(lang, month_year = paste(lang$month, "01", lang$year, sep = "/"))
lang$month_year <- as.POSIXlt(lang$month_year, format="%m/%d/%Y")

# Summarise By Count
langCount <- ddply(lang, c("month_year","langAgg"), summarise, count=length(month_year))
# Subset for non-English
langCountNonEn <- subset(langCount, langAgg != "en")


# Plot Language over Time
langLine <- (ggplot(langCount, aes(x=as.Date(month_year), y=count, group = as.factor(langAgg)))
               + geom_line(aes(colour = langAgg, width = 1))
              + opts(title="Martus Languages Reported")
              + xlab("Date")
              + ylab("Number of Bulletins")
               )
langLine
ggsave("C:/Users/mhan/Documents/graph/Martus Languages Reported.png")

# Plot Language over Time - Non English
langLine <- (ggplot(langCountNonEn, aes(x=as.Date(month_year), y=count, group = as.factor(langAgg)))
               + geom_line(aes(colour = langAgg, width = 1))
              + opts(title="Martus Languages Reported - Non-English")
              + xlab("Date")
              + ylab("Number of Bulletins")
               )
langLine
ggsave("C:/Users/mhan/Documents/graph/Martus Languages Reported non English.png")


# Also Look at bars for easier reading
lang_bar <- (ggplot(lang,
                     aes(as.Date(date.uploaded), fill=langAgg))
              + geom_bar()
              + opts(title="Martus Language Reported")
              + xlab("Date")
              + ylab("Language")
            )
lang_bar
ggsave("C:/Users/mhan/Documents/graph/Martus Language.png")

# Subset of languages for 2010 - present

langLimited <- subset(lang, as.Date(date.uploaded) > c("2010-01-01"))

lang_barlimited <- (ggplot(langLimited,
                     aes(as.Date(date.uploaded), fill=langAgg))
              + geom_bar()
              + opts(title="Martus Language Reported - 2010 to present")
              + xlab("Date")
              + ylab("Language")
            )
lang_barlimited
ggsave("C:/Users/mhan/Documents/graph/Martus Language Limited 2010 to present.png")

#######################################################################################
#######################################################################################
#######################################################################################

# 8 by sealed vs not sealed; variable = type

sealedNames <- names(benetech) %in% c("date.uploaded","type")
types <- benetech[sealedNames]
# Fix Date Range
types <- subset(types, as.Date(date.uploaded) > c("2002-10-01"))
# Make aggregate month/year variable
types <- mutate(types, month = as.POSIXlt(date.uploaded)$mon + 1)
types <- mutate(types, year = as.POSIXlt(date.uploaded)$year + 1900)
types <- mutate(types, month_year = paste(types$month, "01", types$year, sep = "/"))
types$month_year <- as.POSIXlt(types$month_year, format="%m/%d/%Y")

View(types)
summary(types$type) #Shows that 8% of all reports are drafts

# Count by day -- Possibly need to aggregate to count by month
typesCount <- ddply(types, c("month_year","type"), summarise, count=length(month_year))

View(typesCount)

# Plot Draft and Sealed types over time
types_line <- (ggplot(typesCount, aes(x=as.Date(month_year), y=count, group = as.factor(type)))
               + geom_line(aes(colour = type, width = 1))
              + opts(title="Martus Seald and Draft Bulletins")
              + xlab("Date")
              + ylab("Number of Sealed and Draft Bulletins")
               )
types_line
ggsave("C:/Users/mhan/Documents/graph/Martus Sealed vs Draft.png")

# Subset of the plot for 2010 to present
typesCountLimited <- subset(typesCount, as.Date(month_year) > c("2010-01-01"))

types_line_limited <- (ggplot(typesCountLimited, aes(x=as.Date(month_year), y=count, group = as.factor(type)))
               + geom_line(aes(colour = type, width = 3))
              + opts(title="Martus Sealed and Draft Bulletins - 2010 to present")
              + xlab("Date")
              + ylab("Number of Sealed or Draft Bulletins")
               )
types_line_limited
ggsave("C:/Users/mhan/Documents/graph/Martus Sealed vs Draft 2010 to present.png")

# Look at density plots for non-limited period for drafts
typesCountDraft <- subset(typesCount, type == "draft")
typesDensityDraft <- density(typesCountDraft$count)
plot(typesDensityDraft)
# This means we should look at counts over 2000 -- Who was saving tons of drafts in those months?
# First, pull the months where the spikes happened
  # Sort typesCountDraft by count, which will give the top months
  typesCountDraft <- typesCountDraft[order(-typesCountDraft$count),]
  View(typesCountDraft)
  # The trend in more drafts happened in November/December 2010.  That corresponds to a majority of users
  # switching to version 3.4.0.  Could this be related?  Would we expect an increase in drafts with the version push?

# Look at subset of drafts past November 2010  --> USE PUBLIC.CODE
draftsLimited <- subset(benetech, type == "draft" & as.Date(date.uploaded) > c("2010-10-01"))
# Look at HQs Authorized to Read to see if it is just one or multiple (if yes, one explanation, if no, version upgrade seems plausible)
#Subset HQs for non-null values
draftsLimited <- subset(draftsLimited, !is.na(HQs.authorized.to.read))  
View(draftsLimited)
draftsBarLimited <- (ggplot(draftsLimited,
                     aes(as.Date(date.uploaded), fill=HQs.authorized.to.read))
              + geom_bar()
              + opts(title="Martus HQs Authorized to Read")
              + xlab("Date")
              + ylab("Number of HQs Authorized to Read")
            )
draftsBarLimited
ggsave("C:/Users/mhan/Documents/graph/Martus HQs Authorized to Read Nov 2010 to present.png")


#######################################################################################
#######################################################################################
#######################################################################################
  
# 9 by public vs private

pubPrivNames <- names(benetech) %in% c("date.uploaded","all.private")
pubPriv <- benetech[pubPrivNames]

# Fix Date Range
pubPriv <- subset(pubPriv, as.Date(date.uploaded) > c("2002-10-01"))
summary(pubPriv$all.private) # Shows that 4% of all Bulletins are public

# Make aggregate month/year variable
pubPriv <- mutate(pubPriv, month = as.POSIXlt(date.uploaded)$mon + 1)
pubPriv <- mutate(pubPriv, year = as.POSIXlt(date.uploaded)$year + 1900)
pubPriv <- mutate(pubPriv, month_year = paste(pubPriv$month, "01", pubPriv$year, sep = "/"))
pubPriv$month_year <- as.POSIXlt(pubPriv$month_year, format="%m/%d/%Y")

# Count by day -- Possibly need to aggregate to count by month
pubPrivCount <- ddply(pubPriv, c("month_year","all.private"), summarise, count=length(month_year))

# Plot Draft and Sealed types over time
pubPrivLine <- (ggplot(pubPrivCount, aes(x=as.Date(month_year), y=count, group = as.factor(all.private)))
               + geom_line(aes(colour = all.private, width = 1))
              + opts(title="Martus Public and Private Bulletins")
              + xlab("Date")
              + ylab("Number of Public and Private Bulletins")
               )
pubPrivLine
ggsave("C:/Users/mhan/Documents/graph/Martus Public and Private Bulletins.png")


#######################################################################################
#######################################################################################
#######################################################################################
