# average account longevity
# look at the distribution of date.authorized vs. (date.last.saved - date.authorized)
# this file generates the dataframes and graphics for the benetech_report.rnw
# it also includes summary tables that have been commented out (as they write
# to csv's in the same directory)


# loading in a small dataset rather than the whole thing for now
require("plyr")
require("lattice")
require("xtable")

source("load_data.R")

# 'working data frame'
wdf <- with(benetech, data.frame(
  public_code     = public.code,
  authorized_date = date.authorized,
  last_saved_date = date.last.saved))

# getting time differences
wdf$authorized_date_lt <- as.POSIXlt(wdf$authorized_date)
wdf$time_diff     <- with(wdf, last_saved_date - authorized_date)
wdf$time_diff_int <- as.integer(wdf$time_diff)

# getting the month, year, quarter and halves
wdf <- transform(wdf,
authorized_date_month = authorized_date_lt$mon,
authorized_date_year  = authorized_date_lt$year + 1900)

wdf$time_group_quarters <- paste(wdf$authorized_date_year,
"Q", ceiling((wdf$authorized_date_month+1)/3),
sep="")

wdf$time_group_halves <- paste(wdf$authorized_date_year,
"H", ceiling((wdf$authorized_date_month+1)/6),
sep="")

# there are NA's in date.authorized
wdf_na_df <- data.frame(table(is.na(wdf$authorized_date)))
colnames(wdf_na_df) <- c("is.na?", "count")

table_na <- table(is.na(wdf$authorized_date))

# there are cases where date.last.saved - date.authorized is very negative
# some show date.authorized as epoch… discarding those for now
wdf_neg_time_diff <- data.frame(table(wdf$time_diff < 0))
colnames(wdf_neg_time_diff) <- c("negative time diff", "count")

table_neg_time_diff <- table(wdf$time_diff < 0)

# working set excludes NA authorized dates and negative time diffs
working_set <- wdf[!is.na(wdf$authorized_date) & wdf$time_diff > 0, ]
working_set$time_group_quarters <- as.factor(working_set$time_group_quarters)
working_set$time_group_halves <- as.factor(working_set$time_group_halves)

# plots
ggplot(data=working_set, aes(x=time_group_halves, y=time_diff_int/60/60/24)) +
  geom_point() + geom_boxplot() + opts(axis.text.x=theme_text(angle=-90))

# writing to csv
summary_function <- function(df, colname) {
  column <- df[[colname]]
  return(
    data.frame(
      time_diff_min_seconds    = min(column),
      time_diff_q2_seconds     = as.numeric(quantile(column, 0.2)),
      time_diff_mean_seconds   = mean(column),
      time_diff_median_seconds = median(column),
      time_diff_q8_seconds     = as.numeric(quantile(column, 0.8)),
      time_diff_max_seconds    = max(column)
    ))
}


# without summarizing by account
by_quarter   <- ddply(working_set, .(time_group_quarters),  summary_function, "time_diff_int")
by_half_year <- ddply(working_set, .(time_group_halves),    summary_function, "time_diff_int")
by_year      <- ddply(working_set, .(authorized_date_year), summary_function, "time_diff_int")

# commenting out for now. run these if you want the summary tables
# write.csv(by_quarter,   file="longevity_summary_by_quarter.csv")
# write.csv(by_half_year, file="longevity_summary_by_half_year.csv")
# write.csv(by_year,      file="longevity_summary_by_year.csv")

# let's examine by accounts. Do some account have much higher longevity?
# what's the count by account? we should remove the ones with low counts…
by_account <- ddply(working_set, .(public_code), nrow)
colnames(by_account) <- c("public_code", "count")

by_account_quarter <- ddply(working_set, .(public_code, time_group_quarters), summary_function, "time_diff_int")
by_account_quarter <- join(by_account, by_account_quarter)

# ggplot(data=by_account_quarter, aes(x=count, y=time_diff_median_seconds/60/60/24)) +
#   geom_point() + coord_trans(x="log10") + opts(axis.text.x=theme_text(angle=-90)) +
#   scale_x_continuous('Account by bulletin count') +
#   scale_y_continuous('Days since authorized', formatter='comma')

# huge range for accounts who use this once, pretty stead for people who use this more

# group=round_any(log10(by_account_quarter$count), 1)
# with(working_set, plot(time_diff ~ authorized_date))
# xyplot(time_diff ~ authorized_date, data=working_set, scales="free")
#
# ggplot(data=working_set, aes(x=authorized_date, y=time_diff, group=round_a)) + geom_boxplot()


# graveyard
# wdf$authorized_date_group <- apply(wdf$authorized_date_lt, get_date_group_2)
