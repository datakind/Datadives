# parses the files into (file_name, public_id, bulletin_id)
# to be used after
# wget -l 1 -m -c "https://martus.ceu.hu/servlet/DoSearch?typeOfSearch=quickSearchAll"
import re
import csv
import os

out_file = file("url_public_id.csv", "w")

for file_name in os.listdir("."):
  if (re.compile("^FoundBulletin").match(file_name)):
    id = file_name.split("FoundBulletin?index=")[1].split("&")[0]
    try:
      body        = file(file_name, "r").read()
      title       = body.split("<strong>")[1].split("</strong>")[0]
      public_id   = body.split("<!--Account Public Code = ")[1].split(" -->")[0]
      bulletin_id = body.split("<!--Bulletin Local Id = ")[1].split(" -->")[0]
      out_file.write("%s,%s,%s\n" % (title, public_id, bulletin_id))
    except:
      print "Cannot parse %s" % file_name

out_file.close()


for link in br.links(url_regex="FoundBulletin*"):
  response      = br.follow_link(link)
  html_response = response.read()
  title         = html_response.split("<strong>")[1].split("</strong>")[0]
  public_id     = html_response.split("<!--Account Public Code = ")[1].split(" -->")[0]
  bulletin_id   = html_response.split("<!--Bulletin Local Id = ")[1].split(" -->")[0]
  print (title, public_id, bulletin_id)
  print(html_response)
  out_file.write("%s,%s,%s\n" % (title, public_id, bulletin_id))


out_file.close

