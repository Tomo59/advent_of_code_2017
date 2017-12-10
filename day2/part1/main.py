#!/usr/bin/env python3

f = open("input.txt", 'r');

result = 0;

for line in f:
  int_list = [int(i) for i in line.split()];
  result+=max(int_list) - min(int_list)

print("result is {}\n".format(result));
