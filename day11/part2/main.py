#!/usr/bin/env python3

import re
f = open("input.txt", 'r');
line = f.readline()
x = 0
y = 0
result = 0

def distance(x, y):
  if abs(x) > abs(y):
    return abs(x)
  else:
    return int((abs(y)-abs(x))/2 + abs(x))


for d in line.strip('\n').split(','):
  if d == "n":
    y += 2
  elif d == "ne":
    x += 1
    y += 1
  elif d == "se":
    x += 1
    y -= 1
  elif d == "s":
    y -= 2
  elif d == "sw":
    x -= 1
    y -= 1
  elif d == "nw":
    x -= 1
    y += 1
  else:
    print("ERROR with d {}".format(d))
    quit()
  result = max(result, distance(x,y))

print("result is {}".format(result))
