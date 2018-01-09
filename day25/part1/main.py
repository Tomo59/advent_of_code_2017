#!/usr/bin/env python3

states = dict()

states["A"] = [ [1, "+", "B"], [0, "-", "C"] ]
states["B"] = [ [1, "-", "A"], [1, "+", "C"] ]
states["C"] = [ [1, "+", "A"], [0, "-", "D"] ]
states["D"] = [ [1, "-", "E"], [1, "-", "C"] ]
states["E"] = [ [1, "+", "F"], [1, "+", "A"] ]
states["F"] = [ [1, "+", "A"], [1, "+", "E"] ]

print(states)

state = "A"
tape = dict()
pos = 0

for i in range(12134527):
  val = tape.get(pos, 0)
  tape[pos] = states[state][val][0]
  if states[state][val][1] == '+':
    pos += 1
  else:
    pos -= 1
  state = states[state][val][2]

#print(tape)

result = 0;

for v in tape.values():
  result += v

print("result is {}".format(result))
