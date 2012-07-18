
  set dir [file join [pwd] $dir]; # this really shouldn't be necessary, but apparantly sometimes is.

  package ifneeded app-potato 2.0.0 [list source [file join $dir .. potato.tcl]]
  package ifneeded potato-telnet 1.1 [list source [file join $dir .. potato-telnet.tcl]]
  package ifneeded potato-help 2.0.0 [list source [file join $dir .. potato-help.tcl]]
  package ifneeded potato-wikihelp 2.0.0 [list source [file join $dir .. potato-wikihelp.tcl]]
  package ifneeded potato-skin 2.0.0 [list source [file join $dir .. potato-skin.tcl]]
  package ifneeded potato-font 1.0 [list source [file join $dir .. potato-font.tcl]]
  package ifneeded potato-spell 0.1 [list source [file join $dir .. potato-spell.tcl]]

  package ifneeded potato-proxy-SOCKS4 1.1 [list source [file join $dir .. potato-proxy-SOCKS4.tcl]]
  package ifneeded potato-proxy-SOCKS5 1.1 [list source [file join $dir .. potato-proxy-SOCKS5.tcl]]
  package ifneeded potato-proxy-HTTP 1.1 [list source [file join $dir .. potato-proxy-HTTP.tcl]]
  package ifneeded potato-proxy 1.1 [list source [file join $dir .. potato-proxy.tcl]]

  package ifneeded potato-encoding 1.0 [list source [file join $dir .. potato-encoding.tcl]]

  package ifneeded potato-subfiles 1.0 [list ::potato::loadSubFiles [file join $dir ..]]

  # Windows-specific
  package ifneeded potato-winflash 1.0 "[list load [file join $dir windows flash85.dll]] ; [list source [file join $dir windows potato-winflash.tcl]]"
  package ifneeded Winico 0.6 [list load [file join $dir windows Winico06.dll]]

  if { $::tcl_platform(platform) eq "windows" } {
       package ifneeded tls 1.6 "source \[file join [list $dir] windows tls.tcl\] ; tls::initlib [list [file join $dir windows]] tls16.dll"
     }

  # Linux-specific
  # linflash package no longer inside the executable. Instead, if available, it's in $path(lib)/linflash.
  #package ifneeded potato-linflash 1.0 "[list load [file join $dir linux flash.so flash]] ; [list source [file join $dir linux potato-linflash.tcl]]"

  # This is how $dir expands
  #source {C:/Documents and Settings/User/Desktop/potato-2.0.0b3-win-exe.exe/lib/app-potato/windows/potato-flash.tcl} ; load {C:/Documents and Settings/User/Desktop/potato-2.0.0b3-win-exe.exe/lib/app-potato}
