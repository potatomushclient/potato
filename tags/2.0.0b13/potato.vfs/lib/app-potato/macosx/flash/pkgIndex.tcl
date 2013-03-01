if { $::tcl_platform(os) ne "Darwin" } {
     return;
   }

  package ifneeded potato-flash 1.0 [list source [file join $dir potato-flash.tcl]]
