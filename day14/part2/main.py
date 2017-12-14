#!/usr/bin/env python3


INPUT = "ugkiagan"
#INPUT = "flqrgnkx"

table = dict()

def hash(string):
  lengths = [ord(x) for x in list(string)]
  lengths.extend([17, 31, 73, 47, 23])
  l = list(range(256))
  cur_position = 0
  skip_size = 0
  hash = ""
  for i in range(64):
    for length in lengths:
      tmp_list = list(l)
      for i in range(int(length)):
        l[(cur_position+i)%len(l)] = tmp_list[(cur_position+length-1-i)%len(l)]
      cur_position += length + skip_size
      skip_size += 1
  for i in range(0,256,16):
    xor = l[i]
    for j in range(i+1, i+16):
      xor ^= l[j]
    hash += "{:02x}".format(xor)
  return hash



for i in range(128):
  cur_hash = int(hash("{}-{}".format(INPUT, i)), 16)
  l = list(format(cur_hash, '0128b'))
  for j in range(128):
    table[(i,j)] = int(l[j])
  #print("hash of {}-{} is {:032x} {} with {} ones".format(INPUT, i, cur_hash, bin(cur_hash), list(bin(cur_hash)).count('1')))

result = 0
visited = set()

def visit(start):
  global visited
  if start in visited:
    return 0
  visited.add(start)
  if table[start] == 0:
    return 0
  else:
    x, y = start
    if (x+1) < 128: visit((x+1,y))
    if (x-1) >=  0: visit((x-1,y))
    if (y+1) < 128: visit((x,y+1))
    if (y-1) >=  0: visit((x,y-1))
    return 1

while len(visited) != 128*128:
  result += visit(list(table.keys() - visited)[0])

print("result is {}".format(result))

