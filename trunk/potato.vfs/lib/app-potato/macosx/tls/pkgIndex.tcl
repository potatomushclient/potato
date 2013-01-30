
if { $::tcl_platform(os) ne "Darwin" } {
     return;
   }

package ifneeded tls 1.6.1     "[list source [file join $dir tls.tcl]] ;      [list tls::initlib $dir libtls1.6.1.dylib]"
