#!/usr/bin/python3

import sys
import os
import json

if 'REMINDER_LOCATION' in os.environ and os.environ['REMINDER_LOCATION'] != '':
  reminder_file = os.environ['REMINDER_LOCATION']
else:
  reminder_file = os.path.join(os.path.dirname(__file__), '.reminders')

def helptext(*, error = None, code = 1):
  if error is not None:
    print(error)
    print('=================')

  print("""
Adds a reminder for you to check. Recommended to put "reminder list" in your .bashrc, or define CCLEAR_REMINDER to non-empty

Usage:
  reminder [add|list|clear] <args>

'add' args:
  <reminder>

'list' args:
  N/A

'clear' args:
  --all          Clear all reminders
  <id>(,<id>)    One or a list of the IDs to clear - IDs gotten from "reminder list"
"""[1:-1])
  exit(code)

def parse_args__add(args):
  if len(args) < 1:
    helptext(error = "Action 'add' requires a reminder to add")

  return {
    'reminder': ' '.join(args),
  }

def parse_args__list(args):
  if len(args) > 0:
    helptext(error = "Cannot specify flags to 'list' action")
  return {}

def parse_args__clear(args):
  retval = {
    'all': False,
    'id': [],
  }

  i = 0
  while i < len(args):
    if args[i] == '--all':
      retval['all'] = True
    else:
      retval['id'] += args[i].split(',')
    i += 1

  if not retval['all'] and len(retval['id']) == 0:
    helptext(error = "Action 'clear' requires either an ID, a list of IDs, or the flag --all")

  for r in range(len(retval['id'])):
    if not retval['id'][r].isnumeric():
      helptext(error = "The given ID '%s' is not numeric".format(retval['id'][r]))
    retval['id'][r] = int(retval['id'][r])

  return retval

def parse_args(args):
  retval = {
    'mode': None,
  }

  if len(args) < 1 or '--help' in args:
    helptext(code = 0)
  elif args[0] not in ['add', 'clear', 'list']:
    helptext(error="Invalid action '{0}'".format(args[0]))

  retval['mode'] = args[0]
  if retval['mode'] == 'add':
    retval.update(parse_args__add(args[1:]))
  elif retval['mode'] == 'list':
    retval.update(parse_args__list(args[1:]))
  elif retval['mode'] == 'clear':
    retval.update(parse_args__clear(args[1:]))

  return retval

def file_read():
  if not os.path.isfile(reminder_file):
    return []

  with open(reminder_file, 'r') as f:
    return json.loads(f.read())

def file_write(contents):
  with open(reminder_file, 'w') as f:
    f.write(json.dumps(contents, indent = 2))

def action_add(args):
  contents = file_read()
  contents.append(args['reminder'])
  file_write(contents)

def action_list(args):
  contents = file_read()
  if len(contents) == 0:
    exit(1)

  print('\033[1;32m', end="") # Bold green
  print('+--------------------------+')
  print('| You have some reminders! |')
  print('+--------------------------+')
  print('\033[00m', end="") # Neutral
  for i, entry in enumerate(contents):
    print('{0}) {1}'.format(i + 1, entry))
  exit(0)

def action_clear(args):
  if args['all']:
    os.remove(reminder_file)
    return

  contents = file_read()
  ids = sorted(args['id'], reverse = True)
  for id in ids:
    if len(contents) < id:
      break
    del contents[id - 1]

  if len(contents) == 0:
    os.remove(reminder_file)
  else:
    file_write(contents)

def main():
  args = parse_args(sys.argv[1:])

  if args['mode'] == 'add':
    action_add(args)
  elif args['mode'] == 'list':
    action_list(args)
  elif args['mode'] == 'clear':
    action_clear(args)

main()