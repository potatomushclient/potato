
namespace eval ::potato::proxy::SOCKS4 {}

#: proc ::potato::proxy::SOCKS4::start
#: arg c connection id
#: arg hostlist Hostlist to connect to
#: desc Start doing SOCKS4 negotiation on connection $c's connection
#: return nothing
proc ::potato::proxy::SOCKS4::start {c hostlist} {
  variable state;
  upvar #0 ::potato::conn conn;
  upvar #0 ::potato::world world;

  set w $conn($c,world)

  set state($c) ""

  set thishost [lindex $hostlist 0]
  set thisport [expr {$thishost eq "host" ? "port" : "port2"}]

  set base "\x04\x01" ;# SOCKS version 4, TCP/IP stream connection
  set port [binary format S $world($w,$thisport)];# MUSH port
  if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $world($w,$thishost)] } {
       # Connect with IP
       set use_ip 1
       set ip [binary format c4 [split $world($w,$thishost) .]]
     } else {
       # Connect with hostname (SOCKS4a)
       set use_ip 0
       set ip [binary format c4 [list 0 0 0 1]]
     }

  # Username would be here, but we don't supply one. \x00 ends username
  set username \x00

  if { !$use_ip } {
       set host $world($w,$thishost)\x00
     } else {
       set host ""
     }
  fconfigure $conn($c,id) -translation binary -eof {} -buffering none

  ::potato::ioWrite -nonewline $conn($c,id) $base$port$ip$username$host
  fileevent $conn($c,id) readable [list ::potato::proxy::SOCKS4::callback $c $hostlist]

  return;

};# ::potato::proxy::SOCKS4::start

#: proc ::potato::proxy::SOCKS4::callback
#: arg c connection id
#: arg hostlist Hostlist to attempt connection to
#: desc A SOCKS4 negotiation string has been sent to connection $c's socket, and now there's some data sent back. Read in as much as we need to, and see if the connection is working. Either way, call a Potato proc to inform it.
#: return nothing
proc ::potato::proxy::SOCKS4::callback {c hostlist} {
  variable state;
  upvar #0 ::potato::conn conn;
  upvar #0 ::potato::world world;

  if { [eof $conn($c,id)] } {
       ::potato::connectVerifyProxyFail $c SOCKS4 $hostlist "Connection closed by proxy server."
       unset state($c)
       return;
     }

  set w $conn($c,world)

  append state($c) [::potato::ioRead $conn($c,id) 1]
  if { [string length $state($c)] != 8 } {
       return;# not all data read yet
     }
  fileevent $conn($c,id) readable {}

  # We have a full response now, check what it says
  set status [string index $state($c) 1]
  if { $status eq "\x5a" } {
       # Success!
       ::potato::connectVerifyComplete $c
       unset state($c)
       return;
     }
  # Failed. Try and give a specific reason why...
  if { $status eq "\x5c" || $status eq "\x5d" } {
       set msg "identd not running/user ID could not be verified"
     } else {
       set thishost [lindex $hostlist 0]
       set thisport [expr {$thishost eq "host" ? "port" : "port2"}]
       set msg "Proxy server rejected request for $world($w,$thishost):$world($w,$thisport)"
     }
  ::potato::connectVerifyProxyFail $c SOCKS4 $hostlist $msg
  unset state($c)
  return;

};# ::potato::proxy::SOCKS4::callback

package provide potato-proxy-SOCKS4 1.1
