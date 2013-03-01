if { $::tcl_platform(platform) ne "windows" } {
     return;
   }

  package ifneeded potato-winflash 1.0 "[list load [file join $dir flash85.dll] flash] ; package provide potato-winflash 1.0"
  package ifneeded potato-flash 1.0 [list source [file join $dir potato-flash.tcl]]
