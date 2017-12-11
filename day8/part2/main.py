#!/usr/bin/env python3

f = open("input.txt", 'r');

regs = {}
result = 0

def update_reg(name, op, value):
  global result
  if op == "inc":
    regs[name] = regs.get(name, 0) + value
  else:
    regs[name] = regs.get(name, 0) - value
  if regs[name] > result:
    result = regs[name]

for line in f:
  res = line.split()
  if res[5] == '>':
    if regs.get(res[4],0) > int(res[6]):
      update_reg(res[0], res[1], int(res[2]))
  elif res[5] == '<':
    if regs.get(res[4],0) < int(res[6]):
      update_reg(res[0], res[1], int(res[2]))
  elif res[5] == '==':
    if regs.get(res[4],0) == int(res[6]):
      update_reg(res[0], res[1], int(res[2]))
  elif res[5] == '!=':
    if regs.get(res[4],0) != int(res[6]):
      update_reg(res[0], res[1], int(res[2]))
  elif res[5] == '<=':
    if regs.get(res[4],0) <= int(res[6]):
      update_reg(res[0], res[1], int(res[2]))
  elif res[5] == '>=':
    if regs.get(res[4],0) >= int(res[6]):
      update_reg(res[0], res[1], int(res[2]))
  else:
    print("Unknown condition {}".format(res[5]))

print("result is {}".format(result))
