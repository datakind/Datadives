from math import isnan
from dateutil.parser import parse
from gensim.models.ldamodel import LdaModel
from gensim.corpora.dictionary import Dictionary
from pandas import DataFrame
from pandas.io.parsers import read_csv

# Load the data
df = read_csv('mh_messages_clean.csv',na_values=["\N"])

# Map datetime strings to datetime objects
types = df['time_received_or_sent'].apply(type)
df['time_received_or_sent'][types != float] = df['time_received_or_sent'][types != float].apply(parse)

types = df['time_delivered'].apply(type)
df['time_delivered'][types != float] = df['time_delivered'][types != float].apply(parse)

types = df['created_at'].apply(type)
df['created_at'][types != float] = df['created_at'][types != float].apply(parse)

types = df['updated_at'].apply(type)
df['updated_at'][types != float] = df['updated_at'][types != float].apply(parse)

# Get subset with case_id not equal to NaN
df_subset = df[df['case_id'].apply(isnan) == False]

# Get subset with project_id = 1
df_subset = df_subset[df_subset['project_id'] == 1]

# Get subset originating from VHDs
df_subset = df_subset[df_subset['from_person_type'] == 'Vhd']

df = df_subset

# Lowercase the messages. Chop leading characters off before the REQ. 
idx = []
term_lists = []
for i in range(len(df)):
    df['msg'][i] = df['msg'][i].lower()
    j = df['msg'][i].find('req')
    if j > -1:
        df['msg'][i] = df['msg'][i][j:] 
        idx.append(i)
        terms = df['msg'][i].split()
        terms = terms[5:]
        filtered_terms = [t for t in terms if len(t) > 0]
        term_lists.append(filtered_terms)

# Merge term lists into the main dataframe    
d = {'terms':term_lists}
term_df = DataFrame(data=d,columns=['terms'],index=df.index[idx])
df = df.join(term_df)

# Create corpus for topic modeling
corpora_dict = Dictionary(term_lists)
corpus = [corpora_dict.doc2bow(msg) for msg in term_lists]

# Perform topic modeling
lda = LdaModel(corpus=corpus,id2word=corpora_dict,num_topics=5)

# Print out top terms for each topic
topics = lda.show_topics()
i = 0
for topic in topics:
    i += 1
    print "Topic %d: %s" % (i,str(topic))
