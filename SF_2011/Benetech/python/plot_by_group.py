import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import datetime


def mk_date_from_string(s):
    """
    Parse an array-like of strings with 'mm/dd/yyyy' strings in each part and make
    it into an array of datetime.datetime 
    """
    out = [] 
    for this_s in s:
        if isinstance(this_s,float):
            out.append(np.nan)
        else: 
            d = this_s.split('/')
            out.append(datetime.datetime(int(d[2]),int(d[0]),int(d[1])))
    return np.array(out)

def smart_isnan(x):
    # If it's shapeless
    if x.shape == ():
        # Is that thing a nan?
        if np.isnan(x):
            return True
    # If it's not shapeless, it can be indexed: 
    else:
        # If it has a datetime, it's not a nan
        if isinstance(x[0], datetime.datetime):
            return False
        # But if it has a nan, it is:
        if np.isnan(x[0]):
            return True

if __name__=="__main__":
    # How many unique dates should a group have to be considered: 
    min_u_dates = 5

    # Read the data from file into a data frame:
    df = pd.read_csv('/Users/arokem/Dropbox/SFDatadive/Benetech/martus-bullacct-4datadive-2011-11-03.csv')

    # This file will contain some stats: 
    out_file = file('../data/group_usage.csv','w')
    out_file.write('Group, n_bulletins, n_dates, first_date, last_date \n') # Header
    
    # These are filtering variables: 
    osv = df['original server'].values  # This one indicates whether this was a duplication
    tbv = df['test bulletin'].values  # This one indicates whether this was just a test:

    # We want the original and not tests:
    ok_idx = np.intersect1d(np.where(osv==1.0)[0], np.where(tbv!=1)[0])

    # These are the variables we are interested in for this analysis
    group = df['group'].values[ok_idx]
    pub_code = df['public code'].values[ok_idx]
    dates = df['date created'].values[ok_idx]
    language = df['language'].values[ok_idx]

    # The very first group is "nan":
    all_groups = np.unique(group)[1:]

    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)
    ax.set_ylabel('Bulletins (#)')
    ax.set_xlabel('Date')
 
    for g in all_groups:
        g_idx = np.where(group==g)
        # This doesn't work when the group has nans in the date
        # Convert from a string to a date:
        g_dates = mk_date_from_string(dates[g_idx])
        if not smart_isnan(g_dates):
            # Can't do anything with dates that are nans:
            non_nan_idx = np.where(g_dates!=np.nan)
            g_dates = g_dates[non_nan_idx]
            # What are the unique values?
            u_dates = np.unique(g_dates)
            # They are not sorted, so do that 
            sort_idx = np.argsort(u_dates)
            # Count the number of instances in each date:
            n_per_date = [len(np.where(g_dates==thisd)[0]) for
                          thisd in u_dates[sort_idx]]

            # Output stuff to the data file:
            out_file.write('%s, %s, %s, %s, %s \n'%(
                g,  # Group name
                len(g_idx[0]),   #  Number of bulletins
                len(u_dates),  #  Number of dates
                u_dates[sort_idx][0],  #  First date
                u_dates[sort_idx][-1],  #  Last date
                ))
            # If there are fewer than min_u_dates, no need to plot:
            if len(u_dates) < min_u_dates:
                print ("Group %s has only created bulletins on %s dates"%(g,len(u_dates)))
            else:
                # Plot:
                ax.plot(u_dates[sort_idx], n_per_date,'o-', label=g)
                fig.autofmt_xdate()
                
        else:
            print("What's going on with group %s?"%g)

    ax.legend()
    ax.set_ylim([0,120])
    ax.set_xlim(datetime.datetime(2004,1,1),datetime.datetime.now())
    fig.savefig('../images/usage_by_group_date.png')
    fig.savefig('../images/usage_by_group_date.svg')
    out_file.close()
