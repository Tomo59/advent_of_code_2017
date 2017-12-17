#!/usr/bin/env python3

INPUT = 304
#0 will alwaysbe at position 0 so we just needto calculate what is in position 1
pos1 = 0
cur_pos = 0

for i in range (1,50000001):
  cur_pos = ((cur_pos+INPUT)%i + 1)
  if cur_pos == 1:
    pos1 = i
  if (i%1000000) == 0: print(i)

print("result is {}".format(pos1))
