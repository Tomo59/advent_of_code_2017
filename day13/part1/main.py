#!/usr/bin/env python3

import re
f = open("input.txt", 'r');

tree = {};
result = 0;
i = 0;

for line in f:
  d = line.split(': ')
  tree[int(d[0])] = int(d[1])

print(tree)

for i in tree.keys():
  if i%((tree[i]-1)*2) == 0:
    result += tree[i] * i

print("result is {}".format(result))
