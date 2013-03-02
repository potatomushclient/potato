
if { [catch {package require Winico 0.6} err errdict] } {
     ::potato::errorLog "Unable to load Winico: $err" warning [errorTrace $errdict]
     unset -nocomplain err errdict
     return;
   }

set ::potato::systray(mainico) [file join $::potato::path(vfsdir) lib app-potato windows stpotato.ico]
if { ![file exists $::potato::systray(mainico)] } {
     return;
   }


if { [catch {set ::potato::systray(main) [winico createfrom $::potato::systray(mainico)]}] } {
     return;
   }

set ::potato::systray(menu) [menu .systray -tearoff 0]
$::potato::systray(menu) add command -label [::potato::T "Restore"] -command ::potato::winicoRestore
$::potato::systray(menu) add separator
$::potato::systray(menu) add command -label [::potato::T "Hide Icon"] -command ::potato::hideSystrayIcon
$::potato::systray(menu) add separator
$::potato::systray(menu) add command -label [::potato::T "Exit"] -command ::potato::chk_exit

set ::potato::systray(mapped) 0
set ::potato::systray(flashing) 0
set ::potato::systray(pos) 0

#: proc ::potato::hideSystrayIcon
#: desc Turn off the SysTrayIcon otion and hide the Winico icon in the system tray when "Hide" is selected from it's menu.
#: return nothing
proc ::potato::hideSystrayIcon {} {
  variable misc;
  variable systray;

  set misc(showSysTray) 0

  catch {unflashSystray}
  catch {winico taskbar delete $systray(main)}

  return;

};# ::potato::hideSystrayIcon

#: proc ::potato::showSystrayIcon
#: desc Show the sys tray icon on Windows using winico
#: return nothing
proc ::potato::showSystrayIcon {} {
  variable systray;
  variable potato;

  if { $systray(mapped) } {
       return;
     }

  if { [catch {winico taskbar add $systray(main) -text $potato(name) -pos 0 \
                        -callback [list ::potato::winicoCallback %m %x %y]}] } {
       return;
     }

  set systray(mapped) 1

  return;

};# ::potato::showSystrayIcon

#: proc ::potato::flashSystrayIcon
#: desc Flash the winico icon on the taskbar by changing it to another icon and back
#: return nothing
proc ::potato::flashSystrayIcon {{recurse 0}} {
  variable systray;
  variable potato;

  if { $systray(flashing) && !$recurse } {
       return;
     }

  if { $recurse && !$systray(flashing) } {
       return;
     }

  set newpos [lindex [list 1 0] $systray(pos)]
  winico taskbar modify $systray(main) -pos $newpos -text $potato(name)
  set systray(pos) $newpos
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

  if { [info exists systray(after)] } {
       catch {after cancel $systray(after)}
     }
  set systray(pos) 0
  set systray(flashing) 0
  winico taskbar modify $systray(main) -pos 0 -text $potato(name)
  return;

};# ::potato::unflashSystrayIcon

#: proc ::potato::minimizeToSystray
#: desc If $win is a toplevel, and we can minimize to tray, and it's minimized, withdraw $w
#: return nothing
proc ::potato::minimizeToSystray {win} {
  variable systray;
  variable misc;

  if { $win ne [winfo toplevel $win] } {
       return;
     }

  if { !$misc(showSysTray) || !$misc(minToTray) } {
       return;
     }

  if { [wm state $win] ne "iconic" } {
       return;
     }

  # Minimize to tray
  wm withdraw $win

  return;

};# ::potato::minimizeToSystray

#: proc ::potato::winicoCallback
#: arg event The event that triggered the callback
#: arg x X coord of event
#: arg y Y coord of event
#: desc Handle an event on the winico taskbar icon (movement, button click, etc)
#: return nothing
proc ::potato::winicoCallback {event x y} {
  variable systray;

  $systray(menu) unpost
  if { $event eq "WM_LBUTTONUP" } {
       winicoRestore
     } elseif { $event eq "WM_RBUTTONUP" } {
       $systray(menu) post $x $y
       $systray(menu) activate 0
     }

  return;

};# ::potato::winicoCallback

#: proc ::potato::winicoRestore
#: desc Restore the main window when 'Restore' is activated on the winico icon on the taskbar
#: return nothing
proc ::potato::winicoRestore {} {

  wm deiconify .
  raise .
  focus .

  return;

};# ::potato::winicoRestore

package provide potato-systray 1.0
