#!/usr/bin/env python3


from enum import Enum
class Dir(Enum):
  UP = 0
  RIGHT = 1
  DOWN = 2
  LEFT = 3

def left(d):
  return Dir((d.value+4-1)%4)

def right(d):
  return Dir((d.value+1)%4)

def is_infected(y, x):
  global infected
  if y not in infected.keys():
    infected[y] = dict()
  if x not in infected[y].keys():
    infected[y][x] = False
  return infected[y][x]

def move(y, x, direction):
  print("we are at position [{}][{}] and facing {}".format(y, x, direction.name))
  global result
  if is_infected(y, x):
    d = right(direction)
  else:
    d = left(direction)
    result += 1
  infected[y][x] = not infected[y][x]
  if d == Dir.UP: y -= 1
  elif d == Dir.DOWN: y += 1
  elif d == Dir.RIGHT: x += 1
  elif d == Dir.LEFT: x -= 1
  else:
    print("Error bad direction {}".format(d))
    quit()
  return y, x, d

infected = dict()
f = open("input.txt", 'r');
for i,line in enumerate(f):
  infected[i] = dict()
  for j,d in enumerate(list(line)[:-1]):
    infected[i][j] = d == '#'

print(infected)

result = 0
y = (len(infected)-1)//2
x = (len(infected[0])-1)//2
direction = Dir.UP

for i in range(10000):
  y, x, direction = move(y, x, direction)


print("result is {}".format(result))

