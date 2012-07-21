
namespace eval ::potato::proxy::SOCKS4 {}

#: proc ::potato::proxy::SOCKS4::connect
#: arg fid file descriptor
#: arg host
#: arg port
#: desc Start doing SOCKS4 negotiation on connection $fid to $host:$port
#: return 1 on success, -code error with failure message on failure
proc ::potato::proxy::SOCKS4::connect {fid host port} {
  variable state;
  variable succ;

  set state($fid) ""
  unset -nocomplain succ($fid)

  set base "\x04\x01" ;# SOCKS version 4, TCP/IP stream connection
  set xport [binary format S $port];# MUSH port
  if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $host] } {
       # Connect with IP
       set use_ip 1
       set ip [binary format c4 [split $host .]]
     } else {
       # Connect with hostname (SOCKS4a)
       set use_ip 0
       set ip [binary format c4 [list 0 0 0 1]]
     }

  # Username would be here, but we don't supply one. \x00 ends username
  set username \x00

  if { !$use_ip } {
       set xhost $host\x00
     } else {
       set xhost ""
     }
  fconfigure $fid -translation binary -eof {} -buffering none

  ::potato::ioWrite -nonewline $fid $base$xport$ip$username$xhost

  set waitfor "[namespace which -variable succ]($fid)"
  fileevent $fid readable [list ::potato::proxy::SOCKS4::callback $fid $host $port $waitfor]
  vwait $waitfor

  if { [info exists $waitfor] } {
       set res [set $waitfor]
       unset $waitfor
     } else {
       set res "Unknown error"
     }
  if { $res eq "" } {
       return 1;
     } else {
       return -code error $res;
     }

};# ::potato::proxy::SOCKS4::connect

#: proc ::potato::proxy::SOCKS4::callback
#: arg fid
#: arg host
#: arg port
#: arg resvar
#: desc A SOCKS4 negotiation string has been sent to file descriptor $fid, and now there's some data sent back. Read in as much as we need to, and see if the connection is working.
#: return nothing
proc ::potato::proxy::SOCKS4::callback {fid host port resvar} {
  variable state;

  if { [eof $fid] } {
       unset state($fid)
       set $resvar [::potato::T "Connection closed by proxy server."]
       return;
     }

  append state($fid) [::potato::ioRead $fid 1]
  if { [string length $state($fid)] != 8 } {
       return;# not all data read yet
     }
  fileevent $fid readable {}

  # We have a full response now, check what it says
  set status [string index $state($fid) 1]
  if { $status eq "\x5a" } {
       # Success!
       unset state($fid)
       set $resvar ""
       return;
     }
  # Failed. Try and give a specific reason why...
  unset state($fid)
  if { $status eq "\x5c" || $status eq "\x5d" } {
       set $restvar [::potato::T "identd not running/user ID could not be verified"]
     } else {
       set $resvar [::potato::T "Proxy server rejected request for %s:%d" $host $port]
     }
  return;

};# ::potato::proxy::SOCKS4::callback

package provide potato-proxy-SOCKS4 1.2
