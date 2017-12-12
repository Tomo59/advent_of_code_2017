#!/usr/bin/env python3

f = open("input.txt", 'r');

lengths = [ord(x) for x in list(f.readline())[:-1]]
lengths.extend([17, 31, 73, 47, 23])
l = list(range(256))
cur_position = 0
skip_size = 0
print(lengths)

def update_hash(lengths):
  global l, cur_position, skip_size
  for length in lengths:
    tmp_list = list(l)
    for i in range(int(length)):
      l[(cur_position+i)%len(l)] = tmp_list[(cur_position+length-1-i)%len(l)]
    cur_position += length + skip_size
    skip_size += 1

for i in range(64):
  update_hash(lengths)


print("result is : ", end='')

for i in range(0,256,16):
  xor = l[i]
  for j in range(i+1, i+16):
    xor ^= l[j]
  print("{:02x}".format(xor), end='')

print()
