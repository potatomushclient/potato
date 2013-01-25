
  # Commenting this out in the hopes that whatever caused it to be necessary is now gone.
  #set dir [file join [pwd] $dir]; # this really shouldn't be necessary, but apparantly sometimes is.

  package ifneeded app-potato 2.0.0 [list source [file join $dir .. potato.tcl]]
  package ifneeded potato-telnet 1.1 [list source [file join $dir .. potato-telnet.tcl]]
  package ifneeded potato-help 2.0.0 [list source [file join $dir .. potato-help.tcl]]
  package ifneeded potato-wikihelp 2.0.0 [list source [file join $dir .. potato-wikihelp.tcl]]
  package ifneeded potato-skin 2.0.0 [list source [file join $dir .. potato-skin.tcl]]
  package ifneeded potato-font 1.0 [list source [file join $dir .. potato-font.tcl]]
  package ifneeded potato-spell 0.1 [list source [file join $dir .. potato-spell.tcl]]

  package ifneeded potato-proxy-SOCKS4 1.2 [list source [file join $dir .. potato-proxy-SOCKS4.tcl]]
  package ifneeded potato-proxy-SOCKS5 1.2 [list source [file join $dir .. potato-proxy-SOCKS5.tcl]]
  package ifneeded potato-proxy-HTTP 1.2 [list source [file join $dir .. potato-proxy-HTTP.tcl]]
  package ifneeded potato-proxy 1.2 [list source [file join $dir .. potato-proxy.tcl]]

  package ifneeded potato-encoding 1.0 [list source [file join $dir .. potato-encoding.tcl]]

  package ifneeded potato-subfiles 1.0 [list ::potato::loadSubFiles [file join $dir ..]]
