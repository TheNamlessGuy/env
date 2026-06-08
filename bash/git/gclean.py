#!/usr/bin/python3

import os
import sys
import subprocess

opts = {
  'auto': None,
  'quiet': None,
}

def confirm(msg, *, default = None, auto = None, quiet = None):
  msg += ' [' + ('Y' if default == True else 'y') + '/' + ('N' if default == False else 'n') + '] '

  if auto is not None:
    if quiet != True:
      msg += ('y' if auto else 'n')
      print(msg)
    return auto

  while True:
    response = input(msg).lower()
    if response == '' and default is not None:
      return default
    elif response in ['y', 'n']:
      return response == 'y'

def main():
  for arg in sys.argv[1:]:
    if arg == '-y' or arg == '--yes':
      opts['auto'] = True
    elif arg == '-i':
      opts['auto'] = None
    elif arg == '-n' or arg == '--no':
      opts['auto'] = False
    elif arg == '-q' or arg == '--quiet':
      opts['quiet'] = True
    else:
      print("Unknown flag '{0}'".format(arg))
      exit(1)

  output = subprocess.check_output(['git', 'status', '--porcelain', '-s', '-uall']).decode('utf-8').splitlines()
  output.sort(key = lambda line: len(line), reverse = True)
  for line in output:
    status = line[:2]
    filename = line[3:]

    if status == '??':
      response = confirm("Delete '{0}'?".format(filename), default = True, auto = opts['auto'], quiet = opts['quiet'])
      if response:
        if os.path.isfile(filename):
          os.remove(filename)
        else:
          os.rmdir(filename)

try:
  main()
except KeyboardInterrupt:
  print()
  pass # This is fine
