#!/usr/bin/env python3

import re
f = open("input.txt", 'r');

instr = {}
regs = {}
result = 0

for i,line in enumerate(f):
  instr[i] = line.split()

print(instr)

i = 0
while i in range(len(instr)):
  #print("instr {} : {} and regs[{}] = {}".format(i, instr[i], instr[i][1], regs.get(instr[i][1], 0)))
  if len(instr[i]) > 2:
    try:
      Y = int(instr[i][2])
    except ValueError:
      Y = regs.get(instr[i][2], 0)
  if instr[i][0] == "snd":
    last_snd = regs.get(instr[i][1], 0)
  elif instr[i][0] == "set":
    regs[instr[i][1]] = Y
  elif instr[i][0] == "add":
    regs[instr[i][1]] = regs.get(instr[i][1], 0) + Y
  elif instr[i][0] == "mul":
    regs[instr[i][1]] = regs.get(instr[i][1], 0) * Y
  elif instr[i][0] == "mod":
    #if Y != 0:
    regs[instr[i][1]] = regs.get(instr[i][1], 0) % Y
  elif instr[i][0] == "rcv":
    if regs.get(instr[i][1], 0) != 0:
      print("result is {}".format(last_snd))
      quit()
  elif instr[i][0] == "jgz":
    if regs.get(instr[i][1], 0) > 0:
      i += Y
      continue
  else:
    print("problem with instr[{}][0] = {}".format(i, instr[i][0]))
  #print("END : regs[{}] = {}".format(instr[i][1], regs.get(instr[i][1], 0)))
  i += 1
