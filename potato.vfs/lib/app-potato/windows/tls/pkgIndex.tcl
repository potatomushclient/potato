package ifneeded tls 1.6.3 \
    "[list source [file join $dir tls.tcl]] ; \
     [list tls::initlib $dir tls163.dll]"
