#!/usr/bin/env python3

f = open("input.txt", 'r');

table = {};
i = 0;
pos = 0;
result = 0;

for line in f:
  table[i] = int(line);
  i+=1;

print(table);

while True:
  try:
    a=table[pos];
    #print("a = {} pos = {}\n".format(a,pos));
    table[pos] = a+1;
    pos+=a;
    result+=1;
  except KeyError:
    print("result is {}\n".format(result));
    quit();

