#!/usr/bin/env python3


table = dict()
f = open("input.txt", 'r');
for i,line in enumerate(f):
  table[i] = dict()
  for j,d in enumerate(list(line)[:-1]):
    table[i][j] = d

from enum import Enum
class Dir(Enum):
  UP = 1
  DOWN = 2
  LEFT = 3
  RIGHT = 4

def move(y, x, direction):
  #print("we are at position [{}][{}]".format(y, x))
  if direction == Dir.UP:
    if table[y-1][x] != ' ':
      return y-1,x,Dir.UP
    if table[y][x-1] != ' ':
      return y,x-1,Dir.LEFT
    if table[y][x+1] != ' ':
      return y,x+1,Dir.RIGHT
  if direction == Dir.DOWN:
    if table[y+1][x] != ' ':
      return y+1,x,Dir.DOWN
    if table[y][x-1] != ' ':
      return y,x-1,Dir.LEFT
    if table[y][x+1] != ' ':
      return y,x+1,Dir.RIGHT
  if direction == Dir.RIGHT:
    if table[y][x+1] != ' ':
      return y,x+1,Dir.RIGHT
    if table[y-1][x] != ' ':
      return y-1,x,Dir.UP
    if table[y+1][x] != ' ':
      return y+1,x,Dir.DOWN
  if direction == Dir.LEFT:
    if table[y][x-1] != ' ':
      return y,x-1,Dir.LEFT
    if table[y-1][x] != ' ':
      return y-1,x,Dir.UP
    if table[y+1][x] != ' ':
      return y+1,x,Dir.DOWN
  print("cannot move anymore at position [{}][{}]".format(y, x))
  return -1, -1, Dir.UP

result = ""
y = 0
for x in range(len(table[0])):
  if table[0][x] == '|':
    break
direction = Dir.DOWN

while x != -1:
  if table[y][x].isalpha():
    print("found {} at postion [{}][{}]".format(table[y][x], y, x))
    result += table[y][x]
  y, x, direction = move(y, x, direction)


print("result is {}".format(result))

