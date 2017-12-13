#!/usr/bin/env python3

import re
f = open("input.txt", 'r');

tree = {};
weights = {};
result = 0;
i = 0;

for line in f:
  m = re.search(r'(\w+) \((.*)\) -> (.*)', line)
  if m:
    weights[m.group(1)] = int(m.group(2))
    tree[m.group(1)]    = set(m.group(3).split(', '))
  else:
    m = re.search(r'(\w+) \((.*)\)', line)
    if m:
      weights[m.group(1)] = int(m.group(2))
      tree[m.group(1)]    = set()
    else:
      print("ERROR with line {}".format(line))
      quit()

#print(tree)

marked = list()

def visit(start):
  if start in marked:
    return
  for next in tree[start]:
    visit(next)
  marked.append(start)
  return

while len(marked) != len(tree):
  visit(list(tree.keys() - marked)[0])

#marked is now a list with reverse topological order of tree

orig_weights = weights.copy()

def update(start):
  #print("updating {} weighting {}".format(start, weights[start]))
  if not tree[start]:
    return
  first_son = tree[start].pop()
  cur_weight = weights[first_son]
  weights[start] += cur_weight
  #print("weight of first son is {}".format(cur_weight))
  for n in tree[start]:
    #print("testing son {} with weight {}".format(n, weights[n]))
    if weights[n] != cur_weight:
      print("bad node :  weights[{}] = {} != weights[{}] = {} (orig_weights[{}] = {} and orig_weights[{}] = {})".format(n, weights[n], first_son, weights[first_son], n, orig_weights[n], first_son, orig_weights[first_son]))
      #quit()
    weights[start] += weights[n]
      


for i in marked:
  update(i)

