import numpy

word_to_count = {}
for line in body:
  count_and_word = line.lstrip().rstrip().split(" ")
  count = count_and_word[0]
  if len(count_and_word) == 2:
    word = count_and_word[1]
  else:
    word = ""
  word_to_count[word] = count

word_to_count.values
numpy.array(word_to_count.keys())[numpy.argsort(word_to_count.values())][-50:]
# array(['formed', 'Thanpyuzayart', 'ya', 'fruit', '20', 'following',
#        'Division', 'Time)', 'what', 'Operation', '2007', 'endure', 'been',
#        'leader', 'most', 'demanded', 'participation', 'physical', 'arrest',
#        'should', 'tried', 'Kaw', 'when', 'as', 'Nam', '2011', 'taking',
#        'place', 'sent', 'Zaw', 'Tun', 'over', 'Namkham', 'Tin', 'health',
#        'outside', 'I', 'While', 'Moe', 'Lay', 'prisons', 'Three',
#        'further', 'reported', '(First', 'according', "don't", 'If', 'rice',
#        'and'],
#       dtype='|S78')