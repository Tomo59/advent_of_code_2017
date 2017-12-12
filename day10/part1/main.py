#!/usr/bin/env python3

f = open("input.txt", 'r');

lengths = [int(x) for x in f.readline().split(',')]
#lengths = [3, 4, 1, 5]
l = list(range(256))
#l = list(range(5))
cur_position = 0
skip_size = 0

for length in lengths:
  print("will move {} elements at position {} (skip is {})".format(length, cur_position, skip_size))
  tmp_list = list(l)
  for i in range(int(length)):
    l[(cur_position+i)%len(l)] = tmp_list[(cur_position+length-1-i)%len(l)]
  cur_position += length + skip_size
  skip_size += 1
  print("list is now")
  print(l)



print("result is {}".format(l[0]*l[1]))
