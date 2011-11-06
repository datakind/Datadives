with_summaries <- subset(benetech, nchar(summary) > 0)
with_english_summaries <- subset(with_summaries, language == "en")
write.csv(with_english_summaries$summary, "with-summaries.csv", col.names = FALSE, row.names = FALSE, quote=FALSE)

# then use
# cat with-summaries.csv | tr " " "\n" | sort | uniq
# then invoke common_words.py