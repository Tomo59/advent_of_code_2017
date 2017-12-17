#!/usr/bin/env python3

INPUT = 304
tab = [0]
cur_pos = 0

for i in range (1,2018):
  cur_pos = ((cur_pos+INPUT)%i) + 1
  tab.insert(cur_pos,int(i))

print(tab)
print("result is {}".format(tab[cur_pos + 1]))
