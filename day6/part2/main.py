#!/usr/bin/env python3

f = open("input.txt", 'r');

bank_status = [];
result = 0;
i = 0;

for line in f:
  mem = [ int(i) for i in line.split() ]


print(mem)

def update_mem():
  max_value = max(mem)
  index = mem.index(max_value)
  mem[index] = 0
  while max_value > 0:
    index = (index + 1) % 16
    mem[index] += 1
    max_value -= 1

while not mem in bank_status:
  bank_status.append(list(mem))
  update_mem()
  result += 1

print("result is {}\n".format(result - bank_status.index(mem)));

