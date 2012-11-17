package provide app-potato 2.0.0

namespace eval ::potato {}
namespace eval ::potato::img {}
namespace eval ::skin {}

#: proc ::potato::loadWorlds
#: desc load all the stored world info from the files
#: return number of worlds loaded
proc ::potato::loadWorlds {} {
  variable potato;
  variable world;
  variable path;

  set files [glob -nocomplain -dir $path(world) *.wld]

  # "World Loaded Successfully" should NOT be translated.
  if { [llength $files] != 0 } {
       foreach x [lsort -dictionary $files] {
         unset -nocomplain newWorld
         if { ![catch {source $x} return errdict] && [lrange [split $return " "] 0 2] eq [list World Loaded Successfully] } {
              set w $potato(worlds)
              incr potato(worlds)
              foreach opt [array names newWorld] {
                 set world($w,$opt) $newWorld($opt)
              }
              set world($w,id) $w
              manageWorldVersion $w [lindex [split $return " "] 3]
            } else {
              !set errdict [list]
              errorLog "Unable to load world file \"[file nativename [file normalize $x]]\": $return" error [errorTrace $errdict]
            }
       }
     }

  foreach w [concat -1 [worldIDs]] {
    loadWorldDefaults $w 0
  }
  return $potato(worlds);

};# ::potato::loadWorlds

#: proc ::potato::manageWorldVersion
#: arg w world id
#: arg version The version of the world file, or an empty string if none was present (ie, the world file pre-dates versions)
#: desc World $w was loaded from a version $version world file; make any changes necessary to bring it up to date with a current world file.
#: return nothing
proc ::potato::manageWorldVersion {w version} {
  variable world;

  array set wf [worldFlags];# array of all current world flags

  if { ![string is integer -strict $version] } {
       set version 0
     }

  if { ! ($version & $wf(verbose_mu_type)) } {
       set world($w,type) [lindex [list MUD MUSH] $world($w,type)]
     }

  if { ! ($version & $wf(new_encoding)) } {
       if { [info exists world($w,unicode)] } {
            if { $world($w,unicode) == 1 } {
                 set world($w,encoding,negotiate) 0
               }
            unset -nocomplain world($w,unicode)
          }
     }

  if { ! ($version & $wf(many_chars)) } {
       set world($w,charList) [list]
       if { [info exists world($w,charName)] && $world($w,charName) ne "" } {
            !set world($w,charPass) ""
            lappend world($w,charList) [list $world($w,charName) $world($w,charPass)]
          }
       unset -nocomplain world($w,charName) world($w,charPass)
    }


  ### Somewhat separate from the above
  if { ($version & $wf(obfusticated_pw)) && [llength $world($w,charList)] } {
       # Un-obfusticate the passwords, for actual use. It will be re-obfusticated on save.
       # NOTE: By the time we get here, we always have many_chars
       set newCharList [list]
       foreach x $world($w,charList) {
         set char [lindex $x 0]
         set pw [lindex $x 1]
         if { !($version & $wf(fixed_obfusticate)) } {
              lappend newCharList [list $char [obfusticate $pw -1]]
            } else {
              lappend newCharList [list $char [obfusticate $pw 0]]
            }
       }
       set world($w,charList) $newCharList
     }

  if { ! ($version & $wf(event_noactivity)) } {
       foreach x [array names world $w,events,*,pattern] {
         set x [string range $x 0 end-8]
         if { ![info exists world($x,noActivity)] } {
              set world($x,noActivity) 0
            }
       }
     }

  if { !($version & $wf(prefixes_list)) } {
       !set world($w,prefixes) [list]
       foreach x [removePrefix [arraySubelem world $w,prefixes] $w,prefixes] {
         lappend world($w,prefixes) [list $x {*}$world($w,prefixes,$x)]
         unset world($w,prefixes,$x)
       }
     }

  set maplist [list "\[" "\\\[" "\]" "\\\]" \
                    "%0" {[/get 0]} "%1" {[/get 1]} "%2" {[/get 2]} \
                    "%3" {[/get 3]} "%4" {[/get 4]} "%5" {[/get 5]} \
                    "%6" {[/get 6]} "%7" {[/get 7]} "%8" {[/get 8]} \
                    "%9" {[/get 9]} \
              ]
  if { !($version & $wf(new_slash_cmds)) } {
       foreach x [arraySubelem world $w,events] {
         foreach y [list "input,string" "send"] {
           if { [info exists world($x,$y)] && [regexp {%[0-9]} $world($x,$y)] } {
                if { [string match "/*" $world($x,$y)] || [string match {%[0-9]} $world($x,$y)] } {
                     set world($x,$y) [string map $maplist $world($x,$y)]
                   } else {
                     set world($x,$y) "\[[string map $maplist $world($x,$y)]\]"
                   }
              }
         }
       }
     }

  # Example:
  # if { ! ($version & $wf(some_new_feature)) } {
  #      set world($w,new_features_var) foobar
  #    }

  return;

};# potato::manageWorldVersion

#: proc ::potato::loadWorldDefaults
#: arg w world id
#: arg override Override currently set options with defaults?
#: desc Set default settings for any options not set in world $w. If $override is true, override already-set options with defaults, too.
#: return nothing
proc ::potato::loadWorldDefaults {w override} {
  variable world;

  # Options we don't copy. This is a list of option name wildcard patterns.
  set nocopyPatterns [list *,font,created id *,fcmd,* events events,* timer timer,* groups slashcmd slashcmd,* macro,*]

  # Load preset defaults for these, don't copy from world -1. This is a list of optionName optionDefault pairs.
  # All of these should also be matched by nocopyPatterns above.
  set standardDefaults [list fcmd,2 {} fcmd,3 {} fcmd,4 {} fcmd,5 {} fcmd,6 {} fcmd,7 {} fcmd,8 {} \
                             fcmd,9 {} fcmd,10 {} fcmd,11 {} fcmd,12 {} \
                             events {} groups [list] slashcmd [list]]

  if { $w != -1 } {
       foreach optFromArr [array names world -1,*] {
         set opt [string range $optFromArr 3 end]
         set copy 1
         if { !$override && [info exists world($w,$opt)] } {
              continue;
            }
         foreach nocopy $nocopyPatterns {
           if { [string match $nocopy $opt] } {
                set copy 0
                break;
              }
           }
         if { !$copy } {
              continue;
            }
         set world($w,$opt) $world(-1,$opt)
       }
     }

  foreach {opt default} $standardDefaults {
    if { $override || ![info exists world($w,$opt)] } {
         set world($w,$opt) $default
       }
  }

  if { [info exists world($w,events)] } {
       foreach x $world($w,events) {
         foreach {opt def} [list matchAll 0 replace 0 "replace,with" "" name ""] {
           if { ![info exists world($w,events,$x,$opt)] } {
                set world($w,events,$x,$opt) $def
              }
         }
       }
     }

  return;

};# ::potato::loadWorldDefaults

#: proc ::potato::saveWorlds
#: desc save all the stored worlds to disk
#: return 1 on success, 0 on failure
proc ::potato::saveWorlds {} {
  variable world;
  variable path;
  variable potato;

  set make [catch {file mkdir $path(world)}]
  if { $make || ![file exists $path(world)] || ![file isdirectory $path(world)] } {
       tk_messageBox -icon error -parent . -type ok -title $potato(name) \
                     -message [T "Unable to save world info: directory does not exist."]
       return 0;
     }

  foreach x [glob -nocomplain -dir $path(world) *.wld] {
     catch {file delete $x}
  }

  # Generate sorted list of world ids.
  foreach w [worldIDs] {
     lappend temp [list $w $world($w,name)]
  }
  if { ![info exists temp] } {
       return;# no worlds to save
     }
  set temp [lsort -index 1 -dictionary $temp]

  set i 0
  foreach x $temp {
     set w [lindex $x 0]
     if { $world($w,temp) } {
          continue;
        }
     if { [catch {open [file join $path(world) [format "world%02d.wld" $i]] w+} fid] } {
           tk_messageBox -icon error -parent . -type ok -title $potato(name) \
                  -message [T "Unable to save world '%s': %s" $world($w,name) $fid]
           continue;
        }
     puts $fid "# $world($w,name) - $world($w,host):$world($w,port)\n"
     foreach y [lsort -dictionary [array names world $w,*]] {
        scan $y $w,%s opt
        if { $opt eq "top,font,created" || $opt eq "bottom,font,created" || \
             $opt eq "id" || [string match nosave,* $opt] } {
             continue;
           }
        set value $world($w,$opt)
        if { $opt eq "charList" && [llength $world($w,$opt)] } {
             # Obfusticate!
             set value [list]
             foreach x $world($w,$opt) {
               set char [lindex $x 0]
               set pw [lindex $x 1]
               lappend value [list $char [obfusticate $pw 1]]
             }
           }
        puts $fid [list set newWorld($opt) $value]
     }
     # This should NOT be translated
     puts $fid [list return "World Loaded Successfully [worldFlags 1]"]
     close $fid
     incr i
  }

  return 1;

};# ::potato::saveWorlds

#: proc ::potato::obfusticate
#: arg str string to [de]obfusticate
#: arg dir if 1, obfusticate a string. If 0, reverse obfustication.
#: desc Obfusticate a string (or remove obfustication). Used for saving/reading passwords. This is only obfustication, not encryption, but that's about all you can do in an open-source project.
#: return modified $str
proc ::potato::obfusticate {str dir} {

  # For un-obfusticating old, broken passwords.
  set map-1 {5 B f 7 w S L I i 6 2 D + p X V Q Y t u / N e ! x v b P k F c { } 1 d z Z - W 9 , g q s T y l H . m A $ 4 r K ? 8 R C E * o M 3 = G 0 O J j h a n G U # ? 4 z I j V a n 1 q o Z e d w h H = O U b F i . k ! s S R D Q 6 c l / C $ B f T L W + P t , m N y v 2 8 - J 9 p r A x * E 0 X K 5 u 3 Y g 7 M}

  set map1 [list _ z p 5 E c 3 q J S b F q _ z T i K B h L Q u W + t 4 E g n D w U O w + M - 6 6 n 1 2 r l b y L Q 8 Z o I R V 3 . 7 7 f R x f j C s h N A G H D - u c / = C N p F X 8 A O J e P 0 k a 2 k H o Z K Y v g W y Y V / U T 4 s m d i P d S . m 9 5 B 9 M j e r l X 0 1 = x I G v t a]

  set map0 [list]
  foreach {x y} $map1 {
    lappend map0 $y $x
  }

  return [string map [set map$dir] $str];

};# ::potato::obfusticate

#: proc ::potato::worldFlags
#: arg total Return a total of the flags, instead of a list of name/value pairs? Defaults to 0
#: desc Return a list (suitable for [array set]) of name/value pairs of world flags, used in the world config file. If $total is true, return the total of all flags instead.
#: return list of name/value pairs, or total of all flags
proc ::potato::worldFlags {{total 0}} {

  set f(has_world_flags)     1    ;# world file uses flags
  set f(verbose_mu_type)     2    ;# Uses "MUD" and "MUSH" (not 0 and 1) for world($w,type)
  set f(new_encoding)        4    ;# Has the new $w,encoding,* options in place of $w,unicode
  set f(obfusticated_pw)     8    ;# Passwords are obfusticated
  set f(many_chars)         16    ;# World has multiple characters in $world($w,charList) as [list [list name pw] [list name pw]], not $world($w,charName) and $world($w,charPass)
  set f(event_noactivity)   32    ;# Events have a noActivity option
# These two are obsolete, but not reused temporarily for the benefit of anyone using SVN.
#  set f(event_matchall)    64    ;# Events have a matchAll option
#  set f(event_replace)    128    ;# Events have replace / replace,with
  set f(fixed_obfusticate) 256    ;# Password obfustication was broken. Like, really broken.
  set f(prefixes_list)     512    ;# Prefixes are stored in a single list, instead of an array
  set f(new_slash_cmds)   1024    ;# new, nestable /commands, and events using [/get 0] instead of %0
  if { !$total } {
       return [array get f];
     } else {
       set num 0
       foreach x [array names f] {
         set num [expr {$num | $f($x)}]
       }
       return $num;
     }

};# ::potato::worldFlags

#: proc ::potato::prefixWindow
#: arg w world id. Defaults to "".
#: desc Show the window for configuring Prefixes (Auto-Says) for world $w, or the world of the currently displayed connection's world if $c is "".
#: return nothing
proc ::potato::prefixWindow {{w ""}} {
  variable conn;
  variable world;
  variable prefixWindow

  if { $w eq "" } {
       set w $conn([up],world)
     }

  set win .prefixWin$w
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  if { $w == -1 } {
       set title [T "Global Prefixes"]
       set message [T "Set auto-prefixes to apply for all worlds below."]
     } else {
       set title [T "Prefixes for %s" $world($w,name)]
       set message [T "Set auto-prefixes to apply for %s below." $world($w,name)]
     }

  toplevel $win
  wm title $win $title

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both
  pack [label $frame.l -text $message] -side top -anchor n -pady 8

  pack [set sub [::ttk::frame $frame.treeframe]] -expand 1 -fill both -padx 10 -pady 8
  set tree [::ttk::treeview $sub.tree -columns [list Window Prefix] -show [list tree headings] -selectmode browse]
  set sbX [::ttk::scrollbar $sub.sbX -orient horizontal -command [list $tree xview]]
  set sbY [::ttk::scrollbar $sub.sbY -orient vertical -command [list $tree yview]]
  grid_with_scrollbars $tree $sbX $sbY
  $tree configure -xscrollcommand [list $sbX set]
  $tree configure -yscrollcommand [list $sbY set]

  set prefixWindow($w,path,tree) $tree

  $tree column #0  -width 70 -stretch 0 -anchor center
  $tree column Window -width 90 -stretch 1 -anchor e
  $tree column Prefix -width 250 -stretch 1 -anchor w
  $tree heading #0 -text [T "Enabled?"]
  $tree heading Window -text "   [T "Window"]   "
  $tree heading Prefix -text "   [T "Prefix"]   " -anchor w

  $tree tag bind on <Button-1> [list ::potato::prefixWindowToggle $w 1 %x %y]
  $tree tag bind off <Button-1> [list ::potato::prefixWindowToggle $w 0 %x %y]

  # Display prefixes
  prefixWindowUpdate $w

  if { [llength [$tree children {}]] } {
       set first [lindex [$tree children {}] 0]
       $tree selection set $first
       $tree focus $first
       set state "!disabled"
     } else {
       set state "disabled"
     }

  pack [set sub [::ttk::frame $frame.addedit]] -expand 1 -fill y -side top -anchor nw -padx 20 -pady 8
  pack [set prefixWindow($w,path,aewindow) [::ttk::entry $sub.window -textvariable ::potato::prefixWindow($w,ae,window)]] -side left -padx 5
  pack [set prefixWindow($w,path,aeprefix) [::ttk::entry $sub.prefix -textvariable ::potato::prefixWindow($w,ae,prefix)]] -side left -padx 5
  pack [set prefixWindow($w,path,aeadd)    [::ttk::button $sub.add -text [T "Save"] -command [list ::potato::prefixWindowSave $w]]] -side left -padx 5
  pack [set prefixWindow($w,path,aecancel) [::ttk::button $sub.cancel -text [T "Cancel"] -command [list ::potato::prefixWindowCancel $w]]] -side left -padx 5

  foreach x [array names prefixWindow $w,path,ae*] {
    $prefixWindow($x) state disabled
  }

  menu $win.m -tearoff 0
  $win configure -menu $win.m
  menu $win.m.prefix -tearoff 0 -postcommand [list ::potato::prefixWindowPostMenu $w]
  set prefixWindow($w,path,menu) $win.m.prefix
  $win.m add cascade {*}[menu_label [T "&Prefix..."]] -menu $win.m.prefix
  $win.m.prefix add command {*}[menu_label [T "&Add New Prefix"]] -command [list ::potato::prefixWindowAdd $w]
  $win.m.prefix add command {*}[menu_label [T "&Edit Prefix"]] -command [list ::potato::prefixWindowEdit $w]
  $win.m.prefix add command {*}[menu_label [T "&Delete Prefix"]] -command [list ::potato::prefixWindowDelete $w]
  $win.m.prefix add command {*}[menu_label [T "&Cancel Add/Edit"]] -command [list ::potato::prefixWindowCancel $w]
  $win.m.prefix add separator
  $win.m.prefix add command {*}[menu_label [T "C&lose Window"]] -command [list destroy $win]

  bind $win <Destroy> [list array unset ::potato::prefixWindow $w,*]

  return;

};# ::potato::prefixWindow

#: proc ::potato::prefixWindowCancel
#: arg w world id
#: desc Cancel add/editing a prefix in $w's prefix window.
#: return nothing
proc ::potato::prefixWindowCancel {w} {
  variable prefixWindow;

  $prefixWindow($w,path,aewindow) delete 0 end
  $prefixWindow($w,path,aeprefix) delete 0 end
  $prefixWindow($w,path,tree) state !disabled
  foreach x [list window prefix add cancel] {
    $prefixWindow($w,path,ae$x) state disabled
  }

  return;

};# ::potato::prefixWindowCancel

#: proc ::potato::prefixWindowUpdate
#: arg w world id
#: arg sel the tag to select. Defaults to "" for none.
#: desc Update the tree of prefixes in world $w's Prefix Window from the vars. Set selection to $sel
#: return nothing
proc ::potato::prefixWindowUpdate {w {sel ""}} {
  variable world;
  variable prefixWindow;

  set tree $prefixWindow($w,path,tree)
  $tree state !disabled

  $tree delete [$tree children {}]

  set list [lsort -index 0 $world($w,prefixes)]
  set states [list off on]
  set images [list ::potato::img::cb-unticked ::potato::img::cb-ticked]
  foreach x $list {
    foreach {window prefix enabled} $x {break}
    $tree insert {} end -id $window -values [list $window [string map [list " " \u00b7] $prefix]] \
                        -tags [list [lindex $states $enabled]] \
                        -image [list [lindex $images $enabled]]
  }
  if { $sel ne "" } {
       $tree selection set $sel
       $tree focus $sel
     }

  return;

};# ::potato::prefixWindowUpdate

#: proc ::potato::prefixWindowToggle
#: arg w world id
#: arg state Current state; enabled (1) or disabled (0)
#: arg x x-coord
#: arg y y-coord
#: desc Toggle the state of the currently selected item if we're clicking on the Enabled (tree) column
#: return nothing
proc ::potato::prefixWindowToggle {w state x y} {
  variable prefixWindow;
  variable world;

  set tree $prefixWindow($w,path,tree)
  if { [$tree instate disabled] } {
       return;# Very, very annoying. Bah at whoever didn't make disabled Treeviews work right.
     }
  set sel [lindex [$tree selection] 0]
  if { $sel eq "" } {
       return;
     }
  if { [lindex [$tree identify $x $y] 0] eq "item" } {
       # Close enough!
       set tags [list on off]
       set images [list ::potato::img::cb-ticked ::potato::img::cb-unticked]
       set newstates [list 1 0]
       $tree item $sel -tags [list [lindex $tags $state]] -image [lindex $images $state]
       set pos [lsearch -exact -index 0 $world($w,prefixes) $sel]
       set item [lindex $world($w,prefixes) $pos]
       set item [lreplace $item 2 2 [lindex $newstates $state]]
       set world($w,prefixes) [lreplace $world($w,prefixes) $pos $pos $item]
     }

  return;

};# ::potato::prefixWindowToggle

#: proc ::potato::prefixWindowSave
#: arg w world id
#: desc Save the new (or edited) prefix in world $w's prefix window
#: return nothing
proc ::potato::prefixWindowSave {w} {
  variable prefixWindow;
  variable world;
  variable potato;

  set toplevel [winfo toplevel $prefixWindow($w,path,aewindow)]

  set window [$prefixWindow($w,path,aewindow) get]
  set prefix [$prefixWindow($w,path,aeprefix) get]
  # Validate window name
  if { [set window [validSpawnName $window 0]] eq "" || $window eq "_none" } {
        tk_messageBox -icon error -parent $toplevel -title [T "Prefixes"] \
                      -message [T "Invalid window name."]
        return;
     }

  set existing [lsearch -exact -index 0 $world($w,prefixes) $window]

  if { $existing != -1 && $window ne $prefixWindow($w,editing) } {
       set ans [tk_messageBox -icon error -parent $toplevel -title [T "Prefixes"] -type yesno \
                     -message [T "There is already a prefix for \"%s\". Override?" $window]]
       if { $ans ne "yes" } {
            return;
          }
       set world($w,prefixes) [lreplace $world($w,prefixes) $existing $existing]
     }

  set editing [lsearch -exact -index 0 $world($w,prefixes) $prefixWindow($w,editing)]

  if { $editing != -1 } {
       set state [lindex [lindex $world($w,prefixes) $editing] 2]
       set world($w,prefixes) [lreplace $world($w,prefixes) $editing $editing]
     } else {
       set state 1
     }
  if { $prefix ne "" } {
       lappend world($w,prefixes) [list $window $prefix $state]
     }

  $prefixWindow($w,path,aewindow) delete 0 end
  $prefixWindow($w,path,aeprefix) delete 0 end

  foreach x [list window prefix add cancel] {
    $prefixWindow($w,path,ae$x) state disabled
  }

  prefixWindowUpdate $w $window

  return;

};# ::potato::prefixWindowSave

#: proc ::potato::prefixWindowDelete
#: arg w world id
#: desc Delete the currently selected prefix in world $w's prefix window
#: return nothing
proc ::potato::prefixWindowDelete {w} {
  variable prefixWindow;
  variable world;

  set sel [lindex [$prefixWindow($w,path,tree) sel] 0]
  if { $sel eq "" } {
       return;
     }

  set pos [lsearch -exact -nocase -index 0 $world($w,prefixes) $sel]
  if { $pos != -1 } {
       set world($w,prefixes) [lreplace $world($w,prefixes) $pos $pos]
     }

  prefixWindowUpdate $w

  return;

};# ::potato::prefixWindowDelete

#: proc ::potato::prefixWindowAdd
#: arg w world id
#: desc Add a new prefix in world $w's prefix window
#: return nothing
proc ::potato::prefixWindowAdd {w} {
  variable prefixWindow;

  $prefixWindow($w,path,tree) state disabled
  foreach x [list window prefix add cancel] {
    $prefixWindow($w,path,ae$x) state !disabled
  }
  set prefixWindow($w,editing) ""
  focus $prefixWindow($w,path,aewindow)

  return;

};# ::potato::prefixWindowAdd

#: proc ::potato::prefixWindowEdit
#: arg w world id
#: desc Edit the currently selected prefix for world $w's prefix window
#: return nothing
proc ::potato::prefixWindowEdit {w} {
  variable prefixWindow;
  variable world;

  set tree $prefixWindow($w,path,tree)
  set sel [lindex [$tree selection] 0]
  if { $sel eq "" } {
       return;
     }
  $tree state disabled
  foreach x [list window prefix add cancel] {
    $prefixWindow($w,path,ae$x) state !disabled
  }
  $prefixWindow($w,path,aewindow) insert end $sel
  set pos [lsearch -exact -index 0 $world($w,prefixes) $sel]
  if { $pos != -1 } {
       $prefixWindow($w,path,aeprefix) insert end [lindex [lindex $world($w,prefixes) $pos] 1]
     }
  set prefixWindow($w,editing) $sel
  focus $prefixWindow($w,path,aewindow)

  return;

};# ::potato::prefixWindowEdit

#: proc ::potato::prefixWindowPostMenu
#: arg w world id
#: desc Configure menu item states when menu is posted
#: return nothing
proc ::potato::prefixWindowPostMenu {w} {
  variable prefixWindow;

  set m $prefixWindow($w,path,menu)
  if { [$prefixWindow($w,path,aecancel) instate !disabled] } {
       $m entryconfigure 0 -state disabled
       $m entryconfigure 1 -state disabled
       $m entryconfigure 2 -state disabled
       $m entryconfigure 3 -state normal
     } elseif { [llength [$prefixWindow($w,path,tree) children {}]] } {
       $m entryconfigure 0 -state normal
       $m entryconfigure 1 -state normal
       $m entryconfigure 2 -state normal
       $m entryconfigure 3 -state disabled
     } else {
       $m entryconfigure 0 -state normal
       $m entryconfigure 1 -state disabled
       $m entryconfigure 2 -state disabled
       $m entryconfigure 3 -state disabled
     }

  return;

};# ::potato::prefixWindowPostMenu

#: proc ::potato::mailWindow
#: arg c connection id. Defaults to "".
#: desc Show a "send mail" window for connection $c, or the currently displayed connection if $c is ""
#: return nothing
proc ::potato::mailWindow {{c ""}} {
  variable conn;
  variable world;
  variable gameMail;

  if { $c eq "" } {
       set c [up]
     }
  if { $c == 0 } {
       bell -displayof .
       return;
     }
  set win .mailWindow$c
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }
  toplevel $win
  wm withdraw $win
  registerWindow $c $win

  set w $conn($c,world)

  wm title $win [T "Send Mail - \[%d. %s\]" $c $world($w,name)]

  set menu [menu $win.m -tearoff 0]
  $win configure -menu $menu
  $menu add cascade -menu [set fileMenu [menu $menu.file -tearoff 0]] {*}[menu_label [T "&File"]]
  $menu add cascade -menu [set editMenu [menu $menu.edit -tearoff 0]] {*}[menu_label [T "&Edit"]]

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both

  pack [set to [::ttk::frame $frame.to]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $to.l -text [T "Recipient:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $to.e -textvariable ::potato::conn($c,mailWindow,to) -width 40] -side left -anchor nw -fill x

  pack [set cc [::ttk::frame $frame.cc]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $cc.l -text [T "CC:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $cc.e -textvariable ::potato::conn($c,mailWindow,cc) -width 40] -side left -anchor nw -fill x

  pack [set bcc [::ttk::frame $frame.bcc]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $bcc.l -text [T "BCC:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $bcc.e -textvariable ::potato::conn($c,mailWindow,bcc) -width 40] -side left -anchor nw -fill x

  pack [set subject [::ttk::frame $frame.subject]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $subject.l -text [T "Subject:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $subject.e -textvariable ::potato::conn($c,mailWindow,subject) -width 40] \
      -side left -anchor nw -fill x

  foreach x [list to cc bcc subject] {
    set conn($c,mailWindow,$x) ""
    set conn($c,mailWindow,${x}Widget) "[set $x].e"
  }

  set formats [array names gameMail]
  lappend formats "Custom"
  pack [set format [::ttk::frame $frame.format]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $format.l -text [T "Format:"] -width 10] -side left -anchor nw
  pack [::ttk::combobox $format.cb -justify left -state normal -width 40 \
               -textvariable ::potato::conn($c,mailWindow,format) \
               -values $formats -state readonly] -side left -anchor nw -fill x
  set ::potato::conn($c,mailWindow,format) $world($w,mailFormat)
  set ::potato::conn($c,mailWindow,formatWidget) $format.cb

  pack [set custom [::ttk::frame $frame.custom]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $custom.l -text [T "Custom:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $custom.e -textvariable ::potato::conn($c,mailWindow,custom) -width 40 -validate focusout \
                               -validatecommand [list ::potato::mailWindowFormatChange $c]] \
     -side left -anchor nw -fill x
  set conn($c,mailWindow,custom) $world($w,mailFormat,custom)
  set conn($c,mailWindow,customWidget) $custom.e
  if { $conn($c,mailWindow,format) ne "Custom" } {
       $custom.e state disabled
     }

  bind $format.cb <<ComboboxSelected>> [list ::potato::mailWindowFormatChange $c]

  pack [set txt [::ttk::frame $frame.txt]] -side top -anchor nw -expand 1 -fill both -padx 5 -pady 3
  pack [set textWidget [text $txt.t -height 12 -width 40 -wrap word -background white -foreground black \
             -font TkFixedFont -yscrollcommand [list $txt.sb set] -undo 1]] -expand 1 -fill both -side left -anchor nw
  pack [::ttk::scrollbar $txt.sb -orient vertical -command [list $txt.t yview]] -side left -anchor nw -fill y -padx 3
  set conn($c,mailWindow,bodyWidget) $txt.t

  pack [set convert [::ttk::frame $frame.convert]] -side top -anchor n -padx 5 -pady 8
  pack [::ttk::label $convert.l -text [T "Convert returns?"]] -side left -anchor nw -padx 3
  pack [::ttk::checkbutton $convert.cb -variable ::potato::world($w,mailConvertReturns)] -side left -anchor nw -padx 3
  pack [::ttk::label $convert.l2 -text [T "Convert To:"]] -side left -anchor nw -padx 3
  pack [::ttk::entry $convert.e -width 5 -textvariable ::potato::world($w,mailConvertReturns,to)] -side left -anchor nw -padx 3
  pack [set btns [::ttk::frame $frame.btns]] -side top -anchor n -padx 5 -pady 8
  pack [::ttk::button $btns.ok -text [T "Send"] -width 8 -default active \
             -command [list ::potato::mailWindowSend $c $win]] -side left -padx 8
  pack [::ttk::button $btns.cancel -text [T "Cancel"] -width 8 -command [list destroy $win]] -side left -padx 8

  $fileMenu add command {*}[menu_label [T "&Escape Special Characters"]] -command [list ::potato::escapeChars $textWidget]

  bind $win <Escape> [list $btns.cancel invoke]
  bind $win <Destroy> [list ::potato::mailWindowCleanup $c]

  $editMenu add command {*}[menu_label [T "&Copy"]] -command [list event generate $textWidget <<Copy>>] -accelerator Ctrl+C
  $editMenu add command {*}[menu_label [T "C&ut"]] -command [list event generate $textWidget <<Cut>>] -accelerator Ctrl+X
  $editMenu add command {*}[menu_label [T "&Paste"]] -command [list event generate $textWidget <<Paste>>] -accelerator Ctrl+V
  $editMenu configure -postcommand [list ::potato::editMenuCXV $editMenu 0 1 2 $textWidget]

  mailWindowFormatChange $c

  center $win
  reshowWindow $win 0

  return;

};# ::potato::mailWindow

#: proc ::potato::mailWindowFormatChange
#: arg c connection id
#: desc Adjust the states of the entries in $c's mail window, based on the currently selected mail format
#: return 1 (b/c this command is used as a -validatecommand for a ttk::entry widget)
proc ::potato::mailWindowFormatChange {c} {
  variable conn;
  variable gameMail;

  set type [$conn($c,mailWindow,formatWidget) get]
  set custom $conn($c,mailWindow,customWidget)
  if { $type eq "Custom" } {
       $custom state !disabled
       set format [$custom get]
     } else {
       $custom state disabled
       set format $gameMail($type)
     }

  foreach field {to cc bcc subject} {
    if { [string first "%$field%" $format] > -1 } {
         $conn($c,mailWindow,${field}Widget) state !disabled
       } else {
         $conn($c,mailWindow,${field}Widget) state disabled
       }
  }

  return 1;

};# ::potato::mailWindowFormatChange

#: proc ::potato::mailWindowSend
#: arg c connection id
#: arg win the mail window toplevel
#: desc Send the mail typed in the Mail Window for connection $c to the connection, and destroy the mail window $win. (Bindings on $win for <Destroy> take care of variable cleanup)
#: return nothing
proc ::potato::mailWindowSend {c win} {
  variable conn;
  variable world;
  variable gameMail;

  set w $conn($c,world)

  # Figure out the mail format
  set format $conn($c,mailWindow,format)
  if { $format eq "Custom" } {
       set world($w,mailFormat) Custom
       set world($w,mailFormat,custom) $conn($c,mailWindow,custom)
       set cmd [string map [list ";;" \b] $world($w,mailFormat,custom)]
     } else {
       set world($w,mailFormat) $format
       set cmd $gameMail($format)
     }


  set msg [$conn($c,mailWindow,bodyWidget) get 1.0 end-1char]
  if { $world($w,mailConvertReturns) } {
       set msg [string map [list "\n" $world($w,mailConvertReturns,to)] $msg]
     }

  set cmd [string map [list " ;; " "\b" ";;" "\b"] $cmd]
  set maps [list "%body%" $msg]
  foreach x [list to cc bcc subject] {
    if { [string first "%$x%" $cmd] > -1 } {
         lappend maps "%$x%" $conn($c,mailWindow,$x)
       }
  }
  set mailcmd [string map $maps $cmd]

  addToInputHistory $c $mailcmd

  foreach x [split $mailcmd \b] {
    send_to_real $c $x
  }

  destroy $win

  return;

};# ::potato::mailWindowSend

#: proc ::potato::mailWindowCleanup
#: arg c connection id
#: desc Cleanup vars set by the mail window for connection $c, because it's being destroyed
#: return nothing
proc ::potato::mailWindowCleanup {c} {
  variable conn;

  array unset conn $c,mailWindow,*

  return;

};# potato::mailWindowCleanup

#: proc ::potato::editMenuCXV
#: arg menu Path of menu
#: arg copyIndex Index of 'Copy' command in the menu, or -1 for none
#: arg cutIndex Index of 'Cut' command in the menu, or -1 for none
#: arg pasteIndex Index of 'Paste' command in the menu, or -1 for none
#: arg text Path of text widget
#: desc When an Edit menu is being posted, set the states for the Copy, Cut and Paste options, based on
#: desc selected text in a text widget and current clipboard contents.
#: return nothing
proc ::potato::editMenuCXV {menu copyIndex cutIndex pasteIndex text} {

  if { ![winfo exists $text] || [$text cget -state] eq "disabled" } {
       $menu entryconfigure $copyIndex -state disabled
       $menu entryconfigure $cutIndex -state disabled
       $menu entryconfigure $pasteIndex -state disabled
       return;
     }

  set sel [llength [$text tag nextrange sel 1.0]]
  if { $sel } {
       $menu entryconfigure $copyIndex -state normal
       $menu entryconfigure $cutIndex -state normal
     } else {
       $menu entryconfigure $copyIndex -state disabled
       $menu entryconfigure $cutIndex -state disabled
     }

    if { ![catch {::tk::GetSelection $text CLIPBOARD} clipboard] && [string length $clipboard] } {
       set state normal
     } else {
       set state disabled
     }
  $menu entryconfigure $pasteIndex -state $state

  return;

};# ::potato::editMenuCXV

#: proc ::potato::reshowWindow
#: arg win the window to re-show
#: arg bell Ring the [bell]? Defaults to 1
#: desc Raise/reshow window $win to draw a user's attention to it, and possibly [bell]
#: return 1 if window existed (and has been reshown), 0 otherwise
proc ::potato::reshowWindow {win {bell 1}} {

  if { ![winfo exists $win] } {
       return 0;
     }
  wm deiconify $win
  raise $win
  focus -force $win
  if { $bell } {
       bell -displayof $win
     }
  return 1;

};# ::potato::reshowWindow

#: proc ::potato::uploadWindow
#: arg c connection id, defaults to ""
#: desc For connection $c (or the currently displayed connection, if $c is ""), show the dialog to
#: desc allow the user to select a file to upload (if they aren't already doing so), or the dialog for them to cancel, if they are.
#: return nothing
proc ::potato::uploadWindow {{c ""}} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 } {
       bell -displayof .
       return;
     }

  if { $conn($c,upload,fid) eq "" } {
       uploadWindowStart $c
     } else {
       uploadProgressWindow $c
     }

  return;

};# ::potato::uploadWindow

#: proc ::potato::uploadWindowStart
#: arg c connection id
#: desc Show the window which allows the user to upload a file to connection $c
#: return nothing
proc ::potato::uploadWindowStart {c} {
  variable conn;
  variable world;

  set win .upload_file_$c
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  lappend conn($c,widgets) $win
  wm withdraw $win
  wm title $win [T "File Upload - \[%d. %s\]" $c $world($conn($c,world),name)]

  set bindings [list]

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both -side left -anchor nw
  pack [::ttk::labelframe $frame.options -text [T "Options"]] -side top -anchor center -padx 6 -pady 7
  pack [::ttk::frame $frame.options.empty] -side top -pady 3 -anchor nw
  pack [::ttk::label $frame.options.empty.l -text [T "Ignore empty lines?"] -width 20 \
                  -underline 0 -anchor w -justify left] -side left -anchor nw -padx 3
  pack [::ttk::checkbutton $frame.options.empty.cb -variable potato::conn($c,upload,ignoreEmpty) \
                   -onvalue 1 -offvalue 0] -side left -padx 3
  lappend bindings i $frame.options.empty.cb

  pack [::ttk::frame $frame.options.history] -side top -pady 3 -anchor nw
  pack [::ttk::label $frame.options.history.l -text [T "Add to History?"] -width 20 \
                  -underline 7 -anchor w -justify left] -side left -anchor nw -padx 3
  pack [::ttk::checkbutton $frame.options.history.cb -variable potato::conn($c,upload,history) \
                   -onvalue 1 -offvalue 0] -side left -padx 3
  lappend bindings h $frame.options.history.cb

  pack [::ttk::frame $frame.options.mpp] -side top -pady 3 -anchor nw
  pack [::ttk::label $frame.options.mpp.l -text [T "MPP Formatted?"] -width 20 \
                  -underline 0 -anchor w -justify left] -side left -anchor nw -padx 3
  pack [::ttk::checkbutton $frame.options.mpp.cb -variable potato::conn($c,upload,mpp) \
                  -onvalue 1 -offvalue 0] -side left -padx 3
  lappend bindings m $frame.options.mpp.cb

  pack [::ttk::frame $frame.options.delay] -side top -pady 3 -anchor nw
  pack [::ttk::label $frame.options.delay.l -text [T "Delay (seconds):"] -width 20  -anchor w -justify left] \
                  -side left -anchor nw -padx 3
  pack [pspinbox $frame.options.delay.sb -textvariable ::potato::conn($c,upload,delay) -from 0 -to 60 \
             -validate all -validatecommand {regexp {^[0-9]*\.?[0-9]?$} %P} -width 4 -increment 0.5] -side left

  pack [::ttk::frame $frame.file] -side top -anchor center -fill x -padx 6 -pady 8
  pack [entry $frame.file.e -textvariable potato::conn($c,upload,file) \
            -disabledbackground white -state disabled -width 30 -cursor {}] -side left -expand 1 -fill x;#abc make me Tile!
  pack [::ttk::button $frame.file.sel -command [list ::potato::selectFile potato::conn($c,upload,file) $win 0] \
              -image ::potato::img::dotdotdot] -side left -padx 8

  pack [::ttk::frame $frame.btns] -side top -anchor center -fill x -padx 6 -pady 8
  pack [::ttk::frame $frame.btns.ok] -side left -padx 6 -expand 1 -fill x
  pack [set okBtn [::ttk::button $frame.btns.ok.btn -command [list ::potato::uploadWindowInvoke $c $win] \
             -text [T "Upload"] -underline 0 -width 8 -default active]] -side top -anchor center
  lappend bindings u $frame.btns.ok.btn
  pack [::ttk::frame $frame.btns.cancel] -side left -padx 6 -expand 1 -fill x
  pack [set cancelBtn [::ttk::button $frame.btns.cancel.btn -command [list destroy $win] \
             -text [T "Cancel"] -underline 0 -width 8]] -side top -anchor center
  lappend bindings c $frame.btns.cancel.btn

  foreach {letter cmd} $bindings {
     bind $win <Alt-$letter> [list $cmd invoke]
  }
  bind $win <Return> [list $okBtn invoke]
  bind $win <Escape> [list $cancelBtn invoke]

  update idletasks
  center $win
  wm deiconify $win
  return;

};# ::potato::uploadWindowStart

#: proc ::potato::uploadWindowInvoke
#: arg c connection id
#: arg win toplevel window where the upload info was entered
#: desc if a valid file is selected and connection $c is connected, destroy $win and start uploading the given file to the connection. Else, raise an error
#: return nothing
proc ::potato::uploadWindowInvoke {c win} {
  variable conn;
  variable world;

  set file $conn($c,upload,file)
  if { $conn($c,connected) != 1 } {
       set errorMsg [T "Not connected."]
     } elseif { $file eq "" } {
       set errorMsg [T "You must select a file."]
     } elseif { ![file exists $file] || ![file isfile $file] || ![file readable $file] } {
       set errorMsg [T "Unable to read file \"%s\"." $file]
     } elseif { [catch {open $file r} fid] } {
       set errorMsg [T "Unable to open file \"%s\": %s" $file $fid]
     }

  if { [info exists errorMsg] } {
       tk_messageBox -message $errorMsg -title [T "File Upload"] -parent $win -type ok -icon error
       return;
     }

  set int 0
  set fraction 0
  scan $conn($c,upload,delay) %d.%d int fraction
  set delay $int.$fraction
  unregisterWindow $c $win
  destroy $win

  outputSystem $c [T "Uploading file \"%s\"..." $file]

  set conn($c,upload,fileSize) [file size $conn($c,upload,file)]
  set conn($c,upload,fid) $fid
  uploadBegin $c
  uploadProgressWindow $c

  return;

};# ::potato::uploadWindowInvoke

#: proc ::potato::uploadBegin
#: arg c connection id
#: arg win path of the window showing upload progress
#: desc For connection $c, begin uploading the file selected by the user to the game, using the conn($c,upload,*) vars.
#: return nothing
proc ::potato::uploadBegin {c} {
  variable conn;

  if { [eof $conn($c,upload,fid)] } {
       if { $conn($c,upload,mpp) && [string length $conn($c,upload,mpp,buffer)] } {
            # Send what's in the buffer, it's all we have.
            send_to_real $c $conn($c,upload,mpp,buffer)
            if { $conn($c,upload,history) } {
                 addToInputHistory $c $conn($c,upload,mpp,buffer)
               }
            set conn($c,upload,mpp,buffer) ""
          }
       uploadEnd $c 0
       return;
     }

  gets $conn($c,upload,fid) line
  set first_line [expr {$conn($c,upload,bytes) == 0}]
  if { $first_line } {
       # Our first read; check the newline length
       set conn($c,upload,newlineLength) [expr {[tell $conn($c,upload,fid)] - [string bytelength $line]}]
     } else {
       incr conn($c,upload,bytes) $conn($c,upload,newlineLength);# for the newline
     }

  # Increment for the length of the string
  incr conn($c,upload,bytes) [string bytelength $line]

  # Does this line contain any data to be sent, or is it blank?
  set blank 1
  # Data to send
  set data [list]

  # Check for MPP
  if { $conn($c,upload,mpp) } {
       # Need to check things differently. Damn.
       if { [string trim $line " \t"] eq "" || [string range $line 0 1] eq "@@" } {
            # blank/whitespace/comment line
          } elseif { [string index $line 0] eq ">" } {
            # Formatted line
            if { $conn($c,upload,mpp,gt) } {
                 set conn($c,upload,mpp,gt) 0
               } else {
                 append conn($c,upload,mpp,buffer) "%r"
               }
            append conn($c,upload,mpp,buffer) [string map [list " " %b "\t" %t % \\% {;} {\;} \[ \\\[ \] \\\] ( \\( ) \\) , \\, ^ \\^ $ \\$ \{ \\\{ \} \\\} \\ \\\\] [string range $line 1 end]]
          } elseif { [string index $line 0] eq " " || [string index $line 0] eq "\t" } {
            # Unformatted continuation
            append conn($c,upload,mpp,buffer) [string trimleft $line " \t"]
          } else {
            if { [string length $conn($c,upload,mpp,buffer)] } {
                 lappend data $conn($c,upload,mpp,buffer)
                 set blank 0
               }
            set conn($c,upload,mpp,gt) 1
            set conn($c,upload,mpp,buffer) $line
          }
     } elseif { $line ne "" || !$conn($c,upload,ignoreEmpty) } {
       set blank 0
       lappend data $line
     } else {
       set blank 1
     }

  if { !$blank } {
       foreach string $data {
          send_to_real $c $string
          if { $conn($c,upload,history) } {
               addToInputHistory $c $string
             }
       }
       set delay [expr {round(1000 * $conn($c,upload,delay))}]
     } else {
       set delay 0
     }

  set conn($c,upload,after) [after $delay [list ::potato::uploadBegin $c]]

  return;

};# ::potato::uploadBegin

#: proc ::potato::uploadProgressWindow
#: arg c connection id
#: desc Show a window giving the progress of a file upload, and allowing the user to cancel said upload.
#: return nothing
proc ::potato::uploadProgressWindow {c} {
  variable conn;
  variable world;

  if { ![info exists conn($c,upload,fid)] || $conn($c,upload,fid) eq "" } {
       return;
     }

  set win .upload_status_$c
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  registerWindow $c $win
  wm withdraw $win
  wm title $win [T "Upload Status - \[%d. %s\]" $c $world($conn($c,world),name)]

  pack [set frame [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw
  pack [::ttk::frame $frame.top] -side top -fill x -padx 6 -pady 10
  pack [::ttk::label $frame.top.progress -text [T "Progress: "]] -side left
  pack [::ttk::label $frame.top.count -textvariable potato::conn($c,upload,bytes)] -side left
  pack [::ttk::label $frame.top.of -text [T " of "]] -side left
  pack [::ttk::label $frame.top.total -textvariable potato::conn($c,upload,fileSize)] -side left
  pack [::ttk::label $frame.top.bytes -text [T " bytes"]] -side left

  pack [::ttk::frame $frame.progress] -side top -fill x -padx 6 -pady 10
  pack [::ttk::progressbar $frame.progress.pb -orient horizontal -length 275 -maximum $conn($c,upload,fileSize) \
               -variable ::potato::conn($c,upload,bytes)] -side left -expand 1 -fill x

  pack [::ttk::frame $frame.btns] -side top -fill x -padx 6 -pady 10
  pack [::ttk::frame $frame.btns.hide] -side left -expand 1 -fill x
  pack [::ttk::button $frame.btns.hide.btn -text [T "Hide"] -width 8 -default active \
               -underline 0 -command [list destroy $win]] -side top
  pack [::ttk::frame $frame.btns.cancel] -side left -expand 1 -fill x
  pack [::ttk::button $frame.btns.cancel.btn -text [T "Cancel"] -width 8 -underline 0 -command [list ::potato::uploadCancel $c $win]] -side top

  bind $win <Escape> [list $frame.btns.hide.btn invoke]
  bind $win <Return> [list $frame.btns.hide.btn invoke]
  bind $win <Alt-h> [list $frame.btns.hide.btn invoke]
  bind $win <Alt-c> [list $frame.btns.cancel.btn invoke]

  update idletasks
  center $win
  wm deiconify $win

  return;

};# ::potato::uploadProgressWindow

#: proc ::potato::uploadCancel
#: arg c connection id
#: arg win toplevel window
#: desc Run when the user clicks to cancel a file upload. Prompt to check they want to, and if they do, stop the upload for connection $c and destroy window $win
#: return nothing
proc ::potato::uploadCancel {c win} {
  variable conn;
  variable world;

  set ans [tk_messageBox -parent $win -title [T "File Upload"] -type yesno -icon question \
        -message [T "Do you really want to cancel the file upload for \[%d. %s\]?" $c $world($conn($c,world),name)]]
  if { $ans ne "yes" } {
       return;
     }

  unregisterWindow $c $win
  destroy $win
  uploadEnd $c 1

  return;

};# ::potato::uploadCancel

#: proc ::potato::uploadEnd
#: arg c connection id
#: arg cancelled Was the upload cancelled (1), or did it finish (0)?
#: desc Do the back-end work of closing the file upload for connection $c, showing the message, etc.
#: return nothing
proc ::potato::uploadEnd {c cancelled} {
  variable conn;

  if { ![info exists conn($c,upload,fid)] || $conn($c,upload,fid) eq "" } {
       return;
     }

  after cancel $conn($c,upload,after)

  if { $cancelled } {
       outputSystem $c [T "Upload of \"%s\" cancelled." $conn($c,upload,file)]
     } else {
       outputSystem $c [T "Upload of \"%s\" completed." $conn($c,upload,file)]
     }

  close $conn($c,upload,fid)
  set conn($c,upload,fid) ""
  set conn($c,upload,file) ""
  set conn($c,upload,after) ""
  set conn($c,upload,bytes) 0
  set conn($c,upload,newlineLength) 1
  set conn($c,upload,fileSize) 0
  # We leave delay, ignoreEmpty and history for next time

  catch {destroy .upload_status_$c}

  return;

};# ::potato::uploadEnd

#: proc ::potato::logWindow
#: arg c connection id, defaults to ""
#: desc show the log window for connection $c (or the currently displayed connection, if $c is ""), allowing the user to start logging
#: return nothing
proc ::potato::logWindow {{c ""}} {
  variable conn;
  variable world;

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 } {
       bell -displayof .
       return;
     }

  set win .log_win_$c
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  set w $conn($c,world)

  toplevel $win
  registerWindow $c $win
  wm withdraw $win
  wm title $win [T "Log from \[%d. %s\]" $c $world($w,name)]

  set conn($c,logDialog,buffer) {Main Window}
  set conn($c,logDialog,append) 1
  set conn($c,logDialog,future) 1
  #set conn($c,logDialog,wrap) 0
  set conn($c,logDialog,timestamps) 0
  set conn($c,logDialog,html) 0
  set conn($c,logDialog,file) ""

  set bindings [list]

  pack [set frame [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw

  pack [::ttk::frame $frame.top] -side top -padx 5 -pady 10
  pack [::ttk::labelframe $frame.top.buffer -text [T "Include Buffer From: "] -padding 2] -side left -anchor nw -padx 6
  set spawns [list "No Buffer" "Main Window"]
  foreach x $conn($c,spawns) {
    lappend spawns [lindex $x 1]
  }
  pack [::ttk::combobox $frame.top.buffer.cb -values $spawns \
             -textvariable potato::conn($c,logDialog,buffer) -state readonly] -side top -anchor nw

  pack [::ttk::labelframe $frame.top.options -text [T "Other Options"] -padding 2] -side left -anchor nw -padx 6
  pack [::ttk::checkbutton $frame.top.options.future -variable potato::conn($c,logDialog,future) \
             -onvalue 1 -offvalue 0 -text [T "Leave Log Open?"] -underline 10] -side top -anchor w
  lappend bindings o $frame.top.options.future
  pack [::ttk::checkbutton $frame.top.options.append -variable potato::conn($c,logDialog,append) \
             -onvalue 1 -offvalue 0 -text [T "Append to File?"] -underline 0] -side top -anchor w
  lappend bindings a $frame.top.options.append
  pack [::ttk::checkbutton $frame.top.options.timestamps -variable potato::conn($c,logDialog,timestamps) \
             -onvalue 1 -offvalue 0 -text [T "Show Timestamps?"] -underline 5] -side top -anchor w
  lappend bindings t $frame.top.options.timestamps
  pack [::ttk::checkbutton $frame.top.options.html -variable potato::conn($c,logDialog,html) \
             -onvalue 1 -offvalue 0 -text [T "Log as HTML?"] -underline 7] -side top -anchor w
  lappend bindings h $frame.top.options.html

  #pack [::ttk::checkbutton $frame.top.options.wrap -variable potato::conn($c,logDialog,wrap) \
  #           -onvalue 1 -offvalue 0 -text [T "Wrap Lines?"] -underline 0] -side top -anchor w
  #lappend bindings w $frame.top.options.wrap

  pack [::ttk::frame $frame.file] -side top -anchor center -fill x -padx 6 -pady 4
  pack [::ttk::entry $frame.file.e -textvariable potato::conn($c,logDialog,file) -width 30] -side left -expand 1 -fill x
  $frame.file.e state readonly


  set html {
    {{HTML Files}       {.html}        }
  }

  pack [::ttk::button $frame.file.sel -command [list ::potato::selectFile potato::conn($c,logDialog,file) $win 1 $html] \
              -image ::potato::img::dotdotdot] -side left -padx 8
  lappend bindings f $frame.file.sel

  pack [::ttk::frame $frame.btns] -side top -anchor center -expand 1 -fill x -padx 6 -pady 4
  pack [::ttk::frame $frame.btns.ok] -side left -expand 1 -fill x -padx 8
  pack [::ttk::button $frame.btns.ok.btn -text [T "Log"] -width 8 -underline 0 -default active \
              -command [list ::potato::logWindowInvoke $c $win]] -side top
  lappend bindings l $frame.btns.ok.btn
  pack [::ttk::frame $frame.btns.cancel] -side left -expand 1 -fill x -padx 8
  pack [::ttk::button $frame.btns.cancel.btn -text [T "Cancel"] -width 8 -underline 0 \
              -command [list destroy $win]] -side top
  lappend bindings c $frame.btns.cancel.btn

  foreach {letter widget} $bindings {
     bind $win <Alt-$letter> [list $widget invoke]
  }

  bind $win <Return> [list $frame.btns.ok.btn invoke]
  bind $win <Escape> [list $frame.btns.cancel.btn invoke]
  update idletasks
  center $win
  wm deiconify $win

  return;

};# ::potato::logWindow

#: proc ::potato::logWindowInvoke
#: arg c connection id
#: arg win toplevel log window
#: desc Using the options set in window $win for connection $c, start logging
#: return nothing
proc ::potato::logWindowInvoke {c win} {
  variable conn;

  # Don't destroy the window until we've done some validation...
  if { $conn($c,logDialog,file) eq "" || ($conn($c,logDialog,future) == 0 && $conn($c,logDialog,buffer) == -1) } {
       bell -displayof $win
       focus $win
       return; # no file selected, or told not to log anything
     }

  doLog $c $conn($c,logDialog,file) $conn($c,logDialog,append) $conn($c,logDialog,buffer) $conn($c,logDialog,future) $conn($c,logDialog,timestamps) $conn($c,logDialog,html)
  unregisterWindow $c $win
  destroy $win
  array unset conn $c,logDialog,*
  return;

};# ::potato::logWindowInvoke

#: proc ::potato::doLog
#: arg c connection id
#: arg file name of file to log to
#: arg append to file if it exists, instead of overwriting?
#: arg buffer "No Buffer" or "_none" to not include buffered output, "Main Window" or "_main" for $c's main window, or the name of a spawn window
#: arg leave leave the logfile open for future output?
#: arg timestamps Include timestamps for each logged line?
#: arg html Log as HTML instead of plain text?
#: desc Create a log file for connection $c, writing to file $file (and appending, if $append is true and the file exists). If $buffer != "_none"/"No Buffer",
#: desc include output from one of the windows. If $leave, don't close the file, leave it open to log incoming text to, possibly causing us to close an already-open log file.
#: return nothing
proc ::potato::doLog {c file append buffer leave timestamps html} {
  variable conn;
  variable world;
  variable misc;
  variable potato;

  if { ![info exists conn($c,world)] } {
       return;
     }

  set mode [lindex [list w a] $append]

  if { ![catch {clock format [clock seconds] -format $file} newfile] } {
       set file $newfile
     }

  set header [T "Logfile from %s" $world($conn($c,world),name)]
  if { $conn($c,char) ne "" } {
       append header " ($conn($c,char))"
     }

  if { [catch {set subheader [T "Log opened %s" [clock format [clock seconds] -format $misc(clockFormat)]]}] } {
       set subheader ""
       set timestamps 0
     }

  if { $buffer eq "" || $buffer eq "_none" || $buffer eq "No Buffer" || $buffer eq "_all" || [set buffer [validSpawnName $buffer 0]] eq "" } {
       set t ""
     } elseif { $buffer eq "_main" || $buffer eq "main window" } {
       set t $conn($c,textWidget)
     } elseif { [set pos [findSpawn $c $buffer]] != -1 } {
       set t [lindex [lindex $conn($c,spawns) $pos] 0]
     } else {
       set t ""
     }

  if { !$leave && $t eq "" } {
       outputSystem $c [T "Log what?"]
       return;
     }

  set file [file nativename [file normalize $file]]
  set err [catch {open $file $mode} fid]
  if { $err } {
       outputSystem $c "Unable to log to \"$file\": $fid"
       return;
     }
  fconfigure $fid -encoding utf-8

  if { $html } {
       set leave 0;# not currently supported
     }

  if { $html } {
       puts $fid {<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">}
       puts $fid {<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">}
       puts $fid {<head>}
       puts $fid "\t<title>[htmlEscape $header]</title>"
       puts -nonewline $fid "\t"
       puts $fid {<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />}
       puts $fid "\t<meta name=\"description\" content=\"[htmlEscape "$header. $subheader"]\"  />"
       puts $fid [format {%s<meta name="author" content="%s Version %s" />} \t $potato(name) $potato(version)]
       if { $t eq "" } {
            set thtml $conn($c,textWidget)
          } else {
            set thtml $t
          }
       puts $fid "\t<style type=\"text/css\">"
       puts $fid "\t\t<!--"
       puts $fid "\t\t body {"
       puts $fid "\t\t\tbackground-color:[htmlColor [$thtml cget -background]];"
       puts $fid "\t\t\tcolor:[htmlColor [$thtml cget -foreground]];"
       array set font [font actual [$thtml cget -font]]
       puts $fid "\t\t\tfont-family: $font(-family),\"$font(-family)\",monospace;"
       puts $fid "\t\t\tfont-size: $font(-size)pt;"
       if { $font(-weight) eq "bold " } {
            puts $fid "\t\t\tfont-weight:bold;"
          }
       if { $font(-slant) eq "italic" } {
            puts $fid "\t\t\tfont-style:italic;"
          }
       if { $font(-underline) && $font(-overstrike) } {
            puts $fid "\t\t\ttext-decoration:underline line-through;"
          } elseif { $font(-underline) } {
            puts $fid "\t\t\ttext-decoration:underline;"
          } elseif { $font(-overstrike) } {
            puts $fid "\t\t\ttext-decoration:line-through;"
          }
       puts $fid "\t\t}"

       set styles [lsort -dictionary [lsearch -all -inline -glob [$thtml tag names] ANSI*]]
       if { !$leave } {
            # We only need to put the styles we've used
            for {set i [llength $styles];incr i -1} {$i >= 0} {incr i -1} {
              if { ![llength [$thtml tag ranges [lindex $styles $i]]] } {
                   set styles [lreplace $styles $i $i]
                 }
            }
          }
       lappend styles system echo
       foreach x $styles {
         set this ""
         if { [set col [$thtml tag cget $x -foreground]] ne "" } {
              append this "color:[htmlColor $col];"
            }
         if { [set col [$thtml tag cget $x -background]] ne "" } {
              append this "background-color:[htmlColor $col];"
            }
         if { $this ne "" } {
              puts $fid "\t\t.$x {$this}"
            }
       }
       if { "ANSI_underline" in $styles } {
            puts $fid "\t\t.ANSI_underline {text-decoration:underline;}"
          }
       lappend styles weblink
       puts $fid "\t\t.center {text-align:center}"
       puts $fid "\t\t-->"
       puts $fid "\t</style>"
       puts $fid {</head>}
       puts $fid {<body>}
       puts $fid "\t<h1>[htmlEscape $header]</h1>"
       puts $fid "\t<h2>[htmlEscape $subheader]</h2>"
     } else {
       puts $fid "$header\n$subheader\n"
     }

  if { [winfo exists $t] && [winfo class $t] eq "Text" } {
       set max [$t count -lines 1.0 end]
       for {set i 1} {$i <= $max} {incr i} {
         set linking 0
         set omit 0
         set opentags [list]
         if { "nobacklog" in [set tags [$t tag names $i.0]] } {
              continue;
            }
         if { $html } {
              puts -nonewline $fid "\t<div";
              if { "center" in $tags } {
                   puts -nonewline $fid { class="center"}
                 }
              puts -nonewline $fid ">"
            }
         if { $timestamps } {
              if { $html } {
                   # nothing yet
                 } else {
                   puts -nonewline $fid "\[[clock format [$t get {*}[$t tag nextrange timestamp $i.0]] -format $misc(clockFormat)]\] "
                 }
            }
         if { $html } {
              set data [$t dump -tag -text $i.0 "$i.0 lineend"]
              foreach {what info where} $data {
                switch $what {
                  tagon {if { $info eq "weblink" } {
                              set linking 1
                            } elseif { $info eq "timestamp" } {
                              set omit 1
                            } elseif { $linking } {
                              # nothing
                            } elseif { $info in $styles } {
                              puts -nonewline $fid "<span class=\"$info\">"
                              lappend opentags $info
                            }
                         }
                  tagoff {if { $linking } {
                               set linking 0
                               puts -nonewline $fid "<a href=\"[htmlEscape $link]\" target=\"_blank\">[htmlEscape $link]</a>"
                               set link ""
                             } elseif { $omit } {
                               set omit 0
                             } elseif { $info in $opentags } {
                               puts -nonewline $fid "</span>"
                               set pos [lsearch -exact $opentags $info]
                               set opentags [lreplace $opentags $pos $pos]
                             }
                         }
                  text {if { $linking } {
                             append link $info
                           } elseif { $omit } {
                             continue
                           } else {
                             puts -nonewline $fid [htmlEscape $info]
                           }
                       }
                }
              }
              foreach span $opentags {
                puts -nonewline $fid "</span>";
              }
              puts $fid "</div>"
            } else {
              puts $fid [$t get -displaychars -- "$i.0" "$i.0 lineend"]
            }
       }
       flush $fid
     }

  if { $leave } {
       outputSystem $c [T "Now logging to \"%s\"." $file]
       set conn($c,log,$fid) [file nativename [file normalize $file]]
       set conn($c,log,$fid,timestamps) $timestamps
     } else {
       if { $html } {
            puts $fid "</body>\n</html>"
          }
       outputSystem $c [T "Logged to \"%s\"." $file]
       close $fid
     }

  return;

};# ::potato::doLog

proc ::potato::htmlColor {color} {

  foreach [list red green blue] [winfo rgb . $color] {break}

  set red [expr {$red / 256}]
  set blue [expr {$blue / 256}]
  set green [expr {$green / 256}]

  return [format "#%02x%02x%02x" $red $green $blue];

};# ::potato::htmlColor

proc ::potato::htmlEscape {str} {

  set map [list "&" "&amp;" "<" "&lt;" ">" "&gt;" {"} "&quot;" " " "&nbsp;" "\u00a0" "&nbsp;"]
  return [string map $map $str];

};# ::potato::htmlEscape

#: proc ::potato::stopLog
#: arg c connection id. Defaults to ""
#: arg file File to close, or "" (default) for all
#: arg verboseReturn If 1, returns a message on success instead of 1
#: desc Stop logging to filename (or [file channel]) $file, or all files if $file is "", for connection $c.
#: return 0 if no open logs, -1 if specified log not found, -2 if specified log is ambiguous, 1 (or a success message) if log(s) closed successfully.
proc ::potato::stopLog {{c ""} {file ""} {verboseReturn 0}} {
  variable conn;
  variable misc;

  if { $c eq "" } {
       set c [up]
     }
  if { [set count [llength [set list [arraySubelem conn $c,log]]]] == 0 } {
       return 0;# No open logs
     }
  set footer "\nLogging stopped at [clock format [clock seconds] -format $misc(clockFormat)]"
  if { $file eq "" } {
       if { $count == 1 } {
            set msg [T "Logging to \"%s\" stopped." $conn([lindex $list 0])]
          } else {
            set msg [T "Logging to %d logfiles stopped." $count]
          }
        foreach x [removePrefix $list $c,log] {
          catch {puts $x $footer}
          close $x
          unset conn($c,log,$x)
          array unset conn $c,log,$x,*
        }
     } else {
       if { ![info exists conn($c,log,$file)] } {
            set realfile [file nativename [file normalize $file]]
            set shortrealfile [file tail $file]
            set count 0
            foreach x $list {
               if { $conn($x) eq $realfile } {
                    set match [removePrefix $x $c,log]
                    break;
                  } elseif { [file tail $conn($x)] eq $shortrealfile } {
                    set match [removePrefix $x $c,log]
                    incr count
                    # No break
                  }
            }
            if { ![info exists match] } {
                 return -1;
               } elseif { $count > 1 } {
                 return -2;
               }
          } else {
            set match $file
          }
       set msg [T "Logging to \"%s\" stopped." $conn($c,log,$match)]
       catch {puts $match $footer}
       close $match
       unset conn($c,log,$match)
       array unset conn $c,log,$match,*
     }

  if { $verboseReturn } {
       return $msg;
     } else {
       outputSystem $c $msg
       return 1;
     }

};# ::potato::stopLog

#: proc ::potato::log
#: arg c connection id
#: arg str String to log
#: desc Actually log $str to $c's open log files
#: return nothing
proc ::potato::log {c str} {
  variable conn;
  variable misc;

  if { $c eq "" } {
       set c [up]
     }

  set logs [arraySubelem conn $c,log]
  if { [llength $logs] } {
       foreach x [removePrefix $logs $c,log] {
         if { $conn($c,log,$x,timestamps) } {
              if { ![info exists timestamp] } {
                   set timestamp "\[[clock format [clock seconds] -format $misc(clockFormat)]]\]"
                 }
              puts $x "$timestamp $str"
            } else {
              puts $x $str
            }
         flush $x
       }
     }
  return;
};# ::potato::log

#: proc ::potato::selectFile
#: arg var name of a global variable
#: arg win the parent window for the dialog
#: arg save Is this a saveFile dialog (1), or an openFile dialog (0)?
#: desc Show a dialog for selecting a file to either save to or open. If a file is selected, save it into the variable given in $var
#: return nothing
proc ::potato::selectFile {var win save {basetypes ""}} {
  variable path;
  upvar #0 $var local;

  if { $save } {
       set cmd tk_getSaveFile
     } else {
       set cmd tk_getOpenFile
     }

  if { $local eq "" } {
       set basedir $path(homedir)
       set basefile ""
     } else {
       set basedir [file dirname $local]
       set basefile [file tail $local]
     }

  set filetypes {
    {{Text Files}       {.txt}        }
    {{Text Files}       {.log}        }
  }
  if { $basetypes ne "" } {
       set filetypes [concat $filetypes $basetypes]
     }
  lappend filetypes {{All Files}        *             }
  set file [$cmd -parent $win -initialdir $basedir -initialfile $basefile \
                 -defaultextension ".txt" -filetypes $filetypes]

  if { $file eq "" } {
       return;
     }

  set local [file nativename $file]

  return;

};# ::potato::selectFile

#: proc ::potato::newConnectionDefault
#: arg w world id
#: desc Wrapper for [::potato::newConnection $w <defaultChar>]
#: return nothing
proc ::potato::newConnectionDefault {w} {
  variable world;

  if { [info exists world($w,charDefault)] } {
       newConnection $w $world($w,charDefault)
     } else {
       newConnection $w
     }

  return;

};# ::potato::newConnectionDefault

#: proc ::potato::makeTextFrames
#: arg c connection id
#: desc Make a set of three text widgets for conn $c: One for output, and two for input. This may be for the main output window, or for spawn windows.
#: return a list of the three widget paths
proc ::potato::makeTextFrames {c} {
  variable conn;
  variable world;
  variable inputSwap;

  set count [incr conn($c,textFrameTotals)]
  set w $conn($c,world)

  set t .conn_${c}_textWidget_$count
  if { $c == 0 } {
       set out [canvas $t -width 700 -height 500 -highlightthickness 0]
     } else {
       set out [text $t -undo 0 -height 1]
       createOutputTags $out
       configureTextWidget $c $out
       bindtags $out [linsert [bindtags $out] 0 PotatoUserBindings PotatoOutput]
       set pos [lsearch -exact [bindtags $out] "Text"]
       bindtags $out [lreplace [bindtags $out] $pos $pos]
     }

  foreach x [list input1 input2] {
    set $x [text .conn_${c}_${x}_$count -wrap word -undo 1 -height 1 \
              -background $world($w,bottom,bg) -font $world($w,bottom,font,created) \
              -foreground $world($w,bottom,fg) -insertbackground [reverseColour $world($w,bottom,bg)]]
    bindtags [set $x] [linsert [bindtags [set $x]] 0 PotatoUserBindings PotatoInput]
    set inputSwap([set $x],count) -1
    set inputSwap([set $x],conn) $c
    set inputSwap([set $x],backup) ""
  }

  return [list $out $input1 $input2];

};# ::potato::makeTextFrames

#: proc ::potato::newConnection
#: arg w the id of the world to connect to
#: arg character The name of the character in world $w's char list to connect to
#: desc do the basics of opening a new connection to a world, tell the current skin to set things up, then try and connect
#: return nothing
proc ::potato::newConnection {w {character ""}} {
  variable potato;
  variable conn;
  variable world;

  if { $w == -1 } {
       # Set up the "not connected" connection
       set c 0
     } else {
       set c [incr potato(conns)]
       for {set i 1} {$i < $c} {incr i} {
            if { ![info exists conn($i,world)] } {
                 set c $i
                 break;
               }
           }
       unset i
     }

  # Create fonts for this world, if we haven't already
  if { ![info exists world($w,top,font,created)] } {
       set world($w,top,font,created) [font create {*}[font actual $world($w,top,font)]]
     }
  if { ![info exists world($w,bottom,font,created)] } {
       set world($w,bottom,font,created) [font create {*}[font actual $world($w,bottom,font)]]
     }

  set conn($c,world) $w

  set conn($c,char) $character
  updateConnName $c;# sets conn($c,name)
  set conn($c,id) ""
  set conn($c,address) [list]
  set conn($c,address,disp) [T "Not Connected"]
  set conn($c,protocols) [list]
  set conn($c,idle) 0
  set conn($c,upload,fid) ""
  set conn($c,upload,file) ""
  set conn($c,upload,bytes) 0
  set conn($c,upload,newlineLength) 1
  set conn($c,upload,fileSize) 0
  set conn($c,upload,ignoreEmpty) 1
  set conn($c,upload,delay) 0.0
  set conn($c,upload,history) 0
  set conn($c,upload,mpp) 0
  set conn($c,upload,mpp,gt) 0
  set conn($c,upload,mpp,buffer) ""
  set conn($c,connected) 0
  set conn($c,reconnectId) ""
  set conn($c,loginInfoId) ""
  set conn($c,telnet,state) 0
  set conn($c,telnet,subState) 0
  set conn($c,telnet,buffer,line) ""
  set conn($c,telnet,buffer,codes) ""
  set conn($c,telnet,afterPrompt) 0
  set conn($c,telnet,mssp) [list]
  set conn($c,prompt) ""
  set conn($c,outputBuffer) ""
  set conn($c,ansi,fg) fg
  set conn($c,ansi,bg) bg
  set conn($c,ansi,flash) 0
  set conn($c,ansi,underline) 0
  set conn($c,ansi,highlight) 0
  set conn($c,ansi,inverse) 0
  set conn($c,inputHistory) [list]
  set conn($c,inputHistory,count) 0
  set conn($c,stats,prev) 0
  set conn($c,stats,connAt) -1
  set conn($c,stats,formatted) ""
  set conn($c,numConnects) 0
  set conn($c,twoInputWindows) $world($w,twoInputWindows)
  set conn($c,widgets) [list]
  set conn($c,spawnAll) [list]
  set conn($c,spawns) [list]
  set conn($c,limited) [list]
  set conn($c,debugPackets) 0
  set conn($c,userAfterIDs) [list]

  foreach [list conn($c,textWidget) conn($c,input1) conn($c,input2)] [makeTextFrames $c] {break};

  if { $w == -1 } {
       connZero
     }

  ::skin::$potato(skin)::import $c

  showConn $c

  if { $w != -1 } {
       connect $c 1
     }

  return;

};# ::potato::newConnection

#: proc ::potato::updateConnName
#: arg c connection id
#: desc Update the connection name for conn $c based on the world name and the character connected to, if a custom name is not set
#: return nothing
proc ::potato::updateConnName {c} {
  variable conn;
  variable world;

  if { [info exists conn($c,name)] && [llength $conn($c,name)] && [lindex $conn($c,name) 0] } {
       return;# custom name set, don't override
     }

  set connname $world($conn($c,world),name)
  if { [string length $conn($c,char)] } {
       append connname " ($conn($c,char))"
     }
  set conn($c,name) [list 0 $connname]

  return;

};# ::potato::updateConnName

#: proc ::potato::addProtocol
#: arg c connection id
#: arg protocol the name of the protocol
#: desc add $protocol to the list of protocols negotiated by connection $c, if not already present
#: return nothing
proc ::potato::addProtocol {c protocol} {
  variable conn;

  if { $protocol ni $conn($c,protocols) } {
       lappend conn($c,protocols) $protocol
     }

  return;

};# ::potato::addProtocol

#: proc ::potato::hasProtocol
#: arg c connection id
#: arg protocol name of protocol
#: desc return 1 if the given connection has negotiated the given protocol, or 0 otherwise
#: return 1 or 0
proc ::potato::hasProtocol {c protocol} {
  variable conn;

  return [expr {$protocol in $conn($c,protocols)}];

};# ::potato::hasProtocol

#: proc ::potato::sendRaw
#: arg c connection id
#: arg str the string to send
#: arg telnet Is this a telnet string? If so, don't add a newline, and send as binary regardless of current encoding.
#: desc send the string $str to connection $c. Do not perform any escaping.
#: return nothing
proc ::potato::sendRaw {c str telnet} {
  variable conn;

  # Make sure we have an id to send to, and that we're not still trying to connect
  if { $conn($c,id) ne "" && $conn($c,connected) == 1 && $conn($c,id) in [chan names] } {
       if { $conn($c,debugPackets) } {
            if { $telnet } {
                 debug_packet $c 0 $str
               } else {
                 debug_packet $c 0 "$str$conn($c,id,lineending)"
               }
          }
       if { $telnet } {
            ioWrite -nonewline $conn($c,id) $str
          } else {
            if { $conn($c,id,encoding) eq "iso8859-1" } {
                 # Convert Unicode chars to latin equivilents
                 set str [unicode-to-latin1 $str]
               }
            ioWrite -nonewline $conn($c,id) "[encoding convertto $conn($c,id,encoding) $str]$conn($c,id,lineending)"
          }
     }

  return;

};# ::potato::sendRaw

#: proc ::potato::flashANSI
#: arg flashing Are we currently flashing?
#: desc flash the ANSI text for all connections where appropriate
#: return nothing
proc ::potato::flashANSI {flashing} {
  variable misc;
  variable conn;
  variable world;

  if { $flashing } {
       foreach c [connIDs] {
         set w $conn($c,world)
         $conn($c,textWidget) tag configure ANSI_flash -background "" -foreground ""
         foreach x $conn($c,spawns) {
           [lindex $x 1] tag configure ANSI_flash -background "" -foreground ""
         }
       }
       after $misc(ansiFlashDelay,on) [list ::potato::flashANSI 0]
     } else {
       foreach c [connIDs] {
         set w $conn($c,world)
         if { !$world($w,ansi,flash) } {
              continue;
            }
         set bgcol $world($w,top,bg)
         $conn($c,textWidget) tag configure ANSI_flash -background $bgcol -foreground $bgcol
         foreach x $conn($c,spawns) {
           [lindex $x 1] tag configure ANSI_flash -background $bgcol -foreground $bgcol
         }
       }
       after $misc(ansiFlashDelay,off) [list ::potato::flashANSI 1]
     }

  return;

};# ::potato::flashConnANSI

#: proc ::potato::configureTextWidget
#: arg c the connection the widget is being configured for
#: arg t the text widget to be configured
#: desc set the ANSI colours, ANSI underline, BG, FG, system, and echo colours for the text widget based on it's connection's world's settings
#: return nothing
proc ::potato::configureTextWidget {c t} {
  variable conn;
  variable world;

  set w $conn($c,world)
  $t tag configure ANSI_underline -underline $world($w,ansi,underline)
  foreach x [list r g b c m y x w fg] {
     foreach {short long} [list bg background fg foreground] {
        if { $world($w,ansi,colours) } {
             set colour $x
           } else {
             set colour fg
           }
        $t tag configure ANSI_${short}_$x -$long $world($w,ansi,$colour)
        if { $short eq "bg" } {
             $t tag configure ANSI_${short}_${x}h -$long $world($w,ansi,${colour})
           } else {
             $t tag configure ANSI_${short}_${x}h -$long $world($w,ansi,${colour}h)
           }
     }
  }
  $t tag configure limited -elide 1
  $t tag configure ANSI_fg_bg -foreground $world($w,top,bg)
  $t tag configure system -foreground $world($w,ansi,system)
  $t tag configure echo -foreground $world($w,ansi,echo)
  $t tag configure link -foreground $world($w,ansi,link) -underline 1
  $t tag bind link <Enter> [list %W configure -cursor hand2]
  $t tag bind link <Leave> [list %W configure -cursor xterm]
  $t tag bind link <ButtonPress-1> [list ::potato::linkRecolour %W 1]
  $t tag bind link <ButtonRelease-1> [list ::potato::linkRecolour %W 0]
  $t tag configure activeLink -foreground red
  $t configure -background $world($w,top,bg) -foreground $world($w,ansi,fg) \
               -font $world($w,top,font,created) -insertbackground [reverseColour $world($w,top,bg)]
  font configure $world($w,top,font,created) {*}[font actual $world($w,top,font)]
  $t configure -inactiveselectbackground [$t cget -selectbackground]
  $t tag configure prompt

  $t configure -width $world($w,wrap,at)

  if { $world($w,wrap,indent) == 0 } {
       $t tag configure margins -lmargin2 0
     } else {
       # Size looks fine on Windows, and hopefully should everywhere else, too.
       set size [font measure $world($w,top,font,created) -displayof $t "0"]
       set lm2 "[expr {($world($w,wrap,indent) * 0.75) * $size}]p"
       $t tag configure margins -lmargin2 $lm2
     }

  $t tag configure timestamp -elide 1

  # XTerm / FANSI Colors
  set XTerm [list #000000 #AA0000 #00AA00 #AA5500 #0000AA #AA00AA #00AAAA #AAAAAA \
                  #555555 #FF5555 #55FF55 #FFFF55 #5555FF #FF55FF #55FFFF #FFFFFF \
                  #000000 #00005F #000087 #0000AF #0000D7 #0000FF #005F00 #005F5F \
                  #005F87 #005FAF #005FD7 #005FFF #008700 #00875F #008787 #0087AF \
                  #0087D7 #0087FF #00AF00 #00AF5F #00AF87 #00AFAF #00AFD7 #00AFFF \
                  #00D700 #00D75F #00D787 #00D7AF #00D7D7 #00D7FF #00FF00 #00FF5F \
                  #00FF87 #00FFAF #00FFD7 #00FFFF #5F0000 #5F005F #5F0087 #5F00AF \
                  #5F00D7 #5F00FF #5F5F00 #5F5F5F #5F5F87 #5F5FAF #5F5FD7 #5F5FFF \
                  #5F8700 #5F875F #5F8787 #5F87AF #5F87D7 #5F87FF #5FAF00 #5FAF5F \
                  #5FAF87 #5FAFAF #5FAFD7 #5FAFFF #5FD700 #5FD75F #5FD787 #5FD7AF \
                  #5FD7D7 #5FD7FF #5FFF00 #5FFF5F #5FFF87 #5FFFAF #5FFFD7 #5FFFFF \
                  #870000 #87005F #870087 #8700AF #8700D7 #8700FF #875F00 #875F5F \
                  #875F87 #875FAF #875FD7 #875FFF #878700 #87875F #878787 #8787AF \
                  #8787D7 #8787FF #87AF00 #87AF5F #87AF87 #87AFAF #87AFD7 #87AFFF \
                  #87D700 #87D75F #87D787 #87D7AF #87D7D7 #87D7FF #87FF00 #87FF5F \
                  #87FF87 #87FFAF #87FFD7 #87FFFF #AF0000 #AF005F #AF0087 #AF00AF \
                  #AF00D7 #AF00FF #AF5F00 #AF5F5F #AF5F87 #AF5FAF #AF5FD7 #AF5FFF \
                  #AF8700 #AF875F #AF8787 #AF87AF #AF87D7 #AF87FF #AFAF00 #AFAF5F \
                  #AFAF87 #AFAFAF #AFAFD7 #AFAFFF #AFD700 #AFD75F #AFD787 #AFD7AF \
                  #AFD7D7 #AFD7FF #AFFF00 #AFFF5F #AFFF87 #AFFFAF #AFFFD7 #AFFFFF \
                  #D70000 #D7005F #D70087 #D700AF #D700D7 #D700FF #D75F00 #D75F5F \
                  #D75F87 #D75FAF #D75FD7 #D75FFF #D78700 #D7875F #D78787 #D787AF \
                  #D787D7 #D787FF #D7AF00 #D7AF5F #D7AF87 #D7AFAF #D7AFD7 #D7AFFF \
                  #D7D700 #D7D75F #D7D787 #D7D7AF #D7D7D7 #D7D7FF #D7FF00 #D7FF5F \
                  #D7FF87 #D7FFAF #D7FFD7 #D7FFFF #FF0000 #FF005F #FF0087 #FF00AF \
                  #FF00D7 #FF00FF #FF5F00 #FF5F5F #FF5F87 #FF5FAF #FF5FD7 #FF5FFF \
                  #FF8700 #FF875F #FF8787 #FF87AF #FF87D7 #FF87FF #FFAF00 #FFAF5F \
                  #FFAF87 #FFAFAF #FFAFD7 #FFAFFF #FFD700 #FFD75F #FFD787 #FFD7AF \
                  #FFD7D7 #FFD7FF #FFFF00 #FFFF5F #FFFF87 #FFFFAF #FFFFD7 #FFFFFF \
                  #000000 #121212 #1C1C1C #262626 #303030 #3A3A3A #444444 #4E4E4E \
                  #585858 #626262 #6C6C6C #767676 #808080 #8A8A8A #949494 #9E9E9E \
                  #A8A8A8 #B2B2B2 #BCBCBC #C6C6C6 #D0D0D0 #DADADA #E4E4E4 #EEEEEE]
  for {set i 0} {$i < 256} {incr i} {
    $t tag configure ANSI_fg_xterm$i -foreground [lindex $XTerm $i]
    $t tag configure ANSI_bg_xterm$i -background [lindex $XTerm $i]
  }


  return;

};# ::potato::configureTextWidget

#: proc ::potato::createOutputTags
#: arg t text widget to create tags for
#: desc create the tags used by output text widgets (top boxes and spawn windows)
#: return nothing
proc ::potato::createOutputTags {t} {

  $t tag configure margins
  $t tag configure ANSI_flash
  $t tag configure ANSI_underline
  $t tag configure link;# this has the link style
  $t tag configure weblink;# this tells it it's a webpage link, for binding purposes.
  $t tag configure activeLink;# recolours the link when it's being hovered
  $t tag configure nobacklog;# don't log when doing "log previous output"
  $t tag bind weblink <ButtonRelease-1> [list ::potato::doWebLink %W weblink]
  $t tag configure system
  $t tag configure echo
  foreach x [list r g b c m y x w fg] {
     foreach ground [list bg fg] {
        $t tag configure ANSI_${ground}_$x
        $t tag configure ANSI_${ground}_${x}h
     }
  }
  for {set i 0} {$i < 256} {incr i} {
    $t tag configure ANSI_fg_xterm$i
    $t tag configure ANSI_bg_xterm$i
  }
  $t tag configure ANSI_fg_bg
  $t tag configure center -justify center -lmargin1 0 -lmargin2 0
  $t tag raise ANSI_underline
  $t tag raise link
  $t tag raise activeLink
  $t tag raise system
  $t tag raise center
  $t tag raise echo
  $t tag raise ANSI_flash
  $t tag raise sel

  $t configure -wrap word -highlightthickness 0 -borderwidth 0 -height 1

  return;

};# ::potato::createOutputTags

#: proc ::potato::linkRecolour
#: arg t text widget with the link
#: arg dir 1 to recolour, 0 to return to original colour
#: desc Alter the appearance of a link as the link is entered or left, to show activity
#: return nothing
proc ::potato::linkRecolour {t dir} {
  variable potato;

  if { $dir } {
       $t tag add activeLink {*}[$t tag prevrange "link" "current + 1 char"]
     } else {
       $t tag remove activeLink {*}[$t tag prevrange "activeLink" "current + 1 char"]
     }
  return;

};# ::potato::linkRecolour

#: proc ::potato::doWebLink
#: arg t text widget with the link
#: arg tagname the name of the tag used for web links
#: desc a webpage link has just be clicked in text widget $t. Launch the webpage if possible.
#: return nothing
proc ::potato::doWebLink {t tagname} {

  launchWebPage [$t get {*}[$t tag prevrange $tagname "current + 1 char"]]

  return;

};# ::potato::doWebLink

#: proc ::potato::launchWebPage
#: arg url the webpage to launch
#: desc attempt to load the webpage $url in a browser. This proc may need to be more robust at detecting default browsers.
#: return nothing
proc ::potato::launchWebPage {url} {
  variable misc;

  if { ![string match "http://*" $url] && ![string match "https://*" $url] && ![string match "ftp://*" $url] } {
       set url "http://$url"
     }

  if { $misc(browserCmd) ne "" } {
       #set command [string map [list %1 $url] $misc(browserCmd)]
       # Try and parse out the command; this is up to the first space, if there's no leading quote, or
       # the quoted string if there is.
       if { [string index $misc(browserCmd) 0] eq {"} } {
            # A quoted string.
            set secondQuote [string first {"} $misc(browserCmd) 1]
            if { $secondQuote != -1 } {
                 set lead [string range $misc(browserCmd) 1 [expr {$secondQuote - 1}]]
                 set rest [string range $misc(browserCmd) [expr {$secondQuote + 1}] end]
               }
           } else {
             set space [string first " " $misc(browserCmd) ]
             set lead [string range $misc(browserCmd) 0 [expr {$space - 1}]]
             set rest [string range $misc(browserCmd) [expr {$space + 1}] end]
           }
       if { $lead ne "" } {
            set prefix [auto_execok $lead]
            if { $prefix ne "" } {
                 set command "$prefix [string map [list %1 $url] $rest]"
               }
          }
     } else {
       # Try and figure out what to do. From http://wiki.tcl.tk/557
       switch $::tcl_platform(os) {
          Darwin {
             set command [list open $url]
          }
          HP-UX -
          Linux  -
          SunOS {
            foreach executable {firefox mozilla netscape iexplorer opera lynx
                        w3m links epiphany galeon konqueror mosaic amaya
                        browsex elinks} {
               set executable [auto_execok $executable]
               if { $executable ne "" } {
                    set command [list $executable $url]
                    break;
                  }
            }
          }
          "Windows 95" {
            set command "[auto_execok start] {} [list $url]"
          }
          "Windows NT" {
            set command "[auto_execok start] {} [list [string map [list ^ ^^ & ^&] $url]]"
          }
       }
     }

  if { ![info exists command] || [catch {exec {*}$command &} err] } {
       if { [info exists err] } {
            errorLog "Unable to launch browser via \"$command\"" warning $err
          }
       bell -displayof .
     }

  return;

};# ::potato::launchWebPage

#: proc ::potato::connZero
#: desc Delete everything from the output box for world 0, then insert the text shown.
#: return nothing
proc ::potato::connZero {} {
  variable conn;
  variable world;
  variable potato;
  variable menu;

  if { ![info exists conn(0,textWidget)] || ![winfo exists $conn(0,textWidget)] } {
       return;
     }


  set canvas $conn(0,textWidget)

  $canvas configure -background $world(-1,top,bg)

  $canvas delete all

  set fgcol $world(-1,ansi,fg)

  set logo ::potato::img::logoSmall

  set x 25
  set y 25


  $canvas create image $x $y -anchor nw -image $logo -tags [list logo]
  set textpos [expr {($x * 2) + [image width $logo]}]

  set textpos2 [expr {((700 - $textpos)/2)+$textpos}]

  connZeroAddText $canvas $textpos2 y 1 $potato(name) [list Tahoma 18 bold] [list h1] -width 350
  connZeroAddText $canvas $textpos2 y 1 [T "The Graphical MU* Client for Windows and Linux"] \
    [list Tahoma 16 bold] [list h2] -width 350
  connZeroAddText $canvas $textpos2 y 1 [T "Version %s. Written by Mike Griffiths (%s)" $potato(version) $potato(contact)] \
    [list Tahoma 9 bold] [list h3] -width 350

  foreach {h1(x1) y1 h1(x2) -} [$canvas bbox h1] {break}
  foreach {h2(x1) - h2(x2) -} [$canvas bbox h2] {break}
  foreach {h3(x1) - h3(x2) y2} [$canvas bbox h3] {break}

  set textheight [expr {$y2 - $y1}]
  foreach {- imgy1 - imgy2} [$canvas bbox logo] {break}
  set imageheight [expr {$imgy2 - $imgy1}]

  if { $imageheight > $textheight } {
       set amount [expr {($imageheight - $textheight) / 2}]
       $canvas move h1 0 $amount
       $canvas move h2 0 $amount
       $canvas move h3 0 $amount
       set y [expr {$imgy2+20}]
     } else {
       set amount [expr {($textheight - $imageheight) / 2}]
       $canvas move logo 0 $amount
       set y [expr {$y2+20}]
     }

  unset -nocomplain y1 y2 textheight imageheight imgy1 imgy2

  incr y 15 ;# margin

  set font(link) [list -family Tahoma -size 12 -weight bold -underline 1]
  set font(subhead) [list -family Tahoma -size 12 -weight bold]
  set font(normal) [list -family Tahoma -size 12]
  set font(world) [list -family Tahoma -size 10 -underline 1]
  set font(dot) [list -family Tahoma -size 7]

  set linkcol $world(-1,ansi,link)

  set backup_y $y
  set addressbook [connZeroAddText $canvas 0 y 1 [T "Open Address Book"] $font(link) [list clickable addressbook]]
  foreach {x1 y1 x2 y2} [$canvas bbox $addressbook] {break}
  set width [expr {$x2-$x1}]
  set lines 1
  if { $width > 220 } {
       connZeroAddText $canvas 25 backup_y 0 \u2022 $font(dot)
       $canvas move $addressbook 35 0
       $canvas itemconfigure $addressbook -justify left -anchor w
       connZeroAddText $canvas 25 y 0 \u2022 $font(dot)
       set addnewworld [connZeroAddText $canvas 35 y 1 [T "Add New World"] $font(link) [list clickable addnewworld]]
       $canvas itemconfigure $addnewworld -justify left -anchor w
       set lines 2
     } else {
       set backup_y2 $y
       set addnewworld [connZeroAddText $canvas 0 y 1 [T "Add New World"] $font(link) [list clickable addnewworld]]
       foreach {x1 y1 x2 y2} [$canvas bbox $addnewworld] {break}
       set width [expr {$x2-$x1}]
       if { $width > 220 || $lines > 1} {
            $canvas move $addressbook 350 0
            $canvas move $addnewworld 350 0
            set lines 2
          } else {
            $canvas move $addressbook 233 0
            $canvas coords $addnewworld 466 $backup_y
            set y $backup_y2
          }
     }
  set backup_y3 $y
  set quickconnect [connZeroAddText $canvas 0 y 1 [T "Quick Connection"] $font(link) [list clickable quickconnect]]

  foreach {x1 y1 x2 y2} [$canvas bbox $quickconnect] {break}
  set width [expr {$x2-$x1}]
  if { $lines == 1 && $width < 220 } {
       set y $backup_y
       $canvas coords $addressbook 116 $backup_y
       connZeroAddText $canvas 233 backup_y 0 \u2022 $font(dot)
       $canvas coords $addnewworld 349 $backup_y
       connZeroAddText $canvas 466 backup_y 0 \u2022 $font(dot)
       $canvas coords $quickconnect 582 $backup_y
     } elseif { $lines == 1 } {
       $canvas move $quickconnect 350 0
       connZeroAddText $canvas 350 backup_y 0 \u2022 $font(dot)
     } else {
       connZeroAddText $canvas 25 backup_y3 0 \u2022 $font(dot)
       $canvas move $quickconnect 35 0
       $canvas itemconfigure $quickconnect -justify left -anchor w
     }

  set y [expr {[lindex [$canvas bbox $quickconnect] 3] + 25}]

  $canvas bind clickable <Enter> "[list %W itemconfig current -fill red] ; [list %W configure -cursor hand2]"
  $canvas bind clickable <Leave> "[list %W itemconfig current -fill $linkcol] ; [list %W configure -cursor {}]"
  $canvas bind clickable <Button-1> [list ::potato::connZeroClick %W]


  connZeroAddText $canvas $x y 1 [T "Existing Worlds:"] [list Tahoma 14] [list existing] -justify left -anchor nw

  if { $potato(worlds) > 0 } {
       set worldList [potato::worldList]
       set worldList [lsort -dictionary -index 1 $worldList]
       set first 1
       set height 0
       set prevheight 0
       set dotspace 3
       set linespace 8
       foreach winfo $worldList {
          foreach {w name} $winfo {break}
          if { $first } {
               set startx 35
             } else {
               set startx 355
             }
          set dot [$canvas create text $startx $y -text \u2022 -font $font(dot) -justify left -anchor nw -fill $fgcol]
          foreach {x1 - x2 -} [$canvas bbox $dot] {break}
          set width [expr {$x2 - $x1}]
          set entry [$canvas create text [expr {$startx + $width + $dotspace}] $y -text $name -font $font(world) -tags [list clickable world$w] -justify left -anchor nw -width 600]
          foreach {x1 y1 x2 y2} [$canvas bbox $entry] {break}
          incr width [expr {($x2 - $x1) + $dotspace}]
          set height [expr {$y2 - $y1}]
          if { $width > 310 } {
               if { $first } {
                    incr y [expr {$height + $linespace}]
                  } else {
                    set by [expr {$prevheight + $linespace}]
                    incr y [expr {$by + $height + $linespace}]
                    $canvas move $dot -330 $by
                    $canvas move $entry -330 $by
                    set prevheight 0
                    set first 1
                  }
             } elseif { $first } {
               set first 0
               set prevheight $height
             } else {
               set first 1
               incr y [expr {$height + $linespace}]
               set prevheight 0
             }
       }
     } else {
       set noworlds [T "You don't have any worlds defined yet! Use one of the links above to add a world."]
       connZeroAddText $canvas $x y 1 $noworlds $font(normal) [list] -justify left -anchor nw -width 600
     }

  incr y 50;# widen the gap

  # Fact of the Day
  connZeroAddText $canvas $x y 1 [T "Did you know?"] $font(subhead) [list facthead] -justify left -anchor nw
  connZeroAddText $canvas $x y 1 [connZeroFact] $font(normal) [list fact] -justify left -anchor nw -width 600

  foreach item [$canvas find withtag clickable] {
    $canvas itemconfigure $item -fill $linkcol
  }

  $canvas configure -scrollregion [list 0 0 700 [expr {$y + 50}]]

};# ::potato::connZero

#: proc ::potato::connZeroAddText
#: arg canvas Path to canvas widget
#: arg x x-coord to add text at
#: arg _y Varname holding y-coord to add text at
#: arg incry Should we increment the $_y var by the height of the new text?
#: arg text Text to add
#: arg font Font to add text with
#: arg tags List of tags to give text
#: arg args Optional extra args to the [$canvas create text] command
#: desc Add text to the connZero convas, possibly updaying the y position for the next insert
#: return canvas id of new text
proc ::potato::connZeroAddText {canvas x _y incry text font {tags ""} args} {
  upvar 1 $_y y;
  upvar 1 fgcol fgcol;

  set id [$canvas create text $x $y -text $text -font $font -tags $tags -justify center -fill $fgcol -anchor n {*}$args]
  if { $incry } {
       set bbox [$canvas bbox $id]
       set y [lindex $bbox 3]
       incr y 8;# margin;
     }

  return $id;

};# ::potato::connZeroAdd

#: proc ::potato::connZeroFact
#: desc Return a random fact about Potatoes to display on connZero screen
#: return string to use as a fact
proc ::potato::connZeroFact {} {

  set food [list \
    "Potatoes were the first food to be grown in space, aboard the shuttle Columbia, in 1995." \
    "Potatoes were first eaten more than 6,000 years ago by indigenous people living in the Andes mountains of Peru." \
    "In 1778 Prussia and Austria fought the Potato War in which each side tried to starve the other by consuming their potato crop." \
    "Potatoes are the world's fourth food staple - after wheat, corn and rice." \
    "The world’s largest potato weighed in at 18 pounds, 4 ounces according to the Guinness Book of World Records. That’s enough for 73 portions of medium fries at McDonalds." \
    "There are over 5,000 variety of Potato worldwide, not including MUSH clients." \
  ]

  set client [list \
    "Nearly all of Potato's keyboard shortcuts can be customised via the Options menu." \
    "Potato is the only MUSH client with two input windows." \
    "You can use /commands to perform custom actions when Events run." \
    "You can make Potato your default Telnet client on Windows. You probably can on Linux, too, but I couldn't tell you how." \
    "Potato runs on Windows and Linux." \
    "You can force Potato to load/save its configuration and world files in the same directory as the Potato executable or source code by using the --local command line option. This is useful if you're running it on a flash drive." \
    "Potato can run in any language, and there are now translations available for more than 2 languages! (OK, so that's not a lot.) If you'd like to help translate Potato into another language, please let us know." \
    "If you have ASpell installed on your computer, Potato can use it to perform spellchecking." \
    "Potato can log as HTML to preserve ANSI colours in the output." \
    "Potato is the only modern graphical MU* client that runs on Windows and Linux natively. It should run on MacOS X, too, though it's not as heavily tested." \
    "Potato has full Unicode support, allowing you to MU* in any language on games which support it, such as TinyMUXes." \
  ]

  set stupid [list \
    "Over 99% of the people we asked said Potato was their favourite MUSH client ever. (Survey included two people... they may both have been me.)" \
    "Potato is one of the fastest growing clients on the intertubers." \
    "If Potato can't do it, nobody can. Or maybe you'll want to submit a feature request." \
    "'Potato' is the only word which is pronounced exactly the same in every language on the planet, except for the word 'gullible'." \
    "It's rumoured that the man in our logo, Mr Potato, is the illegitimate son of Mr Peanut, though this has never been substantiated." \
    "Anyone who donates towards Potato's development can request a signed photo of the Potato mascot, Mr Potato." \
  ]

  set allfacts [concat $food $client $stupid]

  set rand [expr {round(floor(rand() * [llength $allfacts]))}]

  return [lindex $allfacts $rand];

};# ::potato::connZeroFact

#: proc ::potato::connZeroClick
#: arg win Canvas widget
#: desc Handle a click on a link in the connZero canvas $win, either to connect to a world, open the address book or add a new world
#: return nothing
proc ::potato::connZeroClick {win} {

  set index [$win find withtag current]
  if { [llength $index] != 1 } {
       return;
     }
  set tags [$win itemcget $index -tags]
  set tags [lsearch -all -inline -not $tags clickable]
  set tags [lsearch -all -inline -not $tags current]
  if { [llength $tags] != 1 } {
       return;
     }
  set tag [lindex $tags 0]
  switch $tag {
    quickconnect {newWorld 1 ; return}
    addnewworld  {newWorld 0 ; return}
    addressbook  {manageWorlds ; return}
  }

  if { [string range $tag 0 4] == "world" } {
       set id [string range $tag 5 end]
       if { [string is integer -strict $id] } {
            potato::newConnectionDefault $id
            return;
          }
     }

  bell -displayof .

  return;

};# ::potato::connZeroClick

#: proc ::potato::!set
#: arg _varname Variable to set
#: arg value Value to set
#: desc Set the variable whose name is in $_varname to $value, if it doesn't exist already
#: return Value of variable named in $_varname
proc ::potato::!set {_varname value} {

  upvar 1 $_varname varname
  if { ![info exists varname] } {
       set varname $value
     }

  return $varname;

};# ::potato::!set

#: proc ::potato::reconnect
#: arg c connection id. Defaults to currently displayed connection.
#: desc reconnect connection id $c, or the currently displayed connection. Wrapper for use by skins, etc.
#: return 1 on successful attempt to reconnect, 0 on error
proc ::potato::reconnect {{c ""}} {

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 } {
       return 0;
     }

  return [connect $c 0];

};# ::potato::reconnect

#: proc ::potato:reconnectAll
#: desc Reconnect all disconnected worlds.
#: return nothing
proc ::potato::reconnectAll {} {

  set ids [connIDs]
  if { ![llength $ids] } {
       bell -displayof .
       return;
     }
  foreach c [connIDs] {
    reconnect $c;
  }

};# ::potato::reconnectAll

#: proc ::potato::ioOpen
#: arg host host to connect to
#: arg port port to connect to
#: desc Called to open a new connection. Wrapper for [socket], to allow later override for ipv6, ssl, etc.
#: return Socket id for reading/writing
proc ::potato::ioOpen {host port} {

  return [socket -async $host $port];

};# ::potato::ioOpen

#: proc ::potato::ioClose
#: arg socket Socket id to close
#: desc Close a MUSH's socket connection. Wrapper for [close].
#: return Result of [close]
proc ::potato::ioClose {socket} {

  return [close $socket];

};# ::potato::ioClose

#: proc ::potato::ioRead
#: arg args Arguments to pass
#: desc Read data from a socket connection. Wrapper for [read]
#: return Data read
proc ::potato::ioRead {args} {

  return [read {*}$args]

};# ::potato::ioRead

#: proc ::potato::ioWrite
#: arg args Arguments to pass
#: desc Write data to a socket connection. Wrapper for [puts]
#: return Nothing
proc ::potato::ioWrite {args} {

  catch {puts {*}$args}
  return;

};# ::potato::ioWrite

#: proc ::potato::connect
#: arg c the connection to connect
#: arg first is this the first time we've tried to connect here? Affects messages, etc.
#: desc start connecting to a world. This doesn't handle the full connection, as we connect -async and wait for a response.
#: desc This connection may be to a proxy server, not the actual game. $hostlist contains a list telling us whether to attempt
#: desc to connect to the primary host ("host"), the secondary host ("host2"), or both ("").
#: return 1 on successful connect, 0 otherwise
proc ::potato::connect {c first} {
  variable conn;
  variable world;
  variable potato;

  if { $c == 0 || $conn($c,connected) != 0 } {
       return 0;# already connected or trying to connect
     }

  set w $conn($c,world)

  catch {after cancel $conn($c,reconnectId)}
  set conn($c,reconnectId) ""

  updateConnName $c
  set conn($c,connected) -1 ;# trying to connect

  set up [up]

  set tmplist [list]
  set hostlist [list]
  lappend tmplist [list $world($w,host) $world($w,port) $world($w,ssl)]
  lappend tmplist [list $world($w,host2) $world($w,port2) $world($w,ssl2)]

  set empty [expr {[$conn($c,textWidget) count -chars 1.0 2.0] == 1}]

  foreach x $tmplist {
    foreach {host port ssl} $x {break}
    if { $host eq "" || ![string is integer -strict $port] } {
         continue; # skip quietly
       }
    if { $ssl && !$potato(hasTLS) } {
         outputSystem $c [T "Unable to connect to %s:%d - SSL not available." $host $port]
         continue;
       }
    lappend hostlist $x
  }

  if { ![llength $hostlist] } {
       outputSystem $c [T "No valid addresses to connect to."]
       disconnect $c 0
       skinStatus $c
       return 0;
     }

  set connected 0
  foreach x $hostlist {
    foreach [list host port ssl] $x {break}
    if { $world($w,proxy) ne "None" && $world($w,proxy,host) ne "" && [string is integer -strict $world($w,proxy,port)] } {
           set has_proxy 1
         } else {
           set has_proxy 0
     }
    if { $has_proxy } {
         set proxy $world($w,proxy)
         outputSystem $c [set conn($c,address,disp) [T "Connecting to %s proxy at %s:%s..." $proxy $world($w,proxy,host) $world($w,proxy,port)]]
         if { [catch {::potato::ioOpen $world($w,proxy,host) $world($w,proxy,port)} fid] } {
              outputSystem $c $fid
              disconnect $c 0
              boot_reconnect $c
              skinStatus $c
              return 0;
            }
          set waitfor "[namespace which -variable conn]($c,fid,success)"
          fileevent $fid writable [list ::potato::connectVerify $fid $waitfor]
          vwait $waitfor
          if { ![info exists conn($c,fid,success)] } {
               set res -1
             } else {
               set res $conn($c,fid,success)
             }
          unset -nocomplain conn($c,fid,success)
          switch -exact $res {
            -1 {
                catch {close $fid}
                disconnect $c 0;
                return 0;
               }
             1 {
                # Success
               }
             default {# Error.
                      outputSystem $c [T "Unable to connect to proxy: %s" $res]
                      disconnect $c 0
                      boot_reconnect $c
                      skinStatus $c
                      return 0;
                     }
          }
       }
    set conn($c,address) $x
    outputSystem $c [set conn($c,address,disp) [T "Connecting to %s:%d..." $host $port]]
    if { $has_proxy } {
         if { [catch {::potato::proxy::${proxy}::connect $fid [lindex $x 0] [lindex $x 1]} msg] } {
              outputSystem $c $msg
              catch {ioClose $fid}
              continue;
            }
          # Successful proxy connection! Huzzah!
       } else {
         if { [catch {::potato::ioOpen $host $port} fid] } {
              outputSystem $c [T "Unable to connect to host %s:%d: %s" $host $port $fid]
              continue;
            }
          set waitfor "[namespace which -variable conn]($c,fid,success)"
          fileevent $fid writable [list ::potato::connectVerify $fid $waitfor]
          vwait $waitfor
          if { ![info exists conn($c,fid,success)] } {
               set res -1
             } else {
               set res $conn($c,fid,success)
             }
          unset -nocomplain conn($c,fid,success)
          switch $res {
            -1 {
                catch {close $fid}
                return 0;
                # Cancelled
               }
             1 {
                # Success!
               }
             default {# Error.
                      outputSystem $c [T "Unable to connect to host %s:%d: %s" $host $port $res]
                      continue;
                     }
          }
       }

    if { $ssl } {
         # We use -request 0 to not bother checking the certificate. Without this, self-signed certificates
         # (which the majority of MUSHes use) fail by default. If we ever allow for more specific filtering
         # of certificates, we'll need to -request 1 -require 1, and modify the verifySSL procedure to do
         # more in-depth checks of the certificate, passing self-signed by default
         # (And fix the error message below to only give the 'make sure port is enabled' message if we
         # have an error, instead of a validation failure)
         if { [catch {::tls::import $fid -command ::potato::connectVerifySSL -request 0 -cipher "ALL"} sslError] || [catch {::tls::handshake $fid} sslError] } {
              # -cipher can probably be ALL:!LOW:!EXP:+SSLv2:@STRENGTH but I'd rather be less secure than risk some games not working
              outputSystem $c [T "Unable to negotiate SSL: %s. Please make sure the port is ssl-enabled." $sslError]
              disconnect $c 0
              continue;
            }
       }

    # Success!
    set connected 1
    break;
  }

  if { !$connected } {
       # All hosts/ports failed. Boo. Try again later.
       disconnect $c 0
       boot_reconnect $c
       skinStatus $c
       return 0;
     }

  set conn($c,id) $fid
  if { $ssl } {
       addProtocol $c ssl
     }

  connectComplete $c

  return 1;

};# ::potato::connect

#: proc ::potato::connectVerify
#: arg fid file descriptor
#: arg statevar name of variable (fully qualified) to set result in
#: arg c connection id
#: desc Verify whether the newly made connection to $fid worked. Set $statevar to 1 on success, or an error message on failure
#: return nothing
proc ::potato::connectVerify {fid statevar} {
  variable conn;
  variable world;

  catch {fileevent $fid writable {}}
  if { [catch {fconfigure $fid -error} err] || $err ne "" } {
       if { $err in [list 1 -1 ""] } {
            set err "Unknown error"
          }
       set $statevar $err
       return;
     }
  set $statevar 1
  return;

};# ::potato::connectVerify


#: proc ::potato::connectComplete
#: arg c connection id
#: desc Called when we've just successfully connected to a world (possibly through a proxy), to actually mark us as connected.
#: return nothing
proc ::potato::connectComplete {c} {
  variable conn;
  variable world;

  set w $conn($c,world)
  set id $conn($c,id)

  set conn($c,connected) 1

  set conn($c,stats,connAt) [clock seconds]
  set conn($c,stats,formatted) [statsFormat 0]
  set conn($c,address,disp) "[lindex $conn($c,address) 0]:[lindex $conn($c,address) 1]"
  incr conn($c,numConnects)
  incr world($w,stats,conns)

  fileevent $id writable {}
  fileevent $id readable {}

  switch $world($w,type) {
     "MUSH" {set translation "\r\n"}
     "MUD"  {set translation "\n"}
     default {set translation "\r\n"}
  }

  set conn($c,id,lineending) $translation
  set conn($c,id,lineending,length) [string length $conn($c,id,lineending)]
  set conn($c,id,lineending,length-1) [expr {[string length $conn($c,id,lineending)]-1}]
  if { $world($w,encoding,start) in [encoding names] } {
       set conn($c,id,encoding) $world($w,encoding,start)
     } else {
       set conn($c,id,encoding) iso8859-1
     }
  # Set encoding/translation to binary, otherwise Tcl will helpfully automatically translate
  # \u00ff (y-umlaut) into char 255 (y-umlaut), and we can't distinguish between the unicode char
  # and a telnet IAC. So, get data in binary format, and convert manually after telnet parsing.
  fconfigure $id -translation binary -encoding binary -eof {} -blocking 0 -buffering none

  set peer [fconfigure $id -peername]
  if { [lindex $peer 0] in [list "" [lindex $peer 1]] } {
       set str [lindex $peer 0]
     } else {
       set str "[lindex $peer 0] ([lindex $peer 1])"
     }
  outputSystem $c [T "Connected - %s - %s" $str [timestamp]]

  set conn($c,telnet,state) 0
  set conn($c,telnet,subState) 0
  set conn($c,telnet,buffer) ""
  set conn($c,telnet,mssp) [list]

  #abc handle stats for tracking time connected to world
  fileevent $id readable [list ::potato::get_mushage $c]
  timersStart $c
  skinStatus $c
  if { [hasProtocol $c ssl] } {
       puts $id ""; # SSL connections seem to hang, so we send a newline and flush
       flush $id
     }
  sendLoginInfo $c

  return;

};# ::potato::connectVerifyComplete

#: proc ::potato::connectVerifySSL
#: arg option one of "error", "verify" or "info"
#: arg args list of further options
#: desc Callback function for tls::import, hacked from tls::callback
#: return varies
proc ::potato::connectVerifySSL {option args} {
  switch -- $option {
    "error" {
      lassign $args chan msg
      return $msg; # We don't use [error] or [return -code error] because
                   # this is callback function, and we can't [catch] it
    }
    "verify" {
      lassign $args chan dept cert rc err
      return;
      return $rc;
      array set c $cert
      if { $rc != 1 } {
           puts "TLS/$chan: verify/$depth: Bad Cert: $err (rc = $rc)"
         } else {
           puts "TLS/$chan: verify/$depth: $c(subject)"
         }
      return $rc;
    }
    "info" {
      lassign $args chan major minor state msg

      if { $msg ne "" } {
           append state ": $msg"
         }
      # For tracing
      upvar #0 tls::$chan cb
      set cb($major) $minor
      #puts "TLS/$chan: $major/$minor: $state"
    }
    default {
      return -code error "bad option \"$option\": must be one of error, info, or verify"
    }
  }

};# ::potato::connectVerifySSL

#: proc ::potato::sendLoginInfo
#: arg c connection id
#: desc If connection $c's world has login info, queue it to be sent after the required delay.
#: return nothing
proc ::potato::sendLoginInfo {c} {
  variable world;
  variable conn;

  after cancel $conn($c,loginInfoId)
  set w $conn($c,world)
  set conn($c,loginInfoId) [after [expr {round($world($w,loginDelay)*1000)}] [list ::potato::sendLoginInfoSub $c]]
  return;

};# ::potato::sendLoginInfo

#: proc ::potato::sendLoginInfoSub
#: arg c connection id
#: desc Send the login info (and the autosends) for connection $c
#: return nothing
proc ::potato::sendLoginInfoSub {c} {
  variable world;
  variable conn;

  set w $conn($c,world)
  if { [string length $world($w,autosend,firstconnect)] && $conn($c,numConnects) == 1 } {
       send_to $c $world($w,autosend,firstconnect)
     }
  if { [string length $world($w,autosend,connect)] } {
       send_to $c $world($w,autosend,connect)
     }
  # Don't check for pw being blank, as some games allow empty passwords
  if { [string length $conn($c,char)] && \
       [llength [set charinfo [lsearch -inline -index 0 $world($w,charList) $conn($c,char)]]] } {
       if { ![catch {format $world($w,loginStr) [lindex $charinfo 0] [lindex $charinfo 1]} str] } {
            send_to_real $c $str [format $world($w,loginStr) [lindex $charinfo 0] \
                                 [string repeat \u25cf [string length [lindex $charinfo 1]]]]
          } else {
            errorLog "Invalid Connect String format for world $w ($world($w,name)): $str"
          }
     }
  if { [string length $world($w,autosend,login)] } {
       send_to $c $world($w,autosend,login)
     }

  return;

};# ::potato::sendLoginInfoSub

#: proc ::potato::timersStart
#: arg c connection id
#: desc begin the timers set up for connection $c. Run at [re]connection, or on manual timer reset (ie, after timers are edited)
#: return nothing
proc ::potato::timersStart {c} {
  variable world;
  variable conn;

  timersStop $c; # cancel any already-running timers

  foreach w [list -1 $conn($c,world)] {
    foreach timerStr [array names world -regexp "^$w,timer,\[^,\]+,cmds\$"] {
      scan $timerStr %*d,timer,%d,cmds timerId
      timersStartOne $c $w $timerId
    }
  }

  return;

};# ::potato::timersStart

#: proc ::potato::timersStartOne
#: arg c connection id
#: arg w world id
#: arg timer timer id
#: desc Begin running timer $timer from world $w in connection $c. Called by [timersStart] for each timer, and also by
#: desc [configureWorldCommit] for new timers. Note that the timer must not be running already, as this proc will not cancel the current instance.
#: return nothing
proc ::potato::timersStartOne {c w timer} {
  variable world;
  variable conn;

  if { !$world($w,timer,$timer,enabled) } {
       return;
     }
  if { $world($w,timer,$timer,continuous) } {
       set conn($c,timer,$timer-$w,count) -1
     } else {
       set conn($c,timer,$timer-$w,count) $world($w,timer,$timer,count)
     }
  timerQueue $c $w $timer 1

  return;

};# ::potato::timersStartOne

#: proc ::potato::timerQueue
#: arg c connection id
#: arg w world id
#: arg timerId timer id
#: arg first Is this the first time this timer has been queued?
#: desc Queue timer $timer from world $w (which is either $c's world or -1 for a global timer) to run for
#: desc connection $c. If $first, use the timer's delay interval as the [after] time, otherwise use it's every interval.
#: return nothing
proc ::potato::timerQueue {c w timerId first} {
  variable world;
  variable conn;

  set type [expr {$first ? "delay" : "every"}]
  set conn($c,timer,$timerId-$w,after) \
           [after [expr {$world($w,timer,$timerId,$type) * 1000}] [list ::potato::timerRun $c $w $timerId]]
  return;

};# ::potato::timerQueue

#: proc ::potato::timerRun
#: arg c connection id
#: arg w world id that timer belongs to (world of connection or -1  for global timers)
#: arg timer timer id
#: desc Send the output associated with a particular timer and, if it hasn't run the max number of times, retrigger it
#: return nothing
proc ::potato::timerRun {c w timer} {
  variable conn;
  variable world;

  if { ![info exists conn($c,timer,$timer-$w,count)] || !$world($w,timer,$timer,enabled) } {
       return;
     }

  # Send the command
  send_to $c $world($w,timer,$timer,cmds) "" [expr {$world($w,echo,timers)}]

  if { $conn($c,timer,$timer-$w,count) != 0 } {
       timerQueue $c $w $timer 0
       if { $conn($c,timer,$timer-$w,count) > 0 } {
            incr conn($c,timer,$timer-$w,count) -1
          }
     }

  return;

};# ::potato::timerRun

#: proc ::potato::timersStop
#: arg c connection id
#: desc if there are any timers running for connection $c, stop them. Run at disconnection, and just before timers are restarted for any reason.
#: return nothing
proc ::potato::timersStop {c} {
  variable conn;

  foreach x [array names conn $c,timer,*,after] {
    after cancel $conn($x)
  }
  array unset conn$c,timer,*

  return;

};# ::potato::timersStop

#: proc ::potato::timerCancel
#: arg w world id
#: arg timer timer id
#: desc Cancel all instances of the timer being used currently by connections
#: return nothing
proc ::potato::timerCancel {w timer} {
  variable world;
  variable conn;

  foreach x [array names conn *,timer,$timer-$w,after] {
    after cancel $conn($x)
  }
  array unset conn *,timer,$timer-$w,*

};# ::potato::timerCancel

#: proc ::potato::skinStatus
#: arg c connection id
#: desc notify the current skin that connection $c's status has changed
#: return nothing
proc ::potato::skinStatus {c} {
  variable potato;

  if { $potato(skin) ne "" && $c ne "" } {
       ::skin::${potato(skin)}::status $c
     }

  return;

};# ::potato::skinStatus

#: proc ::potato::disconnect
#: arg c connection id. Defaults to current connection.
#: arg prompt Ask for confirmation? Defaults to 1
#: desc connection $c is disconnected. Try to close the connection, clear the fid, set the state to disconnected, update the skin status, stop any running timers
#: return nothing
proc ::potato::disconnect {{c ""} {prompt 1}} {
  variable conn;
  variable potato;
  variable world;

  set up [up]

  if { $c eq "" } {
       set c $up
     }
  if { $c == 0 } {
       return;
     }

  set w $conn($c,world)

  if { $conn($c,connected) == 0 } {
       # Make sure we don't auto-reconnect
       cancel_reconnect $c
       skinStatus $c
       return;
     }

  if { $prompt } {
       set ans [tk_messageBox -title $potato(name) -type yesno \
                         -message [T "Disconnect from %d. %s?" $c $world($w,name)]]
       if { $ans ne "yes" } {
            return;
          }
     }

  unset -nocomplain conn($c,fid,success)
  catch {fileevent $conn($c,id) writable {}}
  catch {fileevent $conn($c,id) readable {}}
  uploadEnd $c 1;# cancel any in-progress file upload
  catch {::potato::ioClose $conn($c,id)}
  set conn($c,id) ""
  set prevState $conn($c,connected)
  if { $conn($c,connected) == 1 } {
       # Only print message if we were fully connected, otherwise the "failed to connect" message is sufficient, and
       # we don't need to spam.
       outputSystem $c [T "Disconnected from host. - %s" [timestamp]]
     }
  set conn($c,connected) 0
  set conn($c,address) [list]
  set conn($c,address,disp) [T "Not Connected"]
  timersStop $c
  set conn($c,protocols) [list]
  catch {after cancel $conn($c,loginInfoId)}
  set conn($c,loginInfoId) ""
  set conn($c,outputBuffer) ""
  set conn($c,telnet,buffer,line) ""
  set conn($c,telnet,buffer,codes) ""
  set conn($c,telnet,afterPrompt) 0
  setPrompt $c ""

  if { $conn($c,stats,connAt) != -1 } {
       incr conn($c,stats,prev) [expr {[clock seconds] - $conn($c,stats,connAt)}]
     }
  set conn($c,stats,connAt) -1
  set conn($c,stats,formatted) ""
  if { [focus -displayof .] eq "" && $prevState == 1 } {
       flash $w
     }

  skinStatus $c

  return;

};# ::potato::disconnect

#: proc ::potato::timestamp
#: desc Return the current time, appropriately formatted
#: return time string
proc ::potato::timestamp {} {
  variable misc;

  return [clock format [clock seconds] -format $misc(clockFormat)];

};# ::potato::timestamp

#: proc ::potato::debug_packet
#: arg c connection id
#: arg dir 1 if text was received, 0 if sent
#: arg text the text to print
#: return nothing
proc ::potato::debug_packet {c dir text} {
  variable conn;

  set win(toplevel) .debug_packet_$c
  set win(txt,frame) $win(toplevel).txt
  set win(txt,btxt) $win(txt,frame).btxt
  set win(txt,bhex) $win(txt,frame).bhex
  set win(txt,sb) $win(txt,frame).sb
  if { ![winfo exists $win(toplevel)] } {
       toplevel $win(toplevel)
       wm title $win(toplevel) [T "Packet Debugger for \[%d. %s\]" $c [connInfo $c name]]
       pack [::ttk::frame $win(txt,frame)] -side top -expand 1 -fill both
       pack [text $win(txt,btxt) -wrap word] -side left -expand 0 -fill y
       configureTextWidget $c $win(txt,btxt)
       # Widths need to be set after running configureTextWidget.
       $win(txt,btxt) configure -width 37
       pack [text $win(txt,bhex) -wrap word] -side left -expand 0 -fill y
       configureTextWidget $c $win(txt,bhex)
       $win(txt,bhex) configure -width 102
       pack [::ttk::scrollbar $win(txt,sb) -orient vertical -command [list ::potato::multiscroll [list $win(txt,btxt) $win(txt,bhex)] yview]] -side left -fill y
       $win(txt,btxt) configure -yscrollcommand [list ::potato::multiscrollSet $win(txt,btxt) [list $win(txt,bhex)] $win(txt,sb)]
       $win(txt,bhex) configure -yscrollcommand [list ::potato::multiscrollSet $win(txt,bhex) [list $win(txt,btxt)] $win(txt,sb)]
       bind $win(toplevel) <Destroy> [list set ::potato::conn($c,debugPackets) 0]
       update idletasks
       wm maxsize $win(toplevel) [winfo reqwidth $win(toplevel)] 0
     } else {
       $win(txt,btxt) configure -state normal
       $win(txt,bhex) configure -state normal
     }
  set aE [atEnd $win(txt,btxt)]

  if { !$dir } {
       $win(txt,bhex) insert end "\n"
       $win(txt,btxt) insert end "\n"
       set tag "echo"
     } else {
       set tag ""
     }
  set linelen [$win(txt,btxt) count -chars "end-1char linestart" "end-1char"]
  set prev ""
  for {set i 0} {$i < [string length $text]} {incr i} {
    set char [string index $text $i]
    scan $char %c num
    $win(txt,bhex) insert end [format %02X $num] $tag
    $win(txt,bhex) insert end " " $tag
    switch -exact $char {
      "\n"      {set dchar \u21B5}
      "\r"      {set dchar \u240D}
      "\u0020"  {set dchar \u2423}
      default   {set dchar $char}
    }
    $win(txt,btxt) insert end $dchar $tag
    incr linelen
    if { $char eq $conn($c,id,lineending) || "$prev$char" eq $conn($c,id,lineending) ||
         ($linelen > 0 && ($linelen % 32) == 0) } {
         $win(txt,btxt) insert end "\n"
         $win(txt,bhex) insert end "\n"
         set linelen 0
       }
    set prev $char
  }
  if { !$dir } {
       $win(txt,bhex) insert end "\n\n"
       $win(txt,btxt) insert end "\n\n"
     }
  if { $aE } {
       $win(txt,btxt) see end
       $win(txt,bhex) see end
     }
  $win(txt,btxt) configure -state disabled
  $win(txt,bhex) configure -state disabled

  return;

};# ::potato::debug_packet

#: proc ::potato::get_mushage
#: arg c connection id
#: desc Get pending output for connection $c, parse through any necessary protocols and, if a complete
#: desc line is present, display it. Must also watch for the connection being closed and act accordingly.
#: return nothing
proc ::potato::get_mushage {c} {
  variable conn;
  variable world;

  if { $conn($c,id) eq "" || $conn($c,connected) != 1 } {
       return;
     }

  if { [eof $conn($c,id)] } {
       disconnect $c 0
       return;
     }

  set disc [catch {::potato::ioRead $conn($c,id) 10} text]
  if { $disc } {
       disconnect $c 0
       boot_reconnect $c
       skinStatus $c
       return;
     }
  if { $conn($c,debugPackets) } {
       debug_packet $c 1 $text
     }
  if { [hasProtocol $c telnet] || ($world($conn($c,world),telnet) && ([clock seconds] - $conn($c,stats,connAt)) < 90)} {
       set text [::potato::telnet::process $c $text]
     }

  append conn($c,outputBuffer) $text
  while { [set nextNewline [string first $conn($c,id,lineending) $conn($c,outputBuffer)]] > -1 } {
          set toProcess [encoding convertfrom $conn($c,id,encoding) [string range $conn($c,outputBuffer) 0 [expr {$nextNewline-1}]]]
          set conn($c,outputBuffer) [string range $conn($c,outputBuffer) [expr {$nextNewline+$conn($c,id,lineending,length)}] end]
          get_mushageProcess $c $toProcess
        }
  return;

};# ::potato::get_mushage

proc ::potato::parseANSI {line _arr c} {
  upvar 1 $_arr arr;

  set tagged [list]
  while { [string length $line] } {
           set tags [get_mushageColours arr $c]
           set nextAnsi [string first \x1B $line]
           if { $nextAnsi == -1 } {
                # No more ANSI
                foreach x [split $line ""] {
                  lappend tagged [list $x $tags]
                }
                set line ""
                break;
              } else {
                set curr [string range $line 0 $nextAnsi-1]
                foreach x [split $curr ""] {
                  lappend tagged [list $x $tags]
                }
                set nextM [string first "m" $line $nextAnsi]
                if { $nextM == -1 } {
                     # No 'm' to close ANSI - borked ANSI code received.
                     # Process an ANSI Normal and abort the rest of the line.
                     handleAnsiCodes arr $c 0;
                     set line ""
                     break;
                   }
                set codes [string range $line $nextAnsi+2 $nextM-1]
                handleAnsiCodes arr $c [split $codes ";"]
                set line [string range $line $nextM+1 end]
              }
         }

  return $tagged;

};# ::potato::parseANSI

proc ::potato::flattenParsedANSI {tagged {extras ""}} {

  set prevTags [list]
  set flattened [list]
  set curr ""
  set count 0
  foreach x $tagged {
    incr count

    set char [lindex $x 0]
    set tags [concat [lindex $x 1 0] [lindex $x 1 1] [lindex $x 1 2]]
    if { $tags == $prevTags } {
         append curr $char
       } else {
         if { $curr ne "" || [llength $prevTags] } {
              lappend flattened $curr [concat $prevTags $extras]
            }
         set curr $char
         set prevTags $tags
       }
   }
   if { $curr ne "" || [llength $prevTags] } {
        lappend flattened $curr [concat $prevTags $extras]
      }

  return $flattened;

};# ::potato::flattenParsedANSI

#: proc ::potato::get_mushageProcess
#: arg c connection id
#: arg line line of text
#: desc parse $line and output it for connection $c, obeying triggers
#: return nothing
proc ::potato::get_mushageProcess {c line} {
  variable conn;
  variable world;
  variable misc;
  variable potato;

  set w $conn($c,world)

  if { $world($w,convertNonBreakingSpaces) } {
       set line [string map [list [format %c 160] " "] $line]
     }

  # Handle beep chars
  # '\a' is the beep char defined in PennMUSH in ansi.h. If a game has changed this, or another codebase uses something
  # else, you can change it by.. hrm, nope, you're just screwed.
  set beepCount [llength [lsearch -all [split $line ""] \a]]
  if { $beepCount } {
       # We have beeps. Figure out how many times to beep, and whether to display beeps.
       if { !$world($w,beep,show) } {
            regsub -all -- \a $line {} line;# remove beep chars from output
          }
        switch -exact $world($w,beep,sound) {
          None {set beepCount 0}
          Once {set beepCount 1}
        }
     }

  # The format for $tagged is:
  # [list "string" [list "fgTag" "bgTag" [list "other" "tags"]]]
  set tagged [list]
  # ANSI escape char is \x1B, char code 27
  if { [regsub -all {\x1B.*?m} $line "" lineNoansi] } {
       # We have ANSI
       set toparse $line
       set tagged [parseANSI $line conn $c]
     } else {
       # No ANSI
       set tags [get_mushageColours conn $c]
       foreach x [split $line ""] {
         lappend tagged [list $x $tags]
       }
     }

  set insertedAnything 0 ;# we only flash the window if we have

  eventsMatch $c tagged lineNoansi eventInfo

  set empty 0
  if { $lineNoansi eq "" && $world($w,ignoreEmpty) } {
       set empty 1
     }

  if { !$eventInfo(matched) || !$eventInfo(log) } {
       log $c $lineNoansi
     }

  set tagList [list margins]
  set omit 0
  set noActivity 0
  if { $eventInfo(matched) } {
       if { $eventInfo(omit) } {
            set omit 1
          }
       if { $eventInfo(log) } {
            lappend tagList nobacklog
          }
       if { $eventInfo(noActivity) } {
            set noActivity 1
          }
     }

  # Check to see if the line is to be omitted due to a "/limit"
  if { [llength $conn($c,limited)] } {
       set limit [lindex $conn($c,limited) 3]
       set case [lindex $conn($c,limited) 2]
       switch -exact -- [lindex $conn($c,limited) 0] {
         regexp {set limit [regexp {*}$case $limit $lineNoansi]}
         literal {set limit [string equal {*}$case $limit $lineNoansi]}
         glob {set limit [string match {*}$case $limit $lineNoansi]}
       }
       if { ![lindex $conn($c,limited) 1] } {
            set limit [expr {!$limit}]
          }
       if { $limit } {
            lappend tagList "limited"
          }
     } else {
       set limit 0
     }


  # Flatten
  set inserts [flattenParsedANSI $tagged $tagList]

  if { !$empty && $world($w,ansi,force-normal) } {
       # Force explicit ANSI-normal at the end of the line
       handleAnsiCodes conn $c 0
     }

  set up [up]
  if { !$empty && $world($w,act,newActNotice) && ([focus -displayof .] eq "" || $up != $c) && !$conn($c,idle) } {
       set showNewAct 1
     } else {
       set showNewAct 0
     }
  if { !$empty && !$noActivity && $up != $c && $world($w,act,actInWorldNotice) } {
       deleteSystemMessage $up actIn$c
       outputSystem $up [T "----- Activity in %d. %s -----" $c $world($w,name)] [list center actIn$c]
     }
  set newActStr [T "--------- New Activity ---------"]
  set t $conn($c,textWidget)
  if { [llength [$t tag ranges prompt]] } {
       set endPos prompt.first
     } else {
       set endPos end
     }
  set aE [atEnd $t]
  if { !$empty && !$omit && !$limit && $showNewAct } {
       if { $world($w,act,clearOldNewActNotices) && [llength [$t tag nextrange newact 1.0]] } {
            $t delete {*}[$t tag ranges newact]
          }
       $t insert $endPos "\n" [list newact] $newActStr [list system center newact] [clock seconds] [list newact timestamp]
       set insertedAnything 1
     }

  if { !$empty && !$omit } {
       $t insert $endPos "\n" [lindex [list "" limited] $limit] {*}$inserts
       $t insert $endPos  [clock seconds] [list timestamp]
       set insertedAnything 1
       if { $aE } {
            $t see end
          }
     }

  set spawns $conn($c,spawnAll)
  if { !$empty && $eventInfo(matched) && $eventInfo(spawnTo) ne "" } {
       lappend spawns $eventInfo(spawnTo)
     }
  if { !$empty && [llength $spawns] } {
       set limit [expr {$world($w,spawnLimit,on) ? $world($w,spawnLimit,to) : 0}]
       set insertedAnything 1
       foreach x [parseSpawnList $c $spawns] {
         set sname [lindex $x 0]
         set swidget [lindex $x 1]
         set aE [atEnd $swidget]
         if { [$swidget count -chars 1.0 3.0] != 1 } {
              $swidget insert end "\n" ""
            }
         $swidget insert end "" "" {*}$inserts
         $swidget insert end [clock seconds] [list timestamp]
         if { !$noActivity } {
              ::skin::$potato(skin)::spawnUpdate $c $sname
            }
         if { $aE } {
              $swidget see end
            }
         if { $limit } {
              $swidget delete 1.0 end-${limit}lines
            }
       }
     }

  if { $eventInfo(matched) && [info exists eventInfo(send)] } {
       foreach x $eventInfo(send) {
         send_to_noparse $c $x
       }
     }

  if { $eventInfo(matched) && [info exists eventInfo(input)] } {
       foreach x $eventInfo(input) {
         foreach {window text} $x {break}
         if { $window == 3 } {
              set window [connInfo $c inputFocus]
            }
         showInput $c $window $text 1
         if { $window == 2 } {
              # Make sure the second input window is visible, because we've just put stuff in it
              set conn($c,twoInputWindows) 1
              toggleInputWindows $c 0
            }
        }
     }

  if { !$noActivity && $insertedAnything } {
       if { $up != $c } {
            idle $c
          } elseif { $showNewAct } {
            set conn($c,idle) 1
          }
       if { [focus -displayof .] eq "" } {
            flash $w
          }
     }

  beepNumTimes $beepCount

  skinStatus $c

  update idletasks

  return;

};# ::potato::get_mushageProcess

#: proc ::potato::beepNumTimes
#: arg num Number of remaining times to beep
#: desc Beep $num times, with a brief delay between each beep. To avoid locking up the app, this proc calls itself recursively to perform each subsequent beep, using [after]
#: return nothing
proc ::potato::beepNumTimes {num} {

  if { $num == 0 } {
       return;
     }

  bell -displayof .

  after 125 [list ::potato::beepNumTimes [expr {$num - 1}]];

  return;

};# ::potato::beepNumTimes

#: proc ::potato::parseSpawnList
#: arg c Connection id to create new spawns from
#: arg spawns A list of spawn window names, supplied by the user
#: desc For each spawn window name given in $spawns, create a spawn window (if it doesn't exist and we have space), using the info from the connection $c
#: return the list of text-widget and spawn names paths for all the spawn windows successfully created/existing
proc ::potato::parseSpawnList {c spawns} {
  variable conn;

  if { ![llength $spawns] } {
       return; # Optimize for cases when there is no spawning
     }

  set returnList [list]

  # OK, first, let's go through and get a list of valid names
  foreach x $spawns {
    if { $x eq "" } {
         # Ignore empty ones silently
         continue;
       }
       set this [createSpawnWindow $c $x]
       if { [llength $this] == 1 } {
            outputSystem $c [T "Unable to create new spawn window \"%s\": %s" $x [lindex $this 0]]
          } else {
            lappend returnList $this
          }
  }
  # Return the list of successful ones
  return $returnList;

};# ::potato::parseSpawnList

#: proc ::potato::validSpawnName
#: arg name Name to check
#: arg onlyspawns Should we only check if it's a valid spawn name (1), or also allow "_main", "_none" and "_all"?
#: desc Check if the name is a valid spawn name. Optionally, also allow for "_main" and "_all". Names are case-insensitive, and valid names are always returned lower-case.
#: return empty string if invalid, lower-cased $name if valid
proc ::potato::validSpawnName {name onlyspawns} {

  if { ![string length [string trim $name]] } {
       return "";
     }

  set name [string tolower $name]

  if { [string index $name 0] eq "_" } {
       if { $onlyspawns } {
            return "";
          }
       if { $name ni [list "_main" "_all" "_none"] } {
            return "";
          }
       return $name;
     }

  return $name;

};# ::potato::validSpawnName

#: proc ::potato::findSpawn
#: arg c connection id
#: arg name Spawn name
#: desc Find the specified spawn for the connection
#: return position of the spawn in the spawnlist for conn $c
proc ::potato::findSpawn {c name} {
  variable conn;

  return [lsearch -exact -nocase -index 0 $conn($c,spawns) $name];

};# ::potato::findSpawn

#: proc ::potato::createSpawnWindow
#: arg c connection id
#: arg name Spawn window name
#: desc Attempt to create a spawn window $name using settings from connection $c
#: return empty string on success, error message on failure
proc ::potato::createSpawnWindow {c name} {
  variable misc;
  variable conn;
  variable potato;

  if { [set name [validSpawnName $name 1]] eq "" } {
       return [list [T "Invalid Spawn Name"]];
     } elseif { [set find [findSpawn $c $name]] != -1 } {
       # Already exists
       return [lindex $conn($c,spawns) $find];
     } elseif { $misc(maxSpawns) > 0 && [llength $conn($c,spawns)] >= $misc(maxSpawns) } {
       return [list [T "Too many spawns"]];
     } else {
       # set it up.
       set made [makeTextFrames $c]
       set made [linsert $made 0 $name]
       lappend conn($c,spawns) $made
       ::skin::$potato(skin)::addSpawn $c $made
       return $made;
     }

};# ::potato::createSpawnWindow

#: proc ::potato::destroySpawnWindow
#: arg c connection id
#: arg name Spawn name
#: desc Destroy the spawn window $name from connection $c. We also notify the skin of its impending destruction
#: return nothing
proc ::potato::destroySpawnWindow {c name} {
  variable conn
  variable potato;

  set pos [findSpawn $c $name]
  if { $pos == -1 } {
       return; # no such spawn
     }

  set spawn [lindex $conn($c,spawns) $pos]
  set conn($c,spawns) [lreplace $conn($c,spawns) $pos $pos]
  ::skin::$potato(skin)::delSpawn $c $name
  foreach x [lrange $spawn 1 end] {
    destroy $x
  }

  return;

};# ::potato::destroySpawnWindow

#: proc ::potato::atEnd
#: arg t text widget
#: desc is the text widget $t scrolled to the bottom?
#: return 1 or 0
proc ::potato::atEnd {t} {

  set yview [$t yview]
  if { [lindex $yview 1] == 1.0 } {
       return 1;
     }
  return 0;

};# ::potato::atEnd

#: proc ::potato::handleAnsiCodes
#: arg _arr Array holding ANSI meta data, as $_arr($c,ansi,*), to be upvar'd
#: arg c connection id
#: arg codes List of ansi codes
#: desc adjust the conn($c,ansi,*) variables to change the colours for ansi code $code
#: return nothing
proc ::potato::handleAnsiCodes {_arr c codes} {
  upvar 1 $_arr arr;

  set xtermStarts [list 38 48]
  set ansiColors [list x r g y b m c w]
  set highlightable [concat $ansiColors [list fg bg]]
  while { [llength $codes] } {
    set curr [lindex $codes 0]
    set codes [lrange $codes 1 end]
    # We have to use a while loop, not a foreach, because XTerm/FANSI codes eat more than one
    # list element. Boo.

    switch -exact -- $curr {
       0 { # ANSI Normal
          set arr($c,ansi,fg) fg
          set arr($c,ansi,bg) bg
          set arr($c,ansi,highlight) 0
          set arr($c,ansi,underline) 0
          set arr($c,ansi,flash) 0
          set arr($c,ansi,inverse) 0
         }
       1 { # ANSI Highlight
           if { !$arr($c,ansi,highlight) } {
                set arr($c,ansi,highlight) 1
                # Only add "h" if we have a normal ANSI (not XTerm/FANSI) color or normal fg/bg
                if { $arr($c,ansi,fg) in $highlightable } {
                     append arr($c,ansi,fg) h
                   }
                if { $arr($c,ansi,bg) in $highlightable } {
                     append arr($c,ansi,bg) h
                   }
              }
         }
       4 { # ANSI Underline
           set arr($c,ansi,underline) 1
         }
       5 { # ANSI Flash
           set arr($c,ansi,flash) 1
         }
       7 { # ANSI Inverse
           set arr($c,ansi,inverse) 1
         }
      30 -
      31 -
      32 -
      33 -
      34 -
      35 -
      36 -
      37 {# ANSI foreground color
          if { $arr($c,ansi,highlight) } {
               set arr($c,ansi,fg) "[lindex $ansiColors [expr {$curr - 30}]]h"
             } else {
               set arr($c,ansi,fg) [lindex $ansiColors [expr {$curr - 30}]]
             }
         }
      40 -
      41 -
      42 -
      43 -
      44 -
      45 -
      46 -
      47 {# ANSI background color
          if { $arr($c,ansi,highlight) } {
               set arr($c,ansi,bg) "[lindex $ansiColors [expr {$curr - 40}]]h"
             } else {
               set arr($c,ansi,bg) [lindex $ansiColors [expr {$curr - 40}]]
             }
         }
      38 -
      48 {# XTerm color code (used by FANSI)
          if { [llength $codes] < 2 || [lindex $codes 0] ne "5" } {
               return;# FANSI codes are 38;5;<fgcolor> or 48;5;<bgcolor>. Abort on invalid code
             }
          set xterm [lindex $codes 1]
          set codes [lrange $codes 2 end]
          if { ![string is integer -strict $xterm] || $xterm < 0 || $xterm > 255 } {
               return;# Invalid XTerm color
             }
          if { $curr == 38 } {
               set which fg
             } else {
               set which bg
             }
          set arr($c,ansi,$which) "xterm$xterm"
         }
    };# switch
  };# while

  return;

};# ::potato::handleAnsiCodes

#: proc ::potato::get_mushageColours
#: arg _arr Array to use for ANSI metadata, to be upvar'd
#: arg c connection id
#: desc Using the current ANSI settings for connection $c, return a list in the form [list fg_tag bg_tag [list other tags]]
#: desc Where fg_tag and bg_tag are an empty string, or the correct text widget tag for applying the current ANSI colour in use,
#: and other tags are the tags for applying ANSI underline, flash, etc.
#: return [list] of text widget tags
proc ::potato::get_mushageColours {_arr c} {
  upvar 1 $_arr arr;
  variable conn;
  variable world;

  set w $conn($c,world)
  set downgrade [expr {!$world($w,ansi,xterm)}]

  set fg $arr($c,ansi,fg)
  set bg $arr($c,ansi,bg)
  set other [list]
  if { $arr($c,ansi,inverse) } {
       # Invert colors
       foreach [list fg bg] [list $bg $fg] {break;}
     }

  if { $fg in [list "bg" "bgh"] } {
       set fg ANSI_fg_bg
     } elseif { $fg in [list "" "fg"] } {
       set fg ""
     } else {
       if { $downgrade } {
            set fg [downgradeXTERM $fg 0]
          }
       set fg ANSI_fg_$fg
     }
  if { $bg in [list "bg" "bgh" ""] } {
       # Nothing. Normal BG is the default.
       set bg ""
     } else {
       if { $downgrade } {
            set bg [downgradeXTERM $bg 1]
          }
       set bg ANSI_bg_$bg
     }

  if { $arr($c,ansi,flash) } {
       lappend other ANSI_flash
     }
  if { $arr($c,ansi,underline) } {
       lappend other ANSI_underline
     }

  return [list $fg $bg $other];

};# ::potato::get_mushageColours

#: proc ::potato::downgradeXTERM
#: arg col color
#: arg bg is this for a bg color?
#: desc If $col is an XTERM color, downgrade it to the appropriate 16-color palette
#: desc (or 8-color palette, if $bg).
#: return downgraded color
proc ::potato::downgradeXTERM {col bg} {

  if { [string range $col 0 4] ne "xterm" } {
       return $col;# not xterm anyway
     }

  set col [string range $col 5 end]

  set downgrades [list x r g y b m c w xh rh gh yh bh mh ch wh \
                       x b b b bh bh g c b bh bh bh gh g c bh \
                       bh bh gh gh ch ch bh bh gh gh gh ch ch ch gh gh \
                       gh ch ch ch r m m bh bh bh g g c bh bh bh \
                       g g g c c bh gh g g c ch ch gh gh gh ch \
                       ch ch gh gh gh gh ch ch r r m m mh mh g r \
                       m m mh mh g g g c bh bh g g g c ch ch \
                       gh gh gh gh ch ch gh gh gh gh wh wh r m m mh \
                       mh mh rh rh rh mh mh mh y y mh mh mh mh y y \
                       y mh mh mh yh yh yh wh wh wh yh yh yh yh wh wh \
                       r rh mh mh mh mh rh rh rh mh mh mh y y y mh \
                       mh mh y y yh mh mh mh y y yh wh wh wh yh yh \
                       yh wh wh wh rh rh rh mh mh mh rh rh rh mh mh mh \
                       rh rh mh mh mh mh yh yh wh wh wh wh yh yh yh wh \
                       wh wh yh yh yh yh wh wh x x xh xh xh xh xh xh \
                       xh w w w w w w w wh wh wh wh wh wh wh wh]

  set col [lindex $downgrades $col]
  if { $bg } {
       set col [string index $col 0]
     }

  return $col;

};# ::potato::downgradeXTERM

#: proc ::potato::arraySubelem
#: arg _arrName name of array
#: arg prefix Prefix to match (glob pattern)
#: desc Return a list of all the elements in the array $_arrName in the caller's space which match the {^$prefix,[^,]+$}. If none, check for unique ^$prefix,[^,]+ prefixes to keys.
#: return List of matching array elements
proc ::potato::arraySubelem {_arrName prefix} {
  upvar 1 $_arrName arrName

  set first [array names arrName -regexp "[regsub -all {[^[:alnum:]]} $prefix {\\&}],\[^,\]+$"]
  if { [llength $first] } {
       return $first;
     }
  set ret [list]
  set len [string length $prefix]
  incr len
  foreach x [array names arrName -regexp "[regsub -all {[^[:alnum:]]} $prefix {\\&}],\[^,\]+,.*$"] {
    set str [string range $x 0 [string first "," $x $len]-1]
    if { $str ne "" && $str ni $ret } {
         lappend ret $str
       }
  }
  return $ret;

};# ::potato::arraySubelem

#: proc ::potato::removePrefix
#: arg list List to work on
#: arg prefix Prefix string to remove
#: desc For each element in $list, remove the prefix $prefix. We assume all elements in the list have the prefix, and just remove the required number of characters.
#: return Modified list
proc ::potato::removePrefix {list prefix} {

  if { ![llength $list] } {
       return;
     }

  set return [list]
  set length [string length $prefix]
  incr length
  foreach x $list {
     lappend return [string range $x $length end]
  }

  return $return;

};# ::potato::removePrefix

#: proc ::potato::boot_reconnect
#: arg c connection id
#: desc if auto reconnect is on for this connection, set up the reconnection.
#: return nothing
proc ::potato::boot_reconnect {c} {
  variable conn;
  variable world;

  after cancel conn($c,reconnectId)
  set w $conn($c,world)
  if { $world($w,autoreconnect) && $world($w,autoreconnect,time) > 0 } {
       set conn($c,reconnectId) [after [expr { $world($w,autoreconnect,time) * 1000}] [list ::potato::reconnect $c]]
       outputSystem $c [T "Auto-reconnect in %s..." [timeFmt $world($w,autoreconnect,time) 1]]
     } else {
       set conn($c,reconnectId) ""
     }

  skinStatus $c
  return;

};# ::potato::boot_reconnect

#: proc ::potato::cancel_reconnect
#: arg c connection id
#: desc an auto-reconnect has been scheduled for connection $c; cancel it.
#: return nothing
proc ::potato::cancel_reconnect {c} {
  variable conn;

  if { $conn($c,reconnectId) ne "" } {
       after cancel $conn($c,reconnectId)
       set conn($c,reconnectId) ""
       outputSystem $c [T "Auto-reconnect cancelled."]
     }

  return;

};# cancel_reconnect

#: proc ::potato::outputSystem
#: arg c connection id
#: arg msg Message to display
#: arg tags Optional. List of extra tags to use, as well as "margin" and "system" (normally "echo" or "center")
#: desc Show a system message for connection $c (possibly printing to it's spawn windows, too, dependent on the user setting)
#: return nothing
proc ::potato::outputSystem {c msg {tags ""}} {
  variable conn;
  variable world;

  if { $c == 0 || ![info exists conn($c,textWidget)] || ![winfo exists $conn($c,textWidget)] } {
       return;
     }
  set alltags [concat $tags [list system margins]]
  set aE [atEnd $conn($c,textWidget)]
  set empty [expr {[$conn($c,textWidget) count -chars 1.0 2.0] == 1}]

  if { [llength [$conn($c,textWidget) tag ranges prompt]] } {
       set endPos "prompt.first"
     } else {
       set endPos "end"
     }
  if { [$conn($c,textWidget) count -chars 1.0 3.0] > 1 } {
       set inserts [list "\n" $tags $msg $alltags [clock seconds] [concat $tags timestamp]]
     } else {
       set inserts [list $msg $alltags [clock seconds] [concat $tags timestamp]]
     }
  $conn($c,textWidget) insert $endPos {*}$inserts
  if { $aE } {
       $conn($c,textWidget) see end
     }

  if { $world($conn($c,world),spawnSystem) } {
       foreach x $conn($c,spawns) {
         set t [lindex $x 1]
          set aE [atEnd $t]
          if { [$t count -chars 1.0 3.0] > 1 } {
               set newline "\n"
             } else {
               set newline ""
             }
          $t insert end $newline $tags $msg $alltags [clock seconds] [concat timestamp $tags]
          if { $aE } {
               $t see end
             }
       }
     }

  update idletasks

  return;

};# ::potato::outputSystem

#: proc ::potato::verbose
#: arg c connection id
#: arg msg Message to display
#: desc If conn $c is set to display verbose messages, output $msg as a system message
#: return 1 if message was displayed, 0 if not
proc ::potato::verbose {c msg} {
  variable world;
  variable conn;

  if { $c == -1 || !$world($conn($c,world),verbose) } {
       return 0;
     }

  ::potato::outputSystem $c $msg
  return 1;

};# ::potato::verbose

#: proc ::potato::deleteSystemMessage
#: arg c connection id
#: arg tag Tag to delete
#: desc For connection $c, delete all messages with the tag $tag, including in spawn windows if system messages are spawned
#: return nothing
proc ::potato::deleteSystemMessage {c tag} {
  variable conn;
  variable world;

  if { ![info exists conn($c,textWidget)] || ![winfo exists $conn($c,textWidget)] } {
       return;
     }
  catch {$conn($c,textWidget) delete {*}[$conn($c,textWidget) tag ranges $tag]}
  if { $world($conn($c,world),spawnSystem) } {
       foreach x $conn($c,spawns) {
          catch {[lindex $x 1] delete {*}[[lindex $x 1] tag ranges $tag]}
       }
     }

  return;

};# ::potato::deleteSystemMessage

#: proc ::potato::toggleConn
#: arg dir 1 to toggle forwards, -1 to toggle backwards
#: desc go to the next (1) or previous (-1) connection, or do nothing if there is only one connection
#: return nothing
proc ::potato::toggleConn {dir} {
  variable conn;

  set up [up]

  if { $up == 0 } {
       return;
     }

  set list [connIDs]
  if { [llength $list] < 2 } {
       return;
     }
  set pos [lsearch -exact -integer -sorted $list $up]
  if { $pos == -1 } {
       return; # should never happen
     }

  if { $pos == 0 && $dir == -1 } {
       showConn [lindex $list end]
     } elseif { $pos == [expr {[llength $list]-1}] && $dir == 1 } {
       showConn [lindex $list 0]
     } else {
       incr pos $dir
       showConn [lindex $list $pos]
     }

  tooltipLeave .
  return;

};# ::potato::toggleConn

#: proc ::potato::showConn
#: arg c the connection to show
#: arg main if misc(toggleShowMainWindow) is true, should we show _main instead of a spawn?
#: desc show the window holding connection $c. This may require updating the list of worlds
#: desc with new activity (and setting the idle var for the connection), and so on (meaning: maybe more?).
#: return nothing
proc ::potato::showConn {c {main 1}} {
  variable potato;
  variable world;
  variable conn;
  variable menu;
  variable misc;

  if { $c eq "" || ![info exists conn($c,world)] } {
       bell -displayof .
       return;
     }

  set prevUp [up]
  if { $prevUp ne "" } {
       ::skin::$potato(skin)::unshow $prevUp
     }

  set state [expr {$c != 0 && $conn($c,connected) == 1}]

  set potato(up) $c
  ::skin::$potato(skin)::show $c
  setAppTitle
  skinStatus $c
  if { $prevUp ne "" } {
       unidle $c
       skinStatus $prevUp
     }
  if { $misc(toggleShowMainWindow) && $main } {
       showSpawn $c _main
     }
  if { $c == -1 } {
       update
     }
  ::skin::$potato(skin)::inputWindows $c [expr {$conn($c,twoInputWindows) + 1}]

  return;

};# ::potato::showConn

#: proc ::potato::showSpawn
#: arg c connection id.
#: arg spawn spawn name.
#: desc Assuming it exists, switch to connection $c and show it's spawn window $spawn. Otherwise, beep.
#: return nothing
proc ::potato::showSpawn {c spawn} {
  variable conn;
  variable potato;

  if { $c eq "" } {
       set c [up]
     }

  if { [lsearch -nocase -exact [list "" "_main" {Main Window}] $spawn] > -1 } {
       # Actually requesting main window, not a spawn
       showConn $c 0
       ::skin::$potato(skin)::showSpawn $c ""
       return;
     }

  if { $c == 0 } {
       # Impossible to have spawns
       bell -displayof .
       return;
     }

  if { ![info exists conn($c,id)] } {
       # No such connection
       bell -displayof .
       return;
     }

  # We have two choices here:
  # 1) Show connection $c, then request that spawn $spawn be shown. If $spawn is not an existing spawn,
  #    we'll end up viewing connection $c's main window.
  # 2) Check to see if spawn $spawn exists in conn $c, and only show the conn/request the spawn be shown
  #    if it does. If the spawn does not exist, we keep viewing whichever window is currently up.
  # Both require confirmation that conn $c exists before they do anything (else buggy things happen).
  # For now, favour option 2.

  if { [findSpawn $c $spawn] == -1 } {
       bell -displayof .
       return;
     } else {
       showConn $c
       ::skin::$potato(skin)::showSpawn $c $spawn
    }

  return;

};# ::potato::showSpawn

#: proc ::potato::setAppTitle
#: desc Set the title for the main window .
#: return nothing
proc ::potato::setAppTitle {} {
  variable potato;
  variable world;
  variable conn;

  set c [up]
  if { $c eq "" || $c == 0 } {
       wm title . [T "%s Version %s" $potato(name) $potato(version)]
     } else {
       wm title . "$potato(name) - \[$c. $world($conn($c,world),name)\]"
     }

  return;

};# ::potato::setAppTitle

#: proc ::potato::showSkin
#: arg skin name of skin to show
#: desc Do everything necessary to show the skin $skin. The previous skin, if any, is already unpacked.
#: return nothing
proc ::potato::showSkin {skin} {
  variable menu;
  variable potato;
  variable running;

  ::skin::${skin}::packskin
  set potato(skin) $skin
  set potato(skin,version) [set ::skin::${skin}::skin(version)]

  if { $running } {
       set conns [concat 0 [connIDs]]
       foreach c $conns {
         ::skin::${skin}::import $c
       }
       set c [up]
       if { $c eq "" } {
            set c [lindex $conns end]
          } else {
            set potato(up) ""
            showConn $c
          }
     }


  return;

};# ::potato::showSkin

#: proc ::potato::unshowSkin
#: desc Unshow the current skin
#: return nothing
proc ::potato::unshowSkin {} {
  variable potato;
  variable menu;

  if { $potato(skin) ne "" } {
       ::skin::$potato(skin)::unpackskin
     }

  return;

};# ::potato::unshowSkin

#: proc ::potato::closeConn
#: arg c connection id. Defaults to ""
#: arg autoDisconnect if connection is still open, auto-disconnect it? Defaults to 0.
#: arg prompt if connection was quick/temp, prompt to save? 0 = do not save, 1 = prompt, 2 = auto-save.
#: desc close connection $c, or the current connection if $c is "". Never close connection 0.
#: return nothing
proc ::potato::closeConn {{c ""} {autoDisconnect 0} {prompt 1}} {
  variable conn;
  variable potato;
  variable world;
  variable misc;

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 } {
       return;
     }

  set w $conn($c,world)
  set worldname $world($w,name)
  if { $conn($c,connected) == 0 } {
       set disconnect 0
     } elseif { $autoDisconnect } {
       set disconnect 1
     } else {
       set ans [tk_messageBox -title "$potato(name) - \[$c. $worldname\]" -type yesno \
           -message [T "Disconnect and close the window?"]]
       if { $ans eq "yes" } {
            set disconnect 1
          } else {
            return;
          }
     }

  if { [info exists conn($c,stats,prev)] && [string is integer -strict $conn($c,stats,prev)] } {
       incr world($w,stats,time) $conn($c,stats,prev)
     }

  if { $world($w,temp) } {
       if { $prompt == 2 } {
            set world($w,temp) 0
          } elseif { $prompt == 1 } {
            if { $autoDisconnect } {
                 set type "yesno"
               } else {
                 set type "yesnocancel"
               }
            set ans [tk_messageBox -title "$potato(name) - \[$c. $worldname\]" -type $type \
                -message [T "Do you want to save this world for later?"]]
            if { $ans eq "yes" } {
                 set world($w,temp) 0
               } elseif { $ans eq "cancel" } {
                 return;
               }
          }
     }

  if { $disconnect } {
       disconnect $c 0
     } else {
       cancel_reconnect $c
     }
  if { $c == [up] } {
       set allconns [lsort -integer -index 0 [connList]]
       if { [llength $allconns] == 1 } {
            showConn 0
          } else {
            if { [set pos [lsearch -exact -index 0 $allconns $c]] == 0 } {
                 set next [lindex [lindex $allconns 1] 0]
               } else {
                 set next [lindex [lindex $allconns [expr {$pos-1}]] 0]
               }
            showConn $next
         }
     } else {
       skinStatus [up]
     }
  foreach x $conn($c,spawns) {
    destroySpawnWindow $c [lindex $x 0]
  }

  ::skin::$potato(skin)::export $c
  set t $conn($c,textWidget)
  foreach x [removePrefix [arraySubelem conn $c,log] $c,log] {
    catch {flush $x}
    catch {close $x}
    unset conn($c,log,$x)
  }
  catch {destroy {*}$conn($c,widgets) $conn($c,input1) $conn($c,input2)}
  if { [info exists conn($c,userAfterIDs)] } {
       foreach x $conn($c,userAfterIDs) {
         after cancel $x ;# Cancel all "/at"s.
       }
     }
  array unset conn $c,*
  ::skin::$potato(skin)::status $c
  destroy $t

  return;

};# ::potato::closeConn

#: proc ::potato::unidle
#: arg c the connection to mark as no longer being idle
#: desc mark a connection as not being idle, by setting it's idle var to 0 and notifying the current skin to remove it from the list of idle worlds
#: return nothing
proc ::potato::unidle {c} {
  variable conn;

  if { !$conn($c,idle) } {
       return; # not idle anyway
     }
  set conn($c,idle) 0
  skinStatus $c

  return;

};# ::potato::unidle

#: proc ::potato::idle
#: arg c the connection to mark as being idle
#: desc mark a connection as being idle (having new activity), by setting it's idle var to 1 and notifying the current skin to add it to the list of idle worlds
#: return nothing
proc ::potato::idle {c} {
  variable conn;

  if { $conn($c,idle) } {
       return; # already idle
     }
  set conn($c,idle) 1
  skinStatus $c

  return;

};# ::potato::idle

#: proc ::potato::connList
#: desc returns a list, where each element is a sublist of connection id, world name and status. The list is not sorted in any particular order
#: return [list] of connection [list]s
proc ::potato::connList {} {
  variable conn;
  variable world;

  set retlist [list];
  foreach c [connIDs] {
     lappend retlist [list $c $world($conn($c,world),name) [potato::status $c]]
  }

  return $retlist;

};# ::potato::connList

#: proc ::potato::worldList
#: desc returns a list, where each element is a sublist of world id and world name. The list is not sorted in any particular order.
#: desc Does not include world "-1", which is internal and used for "connection 0", the welcome screen.
#: return [list] of world [list]s
proc ::potato::worldList {} {
  variable world;

  set worldList [list]
  foreach w [worldIDs] {
       set name $world($w,name)
       if { $world($w,temp) } {
            append name " " [T "(Temp)"]
          }
       lappend worldList [list $w $name]
  }

  return $worldList;

};# ::potato::worldList

#: proc ::potato::manageWorlds
#: desc Show the "Manage Worlds" window
#: return nothing
proc ::potato::manageWorlds {} {
  variable world;
  variable manageWorlds;

  set win .manageWorlds
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  wm withdraw $win
  wm title $win [T "Manage Worlds"]
  set manageWorlds(toplevel) $win

  pack [set frame [::ttk::frame $win.f]] -side left -expand 1 -fill both
  pack [set top [::ttk::frame $frame.top]] -side top -expand 1 -fill both
  pack [set btm [::ttk::frame $frame.btm]] -side top -expand 0 -fill both
  pack [set left [::ttk::frame $top.left]] -side left -expand 0 -fill both
  set gTree [::ttk::treeview $left.gtree -columns Group -show tree -selectmode browse]
  set manageWorlds(gTree) $gTree
  set sbX [::ttk::scrollbar $left.sbX -orient horizontal -command [list $gTree xview]]
  set sbY [::ttk::scrollbar $left.sbY -orient vertical -command [list $gTree yview]]
  grid_with_scrollbars $gTree $sbX $sbY
  $gTree configure -xscrollcommand [list $sbX set]
  $gTree configure -yscrollcommand [list $sbY set]

  $gTree column #0 -width 65
  $gTree column Group -stretch 1 -width 115

  pack [set right [::ttk::frame $top.right]] -side left -expand 1 -fill both
  set wTree [::ttk::treeview $right.wtree -columns [list "World Name" "Address" "Char"] \
         -show "headings" -selectmode browse]
  set manageWorlds(wTree) $wTree
  set sbX [::ttk::scrollbar $right.sbX -orient horizontal -command [list $wTree xview]]
  set sbY [::ttk::scrollbar $right.sbY -orient vertical -command [list $wTree yview]]
  $wTree heading "World Name" -text [T "World Name"]
  $wTree heading "Address" -text [T "Address"]
  $wTree heading "Char" -text [T "Char"]
  $wTree column "World Name" -stretch 1 -width 170
  $wTree column "Address" -stretch 1 -width 160
  $wTree column "Char" -stretch 0 -width 75
  grid_with_scrollbars $wTree $sbX $sbY
  $wTree configure -xscrollcommand [list $sbX set]
  $wTree configure -yscrollcommand [list $sbY set]

  $wTree tag configure deleted -foreground red
  pack [set btnFrame [::ttk::frame $btm.btns]] -side top -anchor n -expand 0 -fill none -pady 10 -padx 10
  pack [::ttk::button $btnFrame.add -text [T "New World"] -command [list ::potato::newWorld 0]] -side left -padx 5
  pack [set copy [::ttk::button $btnFrame.copy -text [T "Copy World"] \
           -command [list ::potato::manageWorldsBtn "copyworld"]]] -side left -padx 5
  pack [set edit [::ttk::button $btnFrame.edit -text [T "Edit World"] \
           -command [list ::potato::manageWorldsBtn "editworld"]]] -side left -padx 5
  pack [set del [::ttk::button $btnFrame.del -text [T "Delete World"] \
           -command [list ::potato::manageWorldsBtn "delworld"]]] -side left -padx 5
  set manageWorlds(copyBtn) $copy
  set manageWorlds(editBtn) $edit
  set manageWorlds(delBtn) $del

  pack [set btnFrame2 [::ttk::frame $btm.btns2]] -side top -anchor n -expand 0 -fill none -pady 10 -padx 10
  pack [set newGroup [::ttk::button $btnFrame2.new -text [T "New Group"] \
           -command [list ::potato::manageWorldsNewGroup]]] -side left -padx 5
  pack [set delGroup [::ttk::button $btnFrame2.del -text [T "Delete Group"] \
           -command [list ::potato::manageWorldsBtn "delgroup"]]] -side left -padx 5
  set manageWorlds(delGroupBtn) $delGroup
  pack [set close [::ttk::button $btnFrame2.close -text [T "Close"] -width 8 \
           -command [list destroy $win]]] -side left -padx 5


  bind $gTree <<TreeviewSelect>> [list ::potato::manageWorldsSelectGroup]
  bind $wTree <FocusIn> [list ::potato::manageWorldsUpdateWorlds]
  bind $wTree <<TreeviewSelect>> [list ::potato::manageWorldsSelectWorld]
  bind $wTree <ButtonPress-3> "[bind Treeview <ButtonPress-1>] ; [list ::potato::manageWorldsRightClickWorld %X %Y]"

  bind $gTree <Destroy> [list array unset ::potato::manageWorlds]

  manageWorldsUpdateGroups

  update idletasks
  center $win
  wm deiconify $win
  reshowWindow $win 0

  return;

};# ::potato::manageWorlds

#: proc ::potato::manageWorldsRightClickWorld
#: arg xcoord x coordinate to post menu at
#: arg ycoord y coordinate to post menu at
#: desc Handle the right-clicking of the mouse over the World Tree; pop up a menu to allow the selection of groups for the world.
#: return nothing
proc ::potato::manageWorldsRightClickWorld {xcoord ycoord} {
  variable world;
  variable manageWorlds;

  array unset manageWorlds popupMenuGroups,*
  set sel [$manageWorlds(wTree) sel]
  if { [llength $sel] == 0 } {
       return;
     }
  set sel [lindex $sel 0]
  set menu $manageWorlds(wTree).menu
  if { [winfo exists $menu] } {
       $menu delete 0 end
     } else {
       menu $manageWorlds(wTree).menu -tearoff 0
     }
  set i 0
  foreach x $world(-1,groups) {
     set manageWorlds(popupMenuGroups,$i) [expr {$x in $world($sel,groups)}]
     $menu add checkbutton -variable ::potato::manageWorlds(popupMenuGroups,$i) -label $x \
         -command [list ::potato::manageWorldsRightClickWorldToggle $sel $x  $menu]
     incr i
  }

  tk_popup $menu $xcoord $ycoord

  return;

};# ::potato::manageWorldsRightClickWorld

#: proc ::potato::manageWorldsRightClickWorldToggle
#: arg w world id
#: arg group Group name
#: arg menu Menu widget to destroy
#: desc Toggle whether world $w is in group $group, and then destroy $menu
#: return nothing
proc ::potato::manageWorldsRightClickWorldToggle {w group menu} {
  variable world;
  variable manageWorlds;

  array unset manageWorlds popupMenuGroups,*
  set pos [lsearch -exact $world($w,groups) $group]
  if { $pos == -1 } {
       lappend world($w,groups) $group
     } else {
       set world($w,groups) [lreplace $world($w,groups) $pos $pos]
     }
  manageWorldsUpdateWorlds
  destroy $menu

  return;

};# ::potato::manageWorldsRightClickWorldToggle

#: proc ::potato::manageWorldsNewGroup
#: desc Show a pop-up window allowing the user to enter a name for a new World Group
#: return nothing
proc ::potato::manageWorldsNewGroup {} {
  variable world;
  variable manageWorlds;

  set win .manageWorldsNewGroup
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  wm withdraw $win
  wm title $win [T "Add New Group"]
  set manageWorlds(newGroupWin) $win

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both
  pack [::ttk::label $frame.l -text [T "Enter the name for the new Group, and click Add."]] -side top -padx 3 -pady 5
  set name [T "New Group"]
  if { $name in $world(-1,groups) } {
       set num 1
       while { "$name ($num)" in $world(-1,groups) && $num < 1000 } {
               incr num
             }
       if { $num < 1000 } {
            set name "$name ($num)"
          }
     }
  set manageWorlds(newGroupName) $name
  pack [::ttk::entry $frame.e -textvariable ::potato::manageWorlds(newGroupName) \
          -validate none -invalidcommand [list bell -displayof $win] \
          -validatecommand {expr {![string match "INT:*" %P]}} -width 30] -side top -padx 3 -pady 5
  pack [set btns [::ttk::frame $frame.btns]] -side top -anchor n -padx 3 -pady 5
  pack [::ttk::button $btns.add -text [T "Add"] -width 8 -command ::potato::manageWorldsNewGroupAdd] -side left -padx 7
  pack [::ttk::button $btns.cancel -text [T "Cancel"] -width 8 -command [list destroy $win]] -side left -padx 7
  $frame.e selection range 0 end
  $frame.e icursor end

  bind $win <Escape> [list $btns.cancel invoke]
  bind $win <Return> [list $btns.add invoke]

  update idletasks
  center $win
  wm deiconify $win
  reshowWindow $win 0
  focus $frame.e

  return;

};# ::potato::manageWorldsNewGroup

#: proc ::potato::manageWorldsNewGroupAdd
#: desc A new group name has been entered; add it
#: return 1 if it was added, 0 if not (because it had an invalid name)
proc ::potato::manageWorldsNewGroupAdd {} {
  variable world;
  variable manageWorlds;

  set group $manageWorlds(newGroupName)
  if { [string trim $group] eq "" || [string match "INT:*" group] } {
       tk_messageBox -parent $manageWorlds(newGroupWin) -title [T "Add New Group"] -icon error -type ok \
               -message [T "That is not a valid name."]
       return 0;
     }

  if { $group ni $world(-1,groups) } {
       lappend world(-1,groups) $group
       set world(-1,groups) [lsort -dictionary $world(-1,groups)]
     }

  destroy $manageWorlds(newGroupWin)

  manageWorldsUpdateGroups

  return 1;

};# ::potato::manageWorldsNewGroupAdd

#: proc ::potato::manageWorldsUpdateGroups
#: desc Build the list of Groups in the Manage Worlds window
#: return nothing
proc ::potato::manageWorldsUpdateGroups {} {
  variable manageWorlds;
  variable world;

  if { ![info exists manageWorlds(toplevel)] } {
       return;
     }

  set gTree $manageWorlds(gTree);
  $gTree delete [$gTree children {}]
  set gTreeAll [$gTree insert {} end -id INT:All -image ::potato::img::globe -values [list [T "All Worlds"]] -open true]

  foreach x $world(-1,groups) {
    $gTree insert $gTreeAll end -id $x -image ::potato::img::folder -values [list $x] -open true
  }
  $gTree insert $gTreeAll end -id INT:Ungrouped -image ::potato::img::globe -values [list [T "Ungrouped"]] -open true
  $gTree insert $gTreeAll end -id INT:Temp -image ::potato::img::globe -values [list [T "Temp/Deleted"]] -open true

  $gTree selection set INT:All
  manageWorldsSelectGroup

  return;

};# ::potato::manageWorldsUpdateGroups

#: proc ::potato::manageWorldsSelectGroup
#: desc Handle the selection of a new group in the Group Tree; [de]activate buttons as appropriate and update the World Tree.
#: return nothing
proc ::potato::manageWorldsSelectGroup {} {
  variable manageWorlds;
  variable world;

  if { ![info exists manageWorlds(toplevel)] } {
       return;
     }

  set tree $manageWorlds(gTree);
  set sel [lindex [$tree sel] 0]
  if { [string match "INT:*" $sel] || $sel eq "" } {
       $manageWorlds(delGroupBtn) state disabled
     } else {
       $manageWorlds(delGroupBtn) state !disabled
     }

  manageWorldsUpdateWorlds 0
  return;

};# ::potato::manageWorldsSelectGroup

#: proc ::potato::manageWorldsBtn
#: arg type The type of button pressed
#: desc Handle the click of a button in the Manage Worlds window.
#: return nothing
proc ::potato::manageWorldsBtn {type} {
  variable world;
  variable manageWorlds;

  if { ![info exists manageWorlds(toplevel)] } {
       return;
     }

  if { $type eq "copyworld" } {
       foreach w [$manageWorlds(wTree) selection] {
          copyWorld $w
       }
     } elseif { $type eq "editworld" } {
       foreach w [$manageWorlds(wTree) selection] {
          configureWorld $w
       }
     } elseif { $type eq "delworld" } {
       foreach w [$manageWorlds(wTree) selection] {
          if { $world($w,temp) } {
               set world($w,temp) 0
             } else {
               set ans [tk_messageBox -parent $manageWorlds(toplevel) -title [T "Delete World?"] \
                           -icon question -type yesno -message [T "Do you really want to delete \"%s\"?" $world($w,name)]]
               if { $ans eq "yes" } {
                    set world($w,temp) 1
                  }
             }
       }
    } elseif { $type eq "delgroup" } {
      set sel [lindex [$manageWorlds(gTree) sel] 0]
      set ans [tk_messageBox -parent $manageWorlds(toplevel) -title [T "Delete Group?"] \
            -icon question -type yesno -message [T "Do you really want to delete the group \"%s\"?" $sel]]
      if { $ans eq "yes" } {
           # This must also match -1,groups, hence the "-?"
           foreach x [array names world -regexp {^-?[0-9]+,groups}] {
              set index [lsearch -exact $world($x) $sel]
              if { $index > -1 } {
                   set world($x) [lreplace $world($x) $index $index]
                 }
           }
           manageWorldsUpdateGroups
         }
    }

  manageWorldsUpdateWorlds
  manageWorldsSelectWorld

  return;

};# ::potato::manageWorldsBtn

#: proc ::potato::manageWorldsSelectWorld
#: desc Update the Manage World buttons to reflect the currently selected world
#: return nothing
proc ::potato::manageWorldsSelectWorld {} {
  variable manageWorlds;
  variable world;

  if { ![info exists manageWorlds(toplevel)] } {
       return;
     }

  set tree $manageWorlds(wTree)
  set sel [$tree selection]

  if { [llength $sel] == 0 } {
       # No selection, deactivate buttons
       $manageWorlds(copyBtn) state disabled
       $manageWorlds(editBtn) state disabled
       $manageWorlds(delBtn) state disabled
       $manageWorlds(delBtn) configure -text [T "Delete"]
     } else {
       $manageWorlds(copyBtn) state !disabled
       $manageWorlds(editBtn) state !disabled
       $manageWorlds(delBtn) state !disabled
       set text [T "Undelete"]
       foreach w $sel {
          if { !$world($w,temp) } {
               set text [T "Delete"]
               break;
             }
       }
       $manageWorlds(delBtn) configure -text $text
     }

  return;

};# ::potato::manageWorldsSelectWorld

#: proc ::potato::manageWorldsUpdateWorlds
#: arg keepSel Keep the currently selected item selected after the update, if it still exists?
#: desc Check the selection in the Group Tree and update the World Tree with the appropriate list of worlds
#: return nothing
proc ::potato::manageWorldsUpdateWorlds {{keepSel 1}} {
  variable world;
  variable manageWorlds;

  if { ![info exists manageWorlds(toplevel)] } {
       return;
     }

  foreach x [list gTree wTree] {set $x $manageWorlds($x)}

  set wSel [$wTree selection]
  $wTree delete [$wTree children {}]
  set sel [$gTree selection]
  if { $sel eq "" } {
       set sel "INT:All"
     }
  set worlds [list]
  foreach w [worldIDs] {
    if { $sel eq "INT:All" || \
         ( $sel eq "INT:Ungrouped" && [llength $world($w,groups)] == 0) || \
         ( $sel eq "INT:Temp" && $world($w,temp) ) || \
         [lindex $sel 0] in $world($w,groups) } {
         lappend worlds [list $world($w,name) "$world($w,host):$world($w,port)" $world($w,charDefault) $w]
       }
  }
  set worlds [lsort -dictionary -index 0 $worlds]
  foreach x $worlds {
    set w [lindex $x end]
    $wTree insert {} end -id $w -values $x
    if { $world($w,temp) } {
         $wTree item $w -tags deleted
       }
  }

  if { $keepSel && $wSel ne "" && [$wTree exists $wSel] } {
       $wTree selection set $wSel
     } else {
       $wTree selection set [lindex [$wTree children {}] 0]
     }
  manageWorldsSelectWorld

  return;

};# ::potato::manageWorldsUpdateWorlds

#: proc ::potato::newWorld
#: arg quick is this a quick connection?
#: arg hostAddr initial host address to use, defaults to ""
#: arg portNum initial port to use, defaults to ""
#: desc Show the dialog for adding a new world.
#: return nothing.
proc ::potato::newWorld {quick {hostAddr ""} {portNum ""}} {
  variable potato;
  variable newWorld;

  set win .newWorld
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  wm withdraw $win
  #wm transient $win .
  if { $quick } {
       set title [T "Quick Connect"]
     } else {
       set title [T "Add New World"]
     }
  wm title $win "$title - $potato(name)"

  pack [set frame [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw

  set newWorld(name) ""
  set newWorld(host) ""
  set newWorld(port) ""

  set info [::ttk::label $frame.info -text [T "Enter the connection information\nfor the new world below."]]
  $info configure -font [list [lindex [$info cget -font] 0] 11]
  pack $info -side top -anchor n -fill none -padx 4 -pady 4

  set name [::ttk::frame $frame.name]
  pack $name -side top -fill x -anchor nw -padx 5 -pady 1
  pack [::ttk::label $name.l -text [T "Name:"] -width 7 -justify left -anchor w] -side left -anchor nw
  pack [::ttk::entry $name.e -textvariable ::potato::newWorld(name) -width 35] -side left -anchor nw -fill x

  set host [::ttk::frame $frame.host]
  pack $host -side top -fill x -anchor nw -padx 5 -pady 1
  pack [::ttk::label $host.l -text [T "Host:"] -width 7 -justify left -anchor w] -side left -anchor nw
  pack [::ttk::entry $host.e -textvariable ::potato::newWorld(host) -width 35] -side left -anchor nw -fill x
  set potato::newWorld(host) $hostAddr

  set port [::ttk::frame $frame.port]
  pack $port -side top -fill x -anchor nw -padx 5 -pady 1
  pack [::ttk::label $port.l -text [T "Port:"] -width 7 -justify left -anchor w] -side left -anchor nw
  pack [::ttk::entry $port.e -textvariable ::potato::newWorld(port) -width 35] -side left -anchor nw -fill x
  set potato::newWorld(port) $portNum

  set btns [::ttk::frame $frame.btns]
  pack $btns -side top -fill x -anchor n -pady 6
  set ok [::ttk::frame $btns.ok]
  pack $ok -side left -expand 1 -fill x -anchor n
  pack [::ttk::button $ok.btn -text [T "OK"] -width 8 -command [list ::potato::newWorldAdd $quick $win] \
                       -underline 0 -default active] -side top -anchor n

  set cancel [::ttk::frame $btns.cancel]
  pack $cancel -side left -expand 1 -fill x -anchor n
  pack [::ttk::button $cancel.btn -text [T "Cancel"] -width 8 -command [list destroy $win] \
                              -underline 0] -side top -anchor n

  bind $win <Return> [list $ok.btn invoke]
  bind $win <Alt-o> [list $ok.btn invoke]
  bind $win <Alt-c> [list $cancel.btn invoke]
  bind $win <Escape> [list $cancel.btn invoke]

  update idletasks
  center $win
  wm deiconify $win
  focus $name.e
  connZero
  return;

};# ::potato::newWorld

#: proc ::potato::newWorldAdd
#: arg quick was this made via a quick connection?
#: arg dialog widget to destroy where new world info was entered
#: desc After the 'new world' dialog has been filled out, create the new world, and connect (for "quick connect") or show the configure world dialog (for "add new world")
#: return nothing
proc ::potato::newWorldAdd {quick dialog} {
  variable potato;
  variable world;
  variable newWorld;

  destroy $dialog

  if { [string trim $newWorld(name)] eq "" } {
       set name [T "New World"]
     } else {
       set name $newWorld(name)
     }

  set w [addNewWorld $name $newWorld(host) $newWorld(port) $quick]

  if { $quick } {
       newConnection $w
     } else {
       configureWorld $w
     }

  return;

};# ::potato::newWorldAdd

#: proc ::potato::addNewWorld
#: arg name name of the world
#: arg host host of the world
#: arg port port for the world
#: arg temp is this a temporary (quick) world?
#: desc Do the real business (setting vars, etc) of adding a new world
#: return world id
proc ::potato::addNewWorld {name host port temp} {
  variable potato;
  variable world;

  set w $potato(worlds)
  incr potato(worlds)

  loadWorldDefaults $w 0

  # Add a /grab slash command, and an event for matching it.
  # We do it here so they can delete/edit it if they want,
  # without us automatically re-adding it.
  set world($w,events) [list 0]
  set world($w,events,0,bg) ""
  set world($w,events,0,case) 1
  set world($w,events,0,continue) 0
  set world($w,events,0,enabled) 1
  set world($w,events,0,fg) ""
  set world($w,events,0,inactive) "always"
  set world($w,events,0,input,string) {[/get 0]}
  set world($w,events,0,input,window) 3
  set world($w,events,0,log) 0
  set world($w,events,0,matchtype) "wildcard"
  set world($w,events,0,omit) 1
  set world($w,events,0,noActivity) 0
  set world($w,events,0,pattern) "FugueEdit > *"
  set world($w,events,0,pattern,int) "^FugueEdit > (.*)$"
  set world($w,events,0,send) ""
  set world($w,events,0,spawn) 0
  set world($w,events,0,spawnTo) ""
  set world($w,events,0,matchAll) 0
  set world($w,events,0,replace) 0
  set world($w,events,0,replace,with) ""
  set world($w,events,0,name) "grabber"

  set world($w,slashcmd) [list grab]
  set world($w,slashcmd,grab) "^(.+)$"
  set world($w,slashcmd,grab,type) "regexp"
  set world($w,slashcmd,grab,send) "@decompile/tf %0"
  set world($w,slashcmd,grab,case) 1

  set world($w,name) $name
  set world($w,temp) $temp
  set world($w,host) $host
  set world($w,port) $port
  set world($w,id) $w

  set world($w,stats,conns) 0
  set world($w,stats,time) 0
  set world($w,stats,added) [clock seconds]

  saveWorlds
  connZero

  return $w;

};# ::potato::addNewWorld

#: proc ::potato::copyWorld
#: arg w World id
#: desc Make a copy of world $w, and return it's new id.
#: return Id number of new world
proc ::potato::copyWorld {w} {
  variable world;
  variable potato;

  set new $potato(worlds)
  incr potato(worlds)

  foreach x [removePrefix [array names world $w,*] $w] {
    set world($new,$x) $world($w,$x)
  }

  # Reset stats...
  set world($w,stats,conns) 0
  set world($w,stats,time) 0
  set world($w,stats,added) [clock seconds]

  # Make sure it's not set temp...
  set world($w,temp) 0

  # And now fix the name...
  # Possible formats:
  # Copy of OriginalName[ (X)]
  # OriginalName (Copy[ X]) <-- current favourite
  set copyWord [T "Copy"]
  set copyWordRe [regsub -all {([^a-zA-Z0-9?*])} $copyWord {\\\1}]
  set hasCopy 0
  set copyCount [list]
  set namePtn "^[regsub -all {([^a-zA-Z0-9?*])} $world($new,name) {\\\1}] \\($copyWordRe (\[0-9\]+)\\)$"
  foreach x [array names world *,name] {
    if { $x eq "$w,name" || $x eq "$new,name" } {
         continue;
       }
    if { $world($x) eq "$world($new,name) ($copyWord)" } {
         set hasCopy 1
       } elseif { [regexp $namePtn $world($x) {} num] } {
         lappend copyCount $num
       }
  }
  if { !$hasCopy } {
       set world($new,name) "$world($new,name) ($copyWord)"
     } else {
       # First available number...
       set copyCount [lsort -integer $copyCount]
       for {set num 1} {$num < 100 && $num in $copyCount} {incr num} {continue}
       if { $num == 100 } {
            # We already have 99 copies. Feh, just use (Copy) again
            set world($new,name) "$world($new,name) ($copyWord)"
          } else {
            set world($new,name) "$world($new,name) ($copyWord $num)"
          }
     }

  connZero;

  return $new;

};# ::potato::copyWorld

#: proc ::potato::macroWindow
#: arg w world id
#: desc Show the window for configuring Macros for world $w.
#: return nothing
proc ::potato::macroWindow {{w ""}} {
  variable conn;
  variable world;
  variable macroWindow

  if { $w eq "" } {
       set w $conn([up],world)
     }

  set win .macroWindow$w
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  if { $w == -1 } {
       set title [T "Global Macros"]
     } else {
       set title [T "Macros for %s" $world($w,name)]
     }

  toplevel $win
  wm title $win $title

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both

  pack [set top [::ttk::frame $frame.top]] -side left -expand 1 -fill both

  pack [set left [::ttk::frame $top.left]] -side left -expand 1 -fill both
  pack [set right [::ttk::frame $top.right]] -side left -expand 1 -fill both

  set tframe [::ttk::frame $left.tframe]
  set tree [::ttk::treeview $tframe.tree -show [list headings] -columns [list Name Commands] \
               -yscrollcommand [list $tframe.y set] \
               -xscrollcommand [list $tframe.x set] -selectmode browse]
  set x [::ttk::scrollbar $tframe.x -orient horizontal -command [list $tree xview]]
  set y [::ttk::scrollbar $tframe.y -orient vertical -command [list $tree xview]]
  grid_with_scrollbars $tree $x $y

  $tree heading Name -text [T "Name"]
  $tree heading Commands -text [T "Commands"]
  $tree column Name -width 80 -stretch 0
  $tree column Commands -width 150 -stretch 1
  bind $tree <<TreeviewSelect>> [list ::potato::macroWindowState $w]

  pack $tframe -side top -padx 10 -pady 10 -expand 1 -fill both

  pack [set bframe [::ttk::frame $left.bframe]] -side top -anchor n -pady 13

  pack [set add [::ttk::button $bframe.add -image ::potato::img::event-new \
            -command [list ::potato::macroWindowAdd $w]]] -side left -padx 8
  tooltip $add [T "Add Macro"]
  pack [set edit [::ttk::button $bframe.edit -image ::potato::img::event-edit \
            -command [list ::potato::macroWindowEdit $w]]] -side left -padx 8
  tooltip $edit [T "Edit Macro"]
  pack [set delete [::ttk::button $bframe.delete -image ::potato::img::event-delete \
            -command [list ::potato::macroWindowDelete $w]]] -side top -padx 8
  tooltip $delete [T "Delete Macro"]

  pack [set nframe [::ttk::frame $right.name]] -side top -anchor w -padx 10 -pady 10 -expand 1 -fill x
  pack [::ttk::label $nframe.l -text [T "Name:"]] -side left -anchor w
  pack [set name [::ttk::entry $nframe.e]] -side left -anchor w -expand 1 -fill x
  pack [set tframe [::ttk::frame $right.text]] -side top -anchor w -padx 10 -pady 10
  pack [::ttk::label $tframe.l -text [T "Commands:"]] -anchor w
  pack [set commands [text $tframe.txt -height 10 -width 40 -wrap word -font TkFixedFont]] -anchor w
  pack [set bframe [::ttk::frame $right.btns]] -side top -anchor e -padx 10 -pady 10
  pack [set save [::ttk::button $bframe.save -text [T "Save"] -command [list ::potato::macroWindowFinish $w 1]]] -side left -padx 8
  pack [set cancel [::ttk::button $bframe.cancel -text [T "Cancel"] -command [list ::potato::macroWindowFinish $w 0]]] -side left -padx 8

  foreach x [list tree add edit delete name commands save cancel] {
    set macroWindow($w,path,$x) [set $x]
  }

  macroWindowPopulate $w

  bind $win <Destroy> [list array unset macroWindow $w,*]

  return;

};# ::potato::macroWindow

#: proc ::potato::macroWindowDelete
#: arg w world id
#: desc Delete the currently selected macro
#: return nothing
proc ::potato::macroWindowDelete {w} {
  variable macroWindow;
  variable world;

  set sel [lindex [$macroWindow($w,path,tree) selection] 0]
  if { $sel eq "" } {
       return;
     }
  unset world($w,macro,$sel)
  macroWindowPopulate $w

  return;

};# ::potato::macroWindowDelete

#: proc ::potato::macroWindowFinish
#: arg w world id
#: arg save Save (1) or cancel (0)
#: desc Possibly save the currently edited macro, then clear the window
#: return nothing
proc ::potato::macroWindowFinish {w save} {
  variable macroWindow;
  variable world;

  if { $save } {
       set name [$macroWindow($w,path,name) get]
       set commands [$macroWindow($w,path,commands) get 1.0 end-1c]
       if { ![regexp {^[a-zA-Z0-9!._-]{1,49}$} $name] } {
            tk_messageBox -message [T "Invalid name."] -icon error -title [T "Macros"] \
                          -type ok -parent $macroWindow($w,path,commands)
            return;
          }
       if { $name ne $macroWindow($w,editing) } {
            # Using a different name.
            if { [info exists world($w,macro,$name)] } {
                 set ans [tk_messageBox -icon warning -title [T "Macros"] -type yesno \
                            -parent $macroWindow($w,path,commands) \
                            -message [T "A Macro with that name already exists. Override?"]]
                 if { $ans ne "yes" } {
                      return;
                    }
                 unset world($w,macro,$macroWindow($w,editing))
               }
          }
       set world($w,macro,$name) $commands
     }
  $macroWindow($w,path,name) delete 0 end
  $macroWindow($w,path,commands) delete 1.0 end
  macroWindowState $w
  if { $save } {
       macroWindowPopulate $w $name
     }

  return;

};# ::potato::macroWindowFinish

#: proc ::potato::macroWindowAdd
#: arg w world id
#: desc Set up Macro Window for world $w for adding a new macro
#: return nothing
proc ::potato::macroWindowAdd {w} {
  variable macroWindow;

  set macroWindow($w,editing) ""
  macroWindowState $w 2

  return;

};# ::potato::macroWindowAdd

#: proc ::potato::macroWindowEdit
#: arg w world id
#: desc Set up Macro Window for world $w for editing the currently selected macro
#: return nothing
proc ::potato::macroWindowEdit {w} {
  variable macroWindow;
  variable world;

  set which [lindex [$macroWindow($w,path,tree) selection] 0]

  set macroWindow($w,editing) $which
  macroWindowState $w 2
  $macroWindow($w,path,name) insert end $which
  $macroWindow($w,path,commands) insert end $world($w,macro,$which)

  return;

};# ::potato::macroWindowEdit

#: proc ::potato::macroWindowPopulate
#: arg w world id
#: arg sel Item ID to select, defaults to "" for first item
#: desc Populate the Macro Window list for world $w and select the specified item
#: return nothing
proc ::potato::macroWindowPopulate {w {sel ""}} {
  variable macroWindow;
  variable world;

  set tree $macroWindow($w,path,tree)
  $tree delete [$tree children {}]
  foreach x [lsort -dictionary [removePrefix [arraySubelem world $w,macro] $w,macro]] {
    $tree insert {} end -id $x -values [list $x [string map [list \n " \b "] $world($w,macro,$x)]]
  }
  if { $sel eq "" || ![$tree exists $sel] } {
       set sel [lindex [$tree children {}] 0]
     }
  if { $sel eq "" } {
       macroWindowState $w 0
     } else {
       $tree selection set $sel
       $tree focus $sel
       macroWindowState $w 1
     }

  return;

};# ::potato::macroWindowPopulate

#: proc ::potato::macroWindowState
#: arg w world id
#: arg state Window state (0 = empty tree, 1 = selected tree entry, 2 = adding/editing an entry, -1 = check tree selection for 0/1)
#: desc Set widget states in the Macro Window for world $w.
#: return nothing
proc ::potato::macroWindowState {w {state -1}} {
  variable macroWindow;

  if { $state == -1 } {
       if { [llength [$macroWindow($w,path,tree) selection]] } {
            set state 1
          } else {
            set state 0
          }
     }

  if { $state == 2 } {
       foreach x [list tree add edit delete] {
         $macroWindow($w,path,$x) state disabled
       }
       foreach x [list name save cancel] {
         $macroWindow($w,path,$x) state !disabled
       }
       $macroWindow($w,path,commands) configure -state normal
       focus $macroWindow($w,path,name)
     } else {
       foreach x [list tree edit delete] {
         $macroWindow($w,path,$x) state [lindex [list disabled !disabled] $state]
       }
       $macroWindow($w,path,add) state !disabled
       foreach x [list name save cancel] {
         $macroWindow($w,path,$x) state disabled
       }
       $macroWindow($w,path,commands) configure -state disabled
       focus $macroWindow($w,path,tree)
     }
  return;

};# ::potato::macroWindowState

#: proc ::potato::grid_with_scrollbars
#: arg widget The main widget
#: arg x x-scrollbar
#: arg y y-scrollbar
#: desc Grid a widget with x/y scrollbars into a parent frame
#: return nothing
proc ::potato::grid_with_scrollbars {widget x y} {

  set frame [winfo parent $widget]
  grid $widget $y -sticky nsew
  grid $x -sticky nswe
  grid rowconfigure $frame $widget -weight 1
  grid columnconfigure $frame $widget -weight 1
  return;

};# ::potato::grid_with_scrollbars

#: proc ::potato::center
#: arg win a toplevel widget
#: desc center window $win on the screen
#: return nothing
proc ::potato::center {win} {

  update
  if { ![winfo exists $win] } {
       return;
     }
  set w [winfo reqwidth $win]
  set h [winfo reqheight $win]

  set sh [winfo screenheight $win]
  set sw [winfo screenwidth $win]

  set reqX [expr {($sw-$w)/2}]
  set reqY [expr {($sh-$h)/2}]

  wm geometry $win +$reqX+$reqY
  update idletasks
  after 10
  return;

};# ::potato::center

#: proc ::potato::status
#: arg c connection id
#: desc returns the status (normal, disconnected, idle, closed) for a connection
#: return "normal", "disconnected", "idle", "closed"
proc ::potato::status {c} {
  variable conn;

  if { $c == 0 } {
       return "normal";
     } elseif { ![info exists conn($c,connected)] } {
       return "closed";
     } elseif { $conn($c,connected) == 0 } {
       return "disconnected";
     } elseif { $conn($c,idle) == 1 } {
       return "idle";
     } else {
       return "normal";
     }

};# ::potato::status

#: proc ::potato::connStatus
#: arg c connection id
#: desc returns the connection status (connected, disconnected, connecting, closed) for a connection
#: return "connected", "disconnected", "connecting", "closed"
proc ::potato::connStatus {c} {
  variable conn;

  if { $c == 0 } {
       return "connected";
     } elseif { ![info exists conn($c,connected)] } {
       return "closed";
     } elseif { $conn($c,connected) == 0 } {
       return "disconnected";
     } elseif { $conn($c,connected) == -1 } {
       return "connecting";
     } else {
       return "connected";
     }

};# ::potato::connStatus

#: proc ::potato::connInfo
#: arg c connection id
#: arg type type of into to return (name, host, port, text)
#: desc return info about the $type for connection $c
#: return string containing the $type info for the connection
proc ::potato::connInfo {c type} {
  variable conn;
  variable world;

  if { $c eq "" } {
       set c [up]
     }

  switch -glob -- $type {
    name -
    host -
    port -
    top,bg -
    bottom,bg -
    bottom,fg { return $world($conn($c,world),$type); }
    top,font -
    bottom,font { return $world($conn($c,world),$type,created); }
    text -
    widget -
    textWidget -
    textwidget { return $conn($c,textWidget);}
    connname { return [lindex $conn($c,name) 1];}
    input1 { return $conn($c,input1);}
    input2 { return $conn($c,input2);}
    input3 { return $conn($c,input[connInfo $c inputFocus]);}
    inputFocus { return [expr {[focus -displayof $conn($c,input2)] eq $conn($c,input2) ? 2 : 1}]; }
    autoreconnect { return [expr {$world($conn($c,world),autoreconnect) && $conn($c,reconnectId) ne ""}]; }
    world {return $conn($c,world);}
    address {return $conn($c,address);}
    spawns {return $conn($c,spawns);}
  }

  # Note: "input1" and "input2" return the WIDGET PATH of those input windows.
  # "inputFocus" returns a NUMBER, 1 or 2, telling which has focus. "input3" returns the widget path of "inputFocus"

  if { $type eq "autoreconnect,time" } {
       if { !$world($conn($c,world),autoreconnect) } {
            return 0;
          } else {
            set num $world($conn($c,world),autoreconnect,time)
            if { ![string is integer -strict $num] } {
                 return 0;
               } else {
                 return $num;
               }
          }
     }

  return "";

};# ::potato::connInfo

#: proc ::potato::reverseColour
#: arg col a colour
#: desc return the opposite of a colour
#: return the opposite colour, in #RRRRGGGGBBBB notation
proc ::potato::reverseColour {col} {

  foreach [list red green blue] [winfo rgb . $col] {break}

  set red [expr {65535 - $red}]
  set blue [expr {65535 - $blue}]
  set green [expr {65535 - $green}]

  return [format "#%04x%04x%04x" $red $green $blue];

};# ::potato::reverseColour

#: proc ::potato::focusIn
#: arg win the window gaining focus
#: desc when $win is ., twiddle the idle flag for the current connection to show activity
#: return nothing
proc ::potato::focusIn {win} {
  variable conn;
  variable winico;

  if { [winfo toplevel $win] ne "." || $win ne "." } {
       return;
     }

  set focus [focus -displayof .]
  set c [up]

  if { $c ne "" && $focus ne "" } {
       set conn($c,idle) 0
       if { $focus ni [list $conn($c,input1) $conn($c,input2)] } {
            focus $conn($c,input1)
          }
     }

  if { $winico(loaded) && $winico(flashing) } {
       winicoFlashOff
     }

  #abc might need to do a "linunflash ." here when using that package?

  return;

};# ::potato::focusIn

#: proc ::potato::setClock
#: desc set potato(clock) to the current time, formatted according to misc(clockFormat),
#: desc and queue an update in 1 second. Also set the formatted connection stats.
#: return nothing
proc ::potato::setClock {} {
  variable potato;
  variable misc;
  variable conn;

  after 1000 potato::setClock
  set potato(clock) [clock format [set secs [clock seconds]] -format $misc(clockFormat)]
  foreach x [array names conn -regexp {^[0-9]+,stats,formatted$}] {
     scan $x %d,stats,formatted c
     if { $conn($c,stats,connAt) != -1 } {
          set conn($c,stats,formatted) [statsFormat [expr {$secs - $conn($c,stats,connAt)}]]
        }
  }

  return;

};# ::potato::setClock

#: proc ::potato::statsFormat
#: arg secs Number of seconds to format.
#: desc Format the number of seconds that the connection has been established for into a user-friendly format.
#: return Formatted time
proc ::potato::statsFormat {secs} {

  #set h [expr {($secs % 86400) / 3600}]
  set h [expr {$secs / 3600}]
  #set m [expr {($secs % 86400) % 3600) / 60}]
  set m [expr {($secs % 3600) / 60}]

  return [T "%dh %dm" $h $m];

};# ::potato::statsFormat

#: proc ::potato::errorLogWindow
#: desc Create a window for displaying an Error Log of bugs/errors that occur while Potato
#: desc is running (failure to load package, execute external commands, etc). If the window already exists, deiconify it.
#: return nothing
proc ::potato::errorLogWindow {} {

  set win .errorLogWin
  if { [winfo exists $win] } {
       # These messages are reset because we create the window, initially, before translation files are loaded
       # (so we can report errors in doing so), so need to be translated later, when the window is displayed.
       catch {wm title $win [T "Potato Debugging Log"] ; $win.frame.btm.close configure -text [T "Close"]}
       reshowWindow $win 0
       return;
     }

  toplevel $win
  wm withdraw $win
  wm title $win [T "Potato Debugging Log"]

  pack [set frame [::ttk::frame $win.frame]] -side left -anchor nw -expand 1 -fill both
  pack [set cont [::ttk::frame $frame.top]] -side top -anchor nw -expand 1 -fill both

  set text [text $cont.text -width 120 -height 35 -wrap word -undo 0]
  set sbY [::ttk::scrollbar $cont.sbY -orient vertical -command [list $text yview]]
  set sbX [::ttk::scrollbar $cont.sbX -orient horizontal -command [list $text xview]]
  $text configure -yscrollcommand [list $sbY set] -xscrollcommand [list $sbX set]
  grid_with_scrollbars $text $sbX $sbY

  $text tag configure error -foreground #ee0000 -lmargin2 25
  $text tag configure warning -foreground #4f4fff -lmargin2 25
  $text tag configure message -foreground #00c131 -lmargin2 25

  $text tag configure margin -lmargin1 15

  $text tag configure toggleBtn -lmargin1 2
  $text tag bind toggleBtn <ButtonRelease-1> [list ::potato::errorLogToggle $text]
  $text tag bind toggleBtn <Enter> [list $text configure -cursor arrow]
  $text tag bind toggleBtn <Leave> [list $text configure -cursor xterm]
  $text tag configure errorTrace -lmargin1 20 -lmargin2 25

  $text tag configure errorTraceHidden -elide 1

  pack [set btns [::ttk::frame $frame.btm]] -side top -anchor nw -expand 0 -fill x
  pack [::ttk::button $btns.close -text [T "Close"] -underline 0 -command [list wm withdraw $win]]

  $text configure -state disabled

  wm protocol $win WM_DELETE_WINDOW [list wm withdraw $win];# don't destroy, just hide

  return;

};# ::potato::errorLogWindow

#: proc ::potato::errorLog
#: arg msg Message to display
#: arg level The priority level of the message. One of "error", "warning" or "message". Defaults to "error"
#: arg trace If given, an error trace for the message, to be shown with a toggle button to hide/show
#: desc Print the given message to the Error Log window with the given priority level
#: return nothing
proc ::potato::errorLog {msg {level "error"} {trace ""}} {

  set win .errorLogWin.frame.top.text

  $win configure -state normal

  if { $trace ne "" } {
       $win image create end -image ::potato::img::expand -align center -padx 2 -pady 2
       $win tag add toggleBtn end-2c end-1c
       $win insert end $msg [list $level margin] " - \n$trace" [list $level errorTrace errorTraceHidden margin] \n
     } else {
       $win insert end $msg [list $level margin] \n
     }
  $win see end
  $win configure -state disabled

  return;
};# ::potato::errorLog

#: ::potato::errorLogToggle
#: arg win Text widget of the Error Log window
#: desc Called when a + or - button in the Error Log is clicked, to show/hide an error trace
#: return nothing
proc ::potato::errorLogToggle {win} {

  set image [$win index current]
  set tracerange [$win tag nextrange errorTrace $image]
  if { ![llength $tracerange] } {
       return;
     }
  foreach {start end} $tracerange {break}
  if { "errorTraceHidden" in [$win tag names $start] } {
       $win tag remove "errorTraceHidden" $start $end
       $win image configure $image -image ::potato::img::contract
     } else {
       $win tag add "errorTraceHidden" $start $end
       $win image configure $image -image ::potato::img::expand
     }

  return;
};# ::potato::errorLogToggle

#: proc ::potato::main
#: desc called when the program starts, to do some basic init
#: return nothing
proc ::potato::main {} {
  variable potato;
  variable path;
  variable skins;
  variable misc;
  variable running;
  global argc;
  global argv;

  set running 0;

  set potato(name) "Potato MU* Client"
  set potato(version) [source [file join [file dirname [info script]] "potato-version.tcl"]]
  set potato(contact) "talvo@talvo.com"
  set potato(webpage) "http://code.google.com/p/potatomushclient/"

  if { [info exists ::starkit::mode] && $::starkit::mode eq "starpack" } {
       set path(homedir) [file dirname [info nameofexecutable]]
       set path(vfsdir) [info nameofexecutable]
       set potato(wrapped) 1
     } else {
       set path(homedir) [file join [file dirname [info script]] .. ..]
       set path(vfsdir) [file join [file dirname [info script]] ..]
       set potato(wrapped) 0
     }
  set path(lib) [file join $path(vfsdir) lib]
  set path(help) [file join $path(lib) help]
  set path(i18n_int) [file join $path(lib) i18n]

  # Number of connections made
  set potato(conns) 0
  # Number of saved worlds
  set potato(worlds) 0
  set potato(nextWorld) 1
  # The current skin on display
  set potato(skin) ""
  # The current connection on display
  set potato(up) ""
  # Are we running in local mode?
  set potato(local) 0

  set potato(locale) "en_gb"

  # Regexp which spawn names must match
  set potato(spawnRegexp) {^[A-Za-z][A-Za-z0-9_!+=""*#@'-]{0,49}$};# doubled-up " for syntax highlighting

  set potato(skinMinVersion) "1.4" ;# The minimum version of the skin spec this Potato supports.
                                   ;# All skins must be at least this to be usable.

  set potato(skinCurrVersion) "1.4" ;# The current version of the skin spec. If changes made aren't
                                    ;# incompatible, this may be higher than skinMinVersion
  cd $path(homedir)

  set path(log) $path(homedir)
  set path(upload) $path(homedir)

  basic_reqs

  errorLogWindow;# create a window for displaying error log messages

  # Parse command-line options
  foreach x $argv {
    if { [string range $x 0 1] ne "--" } {
         break;
       } else {
         set argv [lrange $argv 1 end]
         incr argc -1
         if { $x eq "--local" } {
              set potato(local) 1
            } else {
              errorLog "Unknown command line paramater: $x" warning
            }
       }
  }

  if { $potato(local) } {
       set path(world) [file join $path(homedir) worlds]
       set path(skins) [file join $path(homedir) skins]
       set path(userlib) [file join $path(homedir) lib]
       set path(preffile) [file join $path(homedir) potato.ini]
       set path(custom) [file join $path(homedir) potato.custom]
       set path(startupCmds) [file join $path(homedir) potato.startup]
       set path(i18n) [file join $path(homedir) i18n]
     } elseif { $::tcl_platform(platform) eq "windows" } {
       set path(world) [file join $path(homedir) worlds]
       set path(skins) [file join $path(homedir) skins]
       set path(userlib) [file join $path(homedir) lib]
       set path(preffile) [file join $path(homedir) potato.ini]
       set path(custom) [file join $path(homedir) potato.custom]
       set path(startupCmds) [file join $path(homedir) potato.startup]
       set path(i18n) [file join $path(homedir) i18n]
     } else {
       set path(world) [file join ~ .potato worlds]
       set path(skins) [file join ~ .potato skins]
       set path(userlib) [file join ~ .potato lib]
       set path(preffile) [file join ~ .potato config]
       set path(custom) [file join ~ .potato potato.custom]
       set path(startupCmds) [file join ~ .potato potato.startup]
       set path(i18n) [file join ~ .potato i18n]
     }
  set dev [file join $path(homedir) potato.dev]


  # This MUST be after basic_reqs, as the [tk] command isn't available on
  # linux until that's called.
  set potato(windowingsystem) [tk windowingsystem]

  treeviewHack;# hackily fix the fact that Treeviews can still be played with when disabled

  option add *Listbox.activeStyle dotbox
  option add *TEntry.Cursor xterm
  createImages

  if { [catch {package require http} errmsg errdict] } {
       errorLog "Unable to load http package: $err" warning [errorTrace $errdict]
     }

  if { ![file exists $dev] } {
       errorLog "Dev file \"[file nativename [file normalize $dev]]\" does not exist." message
     } elseif { [catch {source $dev} err errdict] } {
       errorLog "Unable to source \"[file nativename [file normalize $dev]]\": $err" warning [errorTrace $errdict]
     }
  foreach x [list world skins lib] {
     catch {file mkdir $path($x)}
  }
  catch {file mkdir $paths(world)}
  lappend ::auto_path $path(userlib)
  ::tcl::tm::path add $path(userlib)

  # We need to set the prefs before we load anything...
  setPrefs 1

  # Now set up translation stuff
  i18nPotato

  tasksInit

  # Load TLS if available, for SSL connections
  if { [catch {package require tls} err errdict] } {
       set potato(hasTLS) 0
       errorLog "Unable to load TLS for SSL connecions: $err" warning [errorTrace $errdict]
     } else {
       set potato(hasTLS) 1
     }

  # Set the ttk theme to use
  setTheme
  loadSkins
  loadWorlds

  tooltipInit

  if { $misc(windowSize) eq "zoomed" || $misc(startMaximized) } {
       set zoom 1
     } else {
       set zoom 0
     }
  if { !$zoom || [catch {wm state . zoomed}] } {
       catch {wm geometry . $misc(windowSize)}
     }
  wm protocol . WM_DELETE_WINDOW [list ::potato::chk_exit]
  setUpMenu

  if { $misc(skin) in $skins(int) } {
       set potato(skin) $misc(skin)
     } else {
       errorLog "Requested skin, $misc(skin), is not available. Switching to default skin, potato, instead." warning
       set potato(skin) "potato";# default skin
     }
  showSkin $potato(skin)

  setClock

  set running 1;# so potato.tcl can be re-sourced without re-running this proc

  newConnection -1
  # We do this after newConnection, or the <FocusIn> binding comes up wrong
  setUpBindings

  # setUpWinico must be run before setUpFlash
  setUpWinico
  setUpFlash

  if { $::tcl_platform(platform) eq "windows" } {
       if { ![catch {package require dde 1.3} err errdict] } {
            # Start the DDE server in case we're the default telnet app.
            # Only do this on Windows when DDE is available
            ::potato::ddeStart
          } else {
            errorLog "Unable to load DDE extension: $err" warning [errorTrace $errdict]
          }
     }


  # Alias some /commands
  ::potato::alias_slash_cmd show world ;# /world
  ::potato::alias_slash_cmd show w ;# /w
  ::potato::alias_slash_cmd speedwalk sw;# /sw
  ::potato::alias_slash_cmd null silent ;# /silent

  if { ![file exists $path(custom)] } {
       errorLog "Custom code file \"[file nativename [file normalize $path(custom)]]\" does not exist." message
     } elseif { [catch {source $path(custom)} err errdict] } {
       errorLog "Unable to source Custom file \"[file nativename [file normalize $path(custom)]]\": $err" warning [errorTrace $errdict]
     }

  loadPotatoModules

  if { ![file exists $path(startupCmds)] } {
       errorLog "Startup Commands file \"[file nativename [file normalize $path(startupCmds)]]\" does not exist." message
     } elseif { [catch {open $path(startupCmds) r} fid errdict] } {
       errorLog "Unable to open Startup Commands file \"[file nativename [file normalize $path(startupCmds)]]\": $fid" [errorTrace $errdict]
     } else {
       send_to "" [read $fid] "" 0
     }

  # Attempt to parse out connection paramaters
  switch $::argc {
    0 {}
    1 {handleOutsideRequest cl [lindex $::argv 0]}
    default {parseCommandLine $::argv $::argc}
  }


  after idle [list ::potato::autoConnect]

  after idle [list ::potato::keepalive]

  if { $misc(checkForUpdates) } {
       after 3500 [list ::potato::checkForUpdates 1]
     }


  # Start ANSI-flashing
  after $misc(ansiFlashDelay,on) ::potato::flashANSI 1

  return;

};# ::potato::main

#: proc ::potato::loadPotatoModules
#: desc Load any code files in the userlib directory stored as Tcl modules
#: return nothing
proc ::potato::loadPotatoModules {} {
  variable path;

  foreach x [glob -nocomplain -directory $path(userlib) -tails *.tm] {
    if { ![regexp {^([_[:alpha:]][:_[:alnum:]]*)-([[:digit:]].*)\.tm$} $x - name vers] } {
         continue;
       } elseif { [catch {package require $name $vers} err errdict] } {
         errorLog "Unable to load Module '$name' version '$vers': $err" error [errorTrace $errdict]
       } else {
         errorLog "Module $name version $vers loaded." message
       }
  }

  return;

};# ::potato::loadPotatoModules

#: proc ::potato::keepalive
#: desc Send a Telnet NOP to each connection, as a keepalive, and repeat
#: desc every 45 seconds. Also send a null-byte as a keepalive for worlds
#: desc with that enabled.
#: return nothing
proc ::potato::keepalive {} {
  variable world;
  variable conn;

  foreach c [connIDs] {
    if { $conn($c,connected) != 1 } {
         continue;
       }
    if { [hasProtocol $c telnet] &&
         $world($conn($c,world),telnet,keepalive) } {
         ::potato::telnet::send_keepalive $c
       }
    if { $world($conn($c,world),nbka) } {
         sendRaw $c "\0" 0
       }
  }

  after 45000 [list ::potato::keepalive]

  return;

};# ::potato::keepalive

#: proc ::potato::i18nPotato
#: desc Set up the translation stuff.
#: return nothing
proc ::potato::i18nPotato {} {
  variable misc;
  variable path;
  variable potato;
  variable locales;

  if { [catch {package require msgcat 1.4.2} err errdict] } {
       errorLog "Unable to load msgcat for translations: $err" error [errorTrace $errdict]
       return;
     }

  # Some English "translations".
  # This is where we've used more verbose messages in some places to make phrases which are repeated in English, but with
  # different context, translatable as different strings in other languages. In English we convert the verbose form back to
  # the shorter version. NOTE: Must be done before we load translations, otherwise we may clobber the user's preferred translation.
  namespace eval :: {::msgcat::mcmset en [list "Convert To:" "To:" "Recipient:" "To:" "Limit To:" "To:" "Spawn To:" "To:"]}

  set loclist [list en_gb]

  # Load translation files. We do this in two steps:
  # 1) Load *.ptf files using [::potato::loadTranslationFile]. These are just message catalogues.
  # 2) Use ::msgcat::mcload, which loads *.msg files containing Tcl code for translations
  foreach x [glob -nocomplain -dir $path(i18n_int) -- *.ptf] {
    lappend loclist [loadTranslationFile $x]
  }

  if { [file exists $path(i18n)] && [file isdir $path(i18n)] } {
       foreach x [glob -nocomplain -dir $path(i18n) -- *.ptf] {
         lappend loclist [loadTranslationFile $x]
       }
     }

  array set locales [list \
     map,en      "English" \
     map,en_gb   "English (British)" \
     map,en_us   "English (United States)" \
     map,hr_hr   "Hrvatski (Croatian)" \
     map,es      "Espa\u00f1ol (Spanish)" \
     map,se      "Svenska (Swedish)" \
  ]

  set loclist [lsearch -all -inline -not -regexp $loclist {^(.*,.*)?$}]

  foreach x $loclist {
    if { [info exists locales(map,$x)] } {
         set locales($x) $locales(map,$x)
       } else {
         set locales($x) $x
       }
  }

  ::potato::setLocale

  return;

  # These lines are for the benefit of the script which builds the translation template.
  # They are not necessarily used by Potato directly, but shown in Tcl/Tk by widgets (message dialogs, etc)
  # so we include the strings to ensure they get offered for translation
  # [T "&Yes"]
  # [T "&No"]
  # [T "&OK"]
  # [T "&Retry"]
  # [T "&Abort"]
  # [T "&Ignore"]
  # [T "&Cancel"] from tk_messageBox

};# ::potato::i18nPotato

#: proc ::potato::setLocale
#: desc Using $misc(locale) - the desired locale - set potato(locale) to the best possible locale, update the display everywhere to show stuff in the new language.
#: return nothing
proc ::potato::setLocale {} {
  variable misc;
  variable potato;
  variable locales;

  set split [split $misc(locale) "_"]
  set preflist [list]
  for {set i 0} {$i < [llength $split]} {incr i} {
    lappend preflist [join [lrange $split 0 end-$i] "_"]
  }

  set potato(locale) ""
  foreach x $preflist {
    if { [info exists locales($x)] } {
         set potato(locale) $x
         break;
       }
  }

  if { ![info exists potato(locale)] || $potato(locale) eq "" } {
       set potato(locale) "en_GB"
     }

  # Set our best available
  ::msgcat::mclocale $potato(locale)

  # Update display to make sure we're using it
  if { $potato(skin) ne "" } {
       ::skin::${potato(skin)}::locale
     }
  setUpMenu
  setAppTitle
  if { [up] == 0 } {
       connZero
     }

  return;

};# ::potato::setLocale

#: ::potato::loadTranslationFile
#: arg file The filename to load
#: desc Load translation strings from the file $file
#: return locale on success, empty string on failure
proc ::potato::loadTranslationFile {file} {

  # The format for these files is:
  # <originalMsg>
  # <translatedMsg>
  # <originalMsg>
  # <translatedMsg>
  # etc.
  #
  # All files should be in utf-8 or 7bit ascii - extended characters can be specified via \xHH or \uHHHH syntax.
  # File names are <locale>.ptf
  # All strings are evaluated with [subst -nocommands -novariables] to parse \-syntax.
  #
  # Any empty lines, lines containing only white space, and lines starting with '#' will
  # be ignored as comments/whitespace to make the .ptf file clearer. A <translatedMsg> containing
  # the single character "-" will cause that original message to be skipped, so I can build a template
  # of translatable messages which will "work" but do nothing.

  if { [catch {open $file r} fid] } {
       errorLog "Unable to load translation file \"[file nativename [file normalize $file]]\": $fid" warning
       return "";
     }

  if { [catch {gets $fid line} count] || $count < 0 } {
       catch {close $fid}
       errorLog "Translation file \"[file nativename [file normalize $file]]\" is empty." warning
       return "";
     }

  # msgcat uses lower-case names, so we will too.
  set locale [string tolower [file rootname [file tail $file]]]

  fconfigure $fid -encoding utf-8

  set i 0
  set translations [list]
  while { 1 } {
    if { [string trim $line] ne "" && [string index $line 0] ne "#" } {
            if { $i } {
              set i 0;
              if { $line ne "-" } {
                   lappend translations [subst -nocommands -novariables $msg] [subst -nocommands -novariables $line]
                 }
            } else {
              set msg $line
              set i 1
            }
       }
    if { [catch {gets $fid line} count] || $count < 0 } {
         break;
       }
  }
  close $fid;
  set count [namespace eval :: [list ::msgcat::mcmset $locale $translations]]
  errorLog "$count translations set for $locale." message

  if { $count > 0 } {
       return $locale;
     } else {
       return "";
     }

};# ::potato::loadTranslationFile

#: proc ::potato::treeviewHack
#: desc Fix the fact that Treeview widgets can be played with when disabled.
#: return nothing
proc ::potato::treeviewHack {} {

  foreach x [list Control-Button-1 Shift-Button-1 Key-space Key-Return Key-Left Key-Right \
                  Key-Down Key-Up B1-Motion Double-Button-1 ButtonRelease-1 Button-1] {
     bind Treeview <$x> [format {if { ![%%W instate disabled] } { %s }} [bind Treeview <$x>]]
  }

  # Clear MouseWheel binding in favour of our own binding on "all"
  bind Treeview <MouseWheel> {}

  return;

};# ::potato::treeviewHack

#: proc ::potato::setTheme
#: desc Set the ttk/tile theme
#: return nothing
proc ::potato::setTheme {} {
  variable misc;

  if { [catch {::ttk::style theme use $misc(tileTheme)} err1] && [catch {::ttk::setTheme $misc(tileTheme)} err2] } {
       errorLog "Unable to set style: $err1 // $err2" error
     }

  ttk::style configure error.TLabel -foreground red
  ttk::style layout Plain.TNotebook.Tab null

  return;

};# ::potato::setTheme

#: proc ::potato::tooltipInit
#: desc Initialise the vars, widgets, etc, used by tooltips
#: return nothing
proc ::potato::tooltipInit {} {
  variable tooltip;

  set tooltip(up) ""
  set tooltip(after) ""
  set tooltip(widget) .potato_tooltip
  bind PotatoToolTip <Enter> [list ::potato::tooltipEnter %W]
  bind PotatoToolTip <Leave> [list ::potato::tooltipLeave %W]
  bind PotatoToolTip <Destroy> [list ::potato::tooltip %W ""]

  return;

};# ::potato::tooltipInit

#: proc ::potato::tooltip
#: arg widget Widget path
#: arg txt Text to use as tooltip
#: desc Add a tooltip for $widget (or remove an existing one, if $txt is empty)
#: return nothing
proc ::potato::tooltip {widget txt} {
  variable tooltip;

  if { $txt == "" } {
       unset -nocomplain tooltop(for,$widget)
       if { ![winfo exists $widget] } {
            return;# widget is being destroyed
          }
       set pos [lsearch -exact [bindtags $widget] "PotatoToolTip"]
       if { $pos == -1 } {
            return;
          }
       bindtags $widget [lreplace [bindtags $widget] $pos $pos]
       if { $tooltip(up) == $widget } {
            after cancel $tooltip(after)
            catch {destroy $tooltip(widget)};
          }
       return;
     }

  set tooltip(for,$widget) $txt
  if { [set pos [lsearch -exact [bindtags $widget] "PotatoToolTip"]] == -1 } {
       bindtags $widget [linsert [bindtags $widget] 0 "PotatoToolTip"]
     }

  return;

};# ::potato::tooltip

#: proc ::potato::showMessageTimestamp
#: arg widget text widget path
#: arg x x-coord in widget
#: arg y y-coord in widget
#: desc Wrapper to show a tooltip with the timestamp of the message being hovered in text widget $widget, when the mouse moves in widger $t
#: return nothing
proc ::potato::showMessageTimestamp {widget x y} {
  variable tooltip;
  variable misc;

  if { ![info exists tooltip($widget)] } {
       set tooltip($widget) 0
     }

  set index [$widget index @$x,$y]
  if { $index eq [$widget index end-1char] } {
       # Not over a line
       tooltipLeave $widget
       return;
     }
  scan $index %d.%*d line
  if { $line == $tooltip($widget) } {
       # Do nothing, we're already showing the right timestamp
       return;
     }

  set stamp [$widget tag nextrange timestamp $index]
  if { $stamp eq "" } {
       # No timestamp for line
       tooltipLeave $widget
       return;
     }
  set timestamp [$widget get {*}$stamp]
  # Find coords to show it
  set coords [$widget bbox $index]
  if { [llength $coords] < 2 || [lindex $coords 0] eq "" || [lindex $coords 1] eq "" } {
       tooltipLeave $widget
       return;
     }
  set x [expr {[lindex $coords 0] + [winfo rootx $widget]}]
  set y [expr {[lindex $coords 1] + [winfo rooty $widget]}]
  tooltipEnter $widget 900 [clock format $timestamp -format $misc(clockFormat)] $x $y

  return;

};# ::potato::showMessageTimestamp

#: proc ::potato::tooltipEnter
#: arg widget Widget path
#: arg time Time delay before showing. Defaults to 450
#: arg text Text to show, or empty to use preset text for widget. Defaults to empty string.
#: arg x X-coord to show at, defaults to empty string to show near widget
#: arg y Y-coord to show at, defaults to empty string to show near widget
#: desc Called when a widget with a tooltip has an <Enter> event. Set up an [after] to display the tooltip
#: return nothing
proc ::potato::tooltipEnter {widget {time 450} {text ""} {x ""} {y ""}} {
  variable tooltip;

  after cancel $tooltip(after)
  catch {destroy $tooltip(widget)}
  set tooltip(up) $widget
  set tooltip(after) [after $time [list ::potato::tooltipShow $widget $text $x $y]]

  return;

};# ::potato::tooltipEnter

#: proc ::potato::tooltipLeave
#: arg widget Widget path
#: desc Called when a tooltip'd widget has a <Leave> event. Cancel impending/destroy current tooltip
#: return nothing
proc ::potato::tooltipLeave {widget} {
  variable tooltip;

  after cancel $tooltip(after)
  catch {destroy $tooltip(widget)}
  set tooltip(up) ""
  set tooltip(after) ""

  return;

};# ::potato::tooltipLeave

#: proc ::potato::tooltipShow
#: arg widget Widget path
#: arg text Text to show, or empty to use preset text for widget. Defaults to empty string.
#: arg x x-coord, or "" to use the cursor position. Defaults to ""
#: arg y y-coord, or "" to use either a position near the cursor (if $text is non-empty), or the bottom of the widget. Defaults to ""
#: desc Actually show the tooltip for $widget, if we're still in it.
#: return nothing
proc ::potato::tooltipShow {widget {text ""} {x ""} {y ""}} {
  variable tooltip;

  if { ![winfo exists $widget] || [winfo containing {*}[winfo pointerxy $widget]] ne $widget } {
       return;
     }
  if { $text eq "" } {
       if { ![info exists tooltip(for,$widget)] } {
            return;
          }
       set text $tooltip(for,$widget);
       set pos 1
     } else {
       set pos 0
     }
  set top $tooltip(widget)
  catch {destroy $top}
  toplevel $top
  wm title $top $text
  $top configure -borderwidth 1 -background black
  wm overrideredirect $top 1
  pack [message $top.txt -aspect 10000 -background lightyellow \
        -font {"" 8} -text $text -padx 1 -pady 0]
  bind $top <ButtonPress-1> [list catch [list destroy $tooltip(widget)]]
  if { $x eq "" } {
       set wmx [winfo pointerx $widget]
     } else {
       set wmx $x
     }
  if { $y eq "" } {
       if { $pos } {
            set wmy [expr [winfo rooty $widget]+[winfo height $widget]]
          } else {
            set wmy [expr {[winfo pointery $widget] - 25}]
          }
     } else {
       set wmy [expr {$y - [winfo reqheight $top.txt] - 5}]
     }
  if {[expr $wmy+([winfo reqheight $top.txt]*2)]>[winfo screenheight $top]} {
      incr wmy -[expr [winfo reqheight $top.txt]*2]
     }
  if {[expr $wmx+([winfo reqwidth $top.txt]+5)]>[winfo screenwidth $top]} {
      incr wmx -[expr [winfo reqwidth $top.txt]*2]
      set wmx [expr [winfo screenwidth $top]-[winfo reqwidth $top.txt]-7]
     }
  wm geometry $top \
     [winfo reqwidth $top.txt]x[winfo reqheight $top.txt]+$wmx+$wmy
  raise $top

  return;

};# ::potato::tooltipShow

#: proc ::potato::worldIDs
#: arg includeDefault Include the "default" world, -1? Defaults to 0
#: desc Return a list of all currently defined world's ids, possibly including -1
#: return list of world ids
proc ::potato::worldIDs {{includeDefault 0}} {
  variable world;

  if { $includeDefault } {
       set pattern {^-?[0-9]+,id$}
     } else {
       set pattern {^[0-9]+,id$}
     }
  set ids [array names world -regexp $pattern]

  return [lsort -integer [split [string map [list ",id" ""] [join $ids " "]] " "]];

};# ::potato::worldIDs

#: proc ::potato::connIDs
#: arg includeDefault Include the connection screen, "connection 0"? Defaults to 0
#: desc Return a list of all current connections, possibly including the connection screen 0
#: return list of connection ids
proc ::potato::connIDs {{includeDefault 0}} {
  variable conn;

  if { $includeDefault } {
       set pattern {^[0-9]+,id$}
     } else {
       set pattern {^[1-9][0-9]*,id$}
     }
  set ids [array names conn -regexp $pattern]

  return [lsort -integer [split [string map [list ",id" ""] [join $ids " "]] " "]];

};# ::potato::connIDs

#: proc ::potato::showMSSP
#: desc Show MSSP info for the current connection.
#: return nothing
proc ::potato::showMSSP {} {
  variable conn;
  variable world;

  set c [up]
  if { ![info exists conn($c,telnet,mssp)] || ![llength $conn($c,telnet,mssp)] } {
       bell -displayof .
       return;
     }

  set win .mssp$c
  if { [reshowWindow $win] } {
       return;
     }
  toplevel $win
  registerWindow $c $win
  wm title $win [T "MSSP Info for \[%d. %s\]" $c $world($conn($c,world),name)]

  set tree [::ttk::treeview $win.tree -columns [list Variable Value] -show [list headings] \
                  -xscrollcommand [list $win.x set] -yscrollcommand [list $win.y set]]
  set y [::ttk::scrollbar $win.y -orient vertical -command [list $tree yview]]
  set x [::ttk::scrollbar $win.x -orient horizontal -command [list $tree xview]]
  grid_with_scrollbars $tree $x $y


  $tree heading Variable -text [T "Variable"] -anchor w
  $tree heading Value -text [T "Value"] -anchor w
  $tree column Variable -width 100
  $tree column Value -width 250

  # Build list
  foreach x [lsort -dictionary -index 0 $conn($c,telnet,mssp)] {
     $tree insert {} end -values $x
  }

  return;

};# ::potato::showMSSP

#: proc ::potato::showStats
#: desc Show a window of connection stats for each world.
#: return nothing
proc ::potato::showStats {} {
  variable world;
  variable conn;

  foreach w [worldIDs] {
     set stats($w,name) $world($w,name)
     set stats($w,conns) $world($w,stats,conns)
     set stats($w,time) $world($w,stats,time)
  }

  foreach c [connIDs] {
     set w $conn($c,world)
     if { [info exists conn($c,stats,prev)] && [string is integer -strict $conn($c,stats,prev)] } {
          incr stats($w,time) $conn($c,stats,prev)
        }
     if { $conn($c,stats,connAt) != -1 } {
          incr stats($w,time) [expr {[clock seconds] - $conn($c,stats,connAt)}]
        }
  }

  set win .connStats
  destroy $win;# if it exists, destroy it; we'll remake it with up-to-date stats

  toplevel $win
  wm title $win [T "Connection Statistics"]
  wm withdraw $win

  set sb $win.ysb
  foreach x [list name conns time] y [list [T "MU* Name"] \
                                           [T "No of Connections"] \
                                           [T "Total Connection Time"]] {
     set lb [listbox $win.lb_$x -yscrollcommand [list $sb set] -activestyle none]
     lappend listboxes $lb
     $lb insert end $y
     $lb itemconfigure end -background [$lb cget -foreground] -foreground [$lb cget -background]
     foreach this [lsort -dictionary [array names stats *,$x]] {
        if { $x eq "time" } {
             $lb insert end [timeFmt $stats($this) 0]
           } else {
             $lb insert end $stats($this)
           }
     }
     bindtags $lb [list $win all]
  }
  scrollbar $sb -orient vertical -command [list ::potato::multiscroll $listboxes yview]

  pack {*}$listboxes -side left -anchor nw -fill both -expand 1
  pack $sb -side left -anchor nw -fill y

  bind $win <Escape> [list destroy $win]
  update idletasks
  center $win
  wm deiconify $win
  raise $win
  focus $win
  return;

};# ::potato::showStats

#: proc ::potato::multiscrollSet
#: arg src source widget, to get scroll position from
#: arg dst destination widgets, to set scroll position of
#: arg sb scrollbar
#: arg args args for scrollbar widget
#: desc Scroll additional widgets, and the scrollbar, when one widget is scrolled.
#: return nothing
proc ::potato::multiscrollSet {src dst sb args} {

  foreach x $dst {
    $x yview moveto [lindex $args 0]
  }
  $sb set {*}$args

  return;
}

#: proc ::potato::multiscroll
#: arg widgets list of widgets
#: arg subcmd scroll subcommand (yview or xview)
#: arg args Extra args appended by scrollbar widget's -command
#: desc Scroll each of the widgets in $widgets, with $this $subcmd {*}$args
#: return nothing
proc ::potato::multiscroll {widgets subcmd args} {

  foreach x $widgets {
     $x $subcmd {*}$args
  }

  return;

};# ::potato::multiscroll

#: proc ::potato::minimizeToTray {w} {
#: desc If $w is a toplevel, and we can minimize to tray, and it's minimized, withdraw $w
#: return nothing
proc ::potato::minimizeToTray {w} {
  variable winico;
  variable misc;

  if { $w ne [winfo toplevel $w] } {
       return;
     }

  if { !$winico(loaded) || !$misc(showSysTray) || !$misc(minToTray) } {
       return;
     }

  if { [wm state $w] ne "iconic" } {
       return;
     }

  # Minimize to tray
  wm withdraw $w

  return;

};# ::potato::minimizeToTray

#: proc ::potato::setUpWinico
#: desc Set up the vars used by winico and, if winico is to be used, load the icons, etc. This setup needs doing even when winico isn't loaded (to set vars stating that fact).
#: return nothing
proc ::potato::setUpWinico {} {
  variable winico;
  variable path;
  variable misc;

  set winico(loaded) 0
  set winico(mapped) 0
  set winico(flashing) 0
  if { $::tcl_platform(platform) ne "windows" } {
       return;
     }

  set dir [file join $path(vfsdir) lib app-potato windows]
  set winico(mainico) [file join $dir stpotato.ico]

  if { [catch {package require Winico 0.6} err errdict] } {
       errorLog "Unable to load Winico: $err" warning [errorTrace $errdict]
       return;
     }

  if { ![file exists $dir] || ![file isdirectory $dir] || ![file exists $winico(mainico)] || ![file isfile $winico(mainico)] } {
       return;
     }

  if { [catch {set winico(main) [winico createfrom $winico(mainico)]}] } {
       return;
     }

  set winico(menu) [menu .winico -tearoff 0]

  $winico(menu) add command -label [T "Restore"] -command ::potato::winicoRestore
  $winico(menu) add separator
  $winico(menu) add command -label [T "Hide Icon"] -command ::potato::winicoHideIcon
  $winico(menu) add separator
  $winico(menu) add command -label [T "Exit"] -command ::potato::chk_exit

  set winico(pos) 0
  set winico(loaded) 1
  if { $misc(showSysTray) } {
       winicoMap
     }
  return;


};# ::potato::setUpWinico

#: proc ::potato::winicoHideIcon
#: desc Turn off the SysTrayIcon otion and hide the Winico icon in the system tray when "Hide" is selected from it's menu.
#: return nothing
proc ::potato::winicoHideIcon {} {
  variable misc;

  set misc(showSysTray) 0

  winicoUnmap

  return;

};# ::potato::winicoHideIcon

#: proc ::potato::winicoMap
#: desc Show the sys tray icon on Windows using winico
#: return nothing
proc ::potato::winicoMap {} {
  variable winico;
  variable potato;

  if { $winico(mapped) || !$winico(loaded) } {
       return;
     }

  if { [catch {winico taskbar add $winico(main) -text $potato(name) -pos 0 \
                        -callback [list ::potato::winicoCallback %m %x %y]}] } {
       catch {destroy $winico(menu)}
       catch {winico taskbar delete $winico(main)}
       catch {winico delete $winico(main)}
       set winico(loaded) 0
       return;
     }

  set winico(mapped) 1

  return;

};# ::potato::winicoMap

#: proc ::potato::winicoUnmap
#: desc Remove the sys tray icon which winico placed on Windows
#: return nothing
proc ::potato::winicoUnmap {} {
  variable winico;

  catch {winicoFlashOff}
  catch {winico taskbar delete $winico(main)}
  set winico(mapped) 0

  return;

};# ::potato::winicoUnmap

#: proc ::potato::winicoCallback
#: arg event The event that triggered the callback
#: arg x X coord of event
#: arg y Y coord of event
#: desc Handle an event on the winico taskbar icon (movement, button click, etc)
#: return nothing
proc ::potato::winicoCallback {event x y} {
  variable winico;

  $winico(menu) unpost
  if { $event eq "WM_LBUTTONUP" } {
       winicoRestore
     } elseif { $event eq "WM_RBUTTONUP" } {
       $winico(menu) post $x $y
       $winico(menu) activate 0
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

#: proc ::potato::winicoFlashOn
#: desc Flash the winico icon on the taskbar by changing it to another icon and back
#: return nothing
proc ::potato::winicoFlashOn {} {
  variable winico;
  variable potato;

  set newpos [lindex [list 1 0] $winico(pos)]
  winico taskbar modify $winico(main) -pos $newpos -text $potato(name)
  set winico(pos) $newpos
  set winico(after) [after 750 {::potato::winicoFlashOn}]
  set winico(flashing) 1
  return;

};# ::potato::winicoFlashOn

#: proc ::potato::winicoFlashOff
#: desc Stop the winico icon on the taskbar from flashing by resetting to the default icon and cancelling the flash
#: return nothing
proc ::potato::winicoFlashOff {} {
  variable winico;
  variable potato;

  after cancel $winico(after)
  set winico(pos) 0
  set winico(flashing) 0
  winico taskbar modify $winico(main) -pos 0 -text $potato(name)
  return;
};# ::potato::winicoFlashOff

#: proc ::potato::loadSkins
#: desc load all the skins available, adding them to the $::potato::skins list
#: return nothing
proc ::potato::loadSkins {} {
  variable path;
  variable skins;

  if { ![info exists skins(int)] } {
       set skins(int) [list]
       set skins(display) [list]
     }

  package require potato-skin
  registerSkin potato

  set files [glob -nocomplain -type d -directory $path(skins) *.skn]
  if { [llength $files] == 0 } {
       return;
     }

  foreach SKINDIR $files {
     if { ![catch {source [lindex [glob -dir $SKINDIR *.init] 0]} value] && \
          $value eq [file rootname [file tail $SKINDIR]] } {
          registerSkin $value
        }
  }

  return;

};# ::potato::loadSkins

#: proc ::potato::registerSkin
#: arg skin internal name of the skin
#: desc add the skin $skin to any appropriate lists to make it show up as available
#: return nothing
proc ::potato::registerSkin {skin} {
  variable skins;

  if { $skin ni $skins(int) && "[set ::skin::${skin}::skin(name)] ($skin [set ::skin::${skin}::skin(version)])" ni $skins(display)} {
       lappend skins(int) $skin
       lappend skins(display) "[set ::skin::${skin}::skin(name)] ($skin [set ::skin::${skin}::skin(version)])"
     }

  return;

};# ::potato::registerSkin

#: proc ::potato::history
#: arg c connection id. Defaults to ""
#: desc Show the input history window for connection $c, or the currently displayed connection if $c is empty
proc ::potato::history {{c ""}} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  set win .input_history_$c
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  registerWindow $c $win
  wm withdraw $win
  wm title $win [T "Input History for %d. %s" $c [connInfo $c name]]

  pack [set frame [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw

  set text [T "Select a command and press 1 to place it in the top input window, 2 to place it in the lower input window, or 3 to send it directly to the MU*. Press 4 to copy it to the clipboard. Press escape to close the window."]
  ::ttk::label $frame.label -text $text -wraplength 350
  pack $frame.label -side top -pady 5 -padx 10 -fill x

  set cmds [::ttk::frame $frame.cmds]
  pack $cmds -side top -padx 10 -pady 5 -expand 1 -fill both
  set tree [::ttk::treeview $cmds.lb -height 15 -show headings -selectmode browse \
          -yscrollcommand [list $cmds.sby set] -xscrollcommand [list $cmds.sbx set] \
          -columns [list ID Command]]
  $tree heading ID -text "[T "ID"] " -anchor e
  $tree heading Command -text [T "Command"]
  $tree column ID -anchor e -stretch 0 -width 25
  $tree column Command -anchor w -stretch 1
  foreach x $conn($c,inputHistory) {
     $tree insert {} end -id [lindex $x 0] -values $x
  }
  ::ttk::scrollbar $cmds.sby -orient vertical -command [list $cmds.lb yview]
  ::ttk::scrollbar $cmds.sbx -orient horizontal -command [list $cmds.lb xview]
  grid_with_scrollbars $cmds.lb $cmds.sbx $cmds.sby
  pack $cmds -expand 1 -fill both

  pack [::ttk::frame $frame.filter] -side top -fill x -anchor n -padx 5 -pady 3
  pack [set filter [::ttk::entry $frame.filter.e -validate key \
           -validatecommand [list ::potato::historyFilter $tree %P %s]]] -expand 1 -fill x
  # Switcheroo
  set bindtags [bindtags $filter]
  bindtags $filter [lreplace $bindtags 0 1 [lindex $bindtags 1] [lindex $bindtags 0]]

  pack [::ttk::frame $frame.btns1] -side top -anchor nw -expand 0 -fill x -pady 3
  foreach {x y z} [list 1 top [T "Top Input"] \
                        2 btm [T "Bottom Input"] \
                        3 send [T "Send to MUSH"]] {
      pack [::ttk::frame $frame.btns1.$y] -side left -expand 1 -fill x -anchor n
      pack [set btn($y) [::ttk::button $frame.btns1.$y.btn -text $z \
                -command [list ::potato::historySub $c $win $tree $x]]] -side top -anchor center
  }
  pack [::ttk::frame $frame.btns2] -side top -anchor nw -expand 0 -fill x -pady 3
  foreach {x y z} [list 4 copy [T "Copy to Clipboard"] 5 close [T "Close"]] {
      pack [::ttk::frame $frame.btns2.$y] -side left -expand 1 -fill x -anchor n
      pack [set btn($y) [::ttk::button $frame.btns2.$y.btn -text $z \
                -command [list ::potato::historySub $c $win $tree $x]]] -side top -anchor center
  }
  $btn(close) configure -command [list destroy $win]

  bind $win <Return> [list $btn(close) invoke]
  bind $win <Escape> [list $btn(close) invoke]

  foreach x [list 1 2 3 4] {
    bind $win <KeyPress-$x> [list ::potato::historySub $c $win $tree $x]
    bind $filter <KeyPress-$x> {break}
  }
  bind $tree <Double-ButtonPress-1> [list ::potato::historySub $c $win $tree 5]


  update idletasks

  center $win
  reshowWindow $win 0
  # This is annoying...
  after 25 [list $tree yview moveto 1.0]

  bind $win <Destroy> [list ::potato::unregisterWindow $c $win]

  return;

};# ::potato::history

#: proc ::potato::historyFilter
#: arg tree Treeview widget to filter
#: arg filter The filter string
#: arg change The string being entered/deleted
#: desc If $change isn't empty, filter the elements so only ones matching *$filter* are displayed
#: return 1
proc ::potato::historyFilter {tree filter change} {

  set id 1
  set items [list]
  while { [$tree exists $id] } {
     lappend items $id
     $tree detach $id
     incr id
  }

  if { $filter eq "" } {
       # Special check for empty string, since it's likely the most common
       $tree children {} $items
     } else {
       set matches [list]
       foreach x $items {
         set value [lindex [$tree item $x -values] 1]
         if { [string match "*$filter*" $value] } {
              lappend matches $x
            }
       }
       $tree children {} $matches
     }

  return 1;

};# ::potato::historyFilter

#: proc ::potato::historySub
#: arg c connection id
#: arg top Path to input history window toplevel
#: arg lb Path to input history window's listbox
#: arg key 1-4, indicating the action to take
#: desc Based on $key, either insert the current selection from $lb into an input window, send to the MUSH or put onto the clipboard
#: return nothing
proc ::potato::historySub {c top lb key} {

  set index [$lb selection]
  if { $index == "" } {
       bell -displayof $top
       return;
     }
  set cmd [lindex [$lb item $index -values] 1]
  if { $cmd eq "" } {
       return;
     }

  set cmd [string map [list \b \n] $cmd]
  if { $key == 1 || $key == 2 } {
       showInput $c $key $cmd 0
       destroy $top
     } elseif { $key == 3 } {
       addToInputHistory $c $cmd
       send_to $c $cmd
       destroy $top
     } elseif { $key == 5 } {
       send_to $c $cmd
     } elseif { $key == 4 } {
       clipboard clear -displayof $top
       clipboard append -displayof $top $cmd $cmd]
       bell -displayof $top
     }

  return;

};# ::potato::historySub

#: proc ::potato::createImages
#: desc create the images, in the ::potato::img namespace, used by the app
#: return nothing
proc ::potato::createImages {} {
  variable path;

  set imgPath [file join $path(lib) images]

  foreach x [glob -dir $imgPath -tails *.gif] {
    image create photo ::potato::img::[file rootname $x] -file [file join $imgPath $x]
  }

  return;

};# ::potato::createImages

#: proc ::potato:errorTrace
#: arg errdict The error dict set by [catch $cmd $msg errdict]
#: desc If the dict $errdict contains an -errorinfo, return it, else return an empty string
#: return error trace, or empty string
proc ::potato::errorTrace {errdict} {


  if { [dict exists $errdict -errorinfo] } {
       set trace [dict get $errdict -errorinfo]
     } else {
       set trace ""
     }

  return $trace;

};# ::potato::errorTrace

#: proc ::potato::setUpFlash
#: arg skippackages Skip the [wl]inflash packages and use the fallback?
#: desc Set up the ::potato::flash proc, which flashes the taskbar icon and systray icon for the app.
#: desc If we're on Windows, we try to load the potato-winflash package and use that. On Linux, we try potato-linflash.
#: desc Else, we just "wm deiconify .". For Win we also try and flash the Winico systray icon if requested.
#: return nothing
proc ::potato::setUpFlash {{skippackages 0}} {
  variable winico;
  variable potato;
  variable path;

  if { $skippackages } {
       set taskbarCmd {wm deiconify .}
       set sysTrayCmd {# nothing}
     } elseif { $::tcl_platform(platform) eq "windows" } {
       if { ![catch {package require potato-winflash} err errdict] } {
            set taskbarCmd {winflash . -count 3 -appfocus 1}
          } else {
            errorLog "Unable to load potato-winflash package: $err" error [errorTrace $errdict]
            set taskbarCmd {wm deiconify .}
          }
       if { $winico(loaded) } {
            set sysTrayCmd {winicoFlashOn}
          } else {
            set sysTrayCmd {# nothing}
          }
     } else {
       if { [catch {package require potato-linflash}] } {
            # Attempt to copy linflash out for the first time
            catch {file mkdir $path(userlib)}
            catch {file copy -force [file join $path(lib) app-potato linux linflash1.0] $path(userlib)}
            catch {exec [file join $path(userlib) linflash1.0 compile]}
          }
       if { ![catch {package require potato-linflash} err errdict] } {
            set taskbarCmd {::potato::linflashWrapper}
            set sysTrayCmd {# nothing}
          } else {
            errorLog "Unable to load potato-linflash package: $err" [errorTrace $errdict]
            set taskbarCmd {wm deiconify .}
            set sysTrayCmd {# nothing}
          }
     }
  proc ::potato::flash {w} [format {
   variable world;
   variable winico;
   if { $world($w,act,flashTaskbar) } {
        catch {%s}
      }
   if { !$winico(flashing) && $world($w,act,flashSysTray) && $winico(mapped) } {
        catch {%s}
      }
   return;
  } $taskbarCmd $sysTrayCmd];# ::potato::flash

  return;

};# ::potato::setUpFlash

#: proc ::potato::linflashWrapper
#: desc A wrapper around [linflash] which catches errors and, if serious,
#: desc reverts the [flash] command back to 'wm deiconify' after logging
#: desc the error.
#: return nothing
proc ::potato::linflashWrapper {} {

  if { ![catch {linflash .} err errdict] || $err eq "" } {
       return;
     } else {
       errorLog "Error in linflash: $err. Falling back to 'wm deiconify' for flashing." [errorTrace $errdict]
       setupFlash 1
       flash .
     }

  return;

};# ::potato::linflashWrapper

#: proc ::potato::chk_exit
#: arg prompt If 0, do not prompt. If 1, prompt. If -1, prompt only if there are open (meaning "not closed", as
#: desc opposed to "connected") connections. NOTE: We always prompt if there are still active connections
#: desc if they want to quit, do so correctly
#: return nothing
proc ::potato::chk_exit {{prompt 0}} {
  variable potato;
  variable conn;
  variable misc;
  variable winico;
  variable skins;

  set connected 0
  if { $prompt == 0 } {
       set ask 0
     } elseif { $prompt == 1 || ($prompt == -1 && [llength [connIDs]]) } {
       set ask 1
     } else {
       set ask $misc(confirmExit)
     }

  foreach c [connIDs] {
     if { $conn($c,connected) } {
          set ask 1
          set connected 1
          break;
        }
  }


  if { $ask } {
       if { $connected } {
            set msg [T "Are you sure you want to quit? There are still open connections!"]
          } else {
            set msg [T "Are you sure you want to quit?"]
          }
       set ans [tk_messageBox -title $potato(name) -type yesno -message $msg]
       if { $ans ne "yes" } {
            return;
          }
     }

  # Although Tcl will automatically close any open socket connections,
  # our close world/disconnect procs handle stats checking, saving of temporary
  # worlds, etc, so we need to use them.
  foreach c [connIDs] {
     closeConn $c 1 1
  }

  # Save any global prefs not covered by 'saveWorlds'.
  savePrefs

  # Save skin prefs
  foreach x $skins(int) {
    catch {::skin::${x}::savePrefs}
  }

  # Save the cheerleader. Save the world(s).
  saveWorlds

  if { $winico(loaded) } {
       catch {winico taskbar delete $winico(main)}
     }

  exit;

};# ::potato::chk_exit

#: proc ::potato::menu_label
#: arg str String to parse
#: desc Parse $str and return a -label and -underline option. The -label is $str with the first "&"
#: desc removed, and the -underline is the position of that first & (or -1 if there is none).
#: return Tcl list of -label $label -underline $position
proc ::potato::menu_label {str} {

  set first [string first "&" $str]
  return [list -label [string replace $str $first $first] -underline $first];

};# ::potato::menu_label

#: proc ::potato::createMenuTask
#: arg m The menu to add to
#: arg task The task to add
#: arg c connection id to operate task on, or "" for current
#: arg args Further arguments to pass to the task when it's run
#: desc Add a menu entry for the task $task to menu $m, using the tasks's label, cmd, etc.
#: return nothing
proc ::potato::createMenuTask {m task {c ""} args} {
  variable menu;

  set vars [taskVars $task]
  set command [list -command [concat [list ::potato::taskRun $task $c] $args]]
  if { [llength $vars] != 0 } {
       set type "checkbutton"
       foreach {a b c} $vars {break;}
       set extras [list -variable $a -onvalue $b -offvalue $c]
     } elseif { $task eq "connectMenu" } {
       # Feh! This is a sucky way to do this. It should be recorded in the task somewhere that
       # this is a cascade.
       set type cascade
       set command [list]
       set extras [list -menu $menu(connect,path)]
     } else {
       set type "command"
       set extras [list]
     }

  $m add $type {*}[menu_label [taskLabel $task 1]] {*}$command {*}$extras \
         -state [lindex [list disabled normal] [taskState $task $c]] -accelerator [taskAccelerator $task]

  return;

};# ::potato::createMenuTask

#: proc ::potato::build_menu_file
#: arg m File menu widget
#: desc The File menu is about to be posted. Create its entries appropriately.
#: return nothing
proc ::potato::build_menu_file {m} {
  variable potato;
  variable menu;
  variable conn;

  $m delete 0 end

  if { $potato(worlds) > 0 } {
       set state "normal"
     } else {
       set state "disabled"
     }
  createMenuTask $m manageWorlds
  createMenuTask $m connectMenu
  createMenuTask $m autoConnects

  $m add separator
  createMenuTask $m reconnect
  createMenuTask $m disconnect
  createMenuTask $m close

  $m add separator
  createMenuTask $m reconnectAll

  $m add separator
  $m add command {*}[menu_label [T "&Show Connection Stats"]] \
              -command ::potato::showStats -state $state
  $m add command {*}[menu_label [T "Show &MSSP Info"]] \
              -command ::potato::showMSSP -state [expr {[llength $conn([up],telnet,mssp)] ? "normal" : "disabled"}]

  $m add separator
  createMenuTask $m exit

  return;

};# ::potato::build_menu_file

#: proc ::potato::build_menu_edit
#: arg m Edit menu widget
#: desc The Edit menu is about to be posted. Create its entries appropriately.
#: return nothing
proc ::potato::build_menu_edit {m} {
  variable potato;
  variable menu;

  $m delete 0 end
  set c [up]

  createMenuTask $m spellcheck
  $m add command {*}[menu_label [T "Configure &Prefixes/Auto-Say"]] \
              -command ::potato::prefixWindow

  $m add cascade -menu $menu(edit,convert,path) {*}[menu_label [T "&Convert..."]]

  return;

};# ::potato::build_menu_edit

#: proc ::potato::build_menu_view
#: arg m Widget path to the View menu
#: desc The "View" menu ($m) is about to be posted. Configure it's entries appropriately. Unlike other menus, this one also has entries appended by the skin.
#: return nothing
proc ::potato::build_menu_view {m} {
  variable potato;

  $m delete 0 end

  createMenuTask $m twoInputWins

  ::skin::$potato(skin)::viewMenuPost $m
  $m insert end checkbutton {*}[menu_label [T "&Debug Packets?"]] -variable ::potato::conn([up],debugPackets) \
                     -onvalue 1 -offvalue 0 -state [lindex [list normal disabled] [expr {[up] == 0}]]

  return;

};# ::potato::build_menu_view

#: proc ::potato::build_menu_log
#: arg m Widget path to Logging menu
#: desc The "Logging" menu (.m.log) is about to be posted. Configure it's entries appropriately.
#: return nothing
proc ::potato::build_menu_log {m} {
  variable conn;
  variable menu;

  $m delete 0 end

  set c [up]

  createMenuTask $m log
  $m add cascade {*}[menu_label [T "&Stop Logging"]] -menu $menu(log,stop,path)
  if { ![llength [array names conn $c,log,*]] } {
       $m entryconfigure end -state disabled
     }
  $m add separator
  createMenuTask $m upload

  return;

};# ::potato::build_menu_log

#: proc ::potato::build_menu_log_stop
#: arg m Widget path to the StopLogging menu
#: desc The "Stop Logging" (.m.log.stop) menu is about to be posted. Configure its entries appropriately.
#: return nothing
proc ::potato::build_menu_log_stop {m} {
  variable conn;

  set c [up]

  $m delete 0 end

  createMenuTask $m logStop
  set ids [removePrefix [arraySubelem conn $c,log] $c,log]
  if { [llength $ids] } {
       $m add separator
       foreach x $ids {
         createMenuTask $m logStop $c $c $x
         $m entryconfigure end -label [file nativename [file normalize $conn($c,log,$x)]]
       }
     }

  return;

};# ::potato::build_menu_log_stop

#: proc ::potato::build_menu_options
#: arg m Path to Options menu widget
#: desc Rebuild the Options menu when it's posted
#: return nothing
proc ::potato::build_menu_options {m} {
  variable conn;

  set c [up]

  $m delete 0 end

  createMenuTask $m programConfig
  createMenuTask $m globalEvents
  createMenuTask $m globalSlashCmds
  createMenuTask $m globalMacros

  $m add separator

  createMenuTask $m customKeyboard

  $m add separator

  createMenuTask $m config
  createMenuTask $m events
  createMenuTask $m slashCmds
  createMenuTask $m macroWindow

  $m add separator

  createMenuTask $m pickLocale

  return;

};# ::potato::build_menu_options

#: proc ::potato::build_menu_tools
#: arg m Path to Tools menu widget
#: desc Rebuild the Tools menu when it's posted
#: return nothing
proc ::potato::build_menu_tools {m} {

  $m delete 0 end

  createMenuTask $m inputHistory
  createMenuTask $m mailWindow
  createMenuTask $m textEd

  return;

};# ::potato::build_menu_tools

#: proc ::potato::build_menu_help
#: arg m Path to Help menu widget
#: desc Rebuild the Help menu when it's posted
#: return nothing
proc ::potato::build_menu_help {m} {

  $m delete 0 end

  createMenuTask $m help
  $m add separator
  $m add command {*}[menu_label [T "Tcl Code &Console"]] -command [list console show]
  if { [catch {console title "$::potato::potato(name) - Tcl Code Console"}] } {
       $m entryconfigure end -state disabled
     }
  $m add separator
  $m add command {*}[menu_label [T "&Debugging Log Window"]] -command [list ::potato::errorLogWindow]
  $m add separator
  createMenuTask $m about
  $m add command {*}[menu_label [T "Check for &Updates"]] -command [list ::potato::checkForUpdates]
  $m add command {*}[menu_label [T "Visit Potato &Website"]] -command [list ::potato::launchWebPage $::potato::potato(webpage)]

  return;

};# ::potato::build_menu_help

#: proc ::potato::setUpMenu
#: desc set up the menu in the main window
#: return nothing
proc ::potato::setUpMenu {} {
  variable menu;

  set menuname .potatoMainMenu
  if { [winfo exists $menuname] } {
       destroy $menuname
     }
  menu $menuname -tearoff 0
  . configure -menu $menuname
  catch {destroy {*}[winfo children $menuname]}
  set menu(file,path) [menu $menuname.file -tearoff 0 -postcommand [list ::potato::build_menu_file $menuname.file]]
  set menu(edit,path) [menu $menuname.edit -tearoff 0 -postcommand [list ::potato::build_menu_edit $menuname.edit]]
  set menu(edit,convert,path) [menu $menuname.edit.convert -tearoff 0]
  set menu(connect,path) [menu $menuname.file.connect -tearoff 0 -postcommand [list ::potato::rebuildConnectMenu $menuname.file.connect]]
  set menu(view,path) [menu $menuname.view -tearoff 0 -postcommand [list ::potato::build_menu_view $menuname.view]]
  set menu(log,path) [menu $menuname.log -tearoff 0 -postcommand [list ::potato::build_menu_log $menuname.log]]
  set menu(log,stop,path) [menu $menuname.log.stop -tearoff 0 -postcommand [list ::potato::build_menu_log_stop $menuname.log.stop]]
  set menu(options,path) [menu $menuname.options -tearoff 0 -postcommand [list ::potato::build_menu_options $menuname.options]]
  set menu(tools,path) [menu $menuname.tools -tearoff 0 -postcommand [list ::potato::build_menu_tools $menuname.tools]]
  set menu(help,path) [menu $menuname.help -tearoff 0 -postcommand [list ::potato::build_menu_help $menuname.help]]

  $menuname add cascade -menu $menuname.file {*}[menu_label [T "&File"]]
  set menu(file) [$menuname index end]
  $menuname add cascade -menu $menuname.edit {*}[menu_label [T "&Edit"]]
  set menu(edit) [$menuname index end]
  $menuname add cascade -menu $menuname.view {*}[menu_label [T "&View"]]
  set menu(view) [$menuname index end]
  $menuname add cascade -menu $menuname.log {*}[menu_label [T "&Logging"]]
  set menu(logging) [$menuname index end]
  $menuname add cascade -menu $menuname.options {*}[menu_label [T "&Options"]]
  set menu(options) [$menuname index end]
  $menuname add cascade -menu $menuname.tools {*}[menu_label [T "&Tools"]]
  set menu(tools) [$menuname index end]
  $menuname add cascade -menu $menuname.help {*}[menu_label [T "&Help"]]
  set menu(help) [$menuname index end]

  createMenuTask $menu(edit,convert,path) convertNewlines
  createMenuTask $menu(edit,convert,path) convertSpaces
  createMenuTask $menu(edit,convert,path) convertChars

  return;

};# ::potato::setUpMenu

#: proc ::potato::checkForUpdates
#: arg background Should this window stay in the background?
#: desc Show the window to check to see if an updated version of Potato has been released.
#: return nothing
proc ::potato::checkForUpdates {{background 0}} {
  variable potato;
  variable update;

  set win .checkForUpdates
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }
  toplevel $win
  wm withdraw $win
  pack [set frame [::ttk::frame $win.f]] -side top -expand 1 -fill both
  wm title $win [T "Check for Updates - %s" "Potato"]
  pack [set top [::ttk::frame $frame.top]] -padx 10 -pady 10
  set labelfont [font actual [::ttk::style lookup TLabel -font]]
  dict set labelfont -size [expr {round([dict get $labelfont -size] * 1.5)}]
  pack [::ttk::label $top.l1 -text [T "You are currently running version:"] -font $labelfont -justify center] -side top
  pack [::ttk::label $top.l2 -textvariable potato::potato(version) -font [concat $labelfont -weight bold] -justify center] -side top
  pack [::ttk::label $top.l3 -text [T "Checking for updates..."] -font $labelfont -justify center]

  pack [set progress [::ttk::frame $frame.progress]] -side top -padx 10 -pady 10
  pack [::ttk::progressbar $progress.bar -orient horizontal -mode indeterminate -length 160]
  $progress.bar start 1

  pack [set btns [::ttk::frame $frame.buttons]] -side top -padx 10 -pady 10
  pack [::ttk::button $btns.cancel -text [T "Cancel"] -command [list destroy $win]]

  set update(win) $win
  set update(main) $progress
  set update(btns) $btns
  set update(labelfont) $labelfont
  set update(waiting) 1

  set url {http://potatomushclient.googlecode.com/svn/trunk/potato.vfs/lib/potato-version.tcl}
  if { [catch {set token [::http::geturl $url -command [list ::potato::checkForUpdatesSub]]} err] } {
       ::potato::checkForUpdatesSub {} $err
       return;
     }

  bind $frame <Destroy> [list ::potato::cancelCheckForUpdates]

  if { !$background } {
       update
       center $win
       wm deiconify $win
     }

  return;

};# ::potato::checkForUpdates

#: proc ::potato::checkForUpdatesSub
#: arg token Token generated by http::geturl
#: arg err an error message, if http::geturl failed
#: desc Callback function called by http::geturl when we've downloaded the latest version number for Potato (or failed to).
#: desc Updates the UI to show the result.
#: return nothing
proc ::potato::checkForUpdatesSub {token {err ""}} {
  variable update;
  variable potato;

  if { ![info exists update(win)] || ![winfo exists $update(win)] || \
       ![info exists update(waiting)] || !$update(waiting) } {
       # The update was cancelled
       catch {::http::cleanup $token}
       return;
     }

  set background [expr {[wm state $update(win)] eq "withdrawn"}]

  # Destroy the progressbar to free up the UI for the result
  destroy {*}[winfo children $update(main)]
  destroy {*}[winfo children $update(btns)]

  set font $update(labelfont)
  pack [::ttk::button $update(btns).ok -text [T "OK"] -command [list destroy $update(win)]] -side left -padx 8

  set errorText [T "Sorry, we were unable to check for a new version at this time. Please try again later.\n\nIf the problem persists, please let us know."]
  if { $token eq "" || [::http::status $token] ne "ok" } {
       # Something went wrong
       if { $background } {
            destroy $update(win)
          } else {
            if { $err ne "" } {
                 append errorText [T "Error: %s" $err]
               }
            pack [::ttk::label $update(main).error -text $errorText -font $font]
            update
            center $update(win)
          }
       catch {::http::cleanup $token;}
       return;
     }

  # Try and parse the result
  set body [::http::data $token]
  ::http::cleanup $token
  if { ![regexp {"(.+)"} $body {} vers] || [catch {package vcompare $vers $potato(version)} difference] } {
       # Damn
       if { $background } {
            destroy $update(win)
          } else {
            pack [::ttk::label $update(main).error -text $errorText -font $font]
            update
            center $update(win)
          }
       return;
     }

  if { $difference == 1 } {
       # New version available!
       pack [::ttk::label $update(main).new -font $font \
              -text [T "There is a newer version of Potato (%s) available.\nYou can download it from Potato's Google Code site.\nWould you like to do so now?" $vers]]
       $update(btns).ok configure -text [T "No"]
       pack [::ttk::button $update(btns).yes -text [T "Yes"] \
               -command "[list ::potato::launchWebPage http://code.google.com/p/potatomushclient/wiki/Downloads?tm=2] ; [list destroy $update(win)]"] -side left -before $update(btns).ok -padx 8
       if { $background } {
            update
            center $update(win)
            wm deiconify $update(win)
            bell -displayof $update(win)
          }
     } else {
       if { $background } {
            destroy $update(win)
          } else {
            pack [::ttk::label $update(main).uptodate -text [T "You are already using the latest version of Potato."] -font $font]
            update
            center $update(win)
          }
     }

  return;

};# ::potato::checkForUpdatesSub

#: proc ::potato::cancelCheckForUpdates
#: desc Destroy the 'Check for Updates' window, if it's still there, and cleanup the vars created
#: desc Called when the window has been, or is about to be, closed.
#: return nothing
proc ::potato::cancelCheckForUpdates {} {
  variable update;

  catch {destroy $update(win)}
  array unset update
  set update(waiting) 0

  return;

};# ::potato::cancelCheckForUpdates

#: ::potato::appKeyPress
#: arg win Window where key was pressed
#: arg x X-coordinate of mouse at keypress
#: arg y Y-coordinate of mouse at keypress
#: desc The "App" key, on Windows, should perform a 'right click' in the window with keyboard focus. We try that, then resort to a right-click where the mouse cursor is
#: return nothing
proc ::potato::appKeyPress {win x y} {

  set withmouse [winfo containing $x $y]
  if { $win eq "" } {
       set sendto $withmouse
     } else {
       set sendto $withmouse
       foreach bt [bindtags $win] {
         if { "<Button-3>" in [bind $bt] } {
              set sendto $win
              break;
            }
       }
     }
  if { $sendto eq $withmouse } {
       event generate $sendto <Button-3> -rootx $x -rooty $y
     } else {
       event generate $sendto <Button-3> -x 4 -y 4
     }

  return;

};# ::potato::appKeyPress

#: ::potato::inputWindowRightClickMenu
#: arg input The input window being clicked
#: arg x xcoord
#: arg y ycoord
#: desc Input window $win has just been right-clicked at $x,$y. Post a menu with copy/paste options
#: return nothing
proc ::potato::inputWindowRightClickMenu {input x y} {

  set m .inputWinRCMenu
  if { [winfo exists $m] } {
       destroy $m
     }
  menu $m -tearoff 0
  if { [llength [$input tag nextrange sel 1.0]] } {
       set state normal
     } else {
       set state disabled
     }
  $m add command {*}[menu_label [T "&Copy"]] -accelerator Ctrl+C -command [list event generate $input <<Copy>>] -state $state
  $m add command {*}[menu_label [T "C&ut"]] -accelerator Ctrl+X -command [list event generate $input <<Cut>>] -state $state

  if { ![catch {::tk::GetSelection $input CLIPBOARD} txt] && [string length $txt] } {
       set state normal
     } else {
       set state disabled
     }
  $m add command {*}[menu_label [T "&Paste"]] -accelerator Ctrl+V -command [list event generate $input <<Paste>>] -state $state

  tk_popup $m $x $y

  return;

};# ::potato::inputWindowRightClickMenu

#: proc ::potato::setUpBindings
#: desc set up bindings used throughout Potato, including those for input and output text widgets, and bindings on "." which aren't done elsewhere
#: return nothing
proc ::potato::setUpBindings {} {
  variable potato;

  catch {tcl_endOfWord}
  set ::tcl_wordchars {[a-zA-Z0-9' ]}
  set ::tcl_nonwordchars {[^a-zA-Z0-9']}

  bind . <FocusIn> [list after idle [list ::potato::focusIn %W]]
  bind . <Unmap> [list ::potato::minimizeToTray %W]

  # bindtags:
  # PotatoOutput displays output from the MUSH, and replaces Text in the bindtags.
  # PotatoInput is used for entering input, and comes before Text in the bindtags.
  # PotatoUserBindings have user-defined bindings on, and are included in the bindtags before both the above

  # Control-<num> shows connection <num>
  for {set i 1} {$i < 10} {incr i} {
     bind PotatoInput <Control-Key-$i> [list ::potato::showConn $i]
  }

  bind PotatoInput <Control-Key-0> [list ::potato::showConn 10]

  bind PotatoInput <Button-3> [list ::potato::inputWindowRightClickMenu %W %X %Y]
  # The <App> key may not be available on all systems
  catch {bind PotatoInput <KeyPress-App> [list ::potato::appKeyPress %W %X %Y]}

  # Stop the user being able to select the last newline in the text widget. When it's selected,
  # it causes "bleed" of the selection tag if new text is inserted.
  bind Text <<Selection>> {%W tag remove sel end-1c end}

  # The help for the Listbox widget says that it will only take focus on click if -takefocus is true.
  # It's lying. Let's make it actually do that.
  bind Listbox <1> {    if {[winfo exists %W]} { tk::ListboxBeginSelect %W [%W index @%x,%y] [string is true [%W cget -takefocus]] }}

  # When "Up" is pressed and we're already at the start, or "Down" is pressed and
  # we're already at the end, scroll the output window in that direction instead.
  bind PotatoInput <Up> { if { [%W compare "insert display linestart" == 1.0] } {
                               [::potato::activeTextWidget] yview scroll -1 units
                             }
                   };# up

  bind PotatoInput <Down> { if { [%W compare "insert display lineend" == end-1char] } {
                                 [::potato::activeTextWidget] yview scroll 1 units
                               }
                   };# down

  # Remove vars used for cmd history scrolling in this window when it's nuked
  bind PotatoInput <Destroy> [list array unset ::potato::inputSwap %W,*]

  # See beginning/end of output window
  bind PotatoInput <Control-Alt-Home> {[::potato::activeTextWidget] see 1.0}
  bind PotatoInput <Control-Shift-Home> {continue}
  bind PotatoInput <Control-Alt-End> {[::potato::activeTextWidget] see end}
  bind PotatoInput <Control-Shift-End> {continue}

  # Make "End" show the end of the output window, if we're already at the end of the input window
  bind PotatoInput <End> {if { [%W compare insert == end-1char] } { if { [::potato::up] == 0 } { [::potato::activeTextWidget] yview moveto 1.0} else {[::potato::activeTextWidget] see end}}}

  # Scroll output window by a page
  bind PotatoInput <Prior> {[::potato::activeTextWidget] yview scroll -1 pages}
  bind PotatoInput <Next> {[::potato::activeTextWidget] yview scroll 1 pages}
  bind PotatoInput <Control-Prior> [bind Text <Prior>]
  bind PotatoInput <Control-Next> [bind Text <Next>]


  bind PotatoInput <Tab> "[bind Text <Control-Tab>] ; break"
  bind PotatoInput <Shift-Tab> "[bind Text <Control-Shift-Tab>] ; break"
  bind PotatoInput <Control-Tab> {::potato::toggleConn 1 ; break}
  bind PotatoInput <Control-Shift-Tab> {::potato::toggleConn -1 ; break}
  foreach x [list "" Shift- Control- Control-Shift-] {
     bind PotatoOutput <${x}Tab> [bind PotatoInput <${x}Tab>]
  }

  foreach x [list PotatoInput PotatoOutput Text] {
    foreach y [list MouseWheel 4 5] {
      bind $x <$y> {}
    }
  }
  catch {bind all <MouseWheel> [list ::potato::mouseWheel %W %D]}
  # Some Linuxes use button 4/5 instead of <MouseWheel>. Some don't.
  catch {bind all <4> [list ::potato::mouseWheel %W 120]}
  catch {bind all <5> [list ::potato::mouseWheel %W -120]}

  # Make Control-BackSpace delete the previous word
  bind Text <Control-BackSpace> {set val [%W index insert]
           while {$val != 1.0 && [%W get $val-1c $val] eq " "} {
                  set val [%W index $val-1c]
                 }
            if {$val != 1.0 } {set val [tk::TextPrevPos %W $val tcl_wordBreakBefore]}
            %W delete $val insert
           }
  # These bindings copied from Tk 8.4, because I prefer them to the 8.5 ones,
  # with regard to how they move around text with symbols and spaces.
  bind Text <Control-Left> {set val [%W index insert]
           while {$val != 1.0 && [%W get $val-1c $val] eq " "} {
                  set val [%W index $val-1c]
                 }
            if {$val != 1.0 } {set val [tk::TextPrevPos %W $val tcl_wordBreakBefore]}
            tk::TextSetCursor %W $val
           }
  bind Text <Control-Right> {set val [tk::TextNextPos %W insert tcl_wordBreakAfter]
           set end [%W index end]
           while {[%W index $val] != $end && [%W get $val $val+1c] eq " "} {
                  set val [%W index $val+1c]
                 }
           tk::TextSetCursor %W $val
          }
  bind Text <Control-Shift-Left> {set val [%W index insert]
           while {$val != 1.0 && [%W get $val-1c $val] eq " "} {
                  set val [%W index $val-1c]
                 }
            if {$val != 1.0 } {set val [tk::TextPrevPos %W $val tcl_wordBreakBefore]}
            tk::TextKeySelect %W $val
           }
  bind Text <Control-Shift-Right> {set val [tk::TextNextPos %W insert tcl_wordBreakAfter]
           set end [%W index end]
           while {[%W index $val] != $end && [%W get $val $val+1c] eq " "} {
                  set val [%W index $val+1c]
                 }
           tk::TextKeySelect %W $val
          }

  # Use "Control+A" for "select all"
  bind Text <Control-a> {%W tag add sel 1.0 end-1c; %W mark set insert end-1c; %W see insert; break}

  # stop Tile buttons taking focus when clicked
  bind TButton <1> {%W instate !disabled { %W state pressed }}

  # Make Tile buttons show they have the focus when tabbed into via keyboard.
  bind TButton <FocusIn> {%W instate !disabled {%W state [list active focus]}}
  bind TButton <FocusOut> {%W instate !disabled {%W state [list !active !focus]}}

  # Copy some bindings from Text to PotatoOutput, so we can remove the 'Text' bindtags from it.
  # (safer to copy those we want than block those we don't, as more we don't want might be added later)
  foreach x [list B2-Motion Button-2 Meta-Key-greater Meta-Key-less Meta-f Meta-b Control-t Control-p \
                  Control-n Control-f Control-e Control-b Control-a Escape Control-Key Alt-Key <Copy> \
                  Control-backslash Control-slash Shift-Select Control-Shift-End Control-End \
                  Control-Shift-Home Control-Home Shift-End Shift-Home Home End Next Prior \
                  Shift-Next Shift-Prior Control-Shift-Up Control-Shift-Left Control-Shift-Right \
                  Control-Down Control-Up Control-Right Control-Left Up Down Left Right \
                  Shift-Up Shift-Down Shift-Left Shift-Right Control-Button-1 ButtonRelease-1 B1-Enter B1-Leave \
                  Triple-Shift-Button-1 Double-Shift-Button-1 Shift-Button-1 Triple-Button-1 Double-Button-1 \
                  B1-Motion Button-1 <Selection>] {
     bind PotatoOutput <$x> [bind Text <$x>]
  }
  bind PotatoOutput <<Copy>> [list ::potato::textCopy %W]
  bind PotatoOutput <<Cut>> [list ::potato::textCopy %W]
  bind PotatoOutput <<Selection>> "+;[list ::potato::selectToCopy %W]"

  bind PotatoOutput <Motion> [list ::potato::showMessageTimestamp %W %x %y]

  # Use Return to send text. Inserting a newline is configurable with the insertNewline task
  bind PotatoInput <Return> "::potato::send_mushage %W 0 ; break"

  # Counteract the annoying case-sensitiveness of bindings
  foreach x [list Text PotatoInput PotatoOutput] {
     foreach y [bind $x] {
        if { [regexp {^<.+-[a-z]>$} $y] } {
                  set char [string index $y end-1]
                  bind $x "[string range $y 0 end-2][string toupper $char]>" [bind $x $y]
           }
     }
  }

  # Right-click while resizing a paned window to cancel
  bind Panedwindow <3> {catch {%W proxy forget} ; unset -nocomplain ::tk::Priv(sash) ::tk::Priv(dx) ::tk::Priv(dy)}
  setUpUserBindings

  return;

};# ::potato::setUpBindings

#: proc ::potato::selectToCopy
#: arg win window
#: desc If Select to Copy is configured for the currently-displayed connection, perform a copy in the given window
#: return nothing
proc ::potato::selectToCopy {win} {
  variable world;
  variable conn;

  set c [up]
  set w $conn($c,world)

  if { !$world($w,selectToCopy) } {
       return;
     }

  textCopy $win

  return;

};# ::potato::selectToCopy

#: proc ::potato::textCopy
#: arg win widget path
#: desc Perform a 'Copy' on the text widget $win, skipping elided characters. Based on Tk's built-in tk_textCopy
#: return nothing
proc ::potato::textCopy {win} {

  if { ![catch {$win get -displaychars -- sel.first sel.last} data]} {
       clipboard clear -displayof $win
       clipboard append -displayof $win $data
     }

  return;

};# ::potato::textCopy

#: proc ::potato::activeTextWidget
#: desc Return the text widget currently displayed in the main window. We need to ask the skin, as they may be displaying a spawn window instead.
#: return Path to a text widget
proc ::potato::activeTextWidget {} {
  variable potato;

  return [::skin::$potato(skin)::activeTextWidget];

};# potato::activeTextWidget

#: proc ::potato::textWidgetName
#: arg text text widget path
#: arg c connection id. Defaults to "".
#: desc Given a text widget path (.foo.text) and a connection id, find the "name" of the text widget (_main or a spawn name).
#: return Text widget name, or "" if it can't be found
proc ::potato::textWidgetName {text {c ""}} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { $conn($c,textWidget) eq $text } {
       return "_main";
     }

  # Check spawn widgets
  if { [set pos [lsearch -exact -index 1 $conn($c,spawns) $text]] != -1 } {
       return [lindex [lindex $conn($c,spawns) $pos] 0];
     }

  # Can't find it - return empty string as error
  return "";

};# ::potato::textWidgetName

#: proc ::potato::keyboardShortcutWin
#: desc Show the window for customizing Keyboard Shortcuts
#: return nothing
proc ::potato::keyboardShortcutWin {} {
  variable tasks;
  variable keyShorts;
  variable keyShortsTmp;

  set win .keyShorts
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }
  toplevel $win
  wm title $win [T "Keyboard Shortcuts"]

  # The "Mac" key symbol is \u2318
  # The Mac "option" key symbol is \u2325

  # A frame we don't pack which we set bindings for
  set bindingsWin [frame $win.bindings]

  unset -nocomplain keyShortsTmp

  foreach x [array names keyShorts] {
    set keyShortsTmp($x) $keyShorts($x)
    if { $keyShorts($x) ne "" } {
      bind $bindingsWin <$keyShortsTmp($x)> $x
    }
  }

  pack [::ttk::label $win.l -text [T "Select a command, then click a button to edit its binding"]] \
          -side top -padx 4 -pady 8

  pack [::ttk::frame $win.tree] -side top -anchor nw -expand 1 -fill both
  set sbX $win.tree.x
  set sbY $win.tree.y
  set tree [::ttk::treeview $win.tree.tree -columns [list Command Shortcut] \
            -selectmode browse -show headings -xscrollcommand [list $sbX set] \
            -yscrollcommand [list $sbY set]]
  ::ttk::scrollbar $sbX -orient horizontal -command [list $tree xview]
  ::ttk::scrollbar $sbY -orient vertical -command [list $tree yview]
  $tree heading 0 -text [T "Command"]
  $tree heading 1 -text [T "Keyboard Shortcut"]

  grid_with_scrollbars $tree $sbX $sbY

  foreach x [array names tasks *,name] {
    set task [lindex [split $x ,] 0]
    lappend allTasks [list [taskLabel $task] $task]
  }
  set allTasks [lsort -dictionary -index 0 $allTasks]
  foreach x $allTasks {
    foreach {label task} $x {break}
    if { [info exists keyShortsTmp($task)] && $keyShortsTmp($task) ne "" } {
         set real $keyShortsTmp($task)
         set disp [keysymToHuman $real]
       } else {
         set real ""
         set disp ""
       }
    $tree insert {} end -id $task -values [list $label $disp $real] -tags [list $task]
  }

  $tree selection set [lindex $allTasks 0 1]

  set keyShortsTmp(main,win) $win
  set keyShortsTmp(main,tree) $tree
  set keyShortsTmp(editWin,win) .keyShortsInput
  set keyShortsTmp(bindings,win) $bindingsWin

  pack [::ttk::frame $win.btns] -side top -pady 8
  pack [::ttk::button $win.btns.clear -text [T "Clear"] -width 8 \
             -command [list ::potato::keyboardShortcutClear]] -side left -padx 4
  pack [::ttk::button $win.btns.change -text [T "Change"] -width 8 \
            -command [list ::potato::keyboardShortcutInput]] -side left -padx 4
  pack [::ttk::button $win.btns.save -text [T "Save"] -width 8 -command [list ::potato::keyboardShortcutWinSave]] -side left -padx 4
  pack [::ttk::button $win.btns.close -text [T "Cancel"] -width 8 -command [list destroy $win]] -side left -padx 4


  bind $win <Destroy> [list destroy $keyShortsTmp(editWin,win)]

  reshowWindow $win 0
  focus $tree;

  return;

};# ::potato::keyboardShortcutWin

#: proc ::potato::keyboardShortcutWinSave
#: desc Save the changes to the Keyboard Shortcuts and then destroy the customization window
#: return nothing
proc ::potato::keyboardShortcutWinSave {} {
  variable keyShorts;
  variable keyShortsTmp;

  destroy $keyShortsTmp(main,win)
  array unset keyShortsTmp *,*

  # Clear off current bindings
  foreach x [bind PotatoUserBindings] {
     bind PotatoUserBindings $x ""
  }
  array unset keyShorts
  array set keyShorts [array get keyShortsTmp]
  setUpUserBindings

  return;

};# ::potato::keyboardShortcutWinSave

#: proc ::potato::keyboardShortcutClear
#: desc Prompt the user for comfirmation, then clear the keyboard shortcut for the task selected in the tree
#: return nothing
proc ::potato::keyboardShortcutClear {} {
  variable tasks;
  variable keyShortsTmp;

  set tree $keyShortsTmp(main,tree)

  set task [$tree selection]
  if { ![info exists keyShortsTmp($task)] || $keyShortsTmp($task) eq "" } {
       bell -displayof $tree
       return;
     }

  set ans [tk_messageBox -parent [winfo toplevel $tree] -icon question -title [T "Keyboard Shortcut"] \
             -type yesno -message [T "Do you really want to clear the Keyboard Shortcut for \"%s\"?" [taskLabel $task]]]
  if { $ans != "yes" } {
       return;
     }

  bind $keyShortsTmp(bindings,win) <$keyShortsTmp($task)> ""
  set keyShortsTmp($task) ""
  $tree item $task -values [list [taskLabel $task] "" ""]

  return;

};# ::potato::keyboardShortcutClear

#: proc ::potato::keyboardShortcutInput
#: desc Show a window allowing the user to edit the keyboard binding for the task currently selected in the tree
#: return nothing
proc ::potato::keyboardShortcutInput {} {
  variable keyShortsTmp;

  # We don't reshow, as it's probably presented for a different task,
  # and we don't want them to not realise it's still shown for that task, not the most-recently-selected
  set win $keyShortsTmp(editWin,win)
  if { [winfo exists $win] } {
        destroy $win
     }

  toplevel $win
  wm transient $win $keyShortsTmp(main,win)
  set tree $keyShortsTmp(main,tree)
  set task [$tree selection]
  set taskInfo [$tree item $task -values]
  set taskLabel [lindex $taskInfo 0]
  set taskBinding(display) [lindex $taskInfo 1]
  set taskBinding(real) [lindex $taskInfo 2]
  set keyShortsTmp(editWin,binding) $taskBinding(real)

  wm title $win [T "Keyboard Shortcut for \"%s\"" $taskLabel]
  set keyShorts(editWin,binding) $taskBinding(real)
  if { $taskBinding(display) eq "" } {
       set taskBinding(display) "<[T "None"]>"
     }

  set text [T "Press the desired keyboard shortcut for '%s'.\nWhen the correct shortcut is displayed below, click Accept,\nor click Cancel to keep the current shortcut." $taskLabel]
  pack [::ttk::label $win.l -text $text] -side top -padx 4 -pady 6

  pack [set disp [::ttk::label $win.disp -text "$taskBinding(display)"]] -side top -padx 4 -pady 10
  set keyShortsTmp(editWin,display) $disp
  set keyShortsTmp(editWin,task) $task

  pack [set err [::ttk::label $win.error -style "error.TLabel"]] -side top -padx 4 -pady 7
  set keyShortsTmp(editWin,err) $err

  pack [::ttk::frame $win.btns] -side top -pady 4
  set cmd {if { [::potato::keyboardShortcutSave] } {destroy %s}}
  pack [::ttk::button $win.btns.accept -text [T "Accept"] -width 8 \
                 -command [format $cmd $win]] \
                 -side left -padx 7
  pack [::ttk::button $win.btns.cancel -text [T "Cancel"] -width 8 -command [list destroy $win]] -side left -padx 7

  #abc No bindings for the Mac "Command" key yet.
  #abc No bindings for the Mac "Option" key yet.
  foreach x {Control Alt Shift Control-Alt Control-Alt-Shift Alt-Shift Control-Shift} {
    bind $win <$x-KeyPress> "[list ::potato::keyboardShortcutInputProcess "$x-%K" %A] ; break"
  }
  bind $win <KeyPress-Shift_L> {break}
  bind $win <KeyPress-Shift_R> {break}

  bind $win <KeyPress-Control_L> {break}
  bind $win <KeyPress-Control_R> {break}

  bind $win <KeyPress-Alt_L> {break}
  bind $win <KeyPress-Alt_R> {break}


  bind $win <KeyPress> [list ::potato::keyboardShortcutInputProcess %K %A]


  reshowWindow $win 0
  return;

};# ::potato::keyboardShortcutInput

#: proc ::potato::keyboardShortcutSave
#: arg task The task to save the keysym for
#: arg disp The label widget displaying the Keysysm's name
#: arg bingingsWin The widget to check the bindings against
#: arg tree The tree widget containing the list of tasks/bindings
#: desc Parse the keysym name from $disp's -text. If it's <None>, abort. If the keysym is already inuse by another task, prompt. Else, save it.
#: return 0 if aborting, 1 if saving
proc ::potato::keyboardShortcutSave {} {
  variable keyShortsTmp;

  set disp $keyShortsTmp(editWin,display)
  set task $keyShortsTmp(editWin,task)
  set tree $keyShortsTmp(main,tree)
  set bindingsWin $keyShortsTmp(bindings,win)

  set keysym $keyShortsTmp(editWin,binding)
  set userBind [keysymToHuman $keysym]
  if { $keysym eq "" } {
       # Blank - no change
       return 1;
     }

  if { [string first "?" $keysym] >= 0 } {
       tk_messageBox -parent [winfo toplevel $disp] -type ok -icon error -title [T "Keyboard Shortcut"] \
                     -message [T "You cannot bind to that key. Sorry."]
       return 0;
     }

  set current [bind $bindingsWin "<$keysym>"]
  if { $current ne "" && $current ne $task } {
       set message [T "The Keyboard Shortcut '%s' is already in use by the task '%s'. Do you want to override it?" $userBind [taskLabel $current]]
       set ans [tk_messageBox -parent [winfo toplevel $disp] \
                   -title [T "Keyboard Shortcut"] -type yesno -icon question -message $message]
        if { $ans ne "yes" } {
             return 0;
           }
        set keyShortsTmp($current) ""
        $tree item $current -values [list [taskLabel $current] "" ""]
     }

  if { [info exists keyShortsTmp($task)] && $keyShortsTmp($task) ne "" } {
        bind $bindingsWin <$keyShortsTmp($task)> ""
     }
  bind $bindingsWin "<$keysym>" $task
  set keyShortsTmp($task) $keysym
  $tree item $task -values [list [taskLabel $task] $userBind $keysym]

  return 1;

};# ::potato::keyboardShortcutSave

#: proc ::potato::keyboardShortcutInputProcess
#: arg keyname The keysym for the key that was pressed (%K)
#: arg keydisp The display value for the keypress (%A)
#: desc Process the keypress. This involves checking which modifiers are pressed, validating the keysym, and displaying it if valid.
#: return nothing
proc ::potato::keyboardShortcutInputProcess {keyname keydisp} {
  variable keyShortsTmp;

  set warn_any [list Up Down Left Right Home End Prior Next Delete BackSpace Return Tab]

  set win $keyShortsTmp(editWin,win)
  set disp $keyShortsTmp(editWin,display)
  set realBinding ""

  set fullkeys [split $keyname -]
  set keyind [lindex $fullkeys end]
  set modifiers [lrange $fullkeys 0 end-1]
    set modified [expr {([llength $modifiers] && "Shift" ni $modifiers) || [llength $modifiers] > 1}]

  if { [string length $keyind] == 1 } {
       set keyind [string toupper $keyind]
     }

  set realBinding [join [concat $modifiers $keyind] -]

  set str [keysymToHuman $realBinding]

  $disp configure -text $str
  set keyShortsTmp(editWin,binding) $realBinding

  set err $keyShortsTmp(editWin,err)
  if { [string first "?" $realBinding] >= 0 } {
       $err configure -text [T "Sorry, that key is not allowed."]
     } elseif { (!$modified && [string is print -strict $keydisp]) || $keyname in $warn_any } {
       $err configure -text [T "Warning! Using that key is not recommended!"]
     } else {
       set current [bind $keyShortsTmp(bindings,win) "<$realBinding>"]
       if { $current ne "" && $current ne $keyShortsTmp(editWin,task) } {
            $err configure -text [T "Note: Shortcut in use by '%s'." [taskLabel $current]]
          } else {
            $err configure -text ""
          }
     }

  return;

};# ::potato::keyboardShortcutInputProcess

#: proc ::potato::keysymToHuman
#: arg keysym The keysym to translate
#: arg short Use short names (Ctrl) instead of long names (Control)? Defaults to 0
#: arg joinchar Character to join keysym with. Defaults to +.
#: desc Translate a keysym (valid for [bind]) into a human-readable key name.
#: return The human-readable key name
proc ::potato::keysymToHuman {keysym {short 0} {joinchar +}} {

  foreach x [split $keysym -] {
       if { $x in [list "Key" "KeyPress" "KeyRelease"] } {
            continue;
          } elseif { $short && $x eq "Control" } {
            lappend list "Ctrl"
          } else {
            lappend list $x
          }
     }
  set last [lindex $list end]
  array set map [list Prior "Page Up" Next "Page Down" slash "Forward Slash"]
  if { [info exists map($last)] } {
       set list [lreplace $list end end $map($last)]
     } else {
       set list [lreplace $list end end [string totitle $last]]
     }

  set human [join $list $joinchar]

  return $human;

};# ::potato::keysymToHuman

#: proc ::potato::setUpUserBindings
#: desc Set up the user-defined key bindings. If there are none, load the defaults first, then set them up.
#: return nothing
proc ::potato::setUpUserBindings {} {
  variable keyShorts;

  # Clear off invalid keysyms before loading defaults
  foreach task [array names keyShorts] {
     if { [string match "*,*" $task] } {
          continue;
        }
     if { ![taskExists $task] } {
          unset keyShorts($task)
          continue;
        }
  }

  loadDefaultUserBindings

  foreach task [array names keyShorts] {
     if { [string match "*,*" $task] } {
          continue;
        }
     if { $keyShorts($task) eq "" } {
          continue;# no binding
        }
     bind PotatoUserBindings <$keyShorts($task)> "[list ::potato::taskRun $task] ; break"
     set list [split $keyShorts($task) -]
     set last [lindex $list end]
     if { [string length $last] == 1 && [set reverse [lsearch -inline -not [list [string toupper $last] [string tolower $last]] $last]] ne "" } {
          bind PotatoUserBindings \
                  <[join [lreplace $list end end $reverse] -]> \
                  "[list ::potato::taskRun $task] ; break"
        }
  }

  return;

};# ::potato::setUpUserBindings

#: proc ::potato::loadDefaultUserBindings
#: arg clear Clear existing bindings?
#: desc Load the default user-configurable bindings, when none are set or when the user requests the defaults.
#: return nothing
proc ::potato::loadDefaultUserBindings {{clear 0}} {
  variable keyShorts;

  if { $clear } {
       # Clear off current ones, if any
       array unset keyShorts;
       foreach x [bind PotatoUserBindings] {
          bind PotatoUserBindings $x ""
       }
     }

  set defaults [list \
    "close" "Control-KeyPress-F4" \
    "config" "Control-KeyPress-W" \
    "disconnect" "Control-Alt-KeyPress-D" \
    "events" "Control-KeyPress-E" \
    "exit" "Alt-KeyPress-F4" \
    "find" "Control-KeyPress-F" \
    "inputHistory" "Control-KeyPress-H" \
    "log" "Control-KeyPress-L" \
    "nextConn" "Control-KeyPress-N" \
    "prevConn" "Control-KeyPress-P" \
    "reconnect" "Control-KeyPress-R" \
    "twoInputWins" "Control-KeyPress-I" \
    "upload" "Control-KeyPress-U" \
    "mailWindow" "Control-KeyPress-M" \
    "prevHistCmd" "Control-KeyPress-Up" \
    "nextHistCmd" "Control-KeyPress-Down" \
    "spellcheck" "Control-KeyPress-S" \
    "help" "F1" \
    "fcmd2" "F2" \
    "fcmd3" "F3" \
    "fcmd4" "F4" \
    "fcmd5" "F5" \
    "fcmd6" "F6" \
    "fcmd7" "F7" \
    "fcmd8" "F8" \
    "fcmd9" "F9" \
    "fcmd10" "F10" \
    "fcmd11" "F11" \
    "fcmd12" "F12" \
    "save2history" "Shift-Escape" \
    "toggleInputFocus" "Control-KeyPress-O" \
    "insertNewline" "Control-Return" \
    "resendLastCmd" "Control-Alt-R" \
    ]
  foreach {task binding} $defaults {
    if { ![taskExists $task] } {
         continue;
       }
    if { [info exists keyShorts($task)] } {
         continue; # already have a binding for this
       }
     if { [bind PotatoUserBindings <$binding>] ne "" } {
          continue;# already bound to this combo
        }
     # Good to go
     set keyShorts($task) $binding
   }

  return;

};# ::potato::loadDefaultUserBindings

#: proc ::potato::insertNewline
#: desc Insert a newline in the input window with the focus
#: return nothing
proc ::potato::insertNewline {} {

  set win [focus -displayof .]
  if { $win eq "" || [winfo class $win] ne "Text" || "PotatoInput" ni [bindtags $win] } {
       return;
     }

  eval [string map [list "%W" $win] [bind Text <Return>]]

  return;

};# ::potato::insertNewline

#: proc ::potato::autoConnectWindow
#: desc Show a window allowing the user to configure auto-connects
#: return nothing
proc ::potato::autoConnectWindow {} {
  variable world;
  variable autoConnectWindow;

  set win .autoConnects
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  wm withdraw $win
  wm title $win [T "Potato Auto-Connects"]

  pack [set frame [::ttk::frame $win.frame]] -side left -anchor nw -expand 1 -fill both

  pack [set top [::ttk::frame $frame.top]] -side top -anchor nw -expand 1 -fill both -padx 5 -pady 5
  pack [set btm [::ttk::frame $frame.btm]] -side top -anchor n -expand 0 -fill none -padx 5 -pady 5

  pack [set left [::ttk::frame $top.left]] -side left -anchor nw -expand 1 -fill both
  pack [set mid [::ttk::frame $top.mid]] -side left -anchor center -expand 0 -fill none -padx 6
  pack [set right [::ttk::frame $top.right]] -side left -anchor nw -expand 1 -fill both

  set nTree [::ttk::treeview $left.tree -show {} -columns Worlds -selectmode extended]
  set sbX [::ttk::scrollbar $left.sbX -orient horizontal -command [list $nTree xview]]
  set sbY [::ttk::scrollbar $left.sbY -orient vertical -command [list $nTree yview]]
  $nTree configure -xscrollcommand [list $sbX set] -yscrollcommand [list $sbY set]
  grid_with_scrollbars $nTree $sbX $sbY
  bind $nTree <<TreeviewSelect>> [list ::potato::autoConnectWindowSel nTree]

  pack [set btnAdd [::ttk::button $mid.add -text ">" \
         -command [list ::potato::autoConnectWindowAdd]]] -side top -anchor center -pady 4
  pack [set btnRemove [::ttk::button $mid.remove -text "<" \
         -command [list ::potato::autoConnectWindowRemove]]] -side top -anchor center -pady 4
  pack [set btnUp [::ttk::button $mid.up -text [T "Up"] \
         -command [list ::potato::autoConnectWindowReorder -1]]] -side top -anchor center -pady 4
  pack [set btnDown [::ttk::button $mid.down -text [T "Down"] \
         -command [list ::potato::autoConnectWindowReorder 1]]] -side top -anchor center -pady 4

  set yTree [::ttk::treeview $right.tree -show {} -columns Worlds -selectmode extended]
  set sbX [::ttk::scrollbar $right.sbX -orient horizontal -command [list $yTree xview]]
  set sbY [::ttk::scrollbar $right.sbY -orient vertical -command [list $yTree yview]]
  $yTree configure -xscrollcommand [list $sbX set] -yscrollcommand [list $sbY set]
  grid_with_scrollbars $yTree $sbX $sbY
  bind $yTree <<TreeviewSelect>> [list ::potato::autoConnectWindowSel yTree]

  pack [::ttk::button $btm.save -command ::potato::autoConnectWindowSave -text [T "Save"]] \
          -side left -anchor n -padx 6
  pack [::ttk::button $btm.cancel -command [list destroy $win] -text [T "Cancel"]] \
          -side left -anchor n -padx 6

  set autoConnectWindow(toplevel) $win
  foreach x [list yTree nTree btnAdd btnRemove btnUp btnDown] {
     set autoConnectWindow($x) [set $x]
  }

  set with [list]
  set without [list]
  foreach w [worldIDs] {
    if { $world($w,autoconnect) > -1 } {
         lappend with [list $w $world($w,name) $world($w,autoconnect)]
       } else {
         lappend without [list $w $world($w,name)]
       }
  }

  set first 1
  foreach x [lsort -dictionary -index 1 $without] {
     $nTree insert {} end -id [lindex $x 0] -values [list [lindex $x 1]]
     if { $first } {
          $nTree selection set [lindex $x 0]
          set first 0
        }
  }

  set first 1
  foreach x [lsort -integer -index 2 $with] {
     $yTree insert {} end -id [lindex $x 0] -values [list [lindex $x 1]]
     if { $first } {
          $yTree selection set [lindex $x 0]
          set first 0
        }
  }

  autoConnectWindowSel nTree
  autoConnectWindowSel yTree

  bind $win <Destroy> [list unset -nocomplain ::potato::autoConnectWindow]

  update idletasks
  center $win
  wm deiconify $win
  reshowWindow $win 0

  return;

};# ::potato::autoConnectWindow

#: proc ::potato::autoConnectWindowReorder
#: arg dir Direction to move the current selection, -1 for up or 1 for down
#: desc Move an Autoconnect up or down (based on $dir) in the Auto Connect Window
#: return nothing
proc ::potato::autoConnectWindowReorder {dir} {
  variable autoConnectWindow;

  set yTree $autoConnectWindow(yTree)
  set sel [$yTree sel]
  if { [llength $sel] == 0 } {
       bell -displayof $yTree
       return;
     }
  set sel [lindex $sel 0]
  set pos [$yTree index $sel]
  $yTree move $sel {} [expr {$pos + $dir}]
  if { $pos == [$yTree index $sel] } {
       bell -displayof $yTree;# didn't move
     } else {
       $yTree see $sel
     }

  autoConnectWindowSel yTree

  return;

};# ::potato::autoConnectWindowReorder

#: proc ::potato::autoConnectWindowSel
#: arg tree One of "nTree" or "yTree"
#: desc Update the states of all the buttons appropriately when a selection change is made in one of the trees.
#: return nothing
proc ::potato::autoConnectWindowSel {tree} {
  variable autoConnectWindow;

  if { $tree eq "nTree" } {
       if { [llength [$autoConnectWindow(nTree) selection]] == 0 } {
            $autoConnectWindow(btnAdd) state disabled
          } else {
            $autoConnectWindow(btnAdd) state !disabled
          }
     } elseif { $tree eq "yTree" } {
       set sel [$autoConnectWindow(yTree) selection]
       if { [llength $sel] == 0 } {
            $autoConnectWindow(btnRemove) state disabled
            $autoConnectWindow(btnUp) state disabled
            $autoConnectWindow(btnDown) state disabled
          } else {
            set sel [lindex $sel 0]
            $autoConnectWindow(btnRemove) state !disabled
            if { [$autoConnectWindow(yTree) index $sel] == 0 } {
                 $autoConnectWindow(btnUp) state disabled
               } else {
                 $autoConnectWindow(btnUp) state !disabled
               }
            set children [llength [$autoConnectWindow(yTree) children {}]]
            incr children -1
            if { [$autoConnectWindow(yTree) index $sel] == $children } {
                 $autoConnectWindow(btnDown) state disabled
               } else {
                 $autoConnectWindow(btnDown) state !disabled
               }
          }
     }

  $autoConnectWindow($tree) see [lindex [$autoConnectWindow($tree) selection] 0]

  return;

};# ::potato::autoConnectWindowSel

#: proc ::potato::autoConnectWindowSave
#: desc Update the order of all worlds in the Auto Connect, and destroy the auto connect window
#: return nothing
proc ::potato::autoConnectWindowSave {} {
  variable world;
  variable autoConnectWindow;

  foreach w [$autoConnectWindow(nTree) children {}] {
     set world($w,autoconnect) -1
  }
  set i 0
  foreach w [$autoConnectWindow(yTree) children {}] {
     set world($w,autoconnect) $i
     incr i
  }

  destroy $autoConnectWindow(toplevel);

  return;

};# ::potato::autoConnectWindowSave

#: proc ::potato::autoConnectWindowAdd
#: desc Add the currently selected world to the Autoconnect list, changing the states of the add/remove buttons if necessary.
#: return nothing
proc ::potato::autoConnectWindowAdd {} {
  variable autoConnectWindow;
  variable world;

  set nTree $autoConnectWindow(nTree)
  set yTree $autoConnectWindow(yTree)

  set sel [$nTree selection]
  if { [llength $sel] == 0 } {
       return;
     }

  foreach w $sel {
     if { [$nTree next $w] eq "" } {
          $nTree selection set [$nTree prev $w]
        } else {
          $nTree selection set [$nTree next $w]
        }
     $nTree delete $w
     $yTree insert {} end -id $w -values [list $world($w,name)]
     $yTree selection set $w
     $yTree see $w
  }

  autoConnectWindowSel yTree
  autoConnectWindowSel nTree

  return;

};# ::potato::autoConnectWindowAdd

#: proc ::potato::autoConnectWindowRemove
#: desc Remove the currently selected world from the Autoconnect list, changing the states of the add/remove buttons if necessary.
#: return nothing
proc ::potato::autoConnectWindowRemove {} {
  variable autoConnectWindow;
  variable world;

  set nTree $autoConnectWindow(nTree)
  set yTree $autoConnectWindow(yTree)

  set sel [$yTree selection]
  if { [llength $sel] == 0 } {
       return;
     }

  foreach w $sel {
     if { [$yTree next $w] eq "" } {
          $yTree selection set [$yTree prev $w]
        } else {
          $yTree selection set [$yTree next $w]
        }
     $yTree delete $w
     # Figure out where to insert, alphabetically.
     set items [$nTree children {}]
     if { [llength $items] == 0 } {
          set index end
        } else {
          set temp [list [list $w $world($w,name)]]
          foreach x $items {
            lappend temp [list $x $world($x,name)]
          }
          set temp [lsort -dictionary -index 1 $temp]
          set index [lsearch -index 0 $temp $w]
        }
     $nTree insert {} $index -id $w -values [list $world($w,name)]
     $nTree selection set $w
     $nTree see $w
  }

  autoConnectWindowSel yTree
  autoConnectWindowSel nTree

  return;

};# ::potato::autoConnectWindowRemove

#: proc ::potato::autoConnect
#: desc Connect to any worlds we should auto-connect to.
#: return nothing
proc ::potato::autoConnect {} {
  variable world;
  variable misc;

  if { !$misc(autoConnect) } {
       return;# auto connects disabled
     }

  set autoconnects [list]
  foreach w [worldIDs] {
     if { $world($w,autoconnect) == -1 } {
          continue;
        }
     lappend autoconnects [list $w $world($w,autoconnect)]
  }

  foreach x [lsort -integer -index 1 $autoconnects] {
     after 250 [list ::potato::newConnectionDefault [lindex $x 0]]
  }

};# ::potato::autoConnect

#: proc ::potato::mouseWheel
#: arg widget the widget with focus when the mousewheel was scrolled (%W)
#: arg delta the amount the mousewheel was scrolled (%D)
#: desc scroll the window the mouse is over, if possible, otherwise try to scroll $widget
#: return nothing
proc ::potato::mouseWheel {widget delta} {

  if { ![string is double -strict $delta] || ![winfo exists $widget] } {
       return; # For some reason, $delta isn't always set right on MacOS, so be extra safe.
     }

  set over [winfo containing -displayof $widget {*}[winfo pointerxy $widget]]
  if { $over eq "" || ![mouseWheelScroll $over $delta] } {
       mouseWheelScroll $widget $delta
     }

  return;

};# ::potato::mouseWheel

proc ::potato::mouseWheelScroll {widget delta} {

  if { $widget eq "" || ![winfo exists $widget] } {
       return 0;
     }

  set cmd [list yview scroll]

  switch [winfo class $widget] {
    Canvas {lappend cmd [expr {($delta / abs($delta)) * -1}] units}
    Treeview {lappend cmd [expr {-($delta/120)}] units}
  }

  if { [llength $cmd] == 2 } {
       if { [up] == 0 } {
            lappend cmd [expr {($delta / abs($delta)) * -1}] units
          } elseif { $::tcl_platform(os) eq "Darwin" || [tk windowingsystem] eq "aqua"} {
            # Better MacOS values
            set cmd [list yview scroll [expr {-15 * ($delta)}] pixels]
          } else {
            if { $delta >= 0 } {
                 set cmd [list yview scroll [expr {-$delta/3}] pixels]
               } else {
                 set cmd [list yview scroll [expr {(2-$delta)/3}] pixels]
               }
          }
       }

  if { [catch {$widget {*}$cmd} ] } {
       return 0;
     } else {
       return 1;
     }

  return;
};# ::potato::mouseWheelScroll

#: proc ::potato::send_mushage
#: arg window the text widget to send from
#: arg saveonly if true, don't actually send the text, just add to the input history buffer
#: desc send the text currently in $window to the connection currently up, parsing for /commands
#: return nothing
proc ::potato::send_mushage {window saveonly} {
  variable inputSwap;
  variable conn;
  variable world;

  set c [up]

  if { $window eq "" } {
       set window [connInfo $c input3]
     }


  if { [$window count -chars 1.0 end-1c] == 0 && $conn($c,connected) == 0 } {
       reconnect [up]
       return;
     }

  set w $conn($c,world)

  # Figure out the auto-prefix, if any
  set windowName [textWidgetName [activeTextWidget] $c]
  if { $windowName eq "" } {
       set windows [list _all]
     } else {
       set windows [list $windowName _all]
     }
  if { $w == -1 } {
       set worlds [list -1]
     } else {
       set worlds [list $w -1]
     }
  foreach w $worlds {
    if { [info exists prefix] } {
         break;
       }
    foreach x $windows {
      set pos [lsearch -exact -index 0 $world($w,prefixes) $x]
      if { $pos != -1 } {
           set entry [lindex $world($w,prefixes) $pos]
           if { [lindex $entry 2] == 1 } {
                set prefix [lindex $entry 1]
                break;
              }
         }
    }
  }
  if { ![info exists prefix] } {
       set prefix ""
     }

  set txt [$window get 1.0 end-1char]
  $window edit separator
  $window replace 1.0 end ""

  set inputSwap($window,count) -1
  set inputSwap($window,backup) ""

  addToInputHistory $c $txt

  if { $saveonly } {
       return;
     }

  send_to $c $txt $prefix

  return;

};# ::potato::send_mushage

#: proc ::potato::process_input
#: arg c connection id
#: arg txt Text to process
#: desc Parse a block of text for /commands, and return the result as a list of values to send to the MUSH
#: return List of text lines to send to the MUSH
proc ::potato::process_input {c txt} {

  set txt [string map [list "\r\n" "\n" "\r" "\n"] $txt]

  set res [list]
  set counter 0
  while { [string length $txt] && $counter < 100 } {
    incr counter
    lappend res [process_slash_cmd $c txt 0]
  }

  return $res;

};# ::potato::process_input

#: proc ::potato::send_to
#: arg c connection id
#: arg txt Text to send to MUSH
#: arg prefix A prefix to prepend to each line sent to the MUSH
#: arg echo See comment on ::potato::send_to_real
#: desc Parse a block of text for /commands, possibly append a prefix to each resulting line, and send to the MUSH
#: return nothing
proc ::potato::send_to {c txt {prefix ""} {echo 1}} {

  foreach x [process_input $c $txt] {
    if { $x ne "" } {
         send_to_real $c "$prefix$x" $echo
       }
  }
  return;
};# ::potato::send_to

#: proc ::potato::send_to_noparse
#: arg c connection id
#: arg txt Text to send to MUSH
#: arg prefix A prefix to prepend to each line sent to the MUSH
#: arg echo See comment on ::potato::send_to_real
#: desc Send text to the MUSH, without parsing for /commands, possibly prepending a prefix to each line
#: return nothing
proc ::potato::send_to_noparse {c txt {prefix ""} {echo 1}} {

  set txt [string map [list "\r\n" "\n" "\r" "\n"] $txt]

  foreach x [split $txt "\n"] {
    send_to_real $c "$prefix$x" $echo
  }

  return;
};# ::potato::send_to_noparse

#: proc ::potato::send_to_from
#: arg c connection id
#: arg textWidget Path to a text widget
#: arg parse Should we parse for /commands?
#: arg selonly Only use the selection in the text widget?
#: desc Wrapper function. Get all the text (or possibly just selected text) from a text widget and send to the MUSH, possibly parsing for /commands
#: return nothing
proc ::potato::send_to_from {c textWidget {parse 0} {selonly 0}} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { ![info exists conn($c,id)] || ![winfo exists $textWidget] || [winfo class $textWidget] ne "Text" } {
       return;
     }

   if { $selonly } {
        if { [llength [set sel [$textWidget tag ranges sel]]] == 0 } {
             # No selection
             return;
           }
        set text [$textWidget get sel.first sel.last]
      } else {
        set text [$textWidget get 1.0 end-1c]
      }

   if { $text eq "" } {
        return;
      }

   if { $parse } {
        send_to $c $text
      } else {
        send_to_noparse $c $text
      }

  return;

};# ::potato::send_to_from

#: proc ::potato::send_to_real
#: arg c connection id
#: arg string string to send
#: arg echo If 1, echo the string (if the echo option is on). if 0, don't ever echo. For anything else, echo that value instead of $string.
#: desc send the string $string to connection $c, after protocol escaping. Do not parse for /commands.
#: return nothing
proc ::potato::send_to_real {c string {echo 1}} {
  variable conn;
  variable world;

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 || ![info exists conn($c,connected)] || $conn($c,connected) != 1 } {
       return;
     }

  if { [hasProtocol $c telnet] } {
       set string [::potato::telnet::escape $string]
     }

  sendRaw $c $string 0
  if { $world($conn($c,world),echo) } {
       if { $echo eq "1" } {
            outputSystem $c $string [list "echo"]
          } elseif { $echo ne "0" } {
            outputSystem $c $echo [list "echo"]
          }
     }

  return;

};# ::potato::send_to_real

#: proc ::potato::addToInputHistory
#: arg c connection id
#: arg cmd command to add
#: desc add the given command to the input history for connection $c.
#: return nothing
proc ::potato::addToInputHistory {c cmd} {
  variable conn;
  variable world;

  if { $c == 0 || ![info exists conn($c,inputHistory)] } {
       return;
     }

  lappend conn($c,inputHistory) [list [incr conn($c,inputHistory,count)] [string map [list \n \b] $cmd]]

  set limit $world($conn($c,world),inputLimit,to)

  if { $world($conn($c,world),inputLimit,on) && $limit > 0 } {
       incr limit -1
       set old $conn($c,inputHistory)
       set conn($c,inputHistory) [lrange $conn($c,inputHistory) end-$limit end]
     }

  return;

};# ::potato::addToInputHistory

#: proc ::potato::findDialog
#: arg c connection id. Defaults to ""
#: desc Show the "find" dialog for connection $c (or the current connection if $c is "")
#: return nothing
proc ::potato::findDialog {{c ""}} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 } {
       bell -displayof .
       return;
     }

  set win .find_in_$c
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  registerWindow $c $win
  wm withdraw $win
  wm title $win [T "Find..."]
  wm resizable $win 0 0
  wm transient $win .

  pack [set frame [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw

  pack [::ttk::frame $frame.l] -side left  -expand 1 -fill both -pady 5 -padx 0
  pack [::ttk::frame $frame.r] -side right -expand 0 -fill both -pady 5 -padx 3

  pack [::ttk::frame $frame.l.top] -side top -padx 3 -fill both
  ::ttk::label $frame.l.top.l -text [T "Find:"] -width 6 -anchor w -justify left
  set vcmd {if { [string length %P] } {BTN configure -state normal} else {BTN configure -state disabled} ; return 1}
  set vcmd [string map [list BTN $frame.r.find] $vcmd]
  ::ttk::entry $frame.l.top.e -textvariable ::potato::conn($c,find,str) -width 30 \
          -exportselection 0 -validate key -validatecommand $vcmd
  pack $frame.l.top.l -padx 3 -side left
  pack $frame.l.top.e -padx 3 -side left -expand 1 -fill x

  pack [::ttk::frame $frame.l.mid] -side top -padx 3 -fill x
  pack [::ttk::frame $frame.l.mid.left] -fill both -side left

  ::ttk::labelframe $frame.l.mid.opt -labelanchor nw -text [T "Options"]
  ::ttk::checkbutton $frame.l.mid.opt.case -text [T "Case Sensitive?"] \
                  -variable ::potato::conn($c,find,case)
  ::ttk::checkbutton $frame.l.mid.opt.regexp -text [T "Regexp Match?"] \
                  -variable ::potato::conn($c,find,regexp)
  pack $frame.l.mid.opt.case $frame.l.mid.opt.regexp \
                  -side top -anchor nw
  pack $frame.l.mid.opt -side left -ipadx 4 -padx 4 -pady 2
  set conn($c,find,case) 0
  set conn($c,find,regexp) 0

  ::ttk::labelframe $frame.l.mid.dir -labelanchor nw -text [T "Direction"]
  ::ttk::radiobutton $frame.l.mid.dir.for -text [T "Forwards"] \
                  -variable ::potato::conn($c,find,dir) -value 1
  ::ttk::radiobutton $frame.l.mid.dir.back -text [T "Backwards"] \
                  -variable ::potato::conn($c,find,dir) -value 0
  pack $frame.l.mid.dir.for $frame.l.mid.dir.back \
                  -side top -anchor nw
  pack $frame.l.mid.dir -side right -ipadx 4 -pady 2
  set conn($c,find,dir) 1

  set command "::potato::findIn $c \$::potato::conn($c,find,str) \
                    \$::potato::conn($c,find,dir) \
                    \$::potato::conn($c,find,regexp) \
                    \$::potato::conn($c,find,case)"

  ::ttk::button $frame.r.find -text [T "Find Next"] -underline 0 \
                   -default active -width 11 -state disabled \
                   -command $command
  ::ttk::button $frame.r.cancel -text [T "Cancel"] -underline 0  -width 11\
                     -command [list destroy $win]
  pack $frame.r.find $frame.r.cancel -side top -pady 5 -padx 3

  bind $win <Escape> [list $frame.r.cancel invoke]
  bind $win <Alt-c> [list $frame.r.cancel invoke]
  bind $win <Alt-f> [list $frame.r.find invoke]
  bind $win <Return> [list $frame.r.find invoke]


  update
  ::potato::center $win
  reshowWindow $win 0
  focus $frame.l.top.e

  bind $win <Destroy> [list ::potato::unregisterWindow $c $win]

  return;

};# ::potato::find

#: proc ::potato::findIn
#: arg c connection id
#: arg str String/pattern to search for.
#: arg dir Direction to search. 1 for forwards, 0 for backwards
#: arg regexp Is this a regexp search, or a literal one?
#: arg case Is the search case-sensitive?
#: desc Search the output window for connection $c (or the current connection, if $c is ""), looking for $text.
#: return nothing
proc ::potato::findIn {c str dir regexp case} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 } {
       bell -displayof .
       return;
     }

  if { $str eq "" } {
       bell -displayof .
       return;
     }

  set t $conn($c,textWidget)
  set switches [list]
  if { $dir } {
       lappend switches -forwards
       set start "insert+1c"
     } else {
       lappend switches -backwards
       set start "insert-1c"
     }
  if { $regexp } {
       lappend switches -regexp
     }
  if { !$case } {
       lappend switches -nocase
     }

  set index [$t search {*}$switches -count count -- $str $start]
  if { $index eq "" } {
       bell -displayof .
       return;
     } else {
       $t tag remove sel 1.0 end
       $t tag add sel $index "$index + $count chars"
       $t see $index
       if { $dir } {
            $t mark set insert "$index + $count chars"
          } else {
            $t mark set insert $index
          }
     }

  return;

};# ::potato::findIn

#: proc ::potato::showInput
#: arg c connection id
#: arg num Number of input window to insert to (1 or 2, or 3 for focus widget)
#: arg text Text to insert
#: arg append If true, append to current text instead of replacing
#: desc Replace the current contents of the input window $num for connection $c with $text (or append, if $append)
#: return nothing
proc ::potato::showInput {c num text append} {
  variable conn;

  set t [connInfo $c input$num]

  if { !$append } {
       $t replace 1.0 end $text
     } else {
       if { [$t count -chars 1.0 end-1char] } {
            set text "\n$text"
          }
       $t insert end $text
     }

  return;

};# ::potato::showInput

#: proc ::potato::setUserVar
#: arg c connection id var is set from
#: arg global Is the var we're setting global?
#: arg str a string which should contain the varname, an =, and the value
#: desc Attempt to parse $str into a varname and a value, and set a (possibly global) user var. Output an error to conn $c on failure, nothing on success
#: return 1 on success, 0 on failure
proc ::potato::setUserVar {c global str} {
  variable conn;

  if { ![regexp {^ *(.+?)=(.+)$} $str -> varName value] } {
       outputSystem $c [T "Invalid var string"]
       return 0;
     }

  if { ![regexp {^[a-zA-Z][a-zA-Z0-9_]{1,30}$} $varName] } {
       outputSystem $c [T "Invalid var name"]
       return 0;
     }

  if { $global } {
       set conn(0,uservar,$varName) $value
     } else {
       set conn($c,uservar,$varName) $value
     }

  return 1;

};# ::potato::setUserVar

#: proc ::potato::unsetUserVar
#: arg c connection id var is set from
#: arg global Is the var we're unsetting global?
#: arg varName the name of the variable to unset
#: desc Unset the (possibly global) user-defined variable $varName, if it exists and isn't a pre-defined one.
#: desc Attempting to set a variable that doesn't exist (including ones with invalid names) is not an error.
#: desc Attempting to unset a pre-defined var (ie, one starting with an underscore) is, but we fail silently.
#: return nothing
proc ::potato::unsetUserVar {c global varName} {
  variable conn;

  if { [string index $str 0] eq "_" } {
       return;
     }

  if { $global } {
       set c 0
     }

  unset -nocomplain conn($c,uservar,$varName)

};# ::potato::unsetUserVar

#: proc ::potato::slashConfig
#: arg w world id. Defaults to "" for current connection's world
#: desc Show the window for configure Custom /commands for world $w
#: return nothing
proc ::potato::slashConfig {{w ""}} {
  variable world;
  variable slashConfig;

  if { $w eq "" } {
       set w [connInfo [up] world]
     }

  set win .configSlashCmds_w$w
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }
  if { $w == -1 } {
       set title [T "Global Custom /commands"]
     } else {
       set title [T "Custom /commands for %s" $world($w,name)]
     }
  toplevel $win
  wm withdraw $win
  wm title $win $title

  set slashConfig($w,win) $win

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both

  pack [set top [::ttk::frame $frame.top]] -side top -expand 1 -fill both -padx 3 -pady 7
  pack [set treeframe [::ttk::frame $top.tree]] -side top -anchor nw -fill both
  set tree [::ttk::treeview $treeframe.tree -show [list headings] -columns [list Name Pattern Type] \
           -yscrollcommand [list $treeframe.sbY set] \
           -xscrollcommand [list $treeframe.sbX set] -selectmode browse -height 5]
  set sbX [::ttk::scrollbar $treeframe.sbX -orient horizontal -command [list $tree xview]]
  set sbY [::ttk::scrollbar $treeframe.sbY -orient vertical -command [list $tree yview]]
    $tree heading Name -text "  [T "Name"]  "
    $tree heading Pattern -text "  [T "Pattern"]  "
    $tree heading Type -text "  [T "Type"]  "

  foreach {x y} [list Name 100 Pattern 100 Type 50] {
    $tree column $x -width $y
  }
  grid_with_scrollbars $tree $sbX $sbY

  pack [set btns [::ttk::frame $top.btns]] -side top -anchor nw -fill both -padx 10 -pady 5
  pack [::ttk::frame $btns.add] -side left -expand 1 -fill x
  pack [set add [::ttk::button $btns.add.btn -image ::potato::img::event-new \
          -command [list ::potato::slashConfigAdd $w]]] -side top -anchor center
  tooltip $add [T "Add /command"]

  pack [::ttk::frame $btns.edit] -side left -expand 1 -fill x
  pack [set edit [::ttk::button $btns.edit.btn -image ::potato::img::event-edit \
          -command [list ::potato::slashConfigEdit $w]]] -side top -anchor center
  tooltip $edit [T "Edit /command"]

  pack [::ttk::frame $btns.delete] -side left -expand 1 -fill x
  pack [set delete [::ttk::button $btns.delete.btn -image ::potato::img::event-delete \
          -command [list ::potato::slashConfigDelete $w]]] -side top -anchor center
  tooltip $delete [T "Delete /command"]

  foreach x [list tree sbX sbY add edit delete] {
    set slashConfig($w,win,top,$x) [set $x]
  }

  ########
  pack [::ttk::separator $frame.sep -orient horizontal] -side top -fill x -pady 10 -padx 5

  pack [set bottom [::ttk::frame $frame.bottom]] -side top -expand 1 -fill x -padx 3 -pady 7

  pack [set sub [::ttk::frame $bottom.name]] -side top -fill x -padx 4 -pady 3
  pack [::ttk::label $sub.l -text [T "/command Name:"] -width 18] -side left -padx 3
  pack [set name [::ttk::entry $sub.e -textvariable ::potato::slashConfig($w,name) -width 18]] \
      -side left -fill x -padx 3
  pack [set enabled [::ttk::checkbutton $sub.enabled -variable ::potato::slashConfig($w,enabled) -text [T "Enabled?"] \
             -onvalue 1 -offvalue 0]] -side left -padx 3

  pack [set sub [::ttk::frame $bottom.pattern]] -side top -fill x -padx 4 -pady 3
  pack [::ttk::label $sub.l -text [T "Argument Pattern:"] -width 18] -side left -padx 3
  pack [set pattern [::ttk::entry $sub.e -textvariable ::potato::slashConfig($w,pattern) -width 35]] \
     -side left -fill x -padx 3

  pack [set sub [::ttk::frame $bottom.misc]] -side top -fill x -padx 4 -pady 3
  pack [::ttk::label $sub.l -text [T "Pattern Type:"] -width 18] -side left -padx 3
  pack [set patternType [::ttk::combobox $sub.type -textvariable ::potato::slashConfig($w,patternType) \
             -values [list Wildcard Regexp] -width 15 -state readonly]] -side left -padx 3
  pack [set case [::ttk::checkbutton $sub.case -variable ::potato::slashConfig($w,case) -text [T "Case?"] \
             -onvalue 1 -offvalue 0]] -side left -padx 3

  pack [set sub [::ttk::frame $bottom.send]] -side top -fill x -padx 4 -pady 3
  pack [::ttk::label $sub.l -text [T "Send to MUSH:"] -width 18] -side left -padx 3
  pack [set send [::ttk::entry $sub.e -textvariable ::potato::slashConfig($w,send) -width 35]] -side left -padx 3

  pack [set btns [::ttk::frame $bottom.btns]] -side top -fill x -padx 4 -pady 3
  pack [set sub [::ttk::frame $btns.save]] -side left -expand 1 -fill x
  pack [set save [::ttk::button $sub.btn -text [T "Save"] -command [list ::potato::slashConfigSave $w]]]

  pack [set sub [::ttk::frame $btns.discard]] -side left -expand 1 -fill x
  pack [set discard [::ttk::button $sub.btn -text [T "Discard"] -command [list ::potato::slashConfigDiscard $w]]]

  foreach x [list name enabled pattern patternType case send save discard] {
    set slashConfig($w,win,bottom,$x) [set $x]
  }

  ########

  set slashConfig($w,name) ""
  set slashConfig($w,enabled) 0
  set slashConfig($w,pattern) ""
  set slashConfig($w,patternType) ""
  set slashConfig($w,case) 0
  set slashConfig($w,send) ""

  bind $tree <<TreeviewSelect>> [list ::potato::slashConfigSelect $w]
  bind $tree <Double-ButtonPress-1> [list ::potato::slashConfigEdit $w]

  # Disabled bottom (editing) widgets, leave top (listing) widgets enabled
  foreach x [array names slashConfig $w,win,bottom,*] {
     $slashConfig($x) state disabled
  }

  # Set vars for tracking current state. editing says if we're configuring something now, and "which" is the tree -id of
  # the /command we're editing, or "" if we're adding a new one. "lastsel" stores the previously selected item in the
  # tree when we add a new /command
  set slashConfig($w,editing) 0
  set slashConfig($w,editing,which) ""
  set slashConfig($w,editing,lastsel) ""

  bind $win <Escape> [list destroy $win];#abc edit this to "discard" if currently editing, and "destroy" if not
  # Bind this to the tree, not the toplevel, or we get a fire for every child widget too. Feh.
  bind $slashConfig($w,win,top,tree) <Destroy> "[list ::potato::slashConfigClose $w] ; [list array unset ::potato::slashConfig $w,*]"

  # Propagate the list. We use the array elements, to include disabled slash commands
  set count 0
  foreach x [lsort -dictionary [removePrefix [arraySubelem world $w,slashcmd] $w,slashcmd]] {
    set slashConfig($w,slashcmd,slash$count) $x
    set slashConfig($w,slashcmd,slash$count,pattern) $world($w,slashcmd,$x)
    set slashConfig($w,slashcmd,slash$count,patternType) $world($w,slashcmd,$x,type)
    set slashConfig($w,slashcmd,slash$count,case) $world($w,slashcmd,$x,case)
    set slashConfig($w,slashcmd,slash$count,send) $world($w,slashcmd,$x,send)
    set slashConfig($w,slashcmd,slash$count,enabled) [expr {$x in $world($w,slashcmd)}]
    incr count
  }
  set slashConfig($w,count) $count

  slashConfigUpdateTree $w

  reshowWindow $win 0
  return;

};# ::potato::slashConfig

#: proc ::potato::slashConfigSave
#: arg w world id
#: desc A custom slash command is being edited (or added), and "Save" has been clicked; try and save the changes.
#: return nothing
proc ::potato::slashConfigSave {w} {
  variable slashConfig;

  # Command we use for reporting errors here, to avoid repetition
  set error [list tk_messageBox -icon error -title [T "Custom /command Config"] \
                   -parent $slashConfig($w,win) -type ok -message]

  set name $slashConfig($w,name)

  # Check for valid name
  if { ![regexp -nocase {^[a-z][a-z0-9]{1,50}$} $name] } {
       {*}$error [T "That is not a valid name."]
       return;
     }
  # And check for name already in use
  foreach x [removePrefix [arraySubelem slashConfig $w,slashcmd] $w,slashcmd] {
     if { $name eq $slashConfig($w,slashcmd,$x) && $x ne $slashConfig($w,editing,which) } {
          {*}$error [T "That name is already in use."]
          return;
        }
  }
  # We don't check for existing global /commands with the name. Maybe we should?

  # The name is the only bit we need to validate; now we save it.
  if { $slashConfig($w,editing,which) eq "" } {
       # We're saving a new one
       set id "slash$slashConfig($w,count)"
       incr slashConfig($w,count)
     } else {
       # Editing an existing one
       set id $slashConfig($w,editing,which)
     }
  foreach x [list enabled pattern patternType case send] {
     set slashConfig($w,slashcmd,$id,$x) $slashConfig($w,$x)
  }
  set slashConfig($w,slashcmd,$id) $slashConfig($w,name)

  # Now we reset the window
  slashConfigDiscard $w

  # And now we need to update the treeview widget, as we may have a new name for a /command, or a new /command altogether
  slashConfigUpdateTree $w

  # Now make sure we select the right id
  $slashConfig($w,win,top,tree) selection set $id

  return;

};# ::potato::slashConfigSave

#: proc ::potato::slashConfigDiscard
#: arg w world id
#: desc A custom slash command was being edited (or added), but we're done with the changes made (either we've already saved them, or
#: desc we don't want to because "Discard" was clicked), so clear them out and set up for tree selection again.
#: return nothing
proc ::potato::slashConfigDiscard {w} {
  variable slashConfig;

  # Clear the basics
  set slashConfig($w,name) ""
  set slashConfig($w,enabled) 0
  set slashConfig($w,pattern) ""
  set slashConfig($w,patternType) ""
  set slashConfig($w,case) 0
  set slashConfig($w,send) ""

  # Adjust the active widgets
  foreach x [array names slashConfig $w,win,top,*] {
     $slashConfig($x) state !disabled
  }
  foreach x [array names slashConfig $w,win,bottom,*] {
     $slashConfig($x) state disabled
  }

  # Set the treeview's selection
  $slashConfig($w,win,top,tree) selection set $slashConfig($w,editing,lastsel)

  set slashConfig($w,editing) 0
  set slashConfig($w,editing,which) ""
  set slashConfig($w,editing,lastsel) ""

  return;

};# ::potato::slashConfigDiscard

#: proc ::potato::slashConfigClose
#: arg w world id
#: desc The slashConfig window for world $w is being closed. Update world $w's stored slash commands from it, and clear the vars created for the window
#: return nothing
proc ::potato::slashConfigClose {w} {
  variable slashConfig;
  variable world;

  array unset world $w,slashcmd,*
  set world($w,slashcmd) [list]
  foreach x [arraySubelem slashConfig $w,slashcmd] {
    set name $slashConfig($x)
    set world($w,slashcmd,$name) $slashConfig($x,pattern)
    set world($w,slashcmd,$name,type) $slashConfig($x,patternType)
    set world($w,slashcmd,$name,case) $slashConfig($x,case)
    set world($w,slashcmd,$name,send) $slashConfig($x,send)
    if { $slashConfig($x,enabled) } {
         lappend world($w,slashcmd) $name
       }
  }

  array unset slashConfig $w,*

  return;

};# ::potato::slashConfigClose

#: proc ::potato::slashConfigDelete
#: arg w world id
#: desc Delete the selected /command in the slashconfig window for world $w
#: return nothing
proc ::potato::slashConfigDelete {w} {
  variable slashConfig;

  set sel [$slashConfig($w,win,top,tree) selection]
  if { ![llength $sel] } {
       return;
     }

  array unset slashConfig $w,slashcmd,$sel,*
  unset slashConfig($w,slashcmd,$sel)

  slashConfigUpdateTree $w

  return;

};# ::potato::slashConfigDelete

#: proc ::potato::slashConfigEdit
#: arg w world id
#: desc The "Edit /command" button has been clicked. De/re-activate the appropriate widgets.
#: desc We don't need to check for a selection (as the button is disabled when there isn't one),
#: desc or set the vars to the /command's current values (that's already done on selection), but we
#: desc do need to record that we're now editing, and which.
#: return nothing
proc ::potato::slashConfigEdit {w} {
  variable slashConfig;

  if { ![info exists slashConfig($w,win)] || ![winfo exists $slashConfig($w,win)] } {
       return; # window doesn't exist
     }

  if { $slashConfig($w,editing) } {
       return;# already editing
     }

  set tree $slashConfig($w,win,top,tree)

  set slashConfig($w,editing) 1
  set slashConfig($w,editing,which) [$tree selection]
  set slashConfig($w,editing,lastsel) $slashConfig($w,editing,which)

  foreach x [array names slashConfig $w,win,top,*] {
     $slashConfig($x) state disabled
  }

  foreach x [array names slashConfig $w,win,bottom,*] {
     $slashConfig($x) state !disabled
  }

  focus $slashConfig($w,win,bottom,name)

  return;

};# ::potato::slashConfigEdit

#: proc ::potato::slashConfigAdd
#: arg w world id
#: desc The "Add /command" button has been clicked. De/re-activate the appropriate widgets,
#: desc set default values for the /command, and set vars to show we're editing a new /command
#: return nothing
proc ::potato::slashConfigAdd {w} {
  variable slashConfig;

  if { ![info exists slashConfig($w,win)] || ![winfo exists $slashConfig($w,win)] } {
       return; # window doesn't exist
     }

  if { $slashConfig($w,editing) } {
       return;# already editing
     }

  set tree $slashConfig($w,win,top,tree)

  set slashConfig($w,editing) 1
  set slashConfig($w,editing,which) ""
  set slashConfig($w,editing,lastsel) [$tree selection];# so we can restore
  $tree selection set ""

  foreach x [array names slashConfig $w,win,top,*] {
     $slashConfig($x) state disabled
  }
  foreach x [array names slashConfig $w,win,bottom,*] {
     $slashConfig($x) state !disabled
  }

  set slashConfig($w,name) ""
  set slashConfig($w,enabled) 0
  set slashConfig($w,pattern) ""
  set slashConfig($w,patternType) "Regexp"
  set slashConfig($w,case) 0
  set slashConfig($w,send) ""

  focus $slashConfig($w,win,bottom,name)

  return;

};# ::potato::slashConfigAdd

#: proc ::potato::slashConfigUpdateTree
#: arg w world id
#: desc Update the tree of /commands in world $w's slashConfig window
#: return nothing
proc ::potato::slashConfigUpdateTree {w} {
  variable slashConfig;

  if { ![info exists slashConfig($w,win)] || ![winfo exists $slashConfig($w,win)] } {
       return; # window doesn't exist
     }

  set tree $slashConfig($w,win,top,tree)

  # Get the current selection
  set sel [$tree selection]
  set index [$tree index $sel]

  # Now empty the tree
  $tree delete [$tree children {}]

  # And now reinsert everything in the correct order
  foreach id [lsort -dictionary [removePrefix [arraySubelem slashConfig $w,slashcmd] $w,slashcmd]] {
    $tree insert {} end -id "$id" \
          -values [list $slashConfig($w,slashcmd,$id) $slashConfig($w,slashcmd,$id,pattern) \
                        $slashConfig($w,slashcmd,$id,patternType)]
  }

  # Now try and select the right item
  if { ![llength $sel] } {
       # No original selection, just select the first item
       $tree selection set [lindex [$tree children {}] 0]
     } elseif { ![catch {$tree index $sel}] } {
       # Previously selected item is still present
       $tree selection set $sel
     } else {
       # Not present, try and select the next item down
       set children [$tree children {}]
       set lchildren [llength $children]
       if { $lchildren == 0 } {
            # Nothing to select
          } else {
            if { $index >= $lchildren } {
                 set index [expr {$lchildren-1}]
               }
            $tree selection set [lindex $children $index]
          }
     }

  # Now do the necessary stuff when the selection changes
  slashConfigSelect $w

  return;

};# ::potato::slashConfigUpdateTree

#: proc ::potato::slashConfigSelect
#: arg w world id
#: desc Process the selection of a /command in the tree for world $w's /command config window, and activate buttons/show settings as appropriate.
#: return nothing
proc ::potato::slashConfigSelect {w} {
  variable slashConfig;

  if { ![info exists slashConfig($w,win)] || ![winfo exists $slashConfig($w,win)] } {
       return;
     }

  if { $slashConfig($w,editing) } {
       return; # already editing the current selection
     }

  set tree $slashConfig($w,win,top,tree)
  set sel [$tree selection]
  if { ![llength $sel] } {
       $slashConfig($w,win,top,edit) state disabled
       $slashConfig($w,win,top,delete) state disabled
       # Clear vars to show no selection
         foreach x [list pattern patternType case send enabled] {
            set slashConfig($w,$x) ""
         }
         set slashConfig($w,name) ""
       return;
     }

  # Re-enable buttons that work on current selection
  $slashConfig($w,win,top,edit) state !disabled
  $slashConfig($w,win,top,delete) state !disabled

  # Set vars to show setting of currently selected item
  foreach x [list pattern patternType case send enabled] {
    set slashConfig($w,$x) $slashConfig($w,slashcmd,$sel,$x)
  }
  set slashConfig($w,name) $slashConfig($w,slashcmd,$sel)

  return;

};# ::potato::slashConfigSelect

#: proc ::potato::process_slash_cmd
#: arg c connection id
#: arg _str var containing the string entered, to upvar ("/command arg arg arg")
#: arg mode 0 if we're starting to parse input, 1 if recursing, 2 if we're parsing a field from, for instance, an Event
#: arg _vars Name of var holding option array.
#: desc process $str as a slash command and perform the necessary action. If we're recursing, return the result, otherwise output it on screen.
#: return [list <error?> <result>] for nested invocations, or the text to send to the MUSH for non-nested invocations.
proc ::potato::process_slash_cmd {c _str mode {_vars ""}} {
  variable conn;
  variable world;

  array set modes [list default 0 recursing 1 field 2]
  upvar 1 $_str str;
  if { ![info exists str] } {
       return;
     }
  if { $_vars ne "" } {
       upvar 1 $_vars vars;
     }

  if { ![info exists conn($c,id)] } {
       return; # Running a /command for a closed connection - maybe on a timer that didn't cancel?
     }

  # This while loop is a crude go-to to avoid the need for repeating
  # the checks for $recursing
  while { ![info exists running] } {
    set running 1

    set parsed [parse_slash_cmd $c str $mode vars]
    set wascmd [lindex $parsed 0]
    set cmd [lindex $parsed 1]
    set cmdArgs [lindex $parsed 2]
    if { !$wascmd } {
         # Not a /command, just literal text
         if { $mode == $modes(recursing) } {
              return [list 1 $cmd];
            } else {
              return $cmd;
            }
       }
    set cmd [string range $cmd 1 end]
    # Add 20 chars to the length for the "::potato::slash_cmd_" command prefix
    set len [expr {[string length $cmd]+20}]
    set partial [list]
    set w $conn($c,world)
    foreach x [info procs ::potato::slash_cmd_*] {
       if { [string equal -nocase ::potato::slash_cmd_$cmd $x] } {
            set exact $x
            break;
          } elseif { [info exists world($w,slashcmd)] && [lsearch -exact -nocase $world($w,slashcmd) $cmd] > -1 } {
            set exact $cmd
            set custom $w
          } elseif { $w != -1 && [info exists world(-1,slashcmd)] && \
                     [lsearch -exact -nocase $world(-1,slashcmd) $cmd] > -1 } {
            set exact $cmd
            set custom -1
          } elseif { [string equal -nocase -length $len ::potato::slash_cmd_$cmd $x] } {
            lappend partial $x
          }
    }
    if { [info exists exact] } {
         if { [info exists custom] } {
              # Custom /command
              set ret [customSlashCommand $c $custom $exact $cmdArgs]
            } else {
              # Built-in /command
              set ret [$exact $c 1 $mode $cmdArgs vars]
            }
         break;
       } elseif { [llength $partial] == 1 } {
         set ret [[lindex $partial 0] $c 0 $mode $cmdArgs vars]
         break;
       } elseif { [llength $partial] == 0 } {
         # Check for unique abbreviations of custom /commands.
         if { [info exists world($w,slashcmd)] } {
              foreach x $world($w,slashcmd) {
                 if { [string equal -nocase -length [string length $cmd] $cmd $x] } {
                      lappend partial $x
                      set custom $w
                    }
              }
            }
         if { $w != -1 && [info exists world(-1,slashcmd)] } {
              foreach x $world(-1,slashcmd) {
                 if { [string equal -nocase -length [string length $cmd] $cmd $x] } {
                      lappend partial $x
                      set custom -1
                    }
              }
            }
         if { [llength $partial] == 0 } {
              set ret [list 0 [T "Unknown /command \"%s\". Use /slash for a list. Use //command to send directly to MU*." $cmd]]
              break;
            } elseif { [llength $partial] > 1 } {
              set ret [list 0 [T "Ambiguous /command \"%s\"." $cmd]]
              break;
            }
         set ret [customSlashCommand $c $custom [lindex $partial 0] $mode $cmdArgs vars]
       } else {
         set ret [list 0 [T "Ambiguous /command \"%s\"." $cmd]]
         break;
       }
    break;
  }

  if { ![info exists ret] } {
       # Shouldn't happen
       set ret [list 1 ""]
     }

  if { $mode == $modes(recursing) } {
       return $ret;
     } elseif { $ret eq "" || [catch {lindex $ret 0} retFirst] || $retFirst ni [list 0 1] } {
       # Malformed return value
       return [list 1 ""];
     } elseif { $mode == $modes(field) } {
       return [lindex $ret 1];
     } elseif { ![lindex $ret 0]} {
       bell -displayof .
       if { $c != 0 } {
            if { [llength $ret] > 1 && [string length [lindex $ret 1]] } {
                 outputSystem $c [T "Error: %s" [lindex $ret 1]]
               }
          }
     } elseif { $c != 0 && [llength $ret] > 1 && [string length [lindex $ret 1]]} {
       outputSystem $c [lindex $ret 1]
     }

  return;

};# ::potato::process_slash_cmd

#: proc ::potato::parse_slash_cmd
#: arg c connection id
#: arg _str name of variable containing string, to upvar
#: arg mode if 2, we're recursed to parse nested /commands, and should return on an unescaped "]". If 1, we only do anything at all if the first char is a "["
#: arg _vars
#: desc Parse a string as the args of a slash command; do variable expansion, parse nested /commands, etc
#: return result of parsing the string.
proc ::potato::parse_slash_cmd {c _str mode _vars} {
  upvar 1 $_str str;

  if { $str eq "" } {
       return [list 0 "" ""];
     }

  # Copied from process_slash_command
  array set modes [list default 0 recursing 1 field 2]

  set cmd ""
  set cmdArgs ""
  set appendTo cmd
  set esc 0
  set cmd_found 0
  upvar 1 $_vars vars;

  if { $mode == $modes(field) } {
       if { [string index $str 0] eq "\[" } {
            set str [string range $str 1 end]
            set mode $modes(recursing)
          } else {
            if { [string index $str 0] eq "\\" } {
                 set copy [string range $str 1 end]
               } else {
                 set copy $str
               }
            set str ""
            return [list 0 $copy ""];
          }
     }

  if { [string index $str 0] eq "/" } {
       if { [string index $str 1] eq "/" } {
            set str [string range $str 1 end]
            set cmd_present 0
          } else {
            set cmd_present 1
            set cmd "/"
            set str [string range $str 1 end]
          }
     } else {
       set cmd_present 0
     }

  while { [string length $str] } {
    set x [string index $str 0]
    set str [string range $str 1 end]
    if { $cmd_present && !$cmd_found && $x eq " " } {
         set cmd_found 1
         set appendTo cmdArgs
         continue;
       }
    if { ($mode == $modes(default)) && !$cmd_present } {
         if { $x in [list "\n" "\r"] } {
              # We're done
              break;
            } else {
              append $appendTo $x
              continue;
            }
       } elseif { ($mode == $modes(field)) && $x eq "\]" } {
         # We're done
         break;
       }
    if { $esc } {
         set esc 0
         append $appendTo $x
         continue;
       } elseif { $x eq "\\" } {
         set esc 1
         continue;
       } elseif { $x eq "\[" } {
         append $appendTo [lindex [process_slash_cmd $c str 1 vars] 1]
       } elseif { $x eq ($mode == $modes(recursing) ? "\]" : "\n") } {
         # We're done.
         break;
       } else {
         # Normal char
         append $appendTo $x
       }
  }
  return [list $cmd_present $cmd $cmdArgs];

};# ::potato::parse_slash_cmd

#: proc ::potato::define_slash_cmd
#: arg cmd Name of /command
#: arg code body of /command
#: desc Add a new ::potato::slash_cmd_$cmd proc with the appropriate args, and a body of $code.
#: return nothing.
proc ::potato::define_slash_cmd {cmd code} {

  # c = connection id
  # full = was the command name typed in full?
  # recursing = is this a nested /command?
  # str = the arg given to the /command
  # _vars = name of var to uplevel for array of options
  proc ::potato::slash_cmd_$cmd {c full recursing str _vars} "$code\n;return \[list 1\]";

  return;

};# ::potato::define_slash_cmd

#: proc ::potato::alias_slash_cmd
#: arg orig Original /command name
#: arg new New /command name for alias
#: desc Alias a /command. See define_slash_cmd
#: return 1 on success, 0 on failure
proc ::potato::alias_slash_cmd {orig new} {

  set slashcmds [info commands ::potato::slash_cmd_*]
  if { "::potato::slash_cmd_$orig" ni $slashcmds || "::potato::slash_cmd_$new" in $slashcmds } {
       return 0; # orig doesn't exist, or new already does
     }

  set cmdstring [list proc ::potato::slash_cmd_$new]
  set args [list]
  foreach x [info args ::potato::slash_cmd_$orig] {
    if { [info default ::potato::slash_cmd_$orig $x default] } {
         lappend args [list $x $default]
       } else {
         lappend args [list $x]
       }
  }
  proc ::potato::slash_cmd_$new $args [info body ::potato::slash_cmd_$orig]

  return 1;

};# ::potato::alias_slash_cmd

#: proc ::potato::customSlashCommand
#: arg c connection id
#: arg w world id
#: arg cmd /command name
#: arg str args to /command
#: desc Try and run the custom slash command $cmd, defined in world $w, for connection $c, using args $str. We pass
#: desc $w rather than checking $c's world b/c the command might be defined in -1
#: return nothing
proc ::potato::customSlashCommand {c w cmd str} {
  variable conn;
  variable world;

  if { $world($w,slashcmd,$cmd,type) in [list "regexp" "Regexp"] } {
       set pattern $world($w,slashcmd,$cmd)
     } else {
       set pattern [glob2Regexp $world($w,slashcmd,$cmd)]
     }

  set regexpArgs [list]
  if { !$world($w,slashcmd,$cmd,case) } {
       lappend regexpArgs -nocase
     }
  lappend regexpArgs -- $pattern $str -> a(0) a(1) a(2) a(3) a(4) a(5) a(6) a(7) a(8) a(9)
  if { [catch {regexp {*}$regexpArgs} retval] || !$retval } {
       # Cmd input is invalid, doesn't match pattern
       bell -displayof .
       return [list 0];
     }

  set send $world($w,slashcmd,$cmd,send)
  set send [string map [list %% % %0 $a(0) %1 $a(1) %2 $a(2) %3 $a(3) %4 $a(4) \
                             %5 $a(5) %6 $a(6) %7 $a(7) %8 $a(8) %9 $a(9)] $send]

  send_to_real $c $send

  return [list 1];

};# ::potato::customSlashCommand

#: /prompt
#: Set (or clear) the prompt
::potato::define_slash_cmd prompt {

  if { $c == 0 } {
       return [list 0];
     }
  setPrompt $c $str

  return [list 1];
};# /prompt

#: /rename [<name>]
#: Set (or clear) the custom name for a connection
::potato::define_slash_cmd rename {
  variable conn;

  if { $c == 0 } {
       bell -displayof .
       return [list 0];
     }

  set name [string trim $str]
  if { $name eq "" } {
       set conn($c,name) [list 0 ""]
     } else {
       set conn($c,name) [list 1 $str]
     }
  updateConnName $c
  skinStatus $c

  return [list 1];

};# /rename

#: /null <input>
#: Return nothing; for eating the return values of other /commands.
::potato::define_slash_cmd null {

  return [list 1];

};# /null

#: /input [1|2] <stuff> - print <stuff> to input window [1|2]
::potato::define_slash_cmd input {

  set str [string trimleft $str]
  set list [split $str " "]
  # We use string comparison, not numerical, otherwise "/input 3.0 foo" will pass, but will fail
  # as we don't have conn($c,input3.0) vars.
  if { [lindex $list 0] ne 1 && [lindex $list 0] ne 2 && [lindex $list 0] ne 3 } {
       return [list 0 [T "Invalid input window \"%s\": must be 1, 2 or 3" [lindex $list 0]]];
     }

  showInput $c [lindex $list 0] [join [lrange $list 1 end] " "] 1

  return [list 1];

};# /input

# /tinyurl <url> - print a TinyURL'd version of <url>
# /tinyurl <string> - replace all URLs in <string> with TinyURLs, and send modified <string> to MUSH
::potato::define_slash_cmd tinyurl {

  if { [up] == 0 } {
       bell -displayof .
       return [list 0];
     }

  set re {\m(?:(?:(?:f|ht)tps?://)|www\.)(?:(?:[a-zA-Z_\.0-9%+/@~=&,;-]*))?(?::[0-9]+/)?(?:[a-zA-Z_\.0-9%+/@~=&,;-]*)(?:\?(?:[a-zA-Z_\.0-9%+/@~=&,;:-]*))?(?:#[a-zA-Z_\.0-9%+/@~=&,;:-]*)?}
  set where [regexp -inline -indices -all $re $str]
  if { [llength $where] == 0 } {
       send_to_real [up] $str
       return [list 0];
     }
  set all_url [regexp "^$re\$" $str]
  for {set i 0} {$i < [llength $where]} {incr i} {
    set indices [lindex $where end-$i]
    foreach {start end} $indices {break}
    set url [string range $str $start $end]
    if { [string range $url 0 2] ni [list "htt" "ftp"] } {
         set url "http://$url"
       }
    if { ![catch {TinyURL $url} result] } {
         set str [string replace $str $start $end $result]
       } else {
         errorLog "Unable to launch TinyURL at \"$url\": $result" warning
         if { !$all_url } {
              send_to_real $c $str
            }
         return [list 0 [T "Unable to launch TinyURL at \"%s\": %s" $url $result]];
       }
  }
  if { $all_url} {
       return [list 1 $str]
     } else {
       send_to_real [up] $str
     }

  return [list 1];

};# /tinyurl

#: /setprefix [[<window>=]<prefix>]
#: Set the prefix for <window>, or the current output window (if not given) to <prefix>.
::potato::define_slash_cmd setprefix {
  variable potato;
  variable conn;
  variable world;

  set w $conn($c,world)

  # Just check the Prefix Window isn't open. For simplicity, disallow
  # setting prefixes when it is.
  if { [winfo exists .prefixWin$w] } {
       bell -displayof .
       return [list 0];
     }

  # Parse str
  set window ""
  if { [string match "*=*" $str] } {
       set equals [string first "=" $str]
       set window [string range $str 0 $equals-1]
       set str [string range $str $equals+1 end]
     }
  # Validate window name
  if { $window eq "" } {
       set window [textWidgetName [activeTextWidget] $c]
     } elseif { [set window [validSpawnName $c $window]] ne "" } {
       bell -displayof .
       return [list 0];
     }

  if { $str eq "" } {
       # Clear prefix
       unset -nocomplain world($w,prefixes,$window)
     } else {
       # Update prefix. We enable the new prefix, even if there
       # was an existing, disabled one.
       set curr [lsearch -exact -nocase -index 0 $world($w,prefixes) $window]
       if { $curr == -1 } {
            lappend world($w,prefixes) [list $window $str 1]
          } else {
            set world($w,prefixes) [lreplace $world($w,prefixes) $curr $curr [list $window $str 1]]
          }
     }

  return [list 1];

};# /setprefix

#: /print <str>
#: Print <str> as a system message
::potato::define_slash_cmd print {

  outputSystem $c $str
  return [list 1];

};# /print

#: /at <time>=<action>
#: At [clock scan <time>] send <action> to the MUSH
::potato::define_slash_cmd at {
  variable conn;

  set equals [string first "=" $str]
  if { $equals == -1 } {
       return [list 0 [T "Format: /at <time>=<string>"]];
     }
  set time [string range $str 0 $equals-1]
  set action [string range $str $equals+1 end]
  if { [catch {clock scan $time} inttime] } {
       return [list 0 "/at: $inttime"];
     }

  set now [clock seconds]
  if { $now >= $inttime } {
       return [list 0 [T "/at: Time must be in the future."]];
     }
  set when [expr {($inttime - [clock scan "now"]) * 1000}]
  lappend conn($c,userAfterIDs) [set afterid [after $when [list ::potato::send_to $c $action]]]

  after [expr {$when + 1200}] [list ::potato::cleanup_afters $c]
  if { $recursing } {
       return [list 1 $afterid]
     }
  return [list 1 [T "Command will run at %s, id %s" [clock format $inttime -format "%D %T"] $afterid]]

};# /at

#: /debug [--on | --off | --toggle]
#: Show the Debug Packets window
::potato::define_slash_cmd debug {
  variable conn;

  if { $c == 0 } {
       bell -displayof .
       return [list 0];
     }

  if { $str eq "--on" } {
       set conn($c,debugPackets) 1
     } elseif { $str eq "--off" } {
       set conn($c,debugPackets) 0
     } else {
       set conn($c,debugPackets) [lindex [list 1 0] $conn($c,debugPackets)]
     }

  return [list 1];

};# /debug

#: /runmacro <macro>
#: Run the given macro
::potato::define_slash_cmd runmacro {
  variable world;
  variable conn;

  set w $conn($c,world)

  set argList [list]
  set onearg ""
  if { [set equals [string first "=" $str]] == -1 } {
       set macro $str
     } elseif { 1 } {
       set macro $str
     } else {
       set macro [string range $str 0 $equals-1]
       set argstr [string range $str $equals+1 end]
       while { [string length $argstr] } {
         break;
       }
     }

  if { [info exists world($w,macro,$macro)] } {
       set do $w,macro,$macro
     } elseif { [info exists world(-1,macro,$macro)] } {
       set do -1,macro,$macro
     } else {
       return [list 0 [T "No such macro \"%s\"." $str]];
     }

  send_to $c $world($do)

  return [list 1];

};# /runmacro

#: /cancelat <id>
#: Cancel a previous /at using the after id given by /at
::potato::define_slash_cmd cancelat {
  variable conn;

  if { $str ni $conn($c,userAfterIDs) } {
       return [list 0 [T "Invalid /at ID."]];
     }

  after cancel $str
  cleanup_afters $c
  return [list 1 [T "/at cancelled."]];

};# /cancelat

#: /addspawn <spawn>
#: Add the specified spawn to the spawn-all list for the connection
::potato::define_slash_cmd addspawn {
  variable conn;

  set lc [string tolower $str]
  if { [string length $lc] && $lc ni $conn($c,spawnAll) } {
       lappend conn($c,spawnAll) $lc
     }
  return [list 1];

};# /addspawn

#: /delspawn <spawn>
#: Delete the specified spawn from the spawn-all list for the connection
::potato::define_slash_cmd delspawn {
  variable conn;

  set pos [lsearch -exact -nocase $conn($c,spawnAll) $str]
  if { $pos != -1 } {
       set conn($c,spawnAll) [lreplace $conn($c,spawnAll) $pos $pos]
     }
  return [list 1];

};# /delspawn

#: /limit [-<options>][ -- ]<pattern>
#: Filter output based on the given options and pattern
::potato::define_slash_cmd limit {
  variable conn;

  if { ![info exists conn($c,textWidget)] || ![winfo exists $conn($c,textWidget)]} {
       bell -displayof .
       return;
  }

  set t $conn($c,textWidget)

  if { ![string length $str] } {
       # Just report whether we have a /limit atm
       if { [llength [$conn($c,textWidget) tag nextrange limited 1.0 end]] } {
            return [list 1 1];
          } else {
            return [list 1 0];
          }
     }

  $t tag remove "limited" 1.0 end
  set conn($c,limited) [list]

  set invert 0
  set matchType "glob"

  set list [split $str " "]

  # Parse off args
  set done 0
  set case 1
  foreach x $list {
    if { $done || ![string match "-*" $x] } {
         break; # not an "-option"
       }
    switch -nocase -exact -- $x {
       -v {set invert 1}
       -a {# in TF, -a means "lines that have attributes". Whatever that is. Be nice to TF users and ignore it}
       -msimple -
       -literal {set matchType literal}
       -mglob -
       -glob -
       -wildcard {set matchType glob}
       -mregexp -
       -regexp {set matchType regexp}
       -nocase {set case 0}
       -- {set done 1}
       default {return [list 0 [T "Invalid option \"%s\" to /limit" $x]];}
    }
    set list [lrange $list 1 end]
  }

  set str [join $list " "]
  if { $str eq "" } {
       return [list 1];
     }

  set case [lindex [list -nocase] $case]

  # OK, do limiting.
  for { set i [$t count -lines 1.0 end]} {$i > 0} {incr i -1} {
    if { "system" in [$t tag names $i.0] } {
         continue;
       }
    set line [$t get -displaychars $i.0 "$i.0 lineend"]
    switch -exact -- $matchType {
      regexp {set caught [catch {regexp {*}$case $str $line} match]}
      literal {set caught [catch {string equal {*}$case $str $line} match]}
      glob {set caught [catch {string match {*}$case $str $line} match]}
    }
    if { $caught } {
         return [T "Invalid %s pattern \"%s\": %s" $matchType $str $match];
       }
    if { ($invert ? $match : !$match) } {
         $t tag add limited $i.0 "$i.0 lineend+1char"
       }
  }

  set conn($c,limited) [list $matchType $invert $case $str]

  return [list 1];

};# /limit

#: /unlimit
#: Show all output, when output is reduced by /limit
::potato::define_slash_cmd unlimit {
  variable conn;

  if { [info exists conn($c,textWidget)] && [winfo exists $conn($c,textWidget)] } {
       $conn($c,textWidget) tag remove limited 1.0 end
     }

  set conn($c,limited) [list]

  return [list 1];

};# /unlimit

#: /cls [<c>]  |  /cls [<c>.][<window>]
#: Clear the <window> output window for conn <c>, defaulting to _main and the current connection respectively
::potato::define_slash_cmd cls {
  variable conn;

  if { !$full } {
       bell -displayof .
       return [list 0 [T "/cls cannot be abbreviated."]];# too risky to allow an abbreviation
     }

  if { $str eq "" } {
       set window "_main"
     } elseif { [string is integer -strict $str] } {
       set c $str
       set window "_main"
     } elseif { [regexp -nocase {^(?:([0-9]+)\.)?\.?(_main|[a-zA-Z][a-zA-Z0-9_-]{0,49})?$} $str {} c2 window] } {
       # (Yes, this regexp actually allows for two '.'s between world num and window name. This is because I'm
       #  too lazy to rewrite it more neatly at present to match 'X.Y', 'X.', '.Y' or 'Y'. Maybe later.) #abc
       if { $c2 ne "" } {
            set c $c2
          }
     } else {
       bell -displayof .
       return [list 0 [T "/cls: Invalid window name."]];# invalid window name
     }

  if { ![info exists conn($c,textWidget)] } {
       bell -displayof .
       return [list 0 [T "/cls: Invalid connection."]];# bad connection
     }

  if { $window eq "_main" || $window eq "" || [set pos [findSpawn $c $window]] != -1 } {
       if { ![info exists pos] } {
            set t $conn($c,textWidget)
          } else {
            set t [lindex $pos 1]
          }
       clearOutputWindow $c $t
     } else {
       return [list 0 [T "/cls: No such window."]]
     }

  return [list 1];

};# /cls

#: /send <str>
#: Send <str> to the connection
::potato::define_slash_cmd send {

  send_to_real $c $str
  return [list 1];

};# /send

#: /all <str>
#: Send <str> to all connections
::potato::define_slash_cmd all {

  foreach x [connList] {
    send_to_real [lindex $x 0] $str
  }
  return [list 1];

};# /all

#: /show <c>  |  /show [<c>.]<window>
#: Show <window> in connection <c>, defaulting to <main> and current connection
::potato::define_slash_cmd show {
  variable conn;


  if { [string trim $str] eq "" } {
       return [list 0];
     }

  if { [string is integer -strict $str] } {
       # Just got a connection number
       showConn $str
       return [list 1];
     } elseif { [regexp -nocase {^(?:([0-9]+)\.)?(.+?)$} $str {} c2 window] } {
       # We have an optional connection number, and a valid spawn name
       if { $c2 eq "" } {
            set c2 $c
          }
       set str $window
     } else {
       set c2 $c
     }
  if { [set window [validSpawnName $window]] eq "" || [findSpawn $c2 $window] == -1 } {
       return [list 0]
     }
  # $window may signify the main text widget, but by using showSpawn not showConn we
  # request the skin show the main text widget, if it's not already doing so.
  showSpawn $c2 $window
  return [list 1];

};# /show

#: /slash
#: Print a list of all /commands
::potato::define_slash_cmd slash {
  variable world;

  set list [list]
  foreach x [info procs ::potato::slash_cmd_*] {
     lappend list [string range $x 20 end]
  }
  set return [T "Available slash commands: %s" [itemize [lsort -dictionary $list]]]
  set w [connInfo $c world]
  if { $w != -1 && [llength $world($w,slashcmd)] } {
       append return "\n" [T "User-defined commands for this world: %s" [itemize [lsort -dictionary $world($w,slashcmd)]]]
     }
  if { [llength $world(-1,slashcmd)] } {
       append return "\n" [T "Global User-defined commands: %s" [itemize [lsort -dictionary $world(-1,slashcmd)]]]
     }

  return [list 1 $return];

};# /slash

#: /set <varname>=<value>
#: Set a connection-local variable <varname> (accessed in /commands as $<varname>$ to <value>
::potato::define_slash_cmd set {

  setUserVar $c 0 $str
  return [list 1];

};# /set

#: /unset <varname>
#: Unset the connection-local variable <varname>
::potato::define_slash_cmd unset {

  unsetUserVar $c 0 $str
  return [list 1];

};# /unset

#: /get [-all|-global|-local] <varname>
#: Return the value of the given variable
::potato::define_slash_cmd get {
  variable world;
  variable conn;

  set local 1
  set global 1

  if { [info exists conn($c,world)] } {
       set w $conn($c,world)
       array set masterVars [list _u [up] \
                                  _c $c \
                                  _w $w \
                                  _name $world($w,name) \
                                  _host $world($w,host) \
                                  _port $world($w,port) \
                                  _char $conn($c,char) \
                            ] ;# array set masterVars
     } else {
       array set masterVars [list _u [up] \
                                  _c 0 \
                                  _w -1 \
                                  _name "Potato" \
                                  _host "unknown" \
                                  _port 0 \
                                  _char "" \
                            ] ;# array set masterVars
     }

  upvar 1 $_vars vars;
  if { [info exists vars] && [array exists vars] } {
       array set masterVars [array get vars]
     }

  if { [set space [string first " " $str]] != -1 } {
       set switch [string range $str 0 $space-1]
       set str [string range $str $space+1 end]
       if { $x eq "-local" } {
            set global 0
          } elseif { $x eq "-global" } {
            set local 0
          } elseif { $x ne "-all" } {
            return [list 0 "/get: Invalid switch \"$switch\": Must be one of -all, -global or -local"];
          }
     }

  if { [info exists masterVars($str)] } {
       return [list 1 $masterVars($str)];
     } elseif { $local && [info exists conn($c,uservar,$str)] } {
       return [list 1 $conn($c,uservar,$str];
     } elseif { $global && [info exists conn(0,uservar,$str)] } {
       return [list 1 $conn(0,uservar,$str];
     } else {
       return [list 0];
     }

};# /get

#: /time [<format>]
::potato::define_slash_cmd time {

  set cmd [list clock format [clock seconds]]
  if { [string length $str] } {
       lappend cmd -format $str
     }

  if { [catch {{*}$cmd} output] } {
       return [list 0 ???];
     } else {
       return [list 1 $output];
     }

};# /time

#: /vars [-all|-global|-local]
#: Print a list of all, global or local vars
::potato::define_slash_cmd vars {
  variable conn;

  set local 0
  set global 0

  foreach x [split $str " "] {
    if { $x eq "-all" } {
         set local 1
         set global 1
       } elseif { $x eq "-local" } {
         set local 1
       } elseif { $x eq "-global" } {
         set global 1
       } else {
         return [list 0 "/vars: Invalid arg \"$x\": Must be one of -all, -global or -local"];
       }
  }

  set return ""

  if { !($global || $local) } {
       set local 1
       set global 1
     }

  if { $local && $c != 0 } {
       append return "World vars:"
       foreach x [lsort -dictionary [removePrefix [array names conn $c,uservar,*] $c,uservar]] {
         append return "\n\t$x\t$conn($c,uservar,$x)"
       }
       if { $global } {
            append return "\n"
          }
     }

  if { $global || ($local && $c == 0) } {
       append return "Global vars:"
       foreach x [lsort -dictionary [removePrefix [array names conn 0,uservar,*] 0,uservar]] {
         append return "\n\t$x\t$conn(0,uservar,$x)"
       }
     }

  return [list 1 $return];

};# /vars

#: /setglobal <varname>=<value>
#: Set a global (all connections) variable <varname> to <value>
::potato::define_slash_cmd setglobal {

  setUserVar $c 1 $str
  return [list 1];

};# /setglobal

#: /unsetglobal <varname>
#: Unset global var <varname>
::potato::define_slash_cmd unsetglobal {

  unsetUserVar $c 1 $str
  return [list 1];

};# /unsetglobal

#: /edit
#: Show the Edit Settings window
::potato::define_slash_cmd edit {
  variable conn;

  if { $c == 0 } {
       taskRun programConfig
     } else {
       taskRun config $conn($c,world) $conn($c,world)
     }
  return [list 1];

};# /edit

#: /tcl
#: Show the Tcl code console if available
::potato::define_slash_cmd tcl {

  if { [catch {console show}] } {
       return  [list 0];
     }

  return [list 1];

};# /tcl

#: /reload
#: Reload the main Potato code file and the custom file.
::potato::define_slash_cmd reload {
  variable path;

  if { [catch {source [file join $path(vfsdir) lib potato.tcl]} err] } {
       return [list 0 $err];
     }
  set files [list potato.tcl]
  if { [file exists $path(custom)] } {
       if { [catch {source $path(custom)} err] } {
            return [list 0 $err];
          } else {
            lappend files [file tail $path(custom)]
          }
     }

  return [list 1 [T "%s reloaded successfully." [itemize $files]]];

};# /reload

#: /eval <code>
#: Evaluate the Tcl code <code> and print the result to the output window
::potato::define_slash_cmd eval {

  set err [catch {uplevel #0 $str} msg]
  if { $err } {
       bell -displayof .
       if { !$recursing } {
            set msg [T "Error (%d): %s" [string length $msg] $msg]
          }
       return [list 0 $msg];
     }

  if { !$recursing } {
       set msg [T "Return (%d): %s" [string length $msg] $msg]
     }
  return [list 1 $msg];

};# /eval

#: /speedwalk <dirs>
#: Speedwalk in the given directions. <dirs> is a string in the format [<number>][ ]<direction>[[ ][<numberN>][ ]<directionN>]
::potato::define_slash_cmd speedwalk {

  if { ![regexp {^ *([0-9]+ *([ns][ew]|[nsweudo]) *)+ *$} $str] } {
       return [list 0 [T "Invalid speedwalk command"]];
     }

  set dirs [list n north s south w west e east nw northwest ne northeast sw southwest se southeast \
                 u up d down o out]
  foreach {all num dir} [regexp -all -inline -- { *([0-9]+)? *((?:[ns][ew]|[nsewudo])) *} $str] {
     set which [expr {[lsearch -exact $dirs $dir] + 1}]
     for {set i 0} {$i < $num} {incr i} {
       send_to_real $c [lindex $dirs $which]
     }
  }

  return [list 1];

};# /speedwalk

#: /log  |  /log -close [<path>] |  /log [-options] <path>
#: Either show the logging window, close open log(s) or start logging to a new file
::potato::define_slash_cmd log {
  variable conn;

  if { $c == 0 } {
       return [list 0];
     }

  # Check for no options given
  if { [string trim $str] eq "" } {
       taskRun log $c $c
       return [list 1];
     }

  # Check for "/log -close"
  set argv [split $str " "]
  set argc [llength $argv]

  if { [lsearch -exact -nocase [list -close -stop -off] [lindex $argv 0]] != -1 } {
       # Close an open log file, or all open log files
       set res [taskRun logStop $c $c [join [lrange $argv 1 end] " "] 1]
       if { $res == 0 } {
            return [list 0];
          } elseif { $res == -1 } {
            return [list 0 [T "Log file \"%s\" not found." [join [lrange $argv 1 end] " "]]];
          } elseif { $res == -2 } {
            return [list 0 [T "Log file \"%s\" is ambiguous." [join [lrange $argv 1 end] " "]]];
          } else {
            return [list 1 $res];
          }
     }

  # Try and parse out options...
  array set options [list -buffer "_main" -append 1 -leave 1 -timestamps 0 -html 0]
  set error ""
  set finished 0
  set file [list]
  set needOpt 1
  set i 0
  foreach x $argv {
     incr i
     if { [string length $error] } {
          break;
        }
     if { $finished } {
          lappend file $x
        } else {
          if { $needOpt } {
               # Looking for an -option, not a value
               if { $x eq "--" } {
                    set finished 1
                    continue;
                  } elseif { $x eq "" } {
                    continue;
                  } else {
                    set match [array names options "$x*"]
                    if { [llength $match] == 0 } {
                         if { $i == $argc || ![string match "-*" $x] } {
                              set finished 1
                              lappend file $x
                            } else {
                              set error [T "Unknown option \"%s\"" $x]
                              break;
                            }
                       } elseif { [llength $match] > 1 } {
                         set error [T "Ambiguous option \"%s\"" $x]
                       } else {
                         set needOpt 0
                       }
                  }
              } else {
                # Looking for a value to the option $match
                if { $match in [list "-append" "-leave" "-timestamps" "-html"] } {
                     if { [string is boolean -strict $x] } {
                          set options($match) [string is true -strict $x]
                        } else {
                          set error [T "Invalid setting \"%s\" for \"%s\"" $x $match]
                          break;
                        }
                   } elseif { $match eq "-buffer" } {
                     set options(-buffer) $x;# name of a spawn window
                   }
                set needOpt 1
              }
        }
     }

  if { $error ne "" } {
       return [list 0 "/log: $error"];
     }

  set file [join $file " "]
  if { $file eq "" } {
       # Gahhhh. Why did I write all that parsing code if you DIDN'T GIVE A FILE?!
       taskRun log $c $c
       return [list 1];
     }

  doLog $c $file $options(-append) $options(-buffer) $options(-leave) $options(-timestamps) $options(-html)
  return [list 1];

};# /log

#: /close
#: Close the current connection
::potato::define_slash_cmd close {

  taskRun close $c $c

  return [list 1];

};# /close

#: /connect <worldname>
#: Connect to the saved world <worldname>
::potato::define_slash_cmd connect {
  variable world;
  variable misc;

  if { [string trim $str] eq "" } {
       if { $c == 0 } {
            return [list 0];
          } else {
            taskRun $c reconnect
          }
       return [list 1];
     }
  switch [parseConnectRequest $str] {
     1 {return [list 1];}
     0 {return [list 0 [T "No such world \"%s\". Use \"/quick host port\" to connect to a world that isn't in the address book." $str]];}
    -1 {return [list 0 [T "Ambiguous world name \"%s\"." $str]];}
  }

};# /connect

proc ::potato::parseConnectRequest {str} {
  variable world;
  variable misc;

  set str [string trim $str]
  set len [string length $str]

  set partial [list]
  foreach w [worldIDs] {
     if { [string equal -nocase $world($w,name) $str] } {
          set exact $w
          break;
        } elseif { [string equal -nocase -length $len $world($w,name) $str] } {
          lappend partial $w
        }
  }

  set partial [lsort -dictionary $partial]
  if { [info exists exact] } {
       newConnectionDefault $exact
       return 1;
     } elseif { [llength $partial] == 0 } {
       return 0;
     } elseif { [llength $partial] == 1 || $misc(partialWorldMatch) } {
       newConnectionDefault [lindex $partial 0]
       return 1;
     } else {
       return -1;
     }
};# ::potato::parseConnectRequest

#: /quick [<host>:<port>]
#: Connect to the given address, or show the Quick Connect window
::potato::define_slash_cmd quick {

  set hostAndPort [parseTelnetAddress $str]
  if { [llength $hostAndPort] == 2 } {
       # Make the new world, and connect to it.
       set host [lindex $hostAndPort 0]
       set port [lindex $hostAndPort 1]
       newConnection [addNewWorld "$host:$port" $host $port 1]
     } else {
       # Pop up the "quick connect" dialog.
       potato::newWorld 1
     }

  return [list 1];

};# /quick

#: /exit
::potato::define_slash_cmd exit {

  if { $full } {
       set prompt 0
     } else {
       set prompt -1
     }
  taskRun exit $c $prompt
  return [list 1];

};# /exit

#: /reconnect [<character>]  |  /reconnect <connection>
#: Reconnect the current, possibly as <character>, or reconnect in connection <connection>
::potato::define_slash_cmd reconnect {
  variable conn;
  variable world;

  set w $conn($c,world)
  if { $str eq "" } {
       taskRun reconnect
     } elseif { [string is integer -strict $str] && [info exists conn($str,id)] && $str > 0 } {
       taskRun reconnect $c $str
     } elseif { $str eq "none" } {
       set conn($c,char) ""
       taskRun reconnect
     } elseif { [set chars [lsearch -exact -index 0 $world($w,charList) $str]] != -1 ||
                [set chars [lsearch -exact -nocase -index 0 $world($w,charList) $str]] != -1 } {
       if { [llength $chars] != 1 } {
            return [list 0 [T "Ambiguous character name \"%s\"" $str]];
          } else {
            set conn($c,char) [lindex $world($w,charList) [list $chars 0]]
            taskRun reconnect
          }
     } else {
       return [list 0 [T "Invalid connection id/character name"]];
     }

  return [list 1];

};# /reconnect

#: /disconnect
#: Disconnect the current connection
::potato::define_slash_cmd disconnect {

  taskRun disconnect
  return [list 1];

};# /disconnect

#: /toggle [<direction>]
#: Toggle the shown connection forward/backwards one connection
::potato::define_slash_cmd toggle {

  if { $str eq "down" || $str == -1 } {
       taskRun prevConn
     } else {
       taskRun nextConn
     }
  return [list 1];

};# /toggle

#: /web <address>
#: Launch a web browser to show <address>
::potato::define_slash_cmd web {

  launchWebPage $str
  return [list 1];

};# /web

#: /history [<number>]
#: Show the history window, or place the <number>th history item into the input window
::potato::define_slash_cmd history {
  variable conn;

  if { [string trim $str] eq "" } {
       after idle [list ::potato::taskRun inputHistory $c $c]
     } elseif { [string is integer -strict [set num [string trim $str]]] } {
       if { $num < 1 } {
            if { [llength $conn($c,inputHistory)] > [expr {abs($num)}] } {
                 # use "end-abs($num)" rather than end$num in case $num is 0
                 set pos "end-[expr {abs($num)}]"
               } else {
                 return [list 0 [T "/history: Invalid position"]];
               }
          } elseif { [set pos [lsearch -index 0 $conn($c,inputHistory) $num]] == -1 } {
            return [list 0 [T "/history: Invalid position"]];
          }
       if { [focus -displayof $conn($c,input2)] eq $conn($c,input2) } {
            set input 2
          } else {
            set input 1
          }
       showInput $c $input [string map [list \b \n] [lindex $conn($c,inputHistory) $pos 1]] 1
     }

  return [list 1];

};# /history

#: proc ::potato::clearOutputWindow
#: c connection id
#: t text widget path
#: desc For conn $c, empty the text widget $t. If it's the main output window, re-print the current connection status and leave the prompt.
#: return nothing
proc ::potato::clearOutputWindow {c t} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 || ![winfo exists $t] || [winfo class $t] ne "Text" } {
       return;
     }

  if { [llength [$conn($c,textWidget) tag ranges prompt]] } {
       $t delete 1.0 prompt.first
     } else {
       $t delete 1.0 end
     }
  if { $t eq $conn($c,textWidget) } {
       if { $conn($c,connected) == 1 } {
            set status [T "Connected."]
          } elseif { $conn($c,connected) == -1 } {
            set status [T "Reconnecting..."]
          } elseif { [connInfo $c autoreconnect] && [connInfo $c autoreconnect,time] > 0 } {
            set status [T "Disconnected. Auto-reconnect in %s." [timeFmt [connInfo $c autoreconnect,time] 0]]
          } else {
            set status [T "Disconnected."]
          }
       outputSystem $c $status
     }

  return;
};# ::potato::clearOutputWindow

#: proc ::potato::cleanup_afters
#: arg c connection id
#: desc Cleanup the after IDs for conn $c's userAfterIDs var
#: return nothing
proc ::potato::cleanup_afters {c} {
  variable conn;

  if { ![info exists conn($c,userAfterIDs)] } {
       return;
     }

  set new [list]
  set all [after info]
  foreach x $conn($c,userAfterIDs) {
    if { $x in $all } {
         lappend new $x
       }
  }
  set conn($c,userAfterIDs) $new

  return;

};# ::potato::cleanup_afters

# proc ::potato::TinyURL
#: arg url The URL to shorten
#: desc Return a TinyURL'd/shortened version of $url, using the website specified in settings (like tinyurl.com)
#: return shortened url, or -error and error message on failure
proc ::potato::TinyURL {url} {
  variable misc;
  variable tinyurl;

  set type $misc(tinyurlProvider)

  if { ![info exists tinyurl($type,post)] } {
       set type "TinyURL"
     }

  if { [catch {package present http}] } {
       return -code error [T "Unable to create TinyURL: %s" [T "http package not available"]]
     }

  set post $tinyurl($type,post)
  set address $tinyurl($type,address)
  set regexp $tinyurl($type,regexp)

  set token [::http::geturl $address -query [::http::formatQuery $post $url]]
  if { [::http::ncode $token] != 200 } {
       catch {::http::cleanup $token}
       return -code error [T "Unable to create TinyURL: %s" [::http::data $token]];
     }
  if { ![regexp $regexp [::http::data $token] -> turl] } {
       catch {::http::cleanup $token}
       return -code error [T "Unable to create TinyURL: %s" [T "Unable to parse results."]];
    }
  ::http::cleanup $token

  if { [string length $url] <= [string length $turl] } {
       return $url;
     } else {
       return $turl;
     }

};# ::potato::TinyURL

#: proc ::potato::itemize
#: arg list The list to itemize
#: arg join Joining word. Defaults to "and".
#: desc Turn a list in the form [list a b c] into a string in the form "a, b $join c"
#: return Joined string
proc ::potato::itemize {list {join "and"}} {

  set num [llength $list]
  if { $num == 1 } {
       return [lindex $list 0]
     } elseif { $num == 2 } {
       return [join $list " $join "]
     } else {
       set list [lreplace $list end end "$join [lindex $list end]"]
       return [join $list ", "]
     }

};# ::potato::itemize

#: proc ::potato::timeFmt
#: arg seconds a number of seconds
#: arg full show full words instead of single letter abbreviations?
#: desc format a number of seconds into days, hours, minutes and seconds
#: return formatted result
proc ::potato::timeFmt {seconds full} {
  set timeList [list]
  if { $full } {
       # Each [T] must be on its own line, or the template-generator won't pick them all up
       set singles [list \
                     [T "day"] \
                     [T "hour"] \
                     [T "minute"] \
                     [T "second"]\
                   ]
       set plurals [list \
                     [T "days"] \
                     [T "hours"] \
                     [T "minutes"] \
                     [T "seconds"] \
                   ]
     } else {
       set singles [list \
                      [T "d"] \
                      [T "h"] \
                      [T "m"] \
                      [T "s"] \
                    ]
       set plurals $singles
     }
  foreach div {86400 3600 60 1} mod {0 24 60 60} single $singles plural $plurals {
     set n [expr {$seconds / $div}]
     if {$mod > 0} {
         set n [expr {$n % $mod}]
        }
     if { $n > 0 } {
          if { $full } {
               append n " "
             }
          if { $n > 1 } {
               append n $plural
             } else {
               append n $single
             }
          lappend timeList "$n"
        }
  }
  return [join $timeList " "];

};# ::potato::timeFmt

#: proc ::potato::up
#: desc Return the id of the connection currently being shown
#: return connection id
proc ::potato::up {} {
  variable potato;

  return $potato(up);

};# ::potato::up

#: proc ::potato::about
#: desc Show an 'about' window, showing a small amount of info about the program
#: return nothing
proc ::potato::about {} {
  variable potato;

  set win .aboutPotato
  catch {destroy $win}
  toplevel $win
  wm withdraw $win
  wm title $win [T "About %s" $potato(name)]

  pack [set frame [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw

  pack [::ttk::frame $frame.top] -side top -padx 15 -pady 15
  pack [::ttk::frame $frame.btm] -side top -padx 15 -pady 12

  set str [T "%s Version %s.\nA MU* Client written in Tcl/Tk by\nMike Griffiths (%s)" $potato(name) $potato(version) $potato(contact)]

  pack [::ttk::label $frame.top.img -image ::potato::img::logoSmall] -side left -padx 15

  pack [::ttk::frame $frame.top.right] -side right -padx 5

  set font [list {*}[font actual "TkDefaultFont"] -size 12]
  set lfont [list {*}$font -underline 1]
  pack [::ttk::label $frame.top.right.txt -text $str -justify center -font $font] -side top
  pack [::ttk::label $frame.top.right.web -text $potato(webpage) -justify center -font $lfont -foreground blue] -side top -pady 10

  bind $frame.top.right.web <Enter> [list %W configure -foreground red -cursor hand2]
  bind $frame.top.right.web <Leave> [list %W configure -foreground blue -cursor {}]
  bind $frame.top.right.web <ButtonRelease-1> [list ::potato::launchWebPage $potato(webpage)]

  pack [::ttk::button $frame.btm.close -text [T "Close"] -width 8 \
             -command [list destroy $win] -default active] -side top

  update
  center $win
  wm resizable $win 0 0
  wm deiconify $win
  wm transient $win .
  focus $frame.btm.close
  bind $win <Escape> [list $frame.btm.close invoke]

  return;

};# ::potato::about

#: proc ::potato::ddeStart
#: desc Start up a DDE server on Windows to listen for incoming telnet requests, which we'll receieve if we're the default telnet client
#: return nothing
proc ::potato::ddeStart {} {

  dde servername -handler [list ::potato::handleOutsideRequest dde] -- potatoMUClient
  return;

};# ::potato::ddeStart

#: proc ::potato::parseTelnetAddress
#: arg addr the address to parse
#: desc Attempt to parse $addr as a world address. Ignore the optional "telnet://" prefix, then attempt to match a string (host),
#: desc followed by either a space or a colon, then a group of ints (port).
#: return [list $host $port] on success, or empty [list] on failure
proc ::potato::parseTelnetAddress {addr} {

  if { [regexp -nocase -- {^ *(?:telnet://)?(.+)[: ]+([0-9]+)/? *$} $addr -> host port] } {
       return [list $host $port];
     } else {
       return [list];
     }

};# ::potato::parseTelnetAddress

#: proc ::potato::handleOutsideRequest
#: arg src where the request came from. One of "cl" (from potato.exe <address>), "clP" (from potato.exe -arg <foo>) or "dde" (from a Windows DDE server)
#: arg addr the address we've been asked to connect to
#: arg isWorld if 1, $addr is the name of a world to connect to, else it's a host and port. Defaults to 0
#: desc $addr is an address we've been asked to connect to, either via DDE on Windows or on the command line.
#: desc Attempt to do so, respecting the potato::misc(outsideRequestMethod) var
#: return nothing
proc ::potato::handleOutsideRequest {src addr {isWorld 0}} {
  variable world;
  variable misc;
  variable potato;

  # If $isWorld is 1, $addr is a world name. Else, it's either telnet://host:port, host:port or "host port".
  if { $isWorld } {
       # This is basically identical to using "/connect <world>", so we'll just trigger that.
       parseConnectRequest $addr
       return;
     }

  if { [string length $addr] < 3 } {
       # Too short to be useful. Probably a "-" from DDE when a telnet://
       # link is clicked and Potato wasn't open. Ignore silently.
       return;
     }

  # OK, let's do it the hard way...

  # Let's see if what we have is a valid host and port
  set hostAndPort [parseTelnetAddress $addr]
  if { [llength $hostAndPort] == 0 } {
       errorLog "Invalid address '$addr' from '$src'"
       bell -displayof .
       return;
     }

  foreach {host port} $hostAndPort {break}

  set conn2World -1
  if { $misc(outsideRequestMethod) == 0 } {
       # We do a quick-connect, even if a world exists with this host/port, so don't bother checking
     } else {
       # Check and see if we have a world that matches
       foreach w [worldIDs] {
          if { ![string equal -nocase $host $world($w,host)] } {
               continue;
             }
          if { $port != $world($w,port) } {
               continue;
             }
          set conn2World $w
          break;
       }
     }

  if { $conn2World > -1 && $misc(outsideRequestMethod) == 2 } {
       set ans [tk_messageBox -title $potato(name) -type yesno -message \
           [T "Would you like to use the settings for \[%s. %s\], rather than quick-connected?" $conn2World $world($conn2World,name)]]
       if { $ans ne "yes" } {
            set conn2World -1
          }
     }

  if { $conn2World == -1 } {
       # Do a quick-connect
       newConnection [addNewWorld $host:$port $host $port 1]
     } else {
       newConnectionDefault $conn2World
     }

  return;

};# ::potato::handleOutsideRequest

#: proc ::potato::parseCommandLine
#: arg argList list of args given on command line (a la $argv)
#: arg argCount number of args in argList (a la $argc)
#: desc Parse the command-line args given and attempt to process them
#: return nothing
proc ::potato::parseCommandLine {argList argCount} {

  foreach {opt value} $argList {
    if { $opt eq "" || $value eq "" } {
         continue;
       }
    if { [set length [string length $opt]] < 2 } {
         bell -displayof .
         continue;
       }
    if { [string equal -nocase -length $length $opt "-world"] } {
         handleOutsideRequest clP $value 1
       } elseif { [string equal -nocase -length $length $opt "-address"] } {
         handleOutsideRequest clP $value 0
       } else {
         bell -displayof . ;# unknown option
         continue
       }
  }

};# ::potato::parseCommandLine

#: proc ::potato::registerWindow
#: arg c connection id
#: arg win Window/widget path
#: desc Connection the window/widget $win to connection $c, so that it's destroyed when the connection to $c is closed
#: return nothing
proc ::potato::registerWindow {c win} {
  variable conn;

  if { $win ni $conn($c,widgets) } {
       lappend conn($c,widgets) $win
     }

  return;

};# ::potato::registerWindow

#: proc ::potato::unregisterWindow
#: arg c connection id
#: arg win Window/widiget path
#: desc Remove the connection between the window/widget $win and connection $c, so that $win will not be auto-destroyed when connection $c is closed
#: return nothing
proc ::potato::unregisterWindow {c win} {
  variable conn;

  if { $win ni $conn($c,widgets) } {
       return;
     }

  set pos [lsearch -exact $conn($c,widgets) $win]
  set conn($c,widgets) [lreplace $conn($c,widgets) $pos $pos]
  return;

};# ::potato::unregisterWindow

#: proc ::potato::textEditor
#: arg c connection id. Defaults to ""
#: arg edname name of editor to use, or auto-assign a numeric name if ""
#: arg initialtext If given, text to insert/append into editor window
#: desc Launch a text editor window for connection $c (or current connection if $c is "")
#: return 1 on success, 0 or failure
proc ::potato::textEditor {{c ""} {edname ""} {initialtext ""}} {
  variable potato;
  variable conn;
  variable world;

  if { $c == "" } {
       set c [up]
     }

  if { $edname eq "" } {
       set edname 1
       for {set edname 1} {$edname < 1000 && [winfo exists [set win .textEditor_${c}_$edname]]} {incr edname} {
         continue;
       }
     } else {
       set win .textEditor_${c}_$edname
     }

  if { [string first . $edname] != -1 } {
       outputSystem $c [T "Invalid editor name '%s'." $edname]
       return;
     }

  if { [winfo exists $win] } {
       # Append text to existing editor
       if { $initialtext ne "" } {
            set text $win.frame.main.text
            if { [$text count -chars 1.0 end] > 1 } {
                 $text insert end "\n"
               }
            $text insert end $initialtext
          }
       reshowWindow $win 0
       return;
     }

  if { [catch {toplevel $win}] } {
       outputSystem $c [T "Invalid editor name '%s'." $edname]
       return;
     }
  registerWindow $c $win
  wm withdraw $win
  if { $c == 0 } {
       wm title $win "TextEd $edname ($potato(name))"
     } else {
       wm title $win "TextEd $edname \[$c. $world($conn($c,world),name)\]"
     }

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both -side left -anchor nw

  pack [::ttk::frame $frame.main -relief sunken -borderwidth 2] -expand 1 -fill both -padx 1 -pady 1
  set text [text $frame.main.text -width 40 -height 20 -wrap word -undo 1]
  set sbY [::ttk::scrollbar $frame.main.sbY -orient vertical -command [list $text yview]]
  set sbX [::ttk::scrollbar $frame.main.sbX -orient horizontal -command [list $text xview]]
  $text configure -yscrollcommand [list $sbY set] -xscrollcommand [list $sbX set]
  grid_with_scrollbars $text $sbX $sbY

  set menu [menu $win.menu -tearoff 0]
  $win configure -menu $menu
  set actionMenu [menu $menu.action -tearoff 0]
  set editMenu [menu $menu.edit -tearoff 0]
  # set menuColour [menu $menu.colour -tearoff 0]
  # set menuColourBG [menu $menu.colourBG -tearoff 1]
  # set menuColourFG [menu $menu.colourFG -tearoff 1]
  $menu add cascade {*}[menu_label [T "&Action"]] -menu $actionMenu
  $menu add cascade {*}[menu_label [T "&Edit"]] -menu $editMenu

  set allTxt [format {[%s get 1.0 end-1char]} $text]
  $actionMenu add command {*}[menu_label [T "Send to &World"]] -accelerator "Ctrl+S" \
          -command [list ::potato::send_to_from $c $text]
  $actionMenu add command {*}[menu_label [T "Send &Selection to World"]] -accelerator "Ctrl+Alt+S" \
          -command [list ::potato::send_to_from $c $text 0 1]
  $actionMenu add command {*}[menu_label [T "Place in &Top Input Window"]] \
          -command [format {::potato::showInput %s 1 %s 1} $c $allTxt]
  $actionMenu add command {*}[menu_label [T "Place in &Bottom Input Window"]] \
          -command [format {::potato::showInput %s 2 %s 1} $c $allTxt]
  $actionMenu add separator
  set actionMenuConvert [menu $actionMenu.convert -tearoff 0]
  $actionMenu add cascade {*}[menu_label [T "&Convert..."]] -menu $actionMenuConvert
  # $actionMenu add cascade {*}[menu_label [T "&ANSI Colour..."] -menu $menuColour]
  $actionMenu add separator
  $actionMenu add command {*}[menu_label [T "&Open..."]] -command [list ::potato::textEditorOpen $text]
  $actionMenu add command {*}[menu_label [T "&Save As..."]] -command [list ::potato::textEditorSave $text]

  $actionMenuConvert add command {*}[menu_label [T "&Returns to %r"]] -command [list ::potato::escapeChars $text 0 1 0] -accelerator Ctrl+R
  $actionMenuConvert add command {*}[menu_label [T "Spaces to %&b"]] -command [list ::potato::escapeChars $text 0 0 1] -accelerator Ctrl+B
  $actionMenuConvert add command {*}[menu_label [T "&Escape Special Characters"]] -command [list ::potato::escapeChars $text] -accelerator Ctrl+E

  # $actionMenuConvert add comand {*}[menu_label [T "&ANSI Colours to Tags"]] -command [list ::potato::textEditorConvertANSI $text]

  # Allow for saving to a file, including hard-wrapping and auto-indenting! #abc
  # Do ANSI Colour conversion stuff! #abc

  $editMenu add command {*}[menu_label [T "&Copy"]] -command [list event generate $text <<Copy>>] -accelerator Ctrl+C
  $editMenu add command {*}[menu_label [T "C&ut"]] -command [list event generate $text <<Cut>>] -accelerator Ctrl+X
  $editMenu add command {*}[menu_label [T "&Paste"]] -command [list event generate $text <<Paste>>] -accelerator Ctrl+V
  $editMenu configure -postcommand [list ::potato::editMenuCXV $editMenu 0 1 2 $text]

  bind $text <Control-r> "[list ::potato::escapeChars $text 0 1 0] ; break"
  bind $text <Control-b> "[list ::potato::escapeChars $text 0 0 1] ; break"
  bind $text <Control-e> "[list ::potato::escapeChars $text] ; break"

  bind $text <Control-s> "[list $actionMenu invoke 0] ; break"
  bind $text <Control-Alt-s> "[list $actionMenu invoke 1] ; break"

  $text insert end $initialtext

  update idletasks
  center $win
  reshowWindow $win 0
  focus $text

  return;

};# ::potato::textEditor

#: proc ::potato::textEditorOpen
#: arg text Path to a text widget
#: desc Show an Open File dialog, and open the selected file into the text widget
#: return nothing
proc ::potato::textEditorOpen {text} {


  set file [tk_getOpenFile -filetypes [list {{Text Files} {*.txt}} {{All Files} {*.*}}] -parent $text]
  if { $file eq "" } {
       return;
     }
  if { [catch {open $file r} fid] } {
       tk_messageBox -icon error -title [T "Open File"] -type ok -parent $text -message [T "Unable to open \"%s\": %s" $file $fid]
       return;
     }
  $text replace 1.0 end [read $fid]
  close $fid

  return;

};# ::potato::textEditorOpen

#: proc ::potato::textEditorSave
#: arg text Path to text widget
#: desc Show a Save File dialog, and put the contents of $text into the selected file
#: return nothing
proc ::potato::textEditorSave {text} {

  if { $::tcl_platform(platform) eq "windows" } {
       set de ".txt"
     } else {
       set de ""
     }
  set file [tk_getSaveFile -filetypes  [list {{Text Files} {*.txt}} {{All Files} {*.*}}] -defaultextension $de -parent $text]
  if { $file eq "" } {
       return;
     }
  if { [catch {open $file w} fid] } {
       tk_messageBox -icon error -title [T "Save File"] -type ok -parent $text -message [T "Unable to save to \"%s\": %s" $file $fid]
       return;
     }
  puts -nonewline $fid [$text get 1.0 end-1char]
  close $fid

  return;

};# ::potato::textEditorSave

#: proc ::potato::escapeChars
#: arg win path to text widget
#: arg specials
#: arg newlines Convert newlines to "%r"? Defaults to 0
#: desc Replace all MUSH-special chars in text widget $win with escaped equivilents. Wrapper around textFindAndReplace.
#: return nothing
proc ::potato::escapeChars {win {specials 1} {newlines 0} {spaces 0}} {

  set charmap [list]

  if { $specials } {
       foreach x [list 37 59 91 93 40 41 44 94 36 123 125 92] {
         lappend charmap [format %c $x] "\\[format %c $x]"
       }
       lappend charmap "\t" "%t"
     }

  if { $newlines } {
       lappend charmap "\n" "%r"
     }

  if { $spaces } {
       lappend charmap "  " " %b"
     }

  if { $win eq "" } {
       set win [connInfo "" input3]
     }

  textFindAndReplace $win $charmap

  return;

};# ::potato::escapeChars

#: proc ::potato::textFindAndReplace
#: arg win path to text widget
#: arg chars a list of chars to find and replace, in the form [list find0 replace0 findN replaceN]
#: desc Replace characters in the text widget $win from the char map in $chars
#: return nothing
proc ::potato::textFindAndReplace {win chars} {

  $win replace 1.0 end [string map $chars [$win get 1.0 end-1char]]

  return;

};# ::potato::textFindAndReplace

#: proc ::potato::toggleInputWindows
#: arg c connection id. Defaults to ""
#: arg toggle Should we twiddle the var? This is not needed if called from a checkbutton item (as checkbuttons alter the variable before calling the -command), but is needed if called from a /command, etc. Defaults to 1.
#: desc Toggle between 1 and 2 input windows for connection $c (or currently displayed conn, if $c is ""). If $toggle is true, alter the conn($c,twoInputWindows) variable first.
#: return nothing
proc ::potato::toggleInputWindows {{c ""} {toggle 1}} {
  variable conn;
  variable potato;

  if { $c eq "" } {
       set c [up]
     }

  if { $toggle } {
       set conn($c,twoInputWindows) [lindex [list 1 0] $conn($c,twoInputWindows)]
     }
  ::skin::$potato(skin)::inputWindows $c [expr {$conn($c,twoInputWindows) + 1}]

  return;

};# ::potato::toggleInputWindows

#: proc ::potato::connectMenuPost
#: arg x X-coord for posting menu. Defaults to 0
#: arg y Y-coord for posting menu. Defaults to 0.
#: desc Post the "Connect To.." menu at the given coordinates (or at cursor if both are 0)
#: return nothing
proc ::potato::connectMenuPost {{x 0} {y 0}} {
  variable menu;

  $menu(connect,path) unpost

  if { $x == 0 && $y == 0 } {
       foreach {x y} [winfo pointerxy .] {break}
     }
  catch {tk_popup $menu(connect,path) $x $y}

};# ::potato::connectMenuPost

#: proc ::potato::rebuildConnectMenu
#: arg m menu width path
#: desc Rebuild menu $m with commands for connecting to each world. Called when menu is posted.
#: return nothing
proc ::potato::rebuildConnectMenu {m} {
  variable world;

  $m delete 0 end
  destroy {*}[winfo children $m]

  foreach w [worldIDs] {
     if { [llength $world($w,groups)] == 0 } {
          lappend noGroups [list $w $world($w,name)]
        } else {
          foreach y $world($w,groups) {
            lappend group($y) [list $w $world($w,name)]
          }
        }
  }

  set sep 0

  if { [array exists group] } {
       set sep 1
       set i 0
       foreach x [lsort -dictionary [array names group]] {
          $m add cascade -label $x -menu [set sub [menu $m.sub$i -tearoff 0]]
          foreach y [lsort -dictionary -index 1 $group($x)] {
             foreach {w name} $y {break}
             rebuildConnectMenuSub $w $name $sub
          }
          incr i
       }
     }
  if { [info exists noGroups] } {
       set sep 1
       foreach x [lsort -dictionary -index 1 $noGroups] {
          foreach {w name} $x {break}
          rebuildConnectMenuSub $w $name $m
       }
     }

  if { $sep } {
       $m add separator
     }

  $m add command -label [T "Quick Connect"] -command [list ::potato::newWorld 1]

  return;

};# ::potato::rebuildConnectMenu

#: proc ::potato::rebuildConnectMenuSub
#: arg w world id
#: arg name world name
#: arg m menu widget
#: desc Add a menu to $m which either connects to world $w (if it has no chars defined), or cascades to a menu of chars (if it does)
#: return nothing
proc ::potato::rebuildConnectMenuSub {w name m} {
  variable world;

  if { [llength $world($w,charList)] } {
       $m add cascade -label $name -menu [set sub [menu $m.$w -tearoff 0]]
       set def $world($w,charDefault)
       if { $def eq "" } {
            set def [T "None"]
          }
       $sub add command {*}[menu_label [T "&Default Character (%s)" $def]] -command [list ::potato::newConnectionDefault $w]
       $sub add command {*}[menu_label [T "&No Character"]] -command [list ::potato::newConnection $w]
       $sub add separator
       foreach x $world($w,charList) {
         set char [lindex $x 0]
         $sub add command -label $char -command [list ::potato::newConnection $w $char]
       }
     } else {
       $m add command -label $name -command [list ::potato::newConnection $w]
     }
  return;
};# ::poato::rebuildConnectMenuSub

#: proc ::potato::fcmd
#: arg num F-command number
#: arg c Connection id. Defaults to ""
#: desc Send the stored F-command $num to connection $c (or the current connection if $c is ""). If $c's world has no command for F$num, use the global
#: return nothing
proc ::potato::fcmd {num {c ""}} {
  variable conn;
  variable world;

  if { $c eq "" } {
       set c [up]
     }

  set w $conn($c,world)
  if { [set cmd $world($w,fcmd,$num)] ne "" } {
       # continue, this world has an
     } elseif { $w != -1 && [string trim [set cmd $world(-1,fcmd,$num)]] ne "" } {
       # continue, use -1's command
     } else {
       return; # no command
     }

  addToInputHistory $c $cmd
  send_to $c $cmd

  return;

};# ::potato::fcmd

#: proc ::potato::tasksInit
#: desc Initialise the list of tasks which can be keyboard-bound, appear in menus, etc.
#: return Nothing
proc ::potato::tasksInit {} {
  variable tasks;

  # Set map of task names and commands
  array set tasks [list \
       inputHistory,name   [X "Show Input &History Window"] \
       inputHistory,cmd    "::potato::history" \
       inputHistory,state  notZero \
       goNorth,name        [X "Go &North"] \
       goNorth,cmd         [list ::potato::send_to_real {} north] \
       goNorth,state       connected \
       goSouth,name        [X "Go &South"] \
       goSouth,cmd         [list ::potato::send_to_real {} south] \
       goSouth,state       connected \
       goEast,name         [X "Go &East"] \
       goEast,cmd          [list ::potato::send_to_real {} east] \
       goEast,state        connected \
       goWest,name         [X "Go &West"] \
       goWest,cmd          [list ::potato::send_to_real {} west] \
       goWest,state        connected \
       find,name           [X "&Find"] \
       find,cmd            "::potato::findDialog" \
       find,state          notZero \
       disconnect,name     [X "&Disconnect"] \
       disconnect,cmd      "::potato::disconnect" \
       disconnect,state    {$c != 0 && ($conn($c,connected) != 0 || ($conn($c,connected) == 0 && $conn($c,reconnectId) ne ""))} \
       reconnect,name      [X "&Reconnect"] \
       reconnect,cmd       "::potato::reconnect" \
       reconnect,state     {$c != 0 && $conn($c,connected) == 0} \
       reconnectAll,name   [X "Reconnect All"] \
       reconnectAll,cmd    "::potato::reconnectAll" \
       reconnectAll,state  {[llength [connIDs]] != 0} \
       close,name          [X "&Close Connection"] \
       close,cmd           "::potato::closeConn" \
       close,state         notZero \
       nextConn,name       [X "&Next Connection"] \
       nextConn,cmd        [list ::potato::toggleConn 1] \
       nextConn,state      {[llength [connIDs]] > 1} \
       prevConn,name       [X "&Previous Connection"] \
       prevConn,cmd        [list ::potato::toggleConn -1] \
       prevConn,state      {[llength [connIDs]] > 1} \
       config,name         [X "Configure &World"] \
       config,cmd          "::potato::configureWorld" \
       config,state        notZero \
       programConfig,name  [X "Configure Program &Settings"] \
       programConfig,cmd   [list ::potato::configureWorld -1] \
       programConfig,state always \
       events,name         [X "Configure &Events"] \
       events,cmd          "::potato::eventConfig" \
       events,state        notZero \
       globalEvents,name   [X "&Global Events"] \
       globalEvents,cmd    [list ::potato::eventConfig -1] \
       globalEvents,state  always \
       slashCmds,name      [X "Customise &Slash Commands"] \
       slashCmds,cmd       "::potato::slashConfig" \
       slashCmds,state     notZero \
       globalSlashCmds,name [X "Global S&lash Commands"] \
       globalSlashCmds,cmd [list ::potato::slashConfig -1] \
       globalSlashCmds,state always \
       log,name            [X "Show &Log Window"] \
       log,cmd             "::potato::logWindow" \
       log,state           notZero \
       logStop,name        [X "Close &All Logs"] \
       logStop,cmd         "::potato::stopLog" \
       logStop,state       {[llength [array names ::potato::conn $c,log,*]] > 0} \
       upload,name         [X "&Upload File"] \
       upload,cmd          "::potato::uploadWindow" \
       upload,state        always \
       help,name           [X "Show &Helpfiles"] \
       help,cmd            "::wikihelp::help" \
       help,state          always \
       about,name          [X "&About Potato"] \
       about,cmd           "::potato::about" \
       about,state         always \
       exit,name           [X "E&xit"] \
       exit,cmd            "::potato::chk_exit" \
       exit,state          always \
       textEd,name         [X "&Text Editor"] \
       textEd,cmd          "::potato::textEditor" \
       textEd,state        always \
       twoInputWins,name   [X "Show Two Input Windows?"] \
       twoInputWins,cmd    "::potato::toggleInputWindows" \
       twoInputWins,state  always \
       connectMenu,name    [X "&Connect To..."] \
       connectMenu,cmd     "::potato::connectMenuPost" \
       connectMenu,state   always \
       customKeyboard,name [X "Customise Keyboard Shortcuts"] \
       customKeyboard,cmd  "::potato::keyboardShortcutWin" \
       customKeyboard,state always \
       mailWindow,name     [X "Open &Mail Window"] \
       mailWindow,cmd      "::potato::mailWindow" \
       mailWindow,state    notZero \
       prevHistCmd,name    [X "Previous History Command"] \
       prevHistCmd,cmd     "::potato::inputHistoryScroll -1" \
       prevHistCmd,state   always \
       nextHistCmd,name    [X "Next History Command"] \
       nextHistCmd,cmd     "::potato::inputHistoryScroll 1" \
       nextHistCmd,state   always \
       escHistCmd,name     [X "Clear History Command"] \
       escHistCmd,cmd      "::potato::inputHistoryReset" \
       escHistCmd,state    always \
       manageWorlds,name   [X "&Address Book"] \
       manageWorlds,cmd    "::potato::manageWorlds" \
       manageWorlds,state  always \
       autoConnects,name   [X "Manage &Auto-Connects"] \
       autoConnects,cmd    "::potato::autoConnectWindow" \
       autoConnects,state  always \
       fcmd2,name          [X "Run F2 Command"] \
       fcmd2,state         always \
       fcmd2,cmd           "::potato::fcmd 2" \
       fcmd3,name          [X "Run F3 Command"] \
       fcmd3,state         always \
       fcmd3,cmd           "::potato::fcmd 3" \
       fcmd4,name          [X "Run F4 Command"] \
       fcmd4,state         always \
       fcmd4,cmd           "::potato::fcmd 4" \
       fcmd5,name          [X "Run F5 Command"] \
       fcmd5,state         always \
       fcmd6,name          [X "Run F6 Command"] \
       fcmd5,cmd           "::potato::fcmd 5" \
       fcmd6,state         always \
       fcmd6,cmd           "::potato::fcmd 6" \
       fcmd7,name          [X "Run F7 Command"] \
       fcmd7,state         always \
       fcmd7,cmd           "::potato::fcmd 7" \
       fcmd8,name          [X "Run F8 Command"] \
       fcmd8,state         always \
       fcmd8,cmd           "::potato::fcmd 8" \
       fcmd9,name          [X "Run F9 Command"] \
       fcmd9,state         always \
       fcmd9,cmd           "::potato::fcmd 9" \
       fcmd10,name         [X "Run F10 Command"] \
       fcmd10,state        always \
       fcmd10,cmd          "::potato::fcmd 10" \
       fcmd11,name         [X "Run F11 Command"] \
       fcmd11,state        always \
       fcmd11,cmd          "::potato::fcmd 11" \
       fcmd12,name         [X "Run F12 Command"] \
       fcmd12,state        always \
       fcmd12,cmd          "::potato::fcmd 12" \
       spellcheck,name     [X "Check &Spelling"] \
       spellcheck,cmd      "::potato::spellcheck" \
       spellcheck,state    {[file exists $::potato::misc(aspell)]} \
       macroWindow,name    [X "&Macro Window"] \
       macroWindow,cmd     "::potato::macroWindow" \
       macroWindow,state   notZero \
       globalMacros,name   [X "Global &Macro Window"] \
       globalMacros,cmd    "::potato::macroWindow -1" \
       globalMacros,state  always \
       convertNewlines,name [X "Convert &Returns to %r"] \
       convertNewlines,cmd  [list ::potato::escapeChars "" 0 1 0] \
       convertNewlines,state always \
       convertSpaces,name  [X "Convert &Spaces to %b"] \
       convertSpaces,cmd   [list ::potato::escapeChars "" 0 0 1] \
       convertSpaces,state always \
       convertChars,name   [X "&Escape Special Chars"] \
       convertChars,cmd    [list ::potato::escapeChars ""] \
       convertChars,state  always \
       save2history,name   [X "Save to Input History"] \
       save2history,cmd    [list ::potato::send_mushage "" 1] \
       save2history,state  notZero \
       toggleInputFocus,name   [X "Toggle &Input Windows"] \
       toggleInputFocus,cmd    [list ::potato::toggleInputFocus] \
       toggleInputFocus,state  always \
       insertNewline,name  [X "Insert Newline"] \
       insertNewline,cmd   [list ::potato::insertNewline] \
       insertNewline,state always \
       pickLocale,name     [X "Change &Language"] \
       pickLocale,cmd      [list ::potato::pickLocale] \
       pickLocale,state    always \
       resendLastCmd,name  [X "&Resend Last Command"] \
       resendLastCmd,cmd   [list ::potato::resendLastCmd] \
       resendLastCmd,state connected \


  ]

  return;

};# ::potato::tasksInit

#: proc ::potato::taskExists
#: arg task Task name
#: desc Does the given task exist?
#: return 1 or 0
proc ::potato::taskExists {task} {
  variable tasks;

  if { [info exists tasks($task,state)] && [info exists tasks($task,name)] && [info exists tasks($task,state)] } {
       return 1;
     } else {
       return 0;
     }

};# ::potato::taskExists

#: proc ::potato::taskAccelerator
#: arg task Task name
#: desc Return the accelerator (ie, human-readable short-form keyboart shortcut) for $task
#: return Accelerator string
proc ::potato::taskAccelerator {task} {
  variable keyShorts;

  if { [info exists keyShorts($task)] && $keyShorts($task) ne "" } {
       return [keysymToHuman $keyShorts($task) 1];
     } else {
       return "";
     }

};# ::potato::taskAccelerator

#: proc ::potato::taskVars
#: arg task Task name to return the vars for
#: desc If $task has vars associated with it (ie, is a boolean-var'd task), return them.
#: return A list of the task details, if they exist, or an empty string
proc ::potato::taskVars {task} {
  variable tasks;

  if { [info exists tasks($task,vars)] } {
       return $tasks($task,vars);
     } else {
       return;
     }

};# ::potato::taskVars

#: proc ::potato::taskState
#: arg task Task name to query/change state of
#: arg c Connection id, or "" for current connection
#: desc Return the current state of $task for connection $c.
#: return The state of $task
proc ::potato::taskState {task {c ""}} {
  variable tasks;
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { ![taskExists $task] } {
       return 0; # unknown task
     }

  switch $tasks($task,state) {
     always    {return 1;}
     notZero   {return [expr {$c != 0}];}
     connected {return [expr {$c != 0 && $conn($c,connected) == 1}];}
     default   {return [expr $tasks($task,state)];}
  }

};# ::potato::taskState

#: proc ::potato::taskRun
#: arg task Task name to run
#: arg c connection to run task for, or "" for current, for state-checking
#: arg args Additional args to pass the task
#: desc Run the command associated with the task $task for connection $c, or the currently viewed connection if $c is ""
#: return The return value of running the command.
proc ::potato::taskRun {task {c ""} args} {
  variable tasks;

  if { ![taskExists $task] } {
       return;# invalid task
     }

  if { ![taskState $task $c] } {
       bell;
       return;
     }

  return [uplevel 1 $tasks($task,cmd) $args];

};# ::potato::taskRun

#: proc ::potato::taskLabel
#: arg task Task name to return the label of
#: arg menu Return the label for a menu entry? Defaults to 0
#: desc Return the text label for task $task. If $menu, include the & to show which letter to underline in a menu entry.
#: return The task label
proc ::potato::taskLabel {task {menu 0}} {
  variable tasks;

  if { ![taskExists $task] } {
       return;
     }

  if { $menu } {
       return [T $tasks($task,name)];
     } else {
       return [string map [list & ""] [T $tasks($task,name)]];
     }

};# ::potato::taskLabel

#: proc ::potato::toggleInputFocus
#: arg c connection id, defaults to ""
#: desc Toggle between the two input windows for connection $c, or the current connection if "". If neither currently has focus, move to input 1.
#: return nothing
proc ::potato::toggleInputFocus {{c ""}} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { [focus -displayof $conn($c,input1)] eq $conn($c,input1) } {
       set new $conn($c,input2)
     } else {
       set new $conn($c,input1)
     }
   focus $new;

   return;

};# ::potato::toggleInputFocus

#: proc ::potato::spellcheck
#: desc Launch the spellchecker for the current input window. Note: the actual spellchecking code is in
#: desc potato-spell.tcl, this simply launches it with the correct text and processes the result.
#: return nothing
proc ::potato::spellcheck {} {

  set widget [connInfo [up] input3]
  set text [$widget get 1.0 end-1c]
  if { [string trim $text] eq "" } {
       bell -displayof .
       return;
     }
  set result [::potato::spellcheck::spellcheck $text]
  if { [lindex $result 0] } {
       $widget replace 1.0 end-1c [lindex $result 1]
     }

};# ::potato::spellcheck

#: proc ::potato::glob2Regexp
#: arg pattern A glob pattern
#: desc Convert the glob (wildcard) pattern $pattern into a similar regexp
#: return A regexp
proc ::potato::glob2Regexp {pattern} {

  regsub -all {([^a-zA-Z0-9?*])} $pattern {\\\1} temp
  set temp [string map [list "?" "(.)" "*" "(.*?)"] $temp]

  return "^$temp\$";

};# ::potato::glob2Regexp

#: proc ::potato::resendLastCmd
#: arg c connection id
#: desc Resend the last command from the command history for conn $c to the MUSH
#: return 1 on success, 0 on failure
proc ::potato::resendLastCmd {{c ""}} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 } {
       return 0;
     }

  if { ![info exists conn($c,inputHistory)] || $conn($c,inputHistory,count) == 0 || \
       [llength $conn($c,inputHistory)] == 0 } {
       return 0;
     }

  set cmd [lindex $conn($c,inputHistory) end 1]
  send_to $c $cmd

  return 1;

};# ::potato::resendLastCmd

#: proc ::potato::inputHistoryScroll
#: arg dir Direction to scroll, either -1 (older commands), or 1 (newer commands)
#: arg Win Window to do stuff in. Defaults to ""
#: desc Scroll the text in the input window $win (or the window with focus if $win is "") to show the
#: desc prev/next input history command. If window with focus isn't an input window, do nothing
#: return nothing
proc ::potato::inputHistoryScroll {dir {win ""}} {
  variable conn;
  variable inputSwap;

  if { $win eq "" } {
       set win [focus -displayof .]
     }
  if { $win eq "" ||  "PotatoInput" ni [bindtags $win] } {
       bell -displayof $win
       return;
     }
  if { ![info exists inputSwap($win,conn)] } {
       # bell -displayof .
       return;
     }
  set c $inputSwap($win,conn)
  if { ![info exists conn($c,inputHistory)] || $conn($c,inputHistory,count) == 0 || \
       [llength $conn($c,inputHistory)] == 0 } {
       bell -displayof $win
       return;
     }

  # Find the new input history we want.
  if { $inputSwap($win,count) == -1 } {
       if { $dir == 1 } {
            bell -displayof $win
            return;
          } else {
            foreach {index cmd} [lindex $conn($c,inputHistory) end] {break}
            set cmd [string map [list \b \n] $cmd]
          }
     } elseif { $dir == 1 && [lindex $conn($c,inputHistory) end 0] == $inputSwap($win,count) } {
       set index -1
       set cmd $inputSwap($win,backup)
     } else {
       set index [expr {$inputSwap($win,count) + $dir}]
       if { [set pos [lsearch -exact -integer -sorted -index 0 $conn($c,inputHistory) $index]] == -1 } {
            bell -displayof $win
            return;
          }
       foreach {index cmd} [lindex $conn($c,inputHistory) $pos] {break}
       set cmd [string map [list \b \n] $cmd]
     }

  if { $inputSwap($win,count) == -1 } {
       set inputSwap($win,backup) [$win get 1.0 end-1char]
     } elseif { $index == -1 } {
       set inputSwap($win,backup) ""
     }
  $win replace 1.0 end $cmd
  after idle [list $win mark set insert end-1c]
  set inputSwap($win,count) $index

  return;

};# ::potato::inputHistoryScroll

#: proc ::potato::inputHistoryReset
#: arg Win Window to do stuff in. Defaults to ""
#: desc If input window $win (or the window with focus if $win is "") is showing an input history
#: desc cmd, reset it to the stored cmd. If window with focus isn't an input window, do nothing
#: return nothing
proc ::potato::inputHistoryReset {{win ""}} {
  variable inputSwap;

  if { $win eq "" } {
       set win [focus -displayof .]
     }
  if { ![info exists inputSwap($win,conn)] } {
       $win delete 1.0 end
       return;
     }
  if { $inputSwap($win,count) == -1 } {
       $win delete 1.0 end
       return;
     }
  $win replace 1.0 end $inputSwap($win,backup)
  set inputSwap($win,count) -1

  return;

};# ::potato::inputHistoryReset

#: proc ::potato::setPrompt
#: arg c connection id
#: arg prompt Prompt to set
#: desc Set the prompt for a connection
#: return nothing
proc ::potato::setPrompt {c prompt} {
  variable conn;

  # ANSI-less version
  set hasAnsi [regsub -all {\x1B.*?m} $prompt "" noAnsi]
  if { $noAnsi eq "" } {
       set conn($c,prompt) ""
     } else {
       set conn($c,prompt) "  -   $noAnsi"
     }
  set existing [llength [$conn($c,textWidget) tag ranges prompt]]
  set t $conn($c,textWidget)
  if { $prompt eq "" } {
       if { $existing } {
            $t delete prompt.first prompt.last
          }
     } else {
       set aE [atEnd $t]
       if { $hasAnsi } {
            # We need to parse out the ANSI. Le sigh
            set ansi($c,ansi,fg) fg
            set ansi($c,ansi,bg) bg
            set ansi($c,ansi,flash) 0
            set ansi($c,ansi,underline) 0
            set ansi($c,ansi,highlight) 0
            set ansi($c,ansi,inverse) 0
            set inserts [flattenParsedANSI [parseANSI $prompt ansi $c] [list prompt margins]]
          } else {
            set inserts [list "$prompt" [list prompt margins]]
          }
       set inserts [concat [list "\n> " [list prompt margins]] $inserts [list [clock seconds] [list prompt timestamp]]]
       if { $existing } {
            $t replace prompt.first prompt.last {*}$inserts
          } else {
            $t insert end {*}$inserts
          }
       if { $aE } {
            $t see end
          }
     }

  return;

};# ::potato::setPrompt

#: proc ::potato::T
#: arg msgformat A message format string to pass to msgcat
#: arg args Args to insert into the message format string
#: desc This is a wrapper func for using msgcat to translate Potato's messages
#: return A localized string
proc ::potato::T {msgformat args} {

  if { [catch {::msgcat::mc $msgformat {*}$args} i18n] } {
       errorLog "Unable to format message for translation: $i18n" error
       if { [llength $args] && ![catch {format $msgformat {*}$args} formatted] } {
            return $formatted;
          } else {
            return $msgformat;
          }
     } else {
       return $i18n;
     }

};# ::potato::T

#: proc ::potato::X
#: arg msgformat
#: desc Returns $msgformat. Used for tagging messages which are translatable, but which should not be instantly translated like "T" does.
#: returns $msgformat
proc ::potato::X {msgformat} {

  return $msgformat;

};# ::potato::X

namespace eval ::potato {
  namespace export T
  namespace export X
}

#: proc ::potato::loadSubFiles
#: arg dir directory to load from
#: desc Because Cheetah won't quit bugging me about tidying up the source,
#: desc load bits of Potato from other files in $dir
proc ::potato::loadSubFiles {dir} {

  foreach x [list events config] {
    if { [catch {source [file join $dir "potato-$x.tcl"]} err errdict] } {
         set file [file nativename [file normalize [file join $dir "potato-$x.tcl"]]]
         set msg "Unable to load required file $file:\n$err\n";
         set trace [errorTrace $errdict]
         if { $trace ne "" } {
              append msg "$trace\n"
            }
         append msg "Please make sure your Potato installation is complete, and feel free \n"
         append msg "to blame Cheetah, who bugged me to split potato.tcl into more files."
         tk_messageBox -icon error -title Potato -message $msg
         exit;
       }
  }

  package provide potato-subfiles 1.0

};# ::potato::loadSubFiles

#: proc ::potato::basic_reqs
#: desc Load the basic requirements for Potato - ensure we have a sufficient Tcl and Tk version, required packages, etc
#: return nothing
proc ::potato::basic_reqs {} {
  variable potato;

  if { [catch {package require Tk 8.5}] } {
       if { [catch {package require Tk}] } {
            # No Tk -at all-
            puts "WARNING! Potato is a graphical client, and requires Tk version 8.5. Please"
            puts "install Tk before trying to run Potato, or download a binary of Potato from"
            puts "the website at $potato(webpage)"
          } else {
            # We have Tk, but not a good enough version
            set msg "WARNING! Potato requires Tk 8.5 to run (you only have Tk [package version Tk]).\n"
            append msg "Please install a newer version of Tk, or download a binary of Potato from\n"
            append msg "the website ($potato(webpage)) which includes everything you need."
            tk_messageBox -icon error -title "Potato" -message $msg -type ok
          }
        exit;
     }

  if { [catch {package require Tcl 8.5}] } {
       puts "WARNING! You need to be using at least Tcl 8.5 to run Potato (you only have [package version Tcl])."
       puts "Please download a newer version of Tcl, or download a binary of Potato from"
       puts "the website ($potato(webpage)) which includes everything you need."
       exit;
     }

  # OK, that's Tcl and Tk sorted. Now let's load in the other parts of Potato from separate
  # files. These really shouldn't be an issue....

  if { [catch {
               package require potato-telnet 1.1 ;
               package require potato-proxy 1.2 ;
               package require potato-wikihelp ;
               package require potato-font ;
               package require potato-spell ;
               package require potato-encoding ;
               package require potato-subfiles ;
              } err] } {
        set msg "WARNING! Your Potato installation appears to be corrupt or incomplete -\n"
        append msg "you are missing part of the Potato code. Please re-download Potato from\n"
        append msg "the website ($potato(webpage)), and contact the author if you have\n"
        append msg "any further problems."
        tk_messageBox -icon error -title "Potato" -type ok -message $msg
        tk_messageBox -icon error -title "Potato" -type ok -message "Error: $err"
        exit;
     }

  # Hooray, all good.

  return;

};# ::potato::basic_reqs

#: proc ::potato::pspinbox
#: arg args List of arguments
#: desc Wrapper function. Try and create a ttk::spinbox with the given args. Failing that, fall back on a basic Tk spinbox
#: return widget path
proc ::potato::pspinbox {args} {

  if { [catch {::ttk::spinbox {*}$args} sb] } {
       return [spinbox {*}$args];
     } else {
       return $sb;
     }
}

#########################
# Things below this line are temporary. #abc

# "ffe [<connection>]" fixes the fileevent for <connection> when it's automatically disabled due to get_mushage throwing an error.
proc ffe {{c ""}} {

  if { $c eq "" } {
       set c [::potato::up]
     }
  fileevent $potato::conn($c,id) readable [list ::potato::get_mushage $c]

};# ffe

proc winover {} {

  return [winfo containing {*}[winfo pointerxy .]];

}



##################################
# Run it!

if { [info exists ::potato::running] && $potato::running } {
     return;
   }

::potato::main

#
#########################
proc parray {a args} {

  set nargs [llength $args]
  if { $nargs > 2 } {
       return -code error "Wrong # of arguments. Should be parray array ?type? ?pattern?"
     }
  upvar 1 $a array
  if { ![array exists array] } {
       error "\"$a\" isn't an array"
     }
  set maxl 0
  set names [lsort [array names array {*}$args]]
  foreach name $names {
    if { [string length $name] > $maxl } {
         set maxl [string length $name]
       }
  }
  set maxl [expr {$maxl + [string length $a] + 2}]
  foreach name $names {
    set nameString [format %s(%s) $a $name]
    puts stdout [format "%-*s = %s" $maxl $nameString $array($name)]
  }

}

if { $tcl_platform(platform) eq "windows" } {
     parray potato::world -regexp {^[0-9]+,name$}
     if { !$::potato::potato(wrapped) && [info exists ::potato::winico(mainico)] && [file exists $::potato::winico(mainico)] } {
          rename toplevel _realtoplevel
          proc toplevel {t args} {
            uplevel 1 _realtoplevel $t {*}$args
            after idle [list catch [list wm iconbitmap $t $::potato::winico(mainico)]]
            return $t;
          }
          wm iconbitmap . $::potato::winico(mainico)
        }
   }
