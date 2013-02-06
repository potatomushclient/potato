
namespace eval ::potato::proxy {}

catch {source [file join [file dirname [info script]] potato-proxy-SOCKS4.tcl]}


# Each defined proxy must define the following procedures (where $p is the proxy type):
# ::potato::proxy::$p::connect $fid $host $port - For descriptor $fid, try and negotiate with the $p proxy we're connected to to connect to the MUSH at $host:$port.
# return 1 on success, or -code error $failureMessage on failure (This call is [catch]'d)
