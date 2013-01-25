
if { [catch {package require tkdock 1.0} err errdict] } {
     errorLog "Unable to load tkdock: $err" warning [errorTrace $errdict]
     unset -nocomplain err errdict
     return;
   }

set ::potato::systray(flashing) 0
set ::potato::systray(pos) 0
set ::potato::systray(flashicon) [file join $::potato::path(lib) app-potato macosx warning.icns]

if { ![file exists $::potato::systray(flashicon)] } {
     return;
   }


#: proc ::potato::flashSystrayIcon
#: desc Flash the winico icon on the taskbar by changing it to another icon and back
#: return nothing
proc ::potato::flashSystrayIcon {{recurse 0}} {
  variable systray;
  variable path;

  if { $systray(flashing) && !$recurse } {
       return;
     }

  if { $recurse && !$systray(flashing) } {
       return;
     }

  set systray(pos) [lindex [list 1 0] $systray(pos)]
  if { $systray(pos) } {
       tkdock::switchIcon $systray(flashicon)
     } else {
       tkdock::origIcon
     }
  set systray(after) [after 750 [namespace which [lindex [info level 0] 0]] 1]
  set systray(flashing) 1
  return;

};# ::potato::flashSystrayIcon

#: proc ::potato::unflashSystrayIcon
#: desc Stop the winico icon on the taskbar from flashing by resetting to the default icon and cancelling the flash
#: return nothing
proc ::potato::unflashSystrayIcon {} {
  variable systray;
  variable potato;

  catch {after cancel $systray(after)}
  set systray(pos) 0
  set systray(flashing) 0
  tkdock::origIcon

  return;

};# ::potato::unflashSystrayIcon


package provide potato-systray 1.0
