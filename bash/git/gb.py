#!/usr/bin/python3

import sys
import subprocess

separator = '<>:@$@:<>'
config = [
  'HEAD',
  'refname:short',
  'upstream:short',
  'upstream:track,nobracket',
  'contents:subject',
]

IDX_HEAD = config.index('HEAD')
IDX_REFNAME = config.index('refname:short')
IDX_UPSTREAM = config.index('upstream:short')
IDX_TRACK = config.index('upstream:track,nobracket')
IDX_CONTENTS = config.index('contents:subject')

lines = subprocess.check_output(['git', 'branch', '--format=%(' + '){0}%('.format(separator).join(config) + ')']).decode('utf-8')[:-1].split('\n')
lines = [line.split(separator) for line in lines]

def get_head(line):
  compare = '*' if line[IDX_HEAD] == '*' else ''
  color = '\033[0m' + compare + '\033[0m'
  return [compare, color]

def get_refname(line):
  compare = line[IDX_REFNAME]
  color = ''
  if line[IDX_TRACK] == 'gone':
    color = '\033[91m' + compare
  elif line[IDX_HEAD] == '*':
    color = '\033[92m' + compare
  else:
    color = '\033[0m' + compare
  color += '\033[0m'
  return [compare, color]

def get_upstream(line):
  if line[IDX_UPSTREAM] == '':
    return ['', '']

  compare = '[' + line[IDX_UPSTREAM]
  color = '[' + ('\033[91m' if line[IDX_TRACK] == 'gone' else '\033[94m') + line[IDX_UPSTREAM] + '\033[0m'
  if line[IDX_TRACK] == 'gone':
    pass
  elif line[IDX_TRACK] != '':
    compare += ', ' + line[IDX_TRACK]
    color += ', ' + line[IDX_TRACK]
  compare += ']'
  color += ']'
  return [compare, color]

columns = {
  'head': [],
  'refname': [],
  'upstream': [],
  'contents': [],
}

for line in lines:
  columns['head'    ].append(get_head(line))
  columns['refname' ].append(get_refname(line))
  columns['upstream'].append(get_upstream(line))
  columns['contents'].append([line[IDX_CONTENTS], line[IDX_CONTENTS]])

def longest_len(list, *, start = 0):
  longest = start
  for entry in list:
    if len(entry[0]) > longest:
      longest = len(entry[0])
  return longest

header = {
  'head': '',
  'refname': 'Branch',
  'upstream': 'Upstream',
  'contents': 'Message',
}

longest = {
  'head':     longest_len(columns['head'    ], start = len(header['head'])),
  'refname':  longest_len(columns['refname' ], start = len(header['refname'])),
  'upstream': longest_len(columns['upstream'], start = len(header['upstream'])),
  'contents': longest_len(columns['contents'], start = len(header['contents'])),
}

def justify(key, i, next_key):
  diff = longest[key] - len(columns[key][i][0])
  result = columns[key][i][1]

  if diff > 0 and columns['head'][i][0] == '*':
    if len(result) > 0:
      diff -= 1
      result += ' '
    result += '\033[48;5;235m'

  result = result.ljust(len(result) + diff)

  if next_key is None or len(columns[next_key][i][0]) > 0:
    result += '\033[0m'

  return result

format_str = '{0} {1} {2} {3}'

print(format_str.format(
  header['head'    ].ljust(longest['head']),
  header['refname' ].ljust(longest['refname']),
  header['upstream'].ljust(longest['upstream']),
  header['contents'].ljust(longest['contents']),
))

print(format_str.format(
  ''.ljust(longest['head'    ]),
  ''.ljust(longest['refname' ], '─'),
  ''.ljust(longest['upstream'], '─'),
  ''.ljust(longest['contents'], '─'),
))

for i in range(len(columns['head'])):
  print(format_str.format(
    justify('head',     i, 'refname' ),
    justify('refname',  i, 'upstream'),
    justify('upstream', i, 'contents'),
    justify('contents', i, None      ),
  ))