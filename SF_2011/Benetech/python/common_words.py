# To get the files, you need to run this in the "website" directory:
# wget -l 1 -m -c "https://martus.ceu.hu/servlet/DoSearch?typeOfSearch=quickSearchAll"

import numpy
import re
import csv
import os
import matplotlib.pyplot as plt

out_file_name = "website_public_id.csv"
out_file = file(out_file_name, "w")
website_dir = "../website/martus.ceu.hu/servlet/"

for file_name in os.listdir(website_dir):
  if file_name.startswith("FoundBulletin"):
    id = file_name.split("FoundBulletin?index=")[1].split("&")[0]
    try:
      body = file("%s%s"%(website_dir,file_name), "r").read()
      title = body.split("<strong>")[1].split("</strong>")[0]
      public_id = body.split("<!--Account Public Code = ")[1].split(" -->")[0]
      bulletin_id = body.split("<!--Bulletin Local Id = ")[1].split(" -->")[0]
      out_file.write("%s\t%s\t%s\n" % (title, public_id, bulletin_id))
    except:
      print "Cannot parse %s" % file_name

out_file.close()

# Now read it in and parse: 
in_file = file(out_file_name, 'r')
word_to_count = {}
while 1:
  line = in_file.readline()
  if not line :
    break
  title = line.split("\t")[0].split(" ")
  for word in title:
    if word.lower() in word_to_count.keys():
      word_to_count[word.lower()] += 1
    else:
      word_to_count[word.lower()] = 1

key_array = numpy.array(word_to_count.keys())
sort_idx = numpy.argsort(word_to_count.values())

# Top n entries:
n = 100

top_words = key_array[sort_idx[-n:]][::-1]
n_top_words = numpy.array(word_to_count.values())[sort_idx[-n:]][::-1]

results_file = file("../data/word_counts_website.csv","w")
[results_file.write("%s,%s\n"%(top_words[i],n_top_words[i])) for i in range(n)]
results_file.close()
