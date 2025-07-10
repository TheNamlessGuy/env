#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import subprocess

CONFLICT_FILES = subprocess.check_output(['git', 'diff', '--name-only', '--diff-filter=U']).decode('utf-8')[:-1].split('\n')
if len(CONFLICT_FILES) == 1 and CONFLICT_FILES[0] == '':
  CONFLICT_FILES = []

NEW = 'new'
OTHER = 'other'
STAGED = 'staged'
MODIFIED = 'modified'
UNSTAGED = 'unstaged'
CONFLICT = 'conflict'
DELETED = 'deleted'
RENAMED = 'renamed'
COPIED = 'copied'
TYPECHANGED = 'typechanged'

# Returns a list of lists, each inner list consisting of [<staged status>, <filesystem status>]
def translate_status(s, f):
  if s == '' or f == '':
    return [['', '']]

  # Unstaged
  if s == '??': return [[UNSTAGED, '']]
  if s[1] == 'A':
    if s[0] == ' ': return [[UNSTAGED, NEW]]

  # Conflict
  if f in CONFLICT_FILES:
    return [[CONFLICT, '']]

  # Staged
  if s[0] == 'A':
    if s[1] == ' ': return [[STAGED, NEW]]
    if s[1] == 'M': return [[STAGED, NEW], [MODIFIED, MODIFIED]]
    if s[1] == 'D': return [[STAGED, NEW], [MODIFIED, DELETED]]
    if s[1] == 'A': return [[CONFLICT, MODIFIED]]
  if s[0] == 'M':
    if s[1] == ' ': return [[STAGED, MODIFIED]]
    if s[1] == 'M': return [[STAGED, MODIFIED], [MODIFIED, MODIFIED]]
    if s[1] == 'D': return [[STAGED, MODIFIED], [MODIFIED, DELETED]]
  if s[0] == 'D':
    if s[1] == ' ': return [[STAGED, DELETED]]
  if s[0] == 'R':
    if s[1] == ' ': return [[STAGED, RENAMED]]
  if s[0] == 'C':
    if s[1] == ' ': return [[STAGED, COPIED]]

  # Modified
  if s[1] == 'M':
    if s[0] == ' ': return [[MODIFIED, MODIFIED]]
    if s[0] == 'M': return [[MODIFIED, MODIFIED]]
    if s[0] == 'A': return [[MODIFIED, s]]
    if s[0] == 'R': return [[MODIFIED, RENAMED]]
    if s[0] == 'C': return [[MODIFIED, COPIED]]
  if s[1] == 'D':
    if s[0] == ' ': return [[MODIFIED, DELETED]]

  # Type changed
  if s[0] == 'T':
    if s[1] == ' ': return [[STAGED, TYPECHANGED]]
  if s[1] == 'T':
    if s[0] == ' ': return [[MODIFIED, TYPECHANGED]]

  # Other
  return [[OTHER, s]]

def is_ignored(s, ignore_list):
  for i in ignore_list:
    if i in s:
      return True
  return False

def write(s, arr, color, opts, selector):
  if len(arr) == 0: return

  print(s, '({0})'.format(selector), color)
  if selector in opts['collapse']:
    print('', 'Amount: {0}'.format(len(arr)))
  else:
    ignored = 0
    for a in arr:
      if not is_ignored(a[0], opts['ignore']):
        print('', a[0], '' if a[1] == '' else '({0})'.format(a[1]))
      else:
        ignored += 1

    if ignored > 0:
      print('', 'Ignored: {0}'.format(ignored))

  sys.stdout.write('\033[0m')

staged = []
modified = []
unstaged = []
conflict = []
other = []

args = sys.argv[1:]
opts = {
  'collapse': '',
  'ignore': [],
}

i = 0
while i < len(args):
  if args[i].startswith('-c'):
    opts['collapse'] = args[i][2:]
  elif args[i] == '--ignore':
    i += 1
    opts['ignore'].append(args[i])
  else:
    print("Unknown flag '{0}'".format(args[i]))
    exit(1)

  i += 1

output = subprocess.check_output(['git', 'status', '--porcelain', '-s']).decode('utf-8')[:-1].split('\n')
for line in output:
  status = line[:2]
  filename = line[3:]

  results = translate_status(status, filename)
  for result in results:
    tmp = [filename, result[1], status]
    if result[0] == CONFLICT:
      conflict.append(tmp)
    elif result[0] == STAGED:
      staged.append(tmp)
    elif result[0] == MODIFIED:
      modified.append(tmp)
    elif result[0] == UNSTAGED:
      unstaged.append(tmp)
    elif result[0] == OTHER:
      other.append(tmp)

if len(staged) == len(modified) == len(unstaged) == len(conflict) == len(other) == 0:
  print('Repo is clean')
else:
  write('staged (git reset HEAD -- ...)', staged, '\033[92m', opts, 's')
  write('modified (git checkout -- ...)', modified, '\033[93m', opts, 'm')
  write('unstaged (git add ...)', unstaged, '\033[31m', opts, 'u')
  write('merge conflicts', conflict, '\033[94m', opts, 'e')
  write('other', other, '\033[34m', opts, 'o')
