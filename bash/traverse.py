#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os

def helptext(code = 1):
  print("""
Traverse a directory.

Usage:
  traverse <directory> (<flags>)

Flags:
  -h, -help, --help               Print this text
  --exclude <value(s)>            Exclude printing/traversing the given value(s), with the given delimiter (see --delimiter)
  --delimiter <delimiter>         The delimiter to use with the --exclude flag. Default: ','
  --indent-char <char>            The character to indent with. Default: ' '
  --indent-increment <number>     How many --indent-char to print for each depth level. Default: 2
  --follow-symlinks               The program starts to traverse symlink directories, instead of just printing them
  --sort                          Sorts the traversal in alphabetical order (per depth level)
  --max-depth <number>            Sets the maximum depth the traversal should go. Default: none
"""[1:-1])
  exit(code)

path = os.getcwd()
exclude = []
indent_char = ' '
indent_increment = 2
follow_symlinks = False
sort = False
max_depth = None
delimiter = ','

# Parse args
args = sys.argv[1:]
i = 0
while i < len(args):
  if args[i] == '-h' or args[i] == '-help' or args[i] == '--help':
    helptext(code = 0)
  elif args[i] == '--follow-symlinks':
    follow_symlinks = True
  elif args[i] == '--sort':
    sort = True
  elif args[i] == '--exclude':
    i += 1
    exclude.extend(args[i].split(delimiter))
  elif args[i] == '--delimiter':
    i += 1
    delimiter = args[i]
  elif args[i] == '--indent-char':
    i += 1
    indent_char = args[i]
  elif args[i] == '--indent-increment':
    i += 1
    indent_increment = int(args[i])
  elif args[i] == '--max-depth':
    i += 1
    max_depth = int(args[i])
  else:
    path = args[i]

  i += 1

def is_excluded(rel_path):
  return any(True if entry in rel_path else False for entry in exclude)

def indent(depth):
  return (indent_char * (indent_increment * depth))

def print_entry(entry, rel_path, depth):
  if is_excluded(rel_path): return False

  if os.path.isfile(rel_path):
    if os.access(rel_path, os.X_OK): entry = '\033[92m{0}'.format(entry)
    if os.path.islink(rel_path):
      print('{0}\033[105m{1}\033[0m -> {2}'.format(indent(depth), entry, os.path.realpath(rel_path)))
    else:
      print('{0}{1}\033[0m'.format(indent(depth), entry))
  else:
    if not entry.endswith('/'):
      entry += '/'
      rel_path += '/'

    if os.path.islink(rel_path[:-1]):
      print('{0}\033[105m\033[94m{1}\033[0m -> {2}'.format(indent(depth), entry, os.path.realpath(rel_path)))
      return follow_symlinks
    else:
      print('{0}\033[94m{1}\033[0m'.format(indent(depth), entry))
      return True

  return False

def traverse(folder, depth):
  entries = os.listdir(folder)
  if sort: entries = sorted(entries)

  for entry in entries:
    rel_path = os.path.join(folder, entry)

    should_traverse = print_entry(entry, rel_path, depth)
    if should_traverse:
      if max_depth is None or depth + 1 <= max_depth:
        traverse(rel_path, depth + 1)
      else:
        print('{0}...'.format(indent(depth + 1)))

if os.path.exists(path):
  should_traverse = print_entry(path, path, 0)
  if should_traverse:
    traverse(path, 1)