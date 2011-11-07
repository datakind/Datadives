

## Production file to build a joint vhd-doc conversation file
## Mark Huberty and Clark Bernier
## Begun 6 November 2011
## Data without Borders SF Datadive / MobileHealth

## Purpose:
## Inputs the message file
## Outputs a CSV of this format:
## case_id vhd_msgs doc_msgs
## Where *_msgs are the concatenated strings of all messages associated
## with a given case_id for criteria specified in the
## clean_messages function

import csv
import re
import os
from collections import defaultdict

## Change this as required to deal with the directory sourcing
os.chdir('/Users/markhuberty/Dropbox/SF Datadive/Mobilizing Health/CSV Files')

## Load in the data
## Ideally this would pull directly from 
conn_cases = open("mh_cases.csv", "rb") ## unique case IDs
conn_codes = open("mh_codes.csv", "rb") ## Unique message codes
conn_msgs = open("mh_messages_clean.csv", "rb") ## Master message record

cases = [row for row in csv.DictReader(conn_cases)]
codes = [row for row in csv.DictReader(conn_codes)]
messages = [row for row in csv.DictReader(conn_msgs)]

conn_cases.close()
conn_codes.close()
conn_msgs.close()

## Clean up the message data
## Input: a message dict with col headers as keys
##        a list of person types to retain
## Output: a subsetted list for the criteria specified in the
##         if statement
def clean_messages(msg_dict, person_types=['Doctor', 'Vhd']):
    messages_out = []
    for iter in msg_dict:
        # if iter['case_id'] == '1489':
        #     print iter['incoming']
        #     print iter['from_person_type']
        #     print iter['msg']
        #     print (len(iter['msg']) > 6)
        #     print ' '

        
        if (iter['case_id'] != '' and
            iter['incoming'] == '1' and
            len(iter['msg']) > 6 and
            iter['from_person_type'] in person_types):
                messages_out.append(iter)
        else:
            continue
        
    return(messages_out)

## caseid vhd_message doc_message

## Format and concatenate the msg data for a csv outfile
## Goal is to stitch all vhd messages into a single record, all doc msgs
## into a single record, and return as 3 fiels (case, vhd, doc)
## Input: a dict of messages
## Output: a dict of caseids, for which the element is a 2-string list
##         of [vhd_msg, doc_msg]
def build_output_file(msg_dict):
    dict_out = {}

    for iter in msg_dict:
        # if iter['case_id'] == '1489':
        #     print iter['msg']
            
        if iter['case_id'] not in dict_out:
            dict_out[iter['case_id']] = ['', '']

        if iter['from_person_type'] == 'Vhd':
            dict_out[iter['case_id']][0] += (iter['msg'] + ' ')
        elif iter['from_person_type'] == 'Doctor':
            dict_out[iter['case_id']][1] += (iter['msg'] + ' ')

    return(dict_out)



messages_new = clean_messages(messages)
output_msg_dict = build_output_file(messages_new)

## Write out to CSV
with open("mobilehealth_paired_message_output.csv", "wb") as f:
    writer = csv.writer(f)
    writer.writerow(['case_id', 'vhd_msgs', 'doc_msgs'])
    for key in output_msg_dict.keys():
        row_out = [key, output_msg_dict[key][0], output_msg_dict[key][1]]
        writer.writerow(row_out)

## END
