#!/usr/bin/env python3

from collections import deque
f = open("input.txt", 'r');
instr = {}
for i,line in enumerate(f):
  instr[i] = line.split()


regs = {"a":0, "b":0, "c":0, "d":0, "e":0, "f":0, "g":0, "h":0}
i = 0
result = 0


def execute():
  global result
  global i
  if i not in instr.keys():
    return 0
  #print("instr {} : {} and regs[{}] = {}".format(i, instr[i], instr[i][1], regs.get(instr[i][1], 0)))
  try:
    X = int(instr[i][1])
  except ValueError:
    X = regs.get(instr[i][1], 0)
  if len(instr[i]) > 2:
    try:
      Y = int(instr[i][2])
    except ValueError:
      Y = regs.get(instr[i][2], 0)
  if instr[i][0] == "set":
    regs[instr[i][1]] = Y
  elif instr[i][0] == "sub":
    regs[instr[i][1]] = X - Y
  elif instr[i][0] == "mul":
    regs[instr[i][1]] = X * Y
    result += 1
  elif instr[i][0] == "jnz":
    if X != 0:
      i += Y
      return 1
  else:
    print("problem with instr[{}][0] = {}".format(i, instr[i][0]))
    return 0
  #print("PROG {}: END : regs[{}] = {}".format(ID, instr[i][1], regs.get(instr[i][1], 0)))
  i += 1
  return 1

while execute():
  pass

print("result is {}".format(result))
