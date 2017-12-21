#!/usr/bin/env python3

combi = dict()
f = open("input.txt", 'r');
for line in f:
  l = line.strip().replace("/", "").split(" => ")
  combi[l[0]] = l[1]

def rotate(s):
  if len(s) == 4:
    return s[2]+s[0]+s[3]+s[1]
  elif len(s) == 9:
    return s[6]+s[3]+s[0]+s[7]+s[4]+s[1]+s[8]+s[5]+s[2]
  else:
    print("Invalid string {} in rotate !".format(s))
    quit()

def flip_v(s):
  if len(s) == 4:
    return s[1]+s[0]+s[3]+s[2]
  elif len(s) == 9:
    return s[2]+s[1]+s[0]+s[5]+s[4]+s[3]+s[8]+s[7]+s[6]
  else:
    print("Invalid string {} in flip_v !".format(s))
    quit()


# add all rotations
for key in combi.copy():
  k = key
  for i in range(3):
    k = rotate(k)
    if k not in combi.keys():
      combi[k] = combi[key]

# add all flip
for key in combi.copy():
  k = flip_v(key)
  if k not in combi.keys():
    combi[k] = combi[key]

# redo all rotations after flip
for key in combi.copy():
  k = key
  for i in range(3):
    k = rotate(k)
    if k not in combi.keys():
      combi[k] = combi[key]

# print(combi)

###### MAIN #####
pixels = [['.','#','.'],['.','.','#'],['#','#','#']]

for i in range(18):
  print(i)
  if (len(pixels) % 2) == 0:
    step = 2
  else:
    step = 3
  new_pixels = list()
  for j in range(len(pixels) // step * (step + 1)):
    new_pixels.append(list())
  #print(len(pixels) // step * (step + 1))
  #print(new_pixels)
  for j in range(0,len(pixels),step):
    for k in range(0,len(pixels),step):
      #print(" j = {} k = {}".format(j,k))
      block = ""
      for l in range(step):
        for m in range(step):
          block += pixels[j+l][k+m]
      new_block = combi[block]
      #print("block = {}, new_block = {}".format(block, new_block))
      for l in range(step+1):
        #print("adding {} to line {}".format(new_block[(step+1)*l:(step+1)*(l+1)], (j//step*(step+1))+l))
        new_pixels[(j//step*(step+1))+l].extend(list(new_block[(step+1)*l:(step+1)*(l+1)]))
  #print(new_pixels)
  pixels = new_pixels

result = 0
for i in pixels:
  result += i.count('#')

print("result is {}".format(result))

