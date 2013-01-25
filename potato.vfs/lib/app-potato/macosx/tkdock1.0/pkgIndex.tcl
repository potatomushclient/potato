#
# Tcl package index file
#
package ifneeded tkdock 1.0 "
    package require Tk 8.5-
    if {\"AppKit\" ni \[winfo server .\]} {error {TkAqua Cocoa required}}
     load [list [file join $dir libtkdock1.0.dylib]] tkdock"

package ifneeded potato-systray 1.0 [list source [file join $dir potato-systray.tcl]]
