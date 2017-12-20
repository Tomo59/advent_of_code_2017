#!/usr/bin/env python3

from operator import add

parts = list()
f = open("input.txt", 'r');
for line in f:
  part = dict()
  for values in line[:-1].split(", "):
    key=values[:1]
    part[key] = list()
    for v in values[3:-1].split(','):
      part[key].append(int(v))
  parts.append(part)

print(parts)

def compute(d):
  d['v'] = [a + b for a, b in zip(d['v'], d['a'])]
  d['p'] = [a + b for a, b in zip(d['p'], d['v'])]

for i in range(100000): # TODO find a better condition for stopping
  parts = sorted(parts, key=lambda part: part['p'])
  j = 0
  while j < len(parts) - 1:
    if parts[j]['p'] == parts[j+1]['p']:
      print(parts)
      print("step {}: removing particule {} ({})".format(i, j+1, parts.pop(j+1)))
      while parts[j]['p'] == parts[j+1]['p']:
        print("step {}: removing particule {} ({})".format(i, j+1, parts.pop(j+1)))
      print("step {}: removing particule {} ({})".format(i, j, parts.pop(j)))
    j += 1
  for p in parts:
    compute(p) 
  if (i % 100) == 0:
    print("i = {}, len(parts) = {}".format(i, len(parts)))

print("result is {}".format(len(parts)))
