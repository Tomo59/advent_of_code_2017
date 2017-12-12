#!/usr/bin/env python3

import re
f = open("input.txt", 'r');

tree = {};
result = 0;
i = 0;

for line in f:
  m = re.search(r'(\w+) <-> (.*)', line)
  if m:
    tree[int(m.group(1))] = set([int(i) for i in m.group(2).split(', ')])
  else:
    print("ERROR with line {}".format(line))
    quit()

print(tree)

def dfs(graph, start, visited=None):
  global result
  if visited is None:
    visited = set()
  result += 1
  visited.add(start)
  for next in graph[start] - visited:
    dfs(graph, next, visited)
  return visited

dfs(tree, 0)
print("result is {}".format(result))
