#!/usr/bin/env python3

import numpy as np

#from enum import Enum
#class Dir(Enum):
#  UP = 0
#  RIGHT = 1
#  DOWN = 2
#  LEFT = 3
#
#class State(Enum):
#  CLEAN = 0
#  WEAKENED = 1
#  INFECTED = 2
#  FLAGGED = 3
#
def left(d):
  return (d+4-1)%4

def right(d):
  return (d+1)%4

def reverse(d):
  return (d+2)%4

def state(y, x):
  global infected
  return infected[y,x]

def move(y, x, direction):
  #print("we are at position [{}][{}] and facing {}".format(y, x, direction))
  global result
  if state(y, x) == 2: #State.INFECTED
    d = right(direction)
  elif state(y, x) == 0: #State.CLEAN
    d = left(direction)
  elif state(y, x) == 3: #State.FLAGGED
    d = reverse(direction)
  else: # WEAKENED
    d = direction
    result += 1
  infected[y,x] = (infected[y,x]+1)%4
  if d == 0 : y -= 1
  elif d == 2 : y += 1
  elif d == 1 : x += 1
  elif d == 3 : x -= 1
  else:
    print("Error bad direction {}".format(d))
    quit()
  return y, x, d

infected = np.zeros( (2000, 2000) )
offset = 1000
f = open("input.txt", 'r');
for i,line in enumerate(f):
  for j,d in enumerate(list(line)[:-1]):
    if d == '#':
      infected[offset+i,offset+j] = 2 # State.INFECTED

#print(infected)

result = 0
y = offset + i//2
x = offset + j//2
direction = 0

for i in range(10000000):
  y, x, direction = move(y, x, direction)
  if (i%1000000) == 0: print("i = {} and for now result is {}".format(i, result))


print("result is {}".format(result))

