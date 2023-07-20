#!/usr/bin/python3

import sys
import subprocess
import re
import os

def convert_color(color):
  c1 = '0'
  if color.startswith('bold'):
    color = color[4:]
    c1 = '1'

  c2 = ''
  if color == 'black': c2 = '0'
  elif color == 'red': c2 = '1'
  elif color == 'green': c2 = '2'
  elif color == 'blue': c2 = '4'
  elif color == 'purple': c2 = '5'
  elif color == 'cyan': c2 = '6'
  elif color == 'gray': c2 = '7'
  elif color == 'brown':
    c1 = '0'
    c2 = '3'
  elif color == 'yellow':
    c1 = '1'
    c2 = '3'

  return '\033[{0};3{1}m'.format(c1, c2) if len(c1) > 0 and len(c2) > 0 else color

def color_string(s):
  color = colors[s]
  if color[2]:
    s = s.replace(' ', '{0} \033[0m{1}'.format(color[1], color[0]))
  return color[0] + s

color = '\033[1;31m'
bgcolor = '\033[0;41m'
whitespace = False
lines = []
matches = set()
colors = {}

if not sys.stdin.isatty():
  for line in sys.stdin:
    if line.endswith('\n'):
      line = line[:-1]
    lines += [line]

args = sys.argv[1:]
i = 0
while i < len(args):
  if args[i] == '-w':
    whitespace = not whitespace
  elif args[i] == '--color':
    i += 1
    color = convert_color(args[i])
    bgcolor = color[3:]
    bgcolor = '\033[{0};{1}m'.format(bgcolor[0], int(bgcolor[2:-1]) + 10)
  else:
    for line in lines:
      for match in re.findall(args[i], line):
        colors[match] = [color, bgcolor, whitespace]
        matches.add(match)

  i += 1

def cmp(a, b):
  return (a > b) - (a < b)

matches = sorted(list(matches), key = lambda l: len(l))

new_matches = []
for i in range(len(matches)):
  raw_match = matches[i]
  match = color_string(raw_match)

  for j in range(len(matches)):
    raw_match2 = matches[j]
    if raw_match == raw_match2: continue
    match2 = color_string(raw_match2)
    match = match.replace(raw_match2, match2 + colors[raw_match][0])

  new_matches.append(match + '\033[0m')

for line in lines:
  for i in range(len(matches)):
    line = line.replace(matches[i], new_matches[i])
  print(line)