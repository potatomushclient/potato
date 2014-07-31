
if { $::tcl_platform(platform) ne "unix" } {
     return;
   }

if { [catch {package require potato-linflash}] } {
     # Attempt to copy linflash out for the first time
     catch {file mkdir $::potato::path(userlib)}
     catch {file copy -force [file join $::potato::path(lib) app-potato linux linflash1.0] $::potato::path(userlib)}
     catch {exec [file join $::potato::path(userlib) linflash1.0 compile]}
   }

if { [catch {package require potato-linflash}] } {
     return;
   }

proc ::potato::flashTaskbar {win} {

  if { ![catch {linflash $win} err errdict] || $err eq "" } {
       return;
     } else {
       errorLog "Error in linflash: $err. Falling back to 'wm deiconify' for flashing." [errorTrace $errdict]
       setupFlash 1
       flash .
     }

  return;

};# ::potato::flashTaskbar

proc ::potato::unflashTaskbar {win} {

  linunflash $win
  return;

};# ::potato::unflashTaskbar

package provide potato-flash 1.0
