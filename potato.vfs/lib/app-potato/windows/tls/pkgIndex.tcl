
switch -exact [::potato::checkbits] {
	"32" {package ifneeded tls 1.6.7.1  "[list source [file join $dir tls.tcl]] ;  [list tls::initlib $dir tls1671_32bit.dll]"}
	"64" {package ifneeded tls 1.6.7.1  "[list source [file join $dir tls.tcl]] ;  [list tls::initlib $dir tls1671_64bit.dll]"}
}
