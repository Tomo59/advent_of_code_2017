#!/usr/bin/env python3

from copy import deepcopy

# b is the current bridge
# p is the current port at the end of the bridge
# c are the remaining components
def construct(b, p, c):
  global bridges
  #print("b = {}, p = {}, c = {}".format(b, p, c))
  if p not in c.keys():
    #print("bridge finished")
    bridges.append(b)
    return

  #print("c[{}] = {}".format(p, c[p]))
  # we now that p is in c.keys
  for port in c[p]:
    new_c = deepcopy(c)
    new_c[port].remove(p)
    if len(new_c[port]) == 0:
      del new_c[port]
    if port != p:
      new_c[p].remove(port)
      if len(new_c[p]) == 0:
        del new_c[p]
    new_b = list(b)
    new_b.append(port)
    construct(new_b, port, new_c)

# first element is 0 but is not in bridge so we don't care
# last element should be counted only once
def weight(b):
  return sum(b)*2 - b[-1]

components = dict()
f = open("input.txt", 'r');
for line in f:
  l = line.split("/")
  p0 = int(l[0])
  p1 = int(l[1])
  if p0 not in components.keys():
    components[p0] = list()
  if p1 not in components.keys():
    components[p1] = list()
  components[p0].append(p1)
  if p0 != p1:
    components[p1].append(p0)

bridges = list()
construct(list(), 0, components)

print(bridges)

max_weight = max(map(weight, bridges))

print("result is {}".format(max_weight))
#
