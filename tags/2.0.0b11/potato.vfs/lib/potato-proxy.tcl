
namespace eval ::potato::proxy {}

package provide potato-proxy 1.2

package require potato-proxy-SOCKS4 1.2
#package require potato-proxy-SOCKS5 1.2
#package require potato-proxy-HTTP 1.2


# Each defined proxy must define the following procedures (where $p is the proxy type):
# ::potato::proxy::$p::connect $fid $host $port - For descriptor $fid, try and negotiate with the $p proxy we're connected to to connect to the MUSH at $host:$port.
# return 1 on success, or -code error $failureMessage on failure (This call is [catch]'d)
