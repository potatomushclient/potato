
if { $::tcl_platform(os) ne "Darwin" } {
     return;
   }

if { [catch {wm attributes . -notify}] } {
     return;
   }

proc ::potato::flashTaskbar {win} {

  wm attributes $win -notify 1 -modified 1
  return;

};# ::potato::flashTaskbar

proc ::potato::unflashTaskbar {win} {

  wm attributes $win -notify 0 -modified 0
  return;

};# ::potato::unflashTaskbar

package provide potato-flash 1.0
