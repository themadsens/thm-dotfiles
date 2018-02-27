#!/usr/bin/env tclsh
package require textutil
namespace import textutil::splitx
namespace import tcl::mathfunc::max

array set socks {}

proc testCh {ch} {
  global socks
  read $ch 1
  if {[chan eof $ch]} {
    close $ch
    array unset socks $ch
    if {[array size socks] == 0} {
      puts "Connect to port 10042 to continue"
    }
  }
}

proc serve {channel clientaddr clientport} {
  global socks
  puts "Connection from $clientaddr registered in $channel"
  set socks($channel) [dict create addr $clientaddr port $clientport]
  chan event $channel readable [list testCh $channel]
  if {[array size socks] == 1} { doLine start }
}

set msecs [clock milliseconds]
set tsec 0
set numl 0
set fac 1
proc doLine {verb} {
  global src socks msecs tsec numl fac
  if {$verb == "start"} {
    set msecs [clock milliseconds]
    puts "START $msecs"
  }
  if {[gets $src line] < 0} {
    puts EOF
    exit
  }
  lassign [splitx $line] w1 w2
  set delay 250
  if {[string equal $w1 "L"] && [string is digit $w2]} {
    set delay $w2
    set line [string range $line 8 end]
  }
  incr msecs [expr {$delay / $fac}]
  incr tsec $delay
  incr numl
  if {1 || [string match {[$!][A-Z][A-Z][A-Z][A-Z][A-Z],*} $line]} {
    foreach ch [array names socks] {
      puts $ch $line
      flush $ch
    }
    puts -nonewline [format "\r%s %7.1fs %6dL %8d" [lindex {\\ | / -} [expr {$numl % 4}]] \
                                                   [expr {$tsec / 1000.0}] $numl [tell $src]]
    flush stdout
  }
  if {[array size socks]} {
    after [max [expr {$msecs - [clock milliseconds]}] 0] {doLine line}
  }
}

set src [open [lindex $argv 0]]
if {$argc > 1} {set fac [lindex $argv 1]}
if {$argc > 2} {seek $src [lindex $argv 2]}
socket -server serve 10042
puts "Connect to port 10042 to start"
vwait forever
# vim: set sw=2 ts=2 et:
