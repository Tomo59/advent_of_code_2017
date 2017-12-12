#!/usr/bin/env python3

f = open("input.txt", 'r');

line = f.readline()

i = 0
result = 0
cur_weigth = 0
while i < len(line):
  if line[i] == '{':
    cur_weigth += 1
    result += cur_weigth
  elif line[i] == '}':
    cur_weigth -= 1
  elif line[i] == '!':
    i += 1
  elif line[i] == '<':
    i += 1
    while line[i] != '>':
      if line[i] == '!':
        i += 1
      i += 1
  i += 1

print("result is {}".format(result))
