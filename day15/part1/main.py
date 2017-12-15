#!/usr/bin/env python3


A = 883
B = 879
#A = 65
#B = 8921
result = 0

def next_value_A(val):
  mul = val * 16807
  return mul - int(mul / 2147483647)*2147483647

def next_value_B(val):
  mul = val * 48271
  return mul - int(mul / 2147483647)*2147483647

for i in range(40000000):
#for i in range(5):
  A = next_value_A(A)
  B = next_value_B(B)
  #print("A {:x} B {:x}".format(A, B))
  if (i % 1000000) == 0:
    print("i = {} result is {}".format(i, result))
  if (A & 0xffff) == (B & 0xffff):
    result += 1


print("result is {}".format(result))

