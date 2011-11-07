

# This script examines how people are using the custom fields.
# Miratrix

# of public data
sdat = subset( benetech, tester==0 & all.private==FALSE)
nrow(sdat)

#table( dat$has.custom.fields, dat$all.private, useNA="always" )
#table( sdat$has.custom.fields )

#table( is.na(dat$has.custom.fields), dat$all.private )


#sdat = sdat[1:200,]

#Run for finding levels
#levels = unique( unlist(ab) )
#levels
# getting…
TYPE_LEVELS =  c("STRING",    "LANGUAGE",  "BOOLEAN",   "GRID",      "MESSAGE",   "DROPDOWN",  "MULTILINE" )

splt = strsplit( as.character(sdat$custom.field.types), ", ", fixed=TRUE )

ab = sapply( splt, function( X ) {
	if ( length(X) == 0 ) {
		rep( 0, length(TYPE_LEVELS) )
	} else {
		X = factor( X, levels = TYPE_LEVELS )
		table( X )
	}
} )
ab = t(ab)
colnames(ab) = TYPE_LEVELS

dim(ab)
nrow(sdat)
head(ab)

use.ab = ab > 0 
use.ab = as.data.frame( use.ab )
use.ab$total = apply( use.ab, 1, sum )
use.ab$big.total = apply( ab, 1, sum )
head(use.ab)

table(use.ab$total )
table(use.ab$big.total )

# calc number of bulletins using each type
tots = apply(use.ab[1:length(TYPE_LEVELS)], 2, sum ) 

# calc percent of bullitens using each type
means = round( 100*apply(use.ab[1:length(TYPE_LEVELS)], 2, mean ) )

df = data.frame( total=tots, percent=means )
#df
use.ab$account = sdat$public.code 

# count number of accounts using each type
tot.usage = sapply( TYPE_LEVELS, function(X) { length( unique( use.ab$account[ use.ab[[X]] ] ) ) } )
df$accounts = tot.usage

# Looking at accounts

print( xtable(df, caption="Total number of unique bulletins with given custom field, percent of unique bulletins with given custom field, and number of accounts using that field", digits=0 ) )




