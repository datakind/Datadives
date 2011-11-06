import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import datetime
import utils as ut
reload(ut)

if __name__=="__main__":
    # How many unique dates should a group have to be considered: 
    min_u_dates = 4

    # How many public codes do you want to plot:
    high_n = 100
    
    # Read the data from file into a data frame:
    df = pd.read_csv('../data//martus-bullacct-4datadive-2011-11-03.csv')

    # This file will contain some stats: 
    out_file1 = file('../data/group_usage.csv','w')
    out_file1.write('Group, n_bulletins, n_dates, first_date, last_date \n') # Header
    
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
    ut.plot_bull_date(dates, group, all_groups, out_file1,
                      save_fig_as = '../images/bulletins_by_group') 

    # Move on to the next variable of interest, public codes: 
    pcv = df['public code'].values[ok_idx]
    language = df['language'].values[ok_idx]

    pcvu = np.unique(pcv)
    
    # The frequency of each pcvu: 
    pcvu_freq = [len(pcv[np.where(pcv==this)[0]]) for this in pcvu]
    pcvu_sort_idx = np.argsort(pcvu_freq)
    pcvu_sorted = pcvu[pcvu_sort_idx]
    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)
    ax.plot(np.sort(pcvu_freq)[::-1])
    ax.set_ylim([0, max(pcvu_freq)])
    ax.set_xlim([-10, len(pcvu_freq)])
    ax.set_xlabel("Public code (sorted by # bulletins)")
    ax.set_ylabel("Bulletins (#)")
    fig.savefig('../images/public_code_distribution.png')
    fig.savefig('../images/public_code_distribution.svg')
    
high_idx = pcvu_sort_idx[-high_n:]
high_pc = pcvu[high_idx]

out_file2 = file('../data/public_code_usage.csv','w')
out_file2.write('public_code, n_bulletins, n_dates, first_date, last_date \n') # Header

ut.plot_bull_date(dates, pcv, high_pc, out_file2, 
                      save_fig_as = '../images/bulletins_by_public_code', draw_legend=False) 

                

    
