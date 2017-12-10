#!/usr/bin/env python3

f = open("input.txt", 'r');

result = 0;

for line in f:
  int_list = [int(i) for i in line.split()]
  int_list.sort(reverse=True);
  print(int_list);
  while int_list:
    e = int_list.pop(0)
    for i in int_list:
      if (e//i) == (float(e)/i):
        print("found {}/{} = {}\n".format(e, i, e/i));
        result += e/i;
        break;

print("result is {}\n".format(result));
