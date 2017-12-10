#!/usr/bin/env python3

f = open("input.txt", 'r');

table = {};
pos = 0;
result = 0;

for line in f:
  table.append(int(line));

print(table);

while True:
  try:
    a=table[pos];
    #print("a = {} pos = {}\n".format(a,pos));
    if (a >= 3):
      table[pos] = a-1;
    else:
      table[pos] = a+1;
    pos+=a;
    result+=1;
  except KeyError:
    print("result is {}\n".format(result));
    quit();

