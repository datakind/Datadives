
# plot increase of four usage variables of interest over time.

library( plyr )
library(xtable)

#source( "load_data.R" )
# save( benetech.full, file="thedatafile.rdata" )
if ( FALSE ) {
	bk = benetech.full
	load( file="thedatefile" )
	benetech.full = bk
	table( benetech.full$server, benetech.full$original.server, useNA="ifany" )

	# for debugging -- speed up
	#benetech.full = benetech.full[ sample( 1:nrow(benetech.full), 5000 ), ]
}


bf = subset( benetech.full, !is.na( date.uploaded ) )
if(FALSE){ 
	nrow(bf)
	nrow(benetech.full)
}

bf = bf[ order( bf$date.uploaded ), ]
#nrow(bf)
bf$new.account = !duplicated( bf$public.code )

# compute total from time of start
bf$tot.bull = 1:nrow(bf)
bf$totKb = cumsum( bf$size..Kb. )
bf$accounts = cumsum( bf$new.account )
bf$tot.attach = cumsum( bf$public.attachments + bf$private.attachments )


# select some subsample for plotting
pick = round( seq( 1, nrow(bf), length.out=2000 ) )
pick = pick[ !duplicated( bf$date.uploaded[ pick ], fromLast=TRUE ) ]

# make the full subsample
bfs.big = bf[pick,]
N.big = nrow(bfs.big)

# make the smoothed subsample
pick = pick[ round( seq( 1, N.big, length.out=60 ) ) ]
N.little = length(pick)
bfs.little = bf[pick,]

#plot(pick)

# Calculate numerical derivatives
delt = function( X ) { 
	N = length(X)
	X[2:N] - X[1:(N-1)] 
}

del.ts = as.double( delt( bfs.little$date.uploaded ), units="days")
#del.ts
#summary(del.ts)

days = bfs.little$date.uploaded[2:N.little]

bull.per.day = delt( bfs.little$tot.bull ) / del.ts
kb.per.day = delt( bfs.little$totKb ) / del.ts
account.per.day = delt( bfs.little$accounts ) / del.ts 
attach.per.day = delt( bfs.little$tot.attach ) / del.ts


#######
# PLOTS
#  this code called in sweave
#######

# totals 
plot.tot = function( bfs ) {
	par( mfrow=c(2,2), mar=c(3,3,1,1), mgp=c(2,1,0) )
	plot( bfs$date.uploaded, bfs$tot.bull, type="l", xlab="Time", ylab="Total Bulletins" )
	plot( bfs$date.uploaded, bfs$totKb/1024, type="l", xlab="Time", ylab="Total Megabytes")
	plot( bfs$date.uploaded, bfs$accounts, type="l", xlab="Time", ylab="Total Number of Distinct Accounts" )
	plot( bfs$date.uploaded, bfs$tot.attach, type="l", xlab="Time", ylab="Total Number of Attachments" )
}


# no truncation
plot.deriv = function( bfs ) {
	par( mfrow=c(2,2), mar=c(3,3,1,1), mgp=c(2,1,0) )
	plot( days, bull.per.day, type="l", xlab="Time", ylab="Bulletins Per Day" )
	plot( days, kb.per.day/1024, type="l", xlab="Time", ylab="Megabytes per Day")
	plot( days, account.per.day, type="l", xlab="Time", ylab="New Accounts per Day" )
	plot( days, attach.per.day, type="l", xlab="Time", ylab="Attachments per Day" )
}

# truncated
plot.deriv.trunc = function( bfs ) {
	par( mfrow=c(2,2), mar=c(3,3,1,1), mgp=c(2,1,0) )
	plot( days, bull.per.day, ylim=c(0, quantile( bull.per.day, 0.95 )), type="l", xlab="Time", ylab="Bulletins Per Day" )
	plot( days, kb.per.day/1024, type="l", ylim=c(0, quantile( kb.per.day/1024, 0.95 )), xlab="Time", ylab="Megabytes per Day")
	plot( days, account.per.day, type="l", ylim=c(0, quantile( account.per.day, 0.95 )), xlab="Time", ylab="New Accounts per Day" )
	plot( days, attach.per.day, type="l", ylim=c(0, quantile( attach.per.day, 0.95 )), xlab="Time", ylab="Attachments per Day" )
}



if (FALSE) {

plot.tot( bfs.big )
plot.deriv( bfs.little )
plot.deriv.trunc( bfs.little )

}






###### DEAD CODE

# rg = range(bf$date.uploaded)
# K = 100
# cutpts = seq( rg[1], rg[2], length.out=K )
# midpts = seq( rg[1], rg[2], length.out=(K*2)-1 )
# midpts = midpts[ 2*(1:(K-1)) ]
# #cutpts
# #midpts

# bf.bk = bf
# bf = bf.bk[ sample( nrow(bf), K * 10000 ), ]
# nrow(bf)


# # res = sapply( 2:K, function(X) {
	# cat( "tick", X,K,"\n" )
	# tmp = subset( bf, cutpts[[X-1]] <= date.uploaded & date.uploaded <= cutpts[[X]] )
	
	# bull.per.day=nrow(tmp)
	
	# Kb.per.day=sum( tmp$size..Kb. ) 
	
	# acc.per.day=sum(tmp$new.account)
	
	# attach.per.day=sum(tmp$public.attachments + tmp$private.attachments)
	
	# c( bull.per.day=bull.per.day, Kb.per.day=Kb.per.day, acc.per.day=acc.per.day, attach.per.day=attach.per.day ) / as.numeric((cutpts[X] - cutpts[X-1]))
	
# } )



# # rough plots
# par( mfrow=c(2,2), mar=c(3,3,1,1), mgp=c(2,1,0) )
# plot( midpts, res[1,], type="l", xlab="Time", ylab="Bulletins Per Day" )
# plot( midpts, res[2,], type="l", xlab="Time", ylab="Megabytes per Day")
# plot( midpts, res[3,], type="l", xlab="Time", ylab="New Accounts per Day" )
# plot( midpts, res[4,], type="l", xlab="Time", ylab="Attachments per Day" )



# # smoothed plots
# par( mfrow=c(2,2), mar=c(3,3,1,1), mgp=c(2,1,0) )
# plot( midpts, res[1,], type="n", xlab="Time", ylab="Bulletins Per Day" )
# lines( lowess(midpts, res[1,], f=1/20))
# plot( midpts, res[2,], type="n", xlab="Time", ylab="Megabytes per Day")
# lines( lowess(midpts, res[2,], f=1/20) )
# plot( midpts, res[3,], type="n", xlab="Time", ylab="New Accounts per Day" )
# lines( lowess(midpts, res[3,], f=1/20) )
# plot( midpts, res[4,], type="n", xlab="Time", ylab="Attachments per Day" )
# lines( lowess(midpts, res[4,], f=1/20) )



