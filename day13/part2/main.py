#!/usr/bin/env python3

import re
f = open("input.txt", 'r');

tree = {};
result = 0;
done = 0;
i = 0;

for line in f:
  d = line.split(': ')
  tree[int(d[0])] = int(d[1])

print(tree)

while not done:
  result += 1
  done = 1
  for i in tree.keys():
    if (i+result)%((tree[i]-1)*2) == 0:
      done = 0
      break

print("result is {}".format(result))
