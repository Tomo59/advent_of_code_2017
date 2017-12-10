#!/usr/bin/env python3

INPUT = 347991;

max_x = 1;
x = 0;
y = 0;
cur = 1;
table = {};
table[x, y] = 0;

while True:
  while x < max_x:
    x += 1;
    cur += 1;
    if (cur == INPUT): print("FOUND {} at x={} y={} so dist is {}".format(INPUT, x, y, abs(x) + abs(y))); quit();
    table[x,y] = cur;
  while y < max_x:
    y += 1;
    cur += 1;
    if (cur == INPUT): print("FOUND {} at x={} y={} so dist is {}".format(INPUT, x, y, abs(x) + abs(y))); quit();
    table[x,y] = cur;
  while x > -max_x:
    x -= 1;
    cur += 1;
    if (cur == INPUT): print("FOUND {} at x={} y={} so dist is {}".format(INPUT, x, y, abs(x) + abs(y))); quit();
    table[x,y] = cur;
  while y > -max_x:
    y -= 1;
    cur += 1;
    if (cur == INPUT): print("FOUND {} at x={} y={} so dist is {}".format(INPUT, x, y, abs(x) + abs(y))); quit();
    table[x,y] = cur;
  max_x += 1;

