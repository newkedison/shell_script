#!/usr/bin/env python
#coding=utf-8
import sys
import commands
import getopt
#http://pypi.python.org/pypi/termcolor/
from termcolor import colored, cprint

g_host_name = ''
g_username = ''
g_password = ''
g_mount_pos = ''
g_verbose = False

cprint_error = lambda x: cprint(x, 'red', attrs=['bold'])
colored_error = lambda x: colored(x, 'red', attrs=['bold'])

def usage():
  name = sys.argv[0]
  cprint('usage:', 'green', end='', attrs=['bold'])
  print '   %s [options]' % name
  cprint('  options:', 'green', attrs=['bold'])
  print '  -H/--Host //192.168.18.100  remote host ip'
  print '  -H/--Host //host_name       remote host name'
  print '  -u/--username username      username, if not set, it will be "any"'
  print '  -p/--password password      password, if not set, it will be "any"'
  print '  -m/--mount /mnt             mount pos, if not set, it will be "/mnt"'
  print '  -U/--umount /mnt            umount the given pos'
  print '  -v/--verbose                display all shell command'


def check_opt():
  try:
    opts, args = getopt.getopt(sys.argv[1:], "hvH:u:U:p:m:", 
         ["help", "verbose", "Host", "username", "umount", "password", "mount"])
    for opt, arg in opts:
      if opt in ("-h", "--help"):
        usage()
        exit(0)
      elif opt in ("-H", "--Host"):
        global g_host_name
        g_host_name = arg
      elif opt in ("-u", "--username"):
        global g_username
        g_username = arg
      elif opt in ("-p", "--password"):
        global g_password
        g_password = arg
      elif opt in ("-m", "--mount"):
        global g_mount_pos
        g_mount_pos = arg
      elif opt in ("-U", "--umount"):
        umount_device(arg)
        exit(0);
      elif opt in ('-v', "--verbose"):
        global g_verbose
        g_verbose = True

  except getopt.GetoptError:
    usage()
    exit(2)

  while g_host_name == '':
    g_host_name = raw_input(colored('Please input host name:', 'blue'))
  import re
  if re.match('^\d{1,3}$', g_host_name):
    g_host_name = '//192.168.18.' + g_host_name
  if re.match('^\d{1,3}(\.\d{1,3}){1}$', g_host_name):
    g_host_name = '//192.168.' + g_host_name
  if re.match('^\d{1,3}(\.\d{1,3}){2}$', g_host_name):
    g_host_name = '//192.' + g_host_name
  if re.match('^\d{1,3}(\.\d{1,3}){3}$', g_host_name):
    g_host_name = '//' + g_host_name
  if g_username == '':
    g_username = 'any'
  if g_password == '':
    g_password = 'any'
  if g_mount_pos == '':
    g_mount_pos = '/mnt'

def run_cmd(cmd):
  if g_verbose:
    print 'Shell:', colored(shell_cmd, 'grey')
  return commands.getstatusoutput(cmd)

def get_smbclient_result(host, user, password):
  shell_cmd = "smbclient -L %s -U %s%%%s" % (host, user, password)
  _, b = run_cmd(shell_cmd)
  print b

def get_share_name(host, user, password):
  shell_cmd = "smbclient -L %s -U %s%%%s 2>/dev/null | \
    awk '/.* +Disk *$/ {print}' | sed 's/^\s*\(.*[^ ]\)\s*Disk\s*$/\\1/' " \
    % (host, user, password)
  _, b = run_cmd(shell_cmd)
  all_shares = b.split('\n')
  return all_shares

def get_choise(msg, min_value, max_value):
  c = ''
  while not (c.isdigit() and int(c) >= min_value and int(c) <= max_value):
    c = raw_input(msg)
    if not c.isdigit():
      cprint_error('please input a number')
    elif int(c) < min_value or int(c) > max_value:
      print colored_error('please input a number between [%d, %d]') % (
        min_value, max_value)
  return c

def mount_windows_share(host, share_name, mount_pos, username='', password=''):
  shell_cmd = "sudo mount -t cifs -o username=%s,password=%s '%s\%s' '%s'" % (
    username, password, host, share_name, mount_pos)
  a, _ = run_cmd(shell_cmd)
  if a == 0:
    cprint('%s\%s' % (host, share_name), 'magenta', end=' ')
    print 'is now mount to ', colored(mount_pos, 'magenta')
    print colored('Do you want to open it?', 'green'), colored(
       'Press "Enter" for yes, input any char and press "Enter" for no', 'grey')
    x = raw_input('Please make your choise:')
    if x == '':
      run_cmd('nautilus %s' % mount_pos)
  else:
    cprint_error('mount error, use "dmesg | tail" maybe helpful')

def is_mounted(mount_pos):
  shell_cmd = "mount | grep %s" % mount_pos
  a, _ = run_cmd(shell_cmd)
  return a == 0

def umount_device(path):
  shell_cmd = 'sudo umount %s' % path
  a, _ = run_cmd(shell_cmd)
  if a != 0:
    cprint_error('umount error, maybe nothing is mounted on %s' % path)
  else:
    cprint('umount success', 'yellow')

if __name__ == '__main__':
  check_opt()
  x = get_share_name(g_host_name, g_username, g_password)
  if len(x) == 0 or x[0] == '':
    cprint_error('not any share folder was found')
    exit(1)
  cprint('here is all the shared folders on remote host', 'green')
  cprint('which one do you want to mount?', 'green')
  for i, s in enumerate(x):
    print colored(i + 1, 'blue'), colored(s, 'yellow') 
  print colored(i + 2, 'blue'), colored(
    'Do not mount, just call smbclient without filter', 'yellow')
  print colored(i + 3, 'blue'), colored(
    'umount %s' % g_mount_pos, 'yellow')
  c = get_choise('please make your choise:', 1, i + 3)
  if int(c) == i + 2:
    get_smbclient_result(g_host_name, g_username, g_password)
  elif int(c) == i + 3:
    umount_device(g_mount_pos)
  else:
    if is_mounted(g_mount_pos):
      cprint_error('there is another device mounting on %s, ' % g_mount_pos)
      cprint_error('please select other mount pos')
    else:
      mount_windows_share(g_host_name, x[int(c) - 1], g_mount_pos)

