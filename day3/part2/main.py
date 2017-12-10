#!/usr/bin/env python3

INPUT = 347991;

max_x = 1;
x = 0;
y = 0;
table = {};
table[x, y] = 1;

def sum_neighbours():
  return table.get((x-1,y), 0) + table.get((x-1, y-1), 0) + table.get((x, y-1), 0) + table .get((x+1, y-1), 0) + table.get((x+1,y), 0) + table.get((x+1, y+1), 0) + table.get((x, y+1), 0) + table.get((x-1, y+1), 0)

def update_table():
  table[x,y] = sum_neighbours();
  if (table[x,y] >= INPUT): print("FOUND {} at x={} y={} so dist is {}".format(INPUT, x, y, abs(x) + abs(y))); quit();

while True:
  while x < max_x:
    x += 1;
    update_table();
  while y < max_x:
    y += 1;
    update_table();
  while x > -max_x:
    x -= 1;
    update_table();
  while y > -max_x:
    y -= 1;
    update_table();
  max_x += 1;

