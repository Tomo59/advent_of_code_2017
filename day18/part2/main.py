#!/usr/bin/env python3

from collections import deque
f = open("input.txt", 'r');
instr = {}
for i,line in enumerate(f):
  instr[i] = line.split()


regs = [{"p":0}, {"p":1}]
sent = [deque(), deque()]
i= [0,0]
result = 0


def execute(ID):
  global result
  #print("PROG {}: instr {} : {} and regs[{}] = {}".format(ID, i[ID], instr[i[ID]], instr[i[ID]][1], regs[ID].get(instr[i[ID]][1], 0)))
  try:
    X = int(instr[i[ID]][1])
  except ValueError:
    X = regs[ID].get(instr[i[ID]][1], 0)
  if len(instr[i[ID]]) > 2:
    try:
      Y = int(instr[i[ID]][2])
    except ValueError:
      Y = regs[ID].get(instr[i[ID]][2], 0)
  if instr[i[ID]][0] == "snd":
    sent[ID].append(X)
    #print("PROG {}: sent = {}".format(ID, sent[ID]))
    if ID == 1:
      result += 1
  elif instr[i[ID]][0] == "set":
    regs[ID][instr[i[ID]][1]] = Y
  elif instr[i[ID]][0] == "add":
    regs[ID][instr[i[ID]][1]] = X + Y
  elif instr[i[ID]][0] == "mul":
    regs[ID][instr[i[ID]][1]] = X * Y
  elif instr[i[ID]][0] == "mod":
    regs[ID][instr[i[ID]][1]] = X % Y
  elif instr[i[ID]][0] == "rcv":
    if len(sent[1^ID]):
      regs[ID][instr[i[ID]][1]] = sent[1^ID].popleft()
      #print("PROG {}: receives {}".format(ID, regs[ID][instr[i[ID]][1]]))
    else:
      return 0 # we are waiting for a value
  elif instr[i[ID]][0] == "jgz":
    if X > 0:
      i[ID] += Y
      return 1
  else:
    print("problem with instr[{}][0] = {}".format(i[ID], instr[i[ID]][0]))
  #print("PROG {}: END : regs[{}] = {}".format(ID, instr[i[ID]][1], regs[ID].get(instr[i[ID]][1], 0)))
  i[ID] += 1
  return 1

while execute(0) or execute(1):
  while execute(0): pass # execute as most as possible in 0
  print("0 has sent {} values".format(len(sent[0])))
  while execute(1): pass # execute as most as possible in 1
  print("1 has sent {} values".format(len(sent[1])))

print("result is {}".format(result))
