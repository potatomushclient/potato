
namespace eval ::potato::proxy {}

package provide potato-proxy 1.1

package require potato-proxy-SOCKS4 1.1
#package require potato-proxy-SOCKS5 1.1
#package require potato-proxy-HTTP 1.1


# Each defined proxy must define the following procedures (where $p is the proxy type):
# ::potato::proxy::$p::start $c $hostlist - For Potato connection $c, start negotiating with the $p proxy we're connected to, to connect to the MUSH. $hostlist is a list of hosts ("host"/"host2") we should attempt to connect to, once the proxy is established.

# When the proxy connection has been negotiated successfully, call ::potato::connectVerifyComplete $c
# If it fails, call ::potato::connectVerifyProxyFail $c $p $hostlist ?$errorMsg? - $errorMsg should describe the problem
# encountered, and defaults to a generic message