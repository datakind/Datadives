import numpy as np
import datetime
import matplotlib.pyplot as plt

"""
Utility functions for usage by plot_by_group.
"""

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
    """

    This is so that we can identify groups and public-codes that don't have any
    useful dates to look at.
    
    """
    # If it's shapeless
    if x.shape == ():
        # Is that thing a nan?
        if np.isnan(x):
            return True
        else:
            return False
    # If it's not shapeless, it can be indexed: 
    else:
        # There is a datetime in there:
        if np.any([isinstance(this_x,datetime.datetime) for this_x in x]):
            return False
        else:
            return False
        
def plot_bull_date(dates, var, groups, out_file, save_fig_as,
                   min_u_dates=5, ylim=[0, 120], draw_legend=True,
                   xlim =[datetime.datetime(2004,1,1),datetime.datetime.now()]):
    """
    Given an array of dates, and a variable to choose items from (using
    groups), plot the # bulletins for each of the groups. Also, add stuff into
    a data file.

    """ 
    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)
    ax.set_ylabel('Bulletins (#)')
    ax.set_xlabel('Date')

    for g in groups:
        g_idx = np.where(var==g)
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

    out_file.close()
    if draw_legend:
        ax.legend()

    ax.set_ylim([0,120])
    ax.set_xlim(datetime.datetime(2004,1,1),datetime.datetime.now())
    fig.savefig('%s.png'%save_fig_as)
    fig.savefig('%s.svg'%save_fig_as)

