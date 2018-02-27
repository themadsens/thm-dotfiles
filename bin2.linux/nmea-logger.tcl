#!/usr/bin/env tclsh

set tty [lindex $argv 0]
set port [open $tty r]
exec stty 38400 cs8 < $tty

set log [open [lindex $argv 1] w]

set stamp [clock clicks -milliseconds]
while {[gets $port line] >= 0} {
   set old $stamp
   set stamp [clock clicks -milliseconds]
   puts $log [format "L %5d %s" [expr {$stamp - $old}] $line]
   puts -nonewline .
   flush stdout
   flush $log
}
