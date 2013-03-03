if { $::tcl_platform(platform) ne "windows" } {
     return;
   }

package ifneeded tls 1.6.3 \
    "[list source [file join $dir tls.tcl]] ; \
     [list tls::initlib $dir tls163.dll]"
