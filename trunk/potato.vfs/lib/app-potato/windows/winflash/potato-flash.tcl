
if { $::tcl_platform(platform) ne "windows" } {
     return;
   }

if { [catch {package require potato-winflash}] } {
tk_messageBox -message "Ack!"
     return;
   }
namespace eval ::potato {}

proc ::potato::flashTaskbar {win} {

  winflash $win -count 3 -appfocus 1

  return;

};# ::potato::flashTaskbar

proc ::potato::unflashTaskbar {win} {

  return;

};# ::potato::unflashTaskbar

package provide potato-flash 1.0
