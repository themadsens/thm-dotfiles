#!/usr/bin/env python3
import fcntl
import sys
import termios

opts = (termios.tcgetattr(sys.stdout))
noecho = (*opts[:3], opts[3] & ~termios.ECHO, *opts[4:])


termios.tcsetattr(sys.stdout, termios.TCSANOW, [*noecho])
del sys.argv[0]
for c in ' '.join(sys.argv):
    fcntl.ioctl(sys.stdout, termios.TIOCSTI, c)
termios.tcsetattr(sys.stdout, termios.TCSANOW, [*opts])
