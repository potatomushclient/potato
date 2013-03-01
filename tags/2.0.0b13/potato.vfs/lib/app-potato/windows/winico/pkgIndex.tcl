if { $::tcl_platform(platform) ne "windows" } {
     return;
   }

  package ifneeded Winico 0.6 [list load [file join $dir Winico06.dll]]
  package ifneeded potato-systray 1.0 [list source [file join $dir potato-systray.tcl]]
