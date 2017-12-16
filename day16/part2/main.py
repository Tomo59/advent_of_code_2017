#!/usr/bin/env python3

import re
f = open("input.txt", 'r');
line = f.readline()
result = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p']
orig = result.copy()
loop = 0

def dance():
  global line, result
  for w in line.strip('\n').split(','):
    if list(w)[0] == 'x':
      l = [int(n) for n in w[1:].split('/')]
      tmp = result[l[0]]
      result[l[0]] = result[l[1]]
      result[l[1]] = tmp
    elif list(w)[0] == 'p':
      l = [result.index(n) for n in w[1:].split('/')]
      tmp = result[l[0]]
      result[l[0]] = result[l[1]]
      result[l[1]] = tmp
    elif list(w)[0] == 's':
      n = int(w[1:])
      result = result[-n:] + result[:-n]
    else:
      print("ERROR with w {}".format(w))
      quit()

while loop == 0 or result != orig:
  dance()
  loop += 1

print("have found a loop after {} iterations".format(loop))

for i in range(1000000000%loop):
  dance()

print("result is ", end='')
print(*result, sep='')
