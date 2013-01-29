if { $::tcl_platform(platform) ne "unix" || $::tcl_platform(os) eq "Darwin" } {
     return;
   }

  package ifneeded potato-flash 1.0 [list source [file join $dir potato-flash.tcl]]
