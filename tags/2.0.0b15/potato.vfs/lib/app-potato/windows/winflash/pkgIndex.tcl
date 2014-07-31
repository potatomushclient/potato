if { $::tcl_platform(platform) ne "windows" } {
     return;
   }

  package ifneeded potato-winflash 1.1 [list source [file join $dir potato-winflash.tcl]]
  package ifneeded potato-flash 1.0 [list source [file join $dir potato-flash.tcl]]
