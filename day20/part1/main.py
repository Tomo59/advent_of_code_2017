#!/usr/bin/env python3


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

def dist(l):
  return abs(l[0])+abs(l[1])+abs(l[2])

accs = [dist(x['a']) for x in parts]
min_acc = min(accs)
nb_min = accs.count(min_acc)

if nb_min == 1:
  print("min acceleration is {} for particule {}".format(min_acc, accs.index(min_acc)))
else:
  print("You should do a better program for this input")

