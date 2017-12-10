#!/usr/bin/env python3

f = open("input.txt", 'r');

result = 0;

for line in f:
  my_list = line.split();
  if (len(my_list) == len(set([''.join(sorted(i)) for i in my_list]))):
    result+=1;

print("result is {}\n".format(result));
