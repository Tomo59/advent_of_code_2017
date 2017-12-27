#!/usr/bin/env python3

from collections import deque
f = open("input.txt", 'r');
instr = {}
for i,line in enumerate(f):
  instr[i] = line.split()


regs = {"a":1, "b":0, "c":0, "d":0, "e":0, "f":0, "g":0, "h":0}
i = 0
result = 0

#####################
### FIRST version ###
###   too slow !  ###
#####################

#def execute():
#  global result
#  global i
#  if i not in instr.keys():
#    return 0
#  print("instr {} : {} and regs = {}".format(i, instr[i], regs))
#  try:
#    X = int(instr[i][1])
#  except ValueError:
#    X = regs.get(instr[i][1], 0)
#  if len(instr[i]) > 2:
#    try:
#      Y = int(instr[i][2])
#    except ValueError:
#      Y = regs.get(instr[i][2], 0)
#  if instr[i][0] == "set":
#    regs[instr[i][1]] = Y
#  elif instr[i][0] == "sub":
#    regs[instr[i][1]] = X - Y
#  elif instr[i][0] == "mul":
#    regs[instr[i][1]] = X * Y
#  elif instr[i][0] == "jnz":
#    if X != 0:
#      i += Y
#      return 1
#  else:
#    print("problem with instr[{}][0] = {}".format(i, instr[i][0]))
#    return 0
#  #print("PROG {}: END : regs[{}] = {}".format(ID, instr[i][1], regs.get(instr[i][1], 0)))
#  i += 1
#  return 1
#
#while execute():
#  pass

######################
### SECOND version ###
###   too slow !   ###
######################

#def test(b):
#  for d in range(2,b):
#    for e in range(2,b):
#      if d * e == b:
#        return True
#  return False
#
#
## translate the assembly to a real program:
#for b in range(107900, 124917, 17):
#  print("testing {}".format(b))
#  if test(b):
#    result += 1

#####################
### THIRD version ###
###  good speed ! ###
#####################

import math
def is_prime(n):
  if n % 2 == 0 and n > 2: 
    return False
  for i in range(3, int(math.sqrt(n)) + 1, 2):
    if n % i == 0:
      return False
  return True

for b in range(107900, 124917, 17):
  if not is_prime(b):
    print("{} NOT prime".format(b))
    result += 1
  else:
    print("{} prime".format(b))

print("result is {}".format(result))
