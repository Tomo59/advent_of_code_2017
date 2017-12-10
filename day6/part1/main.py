#!/usr/bin/env python3

f = open("input.txt", 'r');

mem = {}
bank_status = {};
result = 0;
i = 0;

for line in f:
  for nb in line.split():
    mem[i] = int(nb)
    i+=1


print(mem)

def update_mem():
  index = max(mem.keys(), key=(lambda k: mem[k]))
  max_value = mem[index]
  print("max value is {} index is {}\n".format(max_value, index))
  mem[index] = 0
  while max_value > 0:
    index = (index + 1) % 16
    mem[index] += 1
    max_value -= 1
  print(mem)

while not mem in bank_status.values():
  bank_status[result] = mem
  print(bank_status)
  update_mem()
  print(bank_status)
  print(mem)
  result += 1

print("result is {}\n".format(result));

