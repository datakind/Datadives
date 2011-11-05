# average account longevity
# look at the distribution of date.authorized vs. (date.last.saved - date.authorized)

# loading in a small dataset rather than the whole thing for now

require("plyr")
require("lattice")
require("xtable")

# source("load_data.R")

# 'working data frame'
wdf <- with(benetech, data.frame(
authorized_date = date.authorized,
last_saved_date = date.last.saved))

wdf$authorized_date_lt <- as.POSIXlt(wdf$authorized_date)
wdf$time_diff     <- with(wdf, last_saved_date - authorized_date)
wdf$time_diff_int <- as.integer(wdf$time_diff)

wdf <- transform(wdf,
authorized_date_month = authorized_date_lt$mon,
authorized_date_year  = authorized_date_lt$year + 1900)

wdf$time_group_quarters <- paste(wdf$authorized_date_year,
"Q", ceiling(wdf$authorized_date_month / 4),
sep="")

wdf$time_group_halves <- paste(wdf$authorized_date_year,
"H", ceiling(wdf$authorized_date_month / 2),
sep="")

# there are NA's in date.authorized
table(is.na(wdf$authorized_date))

# there are cases where date.last.saved - date.authorized is very negative
# some show date.authorized as epoch… discarding those for now
table(wdf$time_diff < 0)

working_set <- wdf[!is.na(wdf$authorized_date) & wdf$time_diff > 0, ]
working_set$time_group_quarters <- as.factor(working_set$time_group_quarters)
working_set$time_group_halves <- as.factor(working_set$time_group_halves)

ggplot(data=working_set, aes(x=time_group_halves, y=time_diff_int)) + geom_point() + geom_boxplot()

ddply(working_set, .(time_group_halves), summarise,
  time_diff_mean = mean(time_diff_int))

with(working_set, plot(time_diff ~ authorized_date))
xyplot(time_diff ~ authorized_date, data=working_set, scales="free")

ggplot(data=working_set, aes(x=authorized_date, y=time_diff, group=round_a)) + geom_boxplot()


# graveyard
# wdf$authorized_date_group <- apply(wdf$authorized_date_lt, get_date_group_2)
