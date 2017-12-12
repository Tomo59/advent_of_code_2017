#!/usr/bin/env python3

import re
f = open("input.txt", 'r');
line = f.readline()
x = 0
y = 0

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

x = abs(x)
y = abs(y)

if x > y:
  result = x
else:
  result = int((y-x)/2 + x)

print("x = {}, y = {} so result is {}".format(x, y, result))
