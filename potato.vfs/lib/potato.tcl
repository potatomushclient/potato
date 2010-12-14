package provide app-potato 2.0.0

namespace eval ::potato {}
namespace eval ::potato::img {}
namespace eval ::skin {}

#: proc ::potato::setPrefs
#: arg readfile load prefs from file?
#: desc set default preferences and, if $readfile is true, load user prefs from file
#: return nothing
proc ::potato::setPrefs {readfile} {
  variable potato;
  variable world;
  variable path;
  variable misc;
  variable keyShorts;

  # START DEFAULT WORLD SETTINGS
  # default ansi colors
  set world(-1,ansi,fgh) #dfdfdf
  set world(-1,ansi,fg)  #aeaeae
  set world(-1,ansi,rh)  #ff0000
  set world(-1,ansi,r)   #800000
  set world(-1,ansi,gh)  #00ff00
  set world(-1,ansi,g)   #008000
  set world(-1,ansi,bh)  #0000ff
  set world(-1,ansi,b)   #000080
  set world(-1,ansi,yh)  #ffff00
  set world(-1,ansi,y)   #808000
  set world(-1,ansi,mh)  #ff00ff
  set world(-1,ansi,m)   #800080
  set world(-1,ansi,ch)  #00ffff
  set world(-1,ansi,c)   #008080
  set world(-1,ansi,wh)  #ffffff
  set world(-1,ansi,w)   #c0c0c0
  set world(-1,ansi,xh)  #808080
  set world(-1,ansi,x)   #222222
  set world(-1,ansi,system) #ffff00
  set world(-1,ansi,echo) #0000ffff8800
  set world(-1,ansi,link) #4848ff

  # which kinds of ansi are allowed by default
  set world(-1,ansi,flash) 0
  set world(-1,ansi,underline) 1
  set world(-1,ansi,colours) 1
  set world(-1,ansi,force-normal) 0

  # Defaults about the world
  set world(-1,name) "New World"
  set world(-1,id) -1
  set world(-1,host) ""
  set world(-1,port) "4201"
  set world(-1,ssl) 0
  set world(-1,host2) ""
  set world(-1,port2) "4201"
  set world(-1,ssl2) 0
  set world(-1,charList) [list]
  set world(-1,charDefault) ""
  set world(-1,description) ""
  set world(-1,loginStr) {connect %s %s}
  set world(-1,loginDelay) 1.5
  set world(-1,type) "MUD"
  set world(-1,telnet) 1
  set world(-1,telnet,ssl) 0
  set world(-1,telnet,naws) 1
  set world(-1,telnet,term) 1
  set world(-1,telnet,term,as) ""
  set world(-1,encoding,start) iso8859-1
  set world(-1,encoding,negotiate) 1
  set world(-1,groups) [list]

  set world(-1,proxy) "None"
  set world(-1,proxy,host) ""
  set world(-1,proxy,port) ""

  set world(-1,echo) 0
  set world(-1,ignoreEmpty) 0

  set world(-1,outputLimit,on) 0
  set world(-1,outputLimit,to) 500
  set world(-1,spawnLimit,on) 1
  set world(-1,spawnLimit,to) 250
  set world(-1,inputLimit,on) 1
  set world(-1,inputLimit,to) 250
  set world(-1,splitInputCmds) 0

  set world(-1,beep,show) 1
  set world(-1,beep,sound) "All" ;# All, Once or None

  set world(-1,temp) 0
  set world(-1,autoconnect) -1

  set world(-1,top,font) TkFixedFont
  set world(-1,top,bg) #000000
  set world(-1,bottom,font) TkFixedFont
  set world(-1,bottom,bg) #000000
  set world(-1,bottom,fg) #ffffff


  set world(-1,wrap,at) 78
  set world(-1,wrap,indent) 2

  set world(-1,convertNonBreakingSpaces) 1

  set world(-1,spawnSystem) 1

  set world(-1,autoreconnect) 1
  set world(-1,autoreconnect,time) 330

  set world(-1,stats,conns) 0
  set world(-1,stats,time) 0
  set world(-1,stats,added) 1167682020

  set world(-1,notes) ""
  set world(-1,mailFormat) "MUSH @mail"
  set world(-1,mailFormat,custom) "writeto %to% %cc% %bcc% about %subject% ;; write %body% ;; send"
  set world(-1,mailConvertReturns) 1
  set world(-1,mailConvertReturns,to) "%r"

  set world(-1,events) [list]

  set world(-1,verbose) 0;# show extra system messages when things happen?

  set world(-1,slashcmd) [list grab]
  set world(-1,slashcmd,grab) "^(.+)$"
  set world(-1,slashcmd,grab,type) "regexp"
  set world(-1,slashcmd,grab,send) "@decompile/tf %0"
  set world(-1,slashcmd,grab,case) 1

  set world(-1,fcmd,2) ""
  set world(-1,fcmd,3) ""
  set world(-1,fcmd,4) ""
  set world(-1,fcmd,5) ""
  set world(-1,fcmd,6) ""
  set world(-1,fcmd,7) ""
  set world(-1,fcmd,8) ""
  set world(-1,fcmd,9) ""
  set world(-1,fcmd,10) ""
  set world(-1,fcmd,11) ""
  set world(-1,fcmd,12) ""

  set world(-1,autosend,connect) ""
  set world(-1,autosend,login) ""

  set world(-1,act,flashTaskbar) 1
  set world(-1,act,flashSysTray) 0
  set world(-1,act,actInWorldNotice) 0
  set world(-1,act,newActNotice) 1
  set world(-1,act,clearOldNewActNotices) 0
  # These Activity settings used to be program-wide (misc($opt) not world($w,act,$opt)),
  # so for upgraders, we'll use this to import the previous setting
  foreach x [list flashTaskbar flashSysTray actInWorldNotice newActNotice clearOldNewActNotices] {
    if { [info exists misc($x)] } {
         set world(-1,act,$x) $misc($x)
         unset misc($x)
       }
  }

  set world(-1,twoInputWindows) 1
  # used to be per-program. Copy default.
  if { [info exists misc(twoInputWindows)] } {
       set world(-1,twoInputWindows) $misc(twoInputWindows)
       unset misc(twoInputWindows)
     }

  # END DEFAULT WORLD SETTINGS

  # These options aren't configurable from inside the program, but possibly should be? #abc
  set misc(ansiFlashDelay,on) 1200
  set misc(ansiFlashDelay,off) 700
  set misc(maxSpawns) 20

  set misc(showSysTray) 1
  set misc(minToTray) 0
  set misc(startMaximized) 1
  set misc(windowSize) "zoomed"
  set misc(confirmExit) 1
  set misc(clockFormat) "%d/%m/%Y  -  %T"
  set misc(browserCmd) ""
  set misc(partialWorldMatch) 0
  set misc(outsideRequestMethod) 1 ;# 0 = always quick, 1 = always use world, 2 = ask
  set misc(toggleShowMainWindow) 0;# when moving to a conn, show it's main window, even if we last saw a spawn?

  # Default locale
  set misc(locale) "en_gb";# Colour, not Color :)

  # Default skin
  set misc(skin) "potato"

  set misc(aspell) "";# path to aspell executable. None by default.

  if { $potato(windowingsystem) eq "aqua" } {
       set misc(tileTheme) aqua
     } elseif { $potato(windowingsystem) eq "win32" } {
       # Windows. If the user isn't using the XP look, this is identical to "winnative"
       set misc(tileTheme) xpnative
     } else {
       # X11
       set misc(tileTheme) alt
     }
  set defaultTheme $misc(tileTheme)

  if { $readfile } {
       array set prefFlags [prefFlags]
       if { ![catch {source $path(preffile)} retval] } {
            set retval [split $retval .]
            managePrefVersion [lindex $retval 0]
            manageWorldVersion -1 [lindex $retval 1]
          }
     }

  # Check the theme we're using is available. Important if, for instance,
  # a config file is copied from Windows or MacOS to another platform
  # (where 'winnative' or 'aqua' won't be available any more).
  if { ![catch {set styles [::ttk::style theme names]}] && $misc(tileTheme) ni $styles } {
       if { $defaultTheme in $styles } {
            set misc(tileTheme) $defaultTheme;# use what should be a native look, if the user-chosen theme is unavailable
          } else {
            set misc(tileTheme) [lindex $styles 0];# default to the first available theme, let user configure later
          }
     }

  if { ![info exists world(-1,top,font,created)] } {
       set world(-1,top,font,created) [font create {*}[font actual $world(-1,top,font)]]
     }
  if { ![info exists world(-1,bottom,font,created)] } {
       set world(-1,bottom,font,created) [font create {*}[font actual $world(-1,bottom,font)]]
     }

  return;

};# ::potato::setPrefs

#: proc ::potato::savePrefs
#: desc Save the prefs for Potato. This includes default world prefs (world(-1,*)) and misc prefs (misc(*)).
#: return nothing
proc ::potato::savePrefs {} {
  variable path;
  variable world;
  variable misc;
  variable potato;
  variable keyShorts;

  if { [catch {open $path(preffile) w} fid] } {
       tk_messageBox -title $potato(name) -icon error \
                 -message [T "Unable to save preferences: %s" $fid] -type ok
       return;
     }

  # These are not translated. This is deliberate.
  puts $fid "# $potato(name) Preferences."
  puts $fid "# Saved at [clock seconds] from $potato(name) Version $potato(version)"
  puts $fid "# Do not edit this file.\n\n"

  puts $fid "# Default world settings"
  foreach x [lsort -dictionary [array names world -1,*]] {
     if { $x eq "-1,top,font,created" || $x eq "-1,bottom,font,created" || \
          [string match "nosave,*" $x] } {
          continue;
        }
     puts $fid [list set ::potato::world($x) $world($x)]
  }

  # Save the current window size, in case we don't start maximized
  if { [wm state .] eq "zoomed" } {
       set misc(windowSize) "zoomed"
     } else {
       set misc(windowSize) [wm geometry .]
     }
  puts $fid "\n\n# $potato(name) Preference Settings"
  foreach x [lsort -dictionary [array names misc]] {
     puts $fid [list set ::potato::misc($x) $misc($x)]
  }

  puts $fid "\n\n# $potato(name) Keyboard Shortcuts"
  foreach x [lsort -dictionary [array names keyShorts]] {
    puts $fid [list set ::potato::keyShorts($x) $keyShorts($x)]
  }

  puts $fid "\n"
  puts $fid [list return "[prefFlags 1].[worldFlags 1]"]
  close $fid

};# ::potato::savePrefs

#: proc ::potato::managePrefVersion
#: arg version The version of the pref file, or an empty string if none was present (ie, the pref file pre-dates versions)
#: desc Prefs were loaded from a version $version pref  file; make any changes necessary to bring it up to date with a current pref file. NOTE: Does not manage "world -1", the default world settings, as they're generally identical to normal world settings
#: return nothing
proc ::potato::managePrefVersion {version} {
  variable misc;

  array set pf [prefFlags];# array of all current pref flags

  if { ![string is integer -strict $version] } {
       set version 0
     }

  # Example:
  # if { !($version & $pf(foo_removed)) } {
  #      unset misc(foo_var)
  #    }

  return;       

};# potato::managePrefVersion

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
         if { ![catch {source $x} return] && [lrange [split $return " "] 0 2] eq [list World Loaded Successfully] } {
              set w $potato(worlds)
              incr potato(worlds)
              foreach opt [array names newWorld] {
                 set world($w,$opt) $newWorld($opt)
              }
              set world($w,id) $w
              manageWorldVersion $w [lindex [split $return " "] 3]
            }
       }
     }

  foreach w [worldIDs] {
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
         lappend newCharList [list $char [obfusticate $pw 0]]
       }
       set world($w,charList) $newCharList
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

  # Options we don't copy. This is a list of option names.
  set nocopyPatterns [list *,font,created id *,fcmd,* events events,* timer timer,* groups slashcmd slashcmd,* macro,*]

  # Load preset defaults for these, don't copy from world -1. This is a list of optionName optionDefault pairs.
  set standardDefaults [list fcmd,2 {} fcmd,3 {} fcmd,4 {} fcmd,5 {} fcmd,6 {} fcmd,7 {} fcmd,8 {} \
                             fcmd,9 {} fcmd,10 {} fcmd,11 {} fcmd,12 {} \
                             events {} groups [list] slashcmd [list]]

  foreach optFromArr [array names world -1,*] {
    set opt [string range $optFromArr 3 end]
    set copy 1
    foreach nocopy $nocopyPatterns {
      if { [string match $nocopy $opt] } {
           set copy 0
           break;
         }
      if { !$override && [info exists world($w,$opt)] } {
           set copy 0
           break;
         }
    }
    if { $copy } {
         set world($w,$opt) $world(-1,$opt)
       }
  }

  foreach {opt default} $standardDefaults {
    if { $override || ![info exists world($w,$opt)] } {
         set world($w,$opt) $default
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

  # I hope your password is largely letters, numbers, or the symbols I happened to pick.
  set map1 {B 5 7 f S w I L 6 i D 2 p + V X Y Q u t N / ! e v x P b F k { } c d 1 Z z W - , 9 q g T s l y . H A m 4 $ K r 8 ? C R * E M o = 3 0 G J O h j n a U G ? # z 4 j I a V 1 n o q e Z w d H h O = b U i F k . s ! R S Q D c 6 / l $ C f B L T + W t P m , y N 2 v - 8 9 J r p x A E * X 0 5 K 3 u g Y M 7}

  set map0 {5 B f 7 w S L I i 6 2 D + p X V Q Y t u / N e ! x v b P k F c { } 1 d z Z - W 9 , g q s T y l H . m A $ 4 r K ? 8 R C E * o M 3 = G 0 O J j h a n G U # ? 4 z I j V a n 1 q o Z e d w h H = O U b F i . k ! s S R D Q 6 c l / C $ B f T L W + P t , m N y v 2 8 - J 9 p r A x * E 0 X K 5 u 3 Y g 7 M}

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

#: proc ::potato::prefFlags
#: arg total Return a total of the flags, instead of a list of name/value pairs? Defaults to 0
#: desc Return a list (suitable for [array set]) of name/value pairs of Potato preference file flags. If $total is true, return the total of all flags instead.
#: return list of name/value pairs, or total of all flags
proc ::potato::prefFlags {{total 0}} {

  set f(has_pref_flags) 1    ;# pref file uses flags

  if { !$total } {
       return [array get f]
     } else {
       set num 0
       foreach x [array names f] {
         set num [expr {$num | $f($x)}]
       }
       return $num;
     }

};# ::potato::prefFlags

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
  $tree heading #0 -text "Enabled?"
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
  $win.m.prefix add command {*}[menu_label "&Add New Prefix"] -command [list ::potato::prefixWindowAdd $w]
  $win.m.prefix add command {*}[menu_label "&Edit Prefix"] -command [list ::potato::prefixWindowEdit $w]
  $win.m.prefix add command {*}[menu_label "&Delete Prefix"] -command [list ::potato::prefixWindowDelete $w]
  $win.m.prefix add command {*}[menu_label "&Cancel Add/Edit"] -command [list ::potato::prefixWindowCancel $w]
  $win.m.prefix add separator
  $win.m.prefix add command {*}[menu_label "C&lose Window"] -command [list destroy $win]

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

  set list [lsort -dictionary [removePrefix [arraySubelem world $w,prefixes] $w,prefixes]]
  set states [list off on]
  set images [list ::potato::img::cb-unticked ::potato::img::cb-ticked]
  foreach x $list {
    $tree insert {} end -id $x -values [list $x [string map [list " " [format %c 183]] [lindex $world($w,prefixes,$x) 0]]] \
                        -tags [list [lindex $states [lindex $world($w,prefixes,$x) 1]]] \
                        -image [list [lindex $images [lindex $world($w,prefixes,$x) 1]]]
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
       set newstate [list 1 0]
       $tree item $sel -tags [list [lindex $tags $state]] -image [lindex $images $state]
       set world($w,prefixes,$sel) [lreplace $world($w,prefixes,$sel) end end [lindex $newstate $state]]
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
  if { ![regexp $potato(spawnRegexp) $window] && $window ne "_main" && $window ne "_all" } {
        tk_messageBox -icon error -parent $toplevel -title [T "Prefixes"] \
                      -message [T "Invalid window name."] 
        return;
     }

  if { [info exists world($w,prefixes,$window)] && $window ne $prefixWindow($w,editing) } {
       set ans [tk_messageBox -icon error -parent $toplevel -title [T "Prefixes"] -type yesno \
                     -message [T "There is already a prefix for \"%s\". Override?" $window]]
       if { $ans ne "yes" } {
            return;
          }
     }

  if { [info exists world($w,prefixes,$prefixWindow($w,editing))] } {
       set state [lindex $world($w,prefixes,$prefixWindow($w,editing)) 1]
       unset world($w,prefixes,$prefixWindow($w,editing))
     } else {
       set state 1
     }
  if { $prefix eq "" } {
       # Empty prefix - just delete it
       unset -nocomplain world($w,prefixes,$window)
       set window ""
     } else {
       set world($w,prefixes,$window) [list $prefix $state]
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

  unset world($w,prefixes,$sel)

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
  $prefixWindow($w,path,aeprefix) insert end [lindex $world($w,prefixes,$sel) 0]
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
  registerWindow $c $win

  set w $conn($c,world)

  wm title $win [T "Send Mail - \[%d. %s\]" $c $world($w,name)]

  set menu [menu $win.m -tearoff 0]
  $win configure -menu $menu
  $menu add cascade -menu [set fileMenu [menu $menu.file -tearoff 0]] {*}[menu_label [T "&File"]]

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both

  pack [set to [::ttk::frame $frame.to]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $to.l -text [T "Recipient:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $to.e -textvariable ::potato::conn($c,mailWindow,to) -width 40] -side left -anchor nw -fill x
  set ::potato::conn($c,mailWindow,to) ""

  pack [set cc [::ttk::frame $frame.cc]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $cc.l -text [T "CC:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $cc.e -textvariable ::potato::conn($c,mailWindow,cc) -width 40] -side left -anchor nw -fill x
  set ::potato::conn($c,mailWindow,cc) ""

  pack [set bcc [::ttk::frame $frame.bcc]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $bcc.l -text [T "BCC:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $bcc.e -textvariable ::potato::conn($c,mailWindow,bcc) -width 40] -side left -anchor nw -fill x
  set ::potato::conn($c,mailWindow,bcc) ""

  pack [set subject [::ttk::frame $frame.subject]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $subject.l -text [T "Subject:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $subject.e -textvariable ::potato::conn($c,mailWindow,subject) -width 40] \
      -side left -anchor nw -fill x
  set ::potato::conn($c,mailWindow,subject) ""

  pack [set format [::ttk::frame $frame.format]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $format.l -text [T "Format:"] -width 10] -side left -anchor nw
  pack [::ttk::combobox $format.cb -justify left -state normal -width 40 \
               -textvariable ::potato::conn($c,mailWindow,format) \
               -values [list "MUSH @mail" "MUX @mail" "Multi-Command +mail" "MUSE +mail" "Custom"]] -side left -anchor nw -fill x
  set ::potato::conn($c,mailWindow,format) $world($w,mailFormat)
  set ::potato::conn($c,mailWindow,formatWidget) $format.cb

  pack [set custom [::ttk::frame $frame.custom]] -side top -anchor nw -expand 0 -fill x -padx 5 -pady 3
  pack [::ttk::label $custom.l -text [T "Custom:"] -width 10] -side left -anchor nw
  pack [::ttk::entry $custom.e -textvariable ::potato::conn($c,mailWindow,custom) -width 40] \
     -side left -anchor nw -fill x
  set ::potato::conn($c,mailWindow,custom) $world($w,mailFormat,custom)
  if { $conn($c,mailWindow,format) ne "Custom" } {
       $custom.e state disabled
     }

  bind $format.cb <<ComboboxSelected>> [list ::potato::mailWindowFormatChange %W $custom.e]

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

  $fileMenu add command {*}[menu_label [T "&Escape Special Characters"]] \
           -command [format {::potato::textFindAndReplace %s {"%c" %%t %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c \%c \\\%c \%c \\\%c \%c \\\%c}} $textWidget 9 37 37 59 59 91 91 93 93 40 40 41 41 44 44 94 94 36 36 123 123 125 125 92 92]


  bind $win <Escape> [list $btns.cancel invoke]
  bind $win <Destroy> [list ::potato::mailWindowCleanup $c]

  reshowWindow $win 0

  return;

};# ::potato::mailWindow

#: proc ::potato::mailWindowFormatChange
#: arg cb combobox widget path
#: arg e entry widget path
#: desc Change the state of the entry widget based on the combo's value
#: return nothing
proc ::potato::mailWindowFormatChange {cb e} {

  if { [$cb get] eq "Custom" } {
       $e state !disabled
     } else {
       $e state disabled
     }

  return;

};# ::potato::mailWindowFormatChange

#: proc ::potato::mailWindowSend
#: arg c connection id
#: arg win the mail window toplevel
#: desc Send the mail typed in the Mail Window for connection $c to the connection, and destroy the mail window $win. (Bindings on $win for <Destroy> take care of variable cleanup)
#: return nothing
proc ::potato::mailWindowSend {c win} {
  variable conn;
  variable world;

  set w $conn($c,world)

  # Figure out the mail format
  set format $conn($c,mailWindow,format)
  if { $format eq "Custom" } {
       set world($w,mailFormat) Custom
       set world($w,mailFormat,custom) $conn($c,mailWindow,custom)
       set cmd [string map [list ";;" \b] $world($w,mailFormat,custom)]
     } else {
       set world($w,mailFormat) $format
       set cmds [list "@mail %to%=%subject%/%body%" "@mail %to%=%subject% \b -%body% \b --" "+mail %to%=%subject% \b -%body^ \b --" "+mail %to%=%body%"]
       set names [list "MUSH @mail" "MUX @mail" "Multi-Command +mail" "MUSE +mail"]
       set cmd [lindex $cmds [lsearch $names $format]]
     }

  set msg [$conn($c,mailWindow,bodyWidget) get 1.0 end-1char]
  if { $world($w,mailConvertReturns) } {
       set msg [string map [list "\n" $world($w,mailConvertReturns,to)] $msg]
     }
  set mailcmd [string map [list %to% $conn($c,mailWindow,to) %cc% $conn($c,mailWindow,cc) \
              %bcc% $conn($c,mailWindow,bcc) %subject% $conn($c,mailWindow,subject) \
              %body% $msg] $cmd]

  send_to $c $mailcmd \b 1

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
#: desc For connection $c (or the currently displayed connection, if $c is ""), show the dialog to allow the user to select a file to upload (if they aren't already doing so), or the dialog for them to cancel, if they are.
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
  #$frame.options.mpp.l state disabled
  #$frame.options.mpp.cb state disabled
  lappend bindings m $frame.options.mpp.cb

  pack [::ttk::frame $frame.options.delay] -side top -pady 3 -anchor nw
  pack [::ttk::label $frame.options.delay.l -text [T "Delay (seconds):"] -width 20  -anchor w -justify left] \
                  -side left -anchor nw -padx 3
  pack [spinbox $frame.options.delay.sb -textvariable ::potato::conn($c,upload,delay) -from 0 -to 60 \
             -validate all -validatecommand {regexp {^[0-9]*\.?[0-9]?$} %P} -width 4 -increment 0.5] -side left

  pack [::ttk::frame $frame.file] -side top -anchor center -fill x -padx 6 -pady 8
  pack [entry $frame.file.e -textvariable potato::conn($c,upload,file) \
            -disabledbackground white -state disabled -width 30 -cursor {}] -side left -expand 1 -fill x;#abc make me Tile!
  pack [::ttk::button $frame.file.sel -command [list ::potato::selectFile potato::conn($c,upload,file) $win 0] \
              -image ::potato::img::dotdotdot] -side left -padx 8

  pack [::ttk::frame $frame.btns] -side top -anchor center -fill x -padx 6 -pady 8
  pack [::ttk::frame $frame.btns.ok] -side left -padx 6 -expand 1 -fill x
  pack [set okBtn [::ttk::button $frame.btns.ok.btn -command [list potato::uploadWindowInvoke $c $win] \
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
                 addToInputHistory $c $conn($c,upload,mpp,buffer) ""
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
          } elseif { [string range $line 0 0] eq ">" } {
            # Formatted line
            if { $conn($c,upload,mpp,gt) } {
                 set conn($c,upload,mpp,gt) 0
               } else {
                 append conn($c,upload,mpp,buffer) "%r"
               }
            #append conn($c,upload,mpp,buffer) [string map [format {" " %%b "%c" %%t %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c \%c \\\%c \%c \\\%c \%c \\\%c} 9 37 37 59 59 91 91 93 93 40 40 41 41 44 44 94 94 36 36 123 123 125 125 92 92] [string range $line 1 end]]
            append conn($c,upload,mpp,buffer) [string map [list " " %b "\t" %t % \\% {;} {\;} \[ \\\[ \] \\\] ( \\( ) \\) , \\, ^ \\^ $ \\$ \{ \\\{ \} \\\} \\ \\\\] [string range $line 1 end]]
          } elseif { [string range $line 0 0] eq " " || [string range $line 0 0] eq "\t" } {
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
               addToInputHistory $c $string ""
             }
       }
       set delay [expr {round(1000 * $conn($c,upload,delay))}]
     } else {
       set delay 0
     }

  set conn($c,upload,after) [after $delay [list potato::uploadBegin $c]]

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
               -variable potato::conn($c,upload,bytes)] -side left -expand 1 -fill x

  pack [::ttk::frame $frame.btns] -side top -fill x -padx 6 -pady 10
  pack [::ttk::frame $frame.btns.hide] -side left -expand 1 -fill x
  pack [::ttk::button $frame.btns.hide.btn -text [T "Hide"] -width 8 -default active \
               -underline 0 -command [list destroy $win]] -side top
  pack [::ttk::frame $frame.btns.cancel] -side left -expand 1 -fill x
  pack [::ttk::button $frame.btns.cancel.btn -text [T "Cancel"] -width 8 -underline 0 -command [list potato::uploadCancel $c $win]] -side top

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
  set conn($c,logDialog,file) ""

  set bindings [list]

  pack [set frame [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw

  pack [::ttk::frame $frame.top] -side top -padx 5 -pady 10
  pack [::ttk::labelframe $frame.top.buffer -text [T "Include Buffer From: "] -padding 2] -side left -anchor nw -padx 6
  set spawns [removePrefix [arraySubelem conn $c,spawns] $c,spawns]
  pack [::ttk::combobox $frame.top.buffer.cb -values [linsert $spawns 0 {No Buffer} {Main Window}] \
             -textvariable potato::conn($c,logDialog,buffer) -state readonly] -side top -anchor nw

  pack [::ttk::labelframe $frame.top.options -text [T "Other Options"] -padding 2] -side left -anchor nw -padx 6
  pack [::ttk::checkbutton $frame.top.options.future -variable potato::conn($c,logDialog,future) \
             -onvalue 1 -offvalue 0 -text [T "Leave Log Open?"] -underline 10] -side top -anchor w
  lappend bindings o $frame.top.options.future
  pack [::ttk::checkbutton $frame.top.options.append -variable potato::conn($c,logDialog,append) \
             -onvalue 1 -offvalue 0 -text [T "Append to File?"] -underline 0] -side top -anchor w
  lappend bindings a $frame.top.options.append
  #pack [::ttk::checkbutton $frame.top.options.wrap -variable potato::conn($c,logDialog,wrap) \
  #           -onvalue 1 -offvalue 0 -text [T "Wrap Lines?"] -underline 0] -side top -anchor w
  #lappend bindings w $frame.top.options.wrap

  pack [::ttk::frame $frame.file] -side top -anchor center -fill x -padx 6 -pady 4
  pack [::ttk::entry $frame.file.e -textvariable potato::conn($c,logDialog,file) -width 30] -side left -expand 1 -fill x
  $frame.file.e state readonly

  pack [::ttk::button $frame.file.sel -command [list ::potato::selectFile potato::conn($c,logDialog,file) $win 1] \
              -image ::potato::img::dotdotdot] -side left -padx 8
  lappend bindings f $frame.file.sel

  pack [::ttk::frame $frame.btns] -side top -anchor center -expand 1 -fill x -padx 6 -pady 4
  pack [::ttk::frame $frame.btns.ok] -side left -expand 1 -fill x -padx 8
  pack [::ttk::button $frame.btns.ok.btn -text [T "Log"] -width 8 -underline 0 -default active \
              -command [list potato::logWindowInvoke $c $win]] -side top
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

  doLog $c $conn($c,logDialog,file) $conn($c,logDialog,append) $conn($c,logDialog,buffer) $conn($c,logDialog,future)
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
#: desc Create a log file for connection $c, writing to file $file (and appending, if $append is true and the file exists). If $buffer != "_none"/"No Buffer", include output from one of the windows. If $leave, don't close the file, leave it open to log incoming text to, possibly causing us to close an already-open log file.
#: return nothing
proc ::potato::doLog {c file append buffer leave} {
  variable conn;

  if { ![info exists conn($c,world)] } {
       return;
     }

  set mode [lindex [list w a] $append]

  if { ![catch {clock format [clock seconds] -format $file} newfile] } {
       set file $newfile
     }

  set err [catch {open $file $mode} fid]
  if { $err } {
       outputSystem $c "Unable to log to \"$file\": $fid"
       return;
     }

  if { $buffer eq "" || [string equal -nocase $buffer "_none"] || [string equal -nocase $buffer {No Buffer}] } {
       set t ""
     } elseif { [string equal -nocase $buffer {Main Window}] || [string equal -nocase $buffer "_main"] } {
       set t $conn($c,textWidget)
     } elseif { [info exists conn($c,spawns,$buffer)] && [string first "," $buffer] == -1 } {
       set t $conn($c,spawns,$buffer)
     } else {
       set t ""
     }

  if { [winfo exists $t] && [winfo class $t] eq {Text} } {
       set max [$t count -lines 1.0 end]
       for {set i 1} {$i < $max} {incr i} {
         if { "nobacklog" in [$t tag names $i.0] } {
              continue;
            }
         puts $fid [$t get -displaychars -- "$i.0" "$i.0 lineend"]
       }
       flush $fid
     }

  if { $leave } {
       outputSystem $c [T "Now logging to \"%s\"." $file]
       set conn($c,log,$fid) [file nativename [file normalize $file]]
     } else {
       outputSystem $c [T "Logged to \"%s\"." $file]
       close $fid
     }

};# ::potato::doLog

#: proc ::potato::stopLog
#: arg c connection id. Defaults to ""
#: arg file File to close, or "" (default) for all
#: desc Stop logging to filename (or [file channel]) $file, or all files if $file is "", for connection $c.
#: return 0 if no open logs, -1 if specified log not found, -2 if specified log is ambiguous, 1 if log(s) closed successfully.
proc ::potato::stopLog {{c ""} {file ""}} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }
  if { [set count [llength [set list [array names conn $c,log,*]]]] == 0 } {
       return 0;# No open logs
     }
  if { $file eq "" } {
       if { $count == 1 } {
            set msg [T "Logging to \"%s\" stopped." $conn([lindex $list 0])]
          } else {
            set msg [T "Logging to %d logfiles stopped." $count]
          }
        foreach x [removePrefix $list $c,log] {
          close $x
          unset conn($c,log,$x)
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
       close $match
       unset conn($c,log,$match)
     }

  outputSystem $c $msg
  return 1;

};# ::potato::stopLog

#: proc ::potato::log
#: arg c connection id
#: arg str String to log
#: desc Actually log $str to $c's open log files
#: return nothing
proc ::potato::log {c str} {
  variable conn;

  if { $c eq "" } {
       set c [up]
     }

  set logs [array names conn $c,log,*]
  if { [llength $logs] } {
       foreach x [removePrefix $logs $c,log] {
         puts $x $str
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
proc ::potato::selectFile {var win save} {
  variable potato;
  upvar #0 $var local;

  if { $save } {
       set cmd tk_getSaveFile
     } else {
       set cmd tk_getOpenFile
     }

  if { $local eq "" } {
       set basedir $potato(homedir)
       set basefile ""
     } else {
       set basedir [file dirname $local]
       set basefile [file tail $local]
     }

  set filetypes {
    {{Text Files}       {.txt}        }
    {{Text Files}       {.log}        }
    {{All Files}        *             }
  }
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

#: proc ::potato::newConnection
#: arg w the id of the world to connect to
#: arg character The name of the character in world $w's char list to connect to
#: desc do the basics of opening a new connection to a world, tell the current skin to set things up, then try and connect
#: return nothing
proc ::potato::newConnection {w {character ""}} {
  variable potato;
  variable conn;
  variable world;
  variable inputSwap;

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

  set conn($c,textWidget) [text .conn_${c}_textWidget -undo 0]
  createOutputTags $conn($c,textWidget)
  bindtags $conn($c,textWidget) [linsert [bindtags $conn($c,textWidget)] 0 PotatoUserBindings PotatoOutput]
  set pos [lsearch -exact [bindtags $conn($c,textWidget)] {Text}]
  bindtags $conn($c,textWidget) [lreplace [bindtags $conn($c,textWidget)] $pos $pos]

  set conn($c,input1) [text .conn_${c}_input1 -wrap word -height 6 -undo 1]
  set conn($c,input2) [text .conn_${c}_input2 -wrap word -height 4 -undo 1]
  bindtags $conn($c,input1) [linsert [bindtags $conn($c,input1)] 0 PotatoUserBindings PotatoInput]
  bindtags $conn($c,input2) [linsert [bindtags $conn($c,input2)] 0 PotatoUserBindings PotatoInput]
  $conn($c,input1) configure -background $world($w,bottom,bg) -font $world($w,bottom,font,created) \
                   -foreground $world($w,bottom,fg) -insertbackground [reverseColour $world($w,bottom,bg)]
  $conn($c,input2) configure -background $world($w,bottom,bg) -font $world($w,bottom,font,created) \
                   -foreground $world($w,bottom,fg) -insertbackground [reverseColour $world($w,bottom,bg)]

  set inputSwap($conn($c,input1),count) -1
  set inputSwap($conn($c,input1),conn) $c
  set inputSwap($conn($c,input1),backup) ""
  set inputSwap($conn($c,input2),count) -1
  set inputSwap($conn($c,input2),backup) ""
  set inputSwap($conn($c,input2),conn) $c

  set conn($c,world) $w
  set conn($c,char) $character
  set conn($c,id) "" ;# we hope this doesn't break anything.
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
  set conn($c,flashId) ""
  set conn($c,reconnectId) ""
  set conn($c,loginInfoId) ""
  set conn($c,telnet,state) 0
  set conn($c,telnet,subState) 0
  set conn($c,telnet,buffer) ""
  set conn($c,telnet,mssp) [list]
  set conn($c,outputBuffer) ""
  set conn($c,ansi,fg) fg
  set conn($c,ansi,bg) bg
  set conn($c,ansi,flash) 0
  set conn($c,ansi,underline) 0
  set conn($c,ansi,highlight) 0
  set conn($c,ansi,inverse) 0
  set conn($c,reconnectId) ""
  set conn($c,inputHistory) [list]
  set conn($c,inputHistory,count) 0
  set conn($c,stats,prev) 0
  set conn($c,stats,connAt) -1
  set conn($c,stats,formatted) ""
  set conn($c,twoInputWindows) $world($w,twoInputWindows)
  set conn($c,widgets) [list]
  set conn($c,spawnAll) ""
  set conn($c,limited) [list]
  set conn($c,debugPackets) 0
  set conn($c,input1,mode) "multi"
  set conn($c,input2,mode) "multi"
  set conn($c,userAfterIDs) [list]

  if { $w == -1 } {
       connZero
     }

  configureTextWidget $c $conn($c,textWidget)
  ::skin::$potato(skin)::import $c

  showConn $c

  if { $w != -1 } {
       connect $c 1
     }

  return;

};# ::potato::newConnection

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
            ioWrite -nonewline $conn($c,id) "[encoding convertto $conn($c,id,encoding) $str]$conn($c,id,lineending)"
          }
     }

  return;

};# ::potato::sendRaw

#: proc ::potato::flashConnANSI
#: arg c connection id
#: desc flash the ANSI text in the windows for connection $c
#: return nothing
proc ::potato::flashConnANSI {c} {
  variable misc;
  variable conn;
  variable world;

  if { ![info exists conn($c,world)] } {
       return;
     }
  set w $conn($c,world)

  set col [$conn($c,textWidget) tag cget ANSI_flash -background]
  if { $col eq "" } {
       set col $world($w,top,bg)
       set time $misc(ansiFlashDelay,off)
     } else {
       set col ""
       set time $misc(ansiFlashDelay,on)
     }

  $conn($c,textWidget) tag configure ANSI_flash -background $col -foreground $col
  foreach x [arraySubelem conn $c,spawns] {
     $conn($x) tag configure ANSI_flash -background $col -foreground $col
  }

  set conn($c,flashId) [after $time [list potato::flashConnANSI $c]]

  return;

};# ::potato::flashConnANSI

#: proc ::potato::configureTextWidget
#: arg c the connection the widget is being configured for
#: arg t the text widget to be configured
#: desc set the ANSI colours, ANSI underline, BG, FG, system, and echo colours for the text widget based on it's connection's world's settings, and turn ANSI flash on/off as appropriate.
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

  if { $world($w,ansi,flash) } {
       if { $conn($c,flashId) eq "" } {
            flashConnANSI $c
          }
     } elseif { $conn($c,flashId) ne "" } {
       if { $c != -1 } {
            after cancel $conn($c,flashId)
            set conn($c,flashId) ""
          }
       $t tag configure ANSI_flash -background {} -foreground {}
     }
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

  $t configure -wrap word -height 24 -highlightthickness 0 -borderwidth 0

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
#: desc attempt to load the webpage $page in a browser. This proc may need to be more robust at detecting default browsers.
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
       if { [string range $misc(browserCmd) 0 0] eq {"} } {
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

  if { ![info exists command] || [catch {exec {*}$command &}] } {
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
  set t $conn(0,textWidget)
  $t delete 1.0 end
  $t insert end [T "%s Version %s" $potato(name) $potato(version)] [list system margins]
  $t insert end "\n" [list system margins] [T "Written by Mike Griffiths (%s)" $potato(contact)] [list system margins]
  $t insert end "\n\n"

  if { $potato(worlds) > 0 } {
       $t insert end [T "Defined Worlds (click to connect):"] [list margins]
       set worldList [potato::worldList]
       set worldList [lsort -dictionary -index 1 $worldList]
       foreach x $worldList {
          foreach {w name} $x {break}
          $t insert end "\n\n"
          $t insert end $name [list link connect_$w margins]
          if { [string trim $world($w,description)] ne "" } {
               $t insert end " - $world($w,description)" [list margins]
             }
          $t tag bind connect_$w <ButtonRelease-1> [list potato::newConnectionDefault $w]
       }
       $t insert end "\n\n"
       $t insert end [T "Alternatively, you can use the "]
       $t insert end [T "Quick Connect"] [list link quickconnect margins]
       $t insert end [T " to connect to a new world quickly."]
     } else {
       $t insert end [T "There are no worlds defined. You should either "] [list margins]
       $t insert end [T "add a new world"] [list link addnewworld margins]
       $t insert end [T " to the address book, or use the "] [list margins]
       $t insert end [T "Quick Connect"] [list link quickconnect margins]
       $t insert end [T " to connect to a new world quickly."] [list margins]
       $t tag bind addnewworld <ButtonRelease-1> [list potato::newWorld 0]
     }

  $t tag bind quickconnect <ButtonRelease-1> [list potato::newWorld 1]
  return;

};# ::potato::connZero

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
#: return nothing
proc ::potato::reconnect {{c ""}} {

  if { $c eq "" } {
       set c [up]
     }

  if { $c == 0 } {
       return;
     }

  connect $c 0

  return;

};# ::potato::reconnect

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
#: return Data read
proc ::potato::ioWrite {args} {

  return [puts {*}$args]

};# ::potato::ioWrite

#: proc ::potato::connect
#: arg c the connection to connect
#: arg first is this the first time we've tried to connect here? Affects messages, etc.
#: arg hostlist List of hosts to attempt to connect to; some combination of "host" and "host2", or "". Defaults to "".
#: desc start connecting to a world. This doesn't handle the full connection, as we connect -async and wait for a response. This connection may be to a proxy server, not the actual game. $hostlist contains a list telling us whether to attempt to connect to the primary host ("host"), the secondary host ("host2"), or both ("").
#: return nothing
proc ::potato::connect {c first {hostlist ""}} {
  variable conn;
  variable world;
  variable potato;

  if { $conn($c,connected) != 0 || $c == 0 } {
       return;# already connected or trying to connect
     }

  set w $conn($c,world)

  after cancel $conn($c,reconnectId)
  set conn($c,reconnectId) ""

  set conn($c,connected) -1 ;# trying to connect

  set up [up]

  if { ![llength $hostlist] } {
       if { !$world($w,ssl) || $potato(hasTLS) } {
            lappend hostlist host
          } else {
            outputSystem $c [T "Unable to connect to primary host - SSL not available"]
          }
       if { [string length $world($w,host2)] && [string length $world($w,port2)] } {
            if { !$world($w,ssl2) || $potato(hasTLS) } {
                 lappend hostlist host2
               } else {
                 outputSystem $c [T "Unable to connect to secondary host - SSL not available"]
               }
          }
     }

  if { ![llength $hostlist] } {
       # All connections require SSL, and we don't have TLS
       disconnect $c 0
       skinStatus $c
       return;
     }

  set thishost [lindex $hostlist 0]
  if { $thishost eq "host" } {
       set thisport port
       set thisssl ssl
       set message [T "Connecting to host %s:%s..." $world($w,$thishost) $world($w,$thisport)]
     } else {
       set thisport port2
       set thisssl ssl2
       set message [T "Connecting to secondary host %s:%s..." $world($w,$thishost) $world($w,$thisport)]
     }

  if { $world($w,proxy) eq "None" } {
       # No proxy, a straight connection to the game
       set host $world($w,$thishost)
       set port $world($w,$thisport)
       !set message [T "Connecting to %s:%s..." $host $port]
     } else {
       # connect through a proxy. Sigh.
       set host $world($w,proxy,host)
       set port $world($w,proxy,port)
       set message [T "Connecting to %s Proxy at %s:%s..." $world($w,proxy) $host $port]
     }
  if { !$first } {
       # Generic reconnect message
       !set message [T "Attempting to reconnect..."]
     }

  outputSystem $c $message
  if { $first } {
       $conn($c,textWidget) delete 1.0 2.0
     }
  skinStatus $c
  update idletasks

  if { [catch {::potato::ioOpen $host $port} fid] } {
       outputSystem $c $fid
       disconnect $c 0
       boot_reconnect $c
       skinStatus $c
       return;
     }

  set conn($c,id) $fid
  if { $world($w,$thisssl) } {
       addProtocol $c ssl
     }
  fileevent $fid writable [list ::potato::connectVerify $c $hostlist]

  return;

};# ::potato::connect

#: proc ::potato::connectVerify
#: arg c connection id
#: arg hostlist The hostlist, passed from ::potato::connect. List containing a combination of "host" and "host2", or an empty string, telling us which hosts to attempt connection to.
#: desc Verify whether the newly made connection for conn $c has worked or not. If we're connected, and it's through a proxy, verify the proxy is working correctly. (If not through a proxy, we're connected successfully.)
#: return nothing
proc ::potato::connectVerify {c hostlist} {
  variable conn;
  variable world;

  set id $conn($c,id)
  catch {fileevent $id writable {}}

  set w $conn($c,world)
  if { [catch {fconfigure $id -error} err] || $err ne "" } {
       # The connection failed. If we were attempting to connect through a proxy, or
       # we were connecting to the last host we have, run boot_reconnect to start over
       outputSystem $c [T "Connection failed: %s" $err]
       disconnect $c 0
       if { $world($w,proxy) ne "None" || [llength $hostlist] == 1 } {
            boot_reconnect $c
            skinStatus $c
            return;
          } else {
            # Not connecting through a proxy, and we have another host to attempt
            connect $c 0 [lrange $hostlist 1 end]
            return;
          }
     }


  if { $world($w,proxy) ne "None" } {
       connectVerifyProxy $c $hostlist
     } else {
       connectVerifyComplete $c
     }

  return;

};# ::potato::connectVerify

#: proc ::potato::connectVerifyProxy
#: arg c connection id
#: arg hostlist List of hosts ("host", "host2") we should attempt to connect to through the proxy
#: desc Called when a connection has been successfully established to connection $c's proxy host; do the required work to negotiate with the proxy to establish a connection to the end game server. Call connectVerifyComplete on success, or abort, [close] the connection and do standard reconnect if the proxy doesn't play nice.
#: return nothing
proc ::potato::connectVerifyProxy {c hostlist} {
  variable conn;
  variable world;

  ::potato::proxy::$world($conn($c,world),proxy)::start $c $hostlist

  return;

};# ::potato::connectVerifyProxy

#: proc ::potato::connectVerifyProxyFail
#: arg c connection id
#: arg proxy The proxy type (SOCKS4, SOCKS5, HTTP)
#: arg hostlist List of hosts ("host"/"host2") we're attempting to connect to.
#: arg err A string containing the error encountered. Defaults to ""
#: desc Called when we've connected to a proxy server, but failed to negotiate for it to handle our connection to a MUSH. If we have multiple hosts to try, reconnect to the proxy and try the next. Else, do the "failed connect" stuff like print a message (including $err, or a default fail message if $err is ""), set up auto-reconnect, etc
#: return nothing
proc ::potato::connectVerifyProxyFail {c proxy hostlist err} {
  variable conn;

  if { $err eq "" } {
       set err [T "Unable to negotiate with %s proxy" $proxy]
     }
  outputSystem $c [T "Connection failed: %s" $err]
  disconnect $c 0

  if { [llength $hostlist] == 1 } {
       # No more hosts to try, do a failed connect
       boot_reconnect $c
       skinStatus $c
       return;
     } else {
       # Try remaining hosts
       connect $c 0 [lrange $hostlist 1 end]
       return;
     }

};# ::potato::connectVerifyProxyFail

#: proc ::potato::connectVerifyComplete
#: arg c connection id
#: desc Called when we've just successfully connected to a world (and verified the proxy connection, if connecting through a proxy), to actually mark us as connected.
#: return nothing
proc ::potato::connectVerifyComplete {c} {
  variable conn;
  variable world;

  set w $conn($c,world)
  set id $conn($c,id)

  set conn($c,connected) 1

  set conn($c,stats,connAt) [clock seconds]
  set conn($c,stats,formatted) [statsFormat 0]
  incr world($w,stats,conns)

  fileevent $id writable {}

  switch $world($w,type) {
     "MUSH" {set translation "\r\n"}
     "MUD"  {set translation "\n"}
     default {set translation "\r\n"}
  }
  if { [hasProtocol $c ssl] } {
       tls::import $id
     }
  set conn($c,id,lineending) $translation
  set conn($c,id,lineending,length) [string length $conn($c,id,lineending)]
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
  if { [lindex $peer 0] == [lindex $peer 1] } {
       set str [lindex $peer 0]
     } else {
       set str "[lindex $peer 0] ([lindex $peer 1])"
     }
  outputSystem $c [T "Connected - %s" $str]

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
  if { [string length $world($w,autosend,connect)] } {
       send_to $c $world($w,autosend,connect) "\n" 0
     }
  # Don't check for pw being blank, as some games allow empty passwords
  if { [string length $conn($c,char)] && \
       [llength [set charinfo [lsearch -inline -index 0 $world($w,charList) $conn($c,char)]]] &&
       ![catch {format $world($w,loginStr) [lindex $charinfo 0] [lindex $charinfo 1]} str] } {
       # At some point, we may want to print a message if the [format] fails, to let the user know
       # it's incorrect and needs fixing. #abc
       send_to_real $c $str [format $world($w,loginStr) [lindex $charinfo 0] \
                                 [string repeat \u25cf [string length [lindex $charinfo 1]]]]
     }
  if { [string length $world($w,autosend,login)] } {
       send_to $c $world($w,autosend,login) "\n" 0
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
#: desc Begin running timer $timer from world $w in connection $c. Called by [timersStart] for each timer, and also by [configureWorldCommit] for new timers. Note that the timer must not be running already, as this proc will not cancel the current instance.
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
#: desc Queue timer $timer from world $w (which is either $c's world or -1 for a global timer) to run for connection $c. If $first, use the timer's delay interval as the [after] time, otherwise use it's every interval.
#: return nothing
proc ::potato::timerQueue {c w timerId first} {
  variable world;
  variable conn;

  set type [expr {$first ? "delay" : "every"}]
  set conn($c,timer,$timerId-$w,after) \
           [after [expr {$world($w,timer,$timerId,$type) * 1000}] [list potato::timerRun $c $w $timerId]]
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
  send_to $c $world($w,timer,$timer,cmds) "\n" 0

  if { $conn($c,timer,$timer-$w,count) != 0 } {
       timerQueue $c $w $timer 0
     }

  # Check re-queuing
  if { $conn($c,timer,$timer-$w,count) > 0 } {
       incr conn($c,timer,$timer-$w,count) -1
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

  if { $potato(skin) ne "" } {
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

  
  catch {fileevent $conn($c,id) writable {}}
  catch {fileevent $conn($c,id) readable {}}  
  uploadEnd $c 1;# cancel any in-progress file upload
  catch {::potato::ioClose $conn($c,id)}
  set conn($c,id) ""
  set prevState $conn($c,connected)
  if { $conn($c,connected) == 1 } {
       # Only print message if we were fully connected, otherwise the "failed to connect" message is sufficient, and
       # we don't need to spam.
       outputSystem $c [T "Disconnected from host."]
     }
  set conn($c,connected) 0
  timersStop $c
  set conn($c,protocols) [list]
  catch {after cancel $conn($c,loginInfoId)}
  set conn($c,loginInfoId) ""
  set conn($c,outputBuffer) ""

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

#: proc ::potato::debug_packet
#: arg c connection id
#: arg dir 1 if text was received, 0 if sent
#: arg text the text to print
#: return nothing
proc ::potato::debug_packet {c dir text} {

  set win(toplevel) .debug_packet_$c
  set win(txt,frame) $win(toplevel).txt
  set win(txt,txt) $win(txt,frame).t
  set win(txt,sb) $win(txt,frame).sb
  if { ![winfo exists $win(toplevel)] } {
       toplevel $win(toplevel)
       wm title $win(toplevel) [T "Packet Debugger for \[%d. %s\]" $c [connInfo $c name]]
       pack [::ttk::frame $win(txt,frame)] -side top -expand 1 -fill both
       pack [text $win(txt,txt) -wrap word -yscrollcommand [list $win(txt,sb) set]] -side left -expand 1 -fill both
       configureTextWidget $c $win(txt,txt)
       pack [scrollbar $win(txt,sb) -orient vertical -command [list $win(txt,txt) yview]] -side left -fill y
       bind $win(toplevel) <Destroy> [list set ::potato::conn($c,debugPackets) 0]
     }
  set aE [atEnd $win(txt,txt)]
  if { $dir } {
       $win(txt,txt) insert end $text
     } else {
       $win(txt,txt) insert end $text echo
     }
  if { $aE } {
       $win(txt,txt) see end
     }
  return;

};# ::potato::debug_packet

#: proc ::potato::get_mushage
#: arg c connection id
#: desc Get pending output for connection $c, parse through any necessary protocols and, if a complete line is present, display it. Must also watch for the connection being closed and act accordingly.
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
  if { $world($conn($c,world),telnet) || [hasProtocol $c telnet] } {
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

  # ANSI escape char is \x1B, char code 27
  regsub -all {\x1B.*?m} $line "" lineNoansi

  # set matchLinks {\m((https?://)|www\.)(([a-zA-Z_\.0-9%+/@~=&,;-]*))?([a-zA-Z_\.0-9%+/@~=&,;-]*)(\?([a-zA-Z_\.0-9%+/@~=&,;:-]*))?(#[a-zA-Z_\.0-9%+/@~=&,;:-]*)?}
  set matchLinks {\m(?:(?:(?:f|ht)tps?://)|www\.)(?:(?:[a-zA-Z_\.0-9%+/@~=&,;-]*))?(?::[0-9]+/)?(?:[a-zA-Z_\.0-9%+/@~=&,;-]*)(?:\?(?:[a-zA-Z_\.0-9%+/@~=&,;:-]*))?(?:#[a-zA-Z_\.0-9%+/@~=&,;:-]*)?}
  set tmp [regexp -all -inline -indices -- $matchLinks $lineNoansi]
  # '\a' is the beep char defined in PennMUSH in ansi.h. If a game has changed this, or another codebase uses something
  # else, you can change it by.. hrm, nope, you're just screwed.

  # First, we need to count the beeps
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

  set len [string length $lineNoansi]
  set urlIndices [list]
  foreach x $tmp {
    foreach {start end} $x {
       if { $start == -1 } {
            continue;
          } else {
            lappend urlIndices [set tempa "end-[expr {$len-$start+1}]char"]
            if { $end == -1 } {
                 lappend urlIndices [set tempb "end"]
               } else {
                 lappend urlIndices [set tempb "end-[expr {$len-$end}]char"]
               }
          }
    }
  }
  unset -nocomplain tmp x start end len
  set insertedAnything 0 ;# we only flash the window if we have

  set empty 0
  if { $lineNoansi eq "" && $world($w,ignoreEmpty) } {
       set empty 1
     }

  array set eventInfo [events $c $lineNoansi]
  if { !$eventInfo(matched) || !$eventInfo(log) } {
       log $c $lineNoansi
     }

  set tagList [list margins]
  set omit 0
  if { $eventInfo(matched) } {
       if { $eventInfo(omit) } {
            set omit 1
          }
       if { $eventInfo(log) } {
            lappend tagList nobacklog
          }
       set eventfg $eventInfo(fg)
       set eventbg $eventInfo(bg)
       set eventStart $eventInfo(start)
       set eventEnd $eventInfo(end)
     } else {
       set eventfg ""
       set eventbg ""
       set eventStart -1
       set eventEnd -1
       set omit 0
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
       set limit [expr {!$limit || [lindex $conn($c,limited) 1]}]
       if { $limit } {
            lappend tagList "limited"
          }
     } else {
       set limit 0
     }
  # Ansi must be parsed, no matter what we're doing with the line (gagging, recolouring, etc).
  # If nothing else, any ansi tags it leaves open should still affect the next line of text to come.

  set inserts [list]
  set inEvent 0
  while { [string length $line] } {
          set nextAnsi [string first \x1B $line]
          set eventSeq [expr {$inEvent ? $eventEnd : $eventStart}]
          if { $nextAnsi == -1 && $eventSeq < 0 } {
               # Just plain text
               lappend inserts $line [get_mushageColours $c "" "" $tagList]
               break;
             } elseif { $nextAnsi > -1 && ($eventSeq < 0 || $nextAnsi <= $eventSeq) } {
               # Process up to ANSI
               set prev [string range $line 0 $nextAnsi-1]
               if { $inEvent } {
                    lappend inserts $prev [get_mushageColours $c $eventfg $eventbg $tagList]
                  } else {
                    lappend inserts $prev [get_mushageColours $c "" "" $tagList]
                  }
               set prevLen [string length $prev]
               incr eventStart -$prevLen
               incr eventEnd -$prevLen
               # Now process the colours
               set nextM [string first m $line $nextAnsi]
               if { $nextM == -1 } {
                    # There's no 'm' to close the ANSI, but we have a complete line, so something
                    # is wrong. Reset colours to normal and abort the rest of the line.
                    handleAnsiCodes $c 0 ;# ANSI normal
                    set line ""
                    break;
                  }
               set codes [string range $line $nextAnsi+2 $nextM-1]
               handleAnsiCodes $c [split $codes ";"]
               set line [string range $line $nextM+1 end]
             } else {
               # We have an event sequence (start/end of event)
               if { $inEvent } {
                    set prev [string range $line 0 $eventEnd]
                    set line [string range $line $eventEnd+1 end]
                    lappend inserts $prev [get_mushageColours $c $eventfg $eventbg $tagList]
                    set inEvent 0
                  } else {
                    set prev [string range $line 0 $eventStart-1]
                    set line [string range $line $eventStart end]
                    lappend inserts $prev [get_mushageColours $c "" "" $tagList]
                    set inEvent 1
                  }
               set prevLen [string length $prev]
               incr eventStart -$prevLen
               incr eventEnd -$prevLen
              }
        }

  if { !$empty && $world($w,ansi,force-normal) } {
       # Force explicit ANSI-normal at the end of the line
       handleAnsiCodes $c 0
     }

  set up [up]
  if { !$empty && $world($w,act,newActNotice) && ([focus -displayof .] eq "" || $up != $c) && !$conn($c,idle) } {
       set showNewAct 1
     } else {
       set showNewAct 0
     }
  if { !$empty && $up != $c && $world($w,act,actInWorldNotice) } {
       deleteSystemMessage $up actIn$c
       outputSystem $up [T "----- Activity in %d. %s -----" $c $world($w,name)] [list center actIn$c]
     }
  set newActStr [T "--------- New Activity ---------"]
  set t $conn($c,textWidget)
  set aE [atEnd $t]
  if { !$empty && !$omit && !$limit && $showNewAct } {
       if { $world($w,act,clearOldNewActNotices) && [llength [$t tag nextrange newact 1.0]] } {
            $t delete {*}[$t tag ranges newact]
          }
       $t insert end "\n" [list system center newact] [clock seconds] [list system center newact timestamp] $newActStr [list system center newact] 
       set insertedAnything 1
     }
 
  if { !$empty && !$omit } {
       $t insert end "\n" [lindex [list "" limited] $limit]  [clock seconds] [list timestamp] {*}$inserts
       set insertedAnything 1
       if { [llength $urlIndices] } {
            $t tag add link {*}$urlIndices
            $t tag add weblink {*}$urlIndices
          }
       if { $aE } {
            $t see end
          }
     }

  set spawns $conn($c,spawnAll)
  if { !$empty && $eventInfo(matched) && $eventInfo(spawnTo) ne "" } {
       set spawns "$spawns $eventInfo(spawnTo)"
     }
  if { !$empty && [string trim $spawns] ne "" } {
       set limit [expr {$world($w,spawnLimit,on) ? $world($w,spawnLimit,to) : 0}]
       set insertedAnything 1
       foreach {x y} [parseSpawnList $spawns $c] {
         set aE [atEnd $x]
         if { [$x count -chars 1.0 3.0] != 1 } {
              $x insert end "\n" ""
            }
         $x insert end "" "" {*}$inserts
         if { [llength $urlIndices] } {
              $x tag add link {*}$urlIndices
              $x tag add weblink {*}$urlIndices
            }
         if { $aE } {
              $x see end
            }
         if { $limit } {
              $x delete 1.0 end-${limit}lines
            }
         ::skin::$potato(skin)::spawnUpdate $c $y
       }
     }

  if { $eventInfo(matched) && $eventInfo(send) ne "" } {
       send_to $c $eventInfo(send) \n 1
     }

  if { $eventInfo(input,window) != 0 && $eventInfo(input,string) ne "" } {
       if { $eventInfo(input,window) == 3 } {
            set eventInfo(input,window) [connInfo $c inputFocus]
          }
       showInput $c $eventInfo(input,window) $eventInfo(input,string) 1
       if { $eventInfo(input,window) == 2 } {
            # Make sure the second input window is visible, because we've just put stuff in it
            set conn($c,twoInputWindows) 1
            toggleInputWindows $c 0
          }
     }

  if { $insertedAnything } {
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
#: arg spawns A list of spawn window names, supplied by the user
#: arg c Connection id to create new spawns from
#: desc For each spawn window name given in $spawns, create a spawn window (if it doesn't exist and we have space), using the info from the connection $c
#: return the list of text-widget and spawn names paths for all the spawn windows successfully created/existing
proc ::potato::parseSpawnList {spawns c} {
  variable conn;

  if { $spawns eq "" || [string trim $spawns] eq "" } {
       return; # Optimize for cases when there is no spawning
     }

  set returnList [list]

  # OK, first, let's go through and get a list of valid names
  foreach x [split [string trim $spawns] " "] {
    if { $x eq "" } {
         # Ignore empty ones silently
         continue;
       } elseif { ([info exists conn($c,spawns,$x)] || [set create [createSpawnWindow $c $x]] eq "") } {
         # It's good!
         if { $conn($c,spawns,$x) ni $returnList } {
              lappend returnList $conn($c,spawns,$x) $x
            }
       } else {
         # Uh-oh
         outputSystem $c [T "Unable to create new spawn window \"%s\": %s" $x $create]
       }
  }
  # Return the list of successful ones
  return $returnList;

};# ::potato::parseSpawnList

#: proc ::potato::createSpawnWindow
#: arg c connection id
#: arg name Spawn window name
#: desc Attempt to create a spawn window $name using settings from connection $c
#: return empty string on success, error message on failure
proc ::potato::createSpawnWindow {c name} {
  variable misc;
  variable conn;
  variable potato;

  if { ![regexp $potato(spawnRegexp) $name] } {
       return [T "Invalid Spawn Name"];# bad name
     } elseif { $misc(maxSpawns) > 0 && [llength [arraySubelem conn $c,spawns]] >= $misc(maxSpawns) } {
       return [T "Too many spawns"];# too many spawns already
     } else {
       # set it up. NOTE: Using a ::ttk::frame makes it go haywire when using [wm manage]!
       set t [text .spawn_${c}_$name]
       set conn($c,spawns,$name) $t
       createOutputTags $t
       configureTextWidget $c $t
       bindtags $t [linsert [bindtags $t] 0 PotatoUserBindings PotatoOutput]
       set pos [lsearch -exact [bindtags $t] "Text"]
       bindtags $t [lreplace [bindtags $t] $pos $pos]

       ::skin::$potato(skin)::addSpawn $c $name
       return "";
     }

};# ::potato::createSpawnWindow

#: proc ::potato::destroySpawnWindow
#: arg c connection id
#: arg name Spawn name
#: desc Destroy the spawn window $name from connection $c. We also notify the skin of it's impending destruction
#: return nothing
proc ::potato::destroySpawnWindow {c name} {
  variable conn
  variable potato;

  if { ![info exists conn($c,spawns,$name)] } {
       return; # no such spawn
     }

  set togo $conn($c,spawns,$name)
  unset conn($c,spawns,$name)
  ::skin::$potato(skin)::delSpawn $c $name
  destroy $togo

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
#: arg c connection id
#: arg codes List of ansi codes
#: desc adjust the conn($c,ansi,*) variables to change the colours for ansi code $code
#: return nothing
proc ::potato::handleAnsiCodes {c codes} {
  variable conn;

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
          set conn($c,ansi,fg) fg
          set conn($c,ansi,bg) bg
          set conn($c,ansi,highlight) 0
          set conn($c,ansi,underline) 0
          set conn($c,ansi,flash) 0
          set conn($c,ansi,inverse) 0
         }
       1 { # ANSI Highlight
           if { !$conn($c,ansi,highlight) } {
                set conn($c,ansi,highlight) 1
                # Only add "h" if we have a normal ANSI (not XTerm/FANSI) color or normal fg/bg
                if { $conn($c,ansi,fg) in $highlightable } {
                     append conn($c,ansi,fg) h
                   }
                if { $conn($c,ansi,bg) in $highlightable } {
                     append conn($c,ansi,bg) h
                   }
              }
         }
       4 { # ANSI Underline
           set conn($c,ansi,underline) 1
         }
       5 { # ANSI Flash
           set conn($c,ansi,flash) 1
         }
       7 { # ANSI Inverse
           set conn($c,ansi,inverse) 1
         }
      30 -
      31 -
      32 -
      33 -
      34 -
      35 -
      36 -
      37 {# ANSI foreground color
          if { $conn($c,ansi,highlight) } {
               set conn($c,ansi,fg) "[lindex $ansiColors [expr {$curr - 30}]]h"
             } else {
               set conn($c,ansi,fg) [lindex $ansiColors [expr {$curr - 30}]]
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
          if { $conn($c,ansi,highlight) } {
               set conn($c,ansi,bg) "[lindex $ansiColors [expr {$curr - 40}]]h"
             } else {
               set conn($c,ansi,bg) [lindex $ansiColors [expr {$curr - 40}]]
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
          set conn($c,ansi,$which) "xterm$xterm"
         }
    };# switch
  };# while

  return;

};# ::potato::handleAnsiCodes

#: proc ::potato::get_mushageColours
#: arg c connection id
#: arg eventfg the event fg colour, or empty string if none
#: arg eventbg the event bg colour, or empty string if none
#: arg extraTags a list of extra tags to apply
#: desc return a list of all the tags needed to apply the correct ANSI colour for text in connection $c, based on the gag colours given and the current state of connection $c as obtained through $conn($c,ansi,*), plus the $extraTags
#: return [list] of text widget tags
proc ::potato::get_mushageColours {c eventfg eventbg extraTags} {
  variable conn;

  set fg $conn($c,ansi,fg)
  set bg $conn($c,ansi,bg)
  if { $conn($c,ansi,inverse) } {
       # Invert colors
       foreach [list fg bg] [list $bg $fg] {break;}
     }
  if { $eventfg ne "" } {
       set fg $eventfg
     }
  if { $eventbg ne "" } {
       set bg $eventbg
     }

  if { $fg eq "bg" || $fg eq "bgh" } {
       lappend extraTags ANSI_fg_bg
     } elseif { $fg eq "fg" } {
       # Do nothing. Normal FG colour is the default.
     } else {
       lappend extraTags ANSI_fg_$fg
     }
  if { $bg eq "bg" || $bg eq "bgh" } {
       # Nothing. Normal BG is the default.
     } else {
       lappend extraTags ANSI_bg_$bg
     }

  if { $conn($c,ansi,flash) } {
       lappend extraTags ANSI_flash
     }
  if { $conn($c,ansi,underline) } {
       lappend extraTags ANSI_underline
     }

  return $extraTags;

};# ::potato::get_mushageColours

#: proc ::potato::arraySubelem
#: arg _arrName name of array
#: arg prefix Prefix to match (glob pattern)
#: desc Return a list of all the elements in the array $_arrName in the caller's space which match the {^$prefix,[^,]+$}
#: return List of matching array elements
proc ::potato::arraySubelem {_arrName prefix} {
  upvar 1 $_arrName arrName

  return [array names arrName -regexp "[regsub -all {[^[:alnum:]]} $prefix {\\&}],\[^,\]+$"];

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

};# removePrefix

#: proc ::potato::events
#: arg c connection id
#: arg str string to match
#: desc return a list, suitable for [array set], of the events (gag/trigger/highlight/spawn) info that matches $str on connection $c, including "matched", set to 1 if a g/t/h matched and 0 if not, and "result", set to what the match-checking command returned.
#: return [array get] list
proc ::potato::events {c str} {
  variable conn;
  variable world;
  variable events;

  set w $conn($c,world)
  if { $w == -1 } {
       set worldsToCheck [list $w]
     } else {
       set worldsToCheck [list $w -1]
     }

  set break 0
  array set retVals [list matched 0 result "" pattern "" matchtype "" omit 0 log 0 fg "" bg "" \
               spawn 0 spawnTo "" input,window 0 input,string "" send "" start -1 end -1]

  set strL [string tolower $str]
  set focus [focus -displayof .]
  set up [up]
  foreach w $worldsToCheck {
     if { $break } {
          break; # We broke in the inner foreach, so don't check the gth for other worlds.
        }
     foreach x $world($w,events) {
        if { !$world($w,events,$x,enabled) } {
             continue;
           }
        if { ($up == $c) && ($world($w,events,$x,inactive) eq "world") } {
             continue;
           }
        if { ($focus ne "") && ($world($w,events,$x,inactive) eq "program") } {
             continue;
           }
        if { ($focus ne "") && ($up == $c) && ($world($w,events,$x,inactive) eq "inactive") } {
             continue;
           }
        unset -nocomplain arg
        switch $world($w,events,$x,matchtype) {
            "regexp" -
            "wildcard" {
                      set failStr 0
                      set matchCmd [list regexp -indices]
                      if { !$world($w,events,$x,case) } {
                           lappend matchCmd "-nocase"
                         }
                      lappend matchCmd "--"
                      if { $world($w,events,$x,matchtype) eq "wildcard" } {
                           lappend matchCmd $world($w,events,$x,pattern,int)
                         } else {
                           lappend matchCmd $world($w,events,$x,pattern)
                         }
                      lappend matchCmd $str -> arg(0) arg(1) arg(2) arg(3) \
                              arg(4) arg(5) arg(6) arg(7) arg(8) arg(9)
                     }
            "contains" {
                      set failStr -1
                      set matchCmd [list string first]
                      if { $world($w,events,$x,case) } {
                           lappend matchCmd $world($w,events,$x,pattern) $str
                         } else {
                           lappend matchCmd [string tolower $world($w,events,$x,pattern)] $strL
                         }
                     }
        };# switch
        if { [catch {{*}$matchCmd} result] || $result == $failStr } {
             continue;
           }
        set mapList [list "%%" "%"]
        for {set i 0} {$i < 10} {incr i} {
             lappend mapList %$i
             if { [info exists arg($i)] } {
                  lappend mapList [string range $str {*}$arg($i)]
                } else {
                  lappend mapList ""
                }
           }
        if { !$retVals(matched) } {
             array set retVals [list matched 1 result $result pattern $world($w,events,$x,pattern) \
                     matchtype $world($w,events,$x,matchtype)]
           }
        if { !$retVals(spawn) && $world($w,events,$x,spawn) } {
             set retVals(spawnTo) [parseUserVars $c [string map $mapList $world($w,events,$x,spawnTo)]]
           }
        if { !$retVals(omit) } {
             set retVals(omit) $world($w,events,$x,omit)
           }
        if { !$retVals(log) } {
             set retVals(log) $world($w,events,$x,log)
           }
        if { $retVals(fg) eq "" } {
             set retVals(fg) $world($w,events,$x,fg)
           }
        if { $retVals(bg) eq "" } {
             set retVals(bg) $world($w,events,$x,bg)
           }
        if { $retVals(start) == -1 && ($retVals(fg) ne "" || $retVals(bg) ne "") } {
             if { $world($w,events,$x,matchtype) eq "contains" } {
                  # $result is result of [string first]
                  set retVals(start) $result
                  set retVals(end) [expr {$result + [string length $world($w,events,$x,pattern)] - 1}]
                } else {
                  # [regexp -indices]
                  foreach {retVals(start) retVals(end)} [set ->] {break}
                }
            }
        if { $retVals(input,window) eq 0 && $world($w,events,$x,input,window) != 0 } {
             set retVals(input,window) $world($w,events,$x,input,window)
             set retVals(input,string) [string map $mapList $world($w,events,$x,input,string)]
           }
        if { $retVals(send) eq "" } {
             set retVals(send) [string map $mapList $world($w,events,$x,send)]
           }
        if { !$world($w,events,$x,continue) } {
             set break 1
             break;
           }
     }
  }

  return [array get retVals];

};# ::potato::events

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

  set tags [concat $tags [list system margins]]
  if { ![info exists conn($c,textWidget)] || ![winfo exists $conn($c,textWidget)] } {
       return;
     }
  set aE [atEnd $conn($c,textWidget)]
  $conn($c,textWidget) insert end "\n" $tags [clock seconds] [concat $tags timestamp] $msg $tags
  if { $aE } {
       $conn($c,textWidget) see end
     }

  if { $world($conn($c,world),spawnSystem) } {
       foreach x [arraySubelem conn $c,spawns] {
          set aE [atEnd $conn($x)]
          if { [$conn($x) count -chars 1.0 3.0] > 1 } {
               set newline "\n"
             } else {
               set newline ""
             }
          $conn($x) insert end $newline $tags [clock seconds] [concat $tags timestamp] $msg $tags
          if { $aE } {
               $conn($x) see end
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
       foreach x [arraySubelem conn $c,spawns] {
          $conn($x) delete {*}[$conn($x) tag ranges $tag]
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

  tooltipLeave .;
  return;

};# ::potato::toggleConn

#: proc ::potato::showConn
#: arg c the connection to show
#: arg main if misc(toggleShowMainWindow) is true, should we show _main instead of a spawn?
#: desc show the window holding connection $c. This may require updating the list of worlds with new activity (and setting the idle var for the connection), and so on (meaning: maybe more?).
#: return nothing
proc ::potato::showConn {c {main 1}} {
  variable potato;
  variable world;
  variable conn;
  variable menu;
  variable misc;

  if { ![info exists conn($c,world)] } {
       bell -displayof .
       return;
     }

  set prevUp [up]
  if { $prevUp ne "" } {
       ::skin::$potato(skin)::unshow $prevUp
     }

  # We used to do this, but it led to problems during debugging if an error occurred during this proc, so now we don't
  #set potato(up) ""

  set state [expr {$c != 0 && $conn($c,connected) == 1}]

  ::skin::$potato(skin)::show $c
  set potato(up) $c
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
  ::skin::$potato(skin)::inputWindows [expr {$conn($c,twoInputWindows) + 1}]

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

  if { ![info exists conn($c,spawns,$spawn)] } {
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
  if { $c == 0 } {
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

  ::skin::${skin}::packskin
  #abc Surely this skin now needs to import a connection?
  set potato(skin) $skin
  set potato(skin,version) [set ::skin::${skin}::skin(version)]

  return;

};# ::potato::showSkin

#: proc ::potato::unshowSkin
#: desc Unshow the current skin
#: return nothing
proc ::potato::unshowSkin {} {
  variable potato;

  if { $potato(skin) ne "" } {
       ::skin::$potato(skin)::unpackskin
     }
  .m entryconfigure $menu(view) -menu {} -state disabled

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
  foreach spawn [removePrefix [arraySubelem conn $c,spawns] $c,spawns] {
    destroySpawnWindow $c $spawn
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
#: desc returns a list, where each element is a sublist of world id and world name. The list is not sorted in any particular order. Does not include world "-1", which is internal and used for "connection 0", the welcome screen.
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
  wm title $win "$potato(name) - $title"

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

  set world($w,name) $name
  set world($w,temp) $temp
  set world($w,host) $host
  set world($w,port) $port
  set world($w,id) $w

  set world($w,stats,conns) 0
  set world($w,stats,time) 0
  set world($w,stats,added) [clock seconds]

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
  # Unfortunately, we can't easily translate the word 'Copy' due to the regsub below.
  set hasCopy 0
  set copyCount [list]
  set namePtn "^[regsub -all {([^a-zA-Z0-9?*])} $world($new,name) {\\\1}] \\(Copy (\[0-9\]+)\\)$"
  foreach x [array names world *,name] {
    if { $x eq "$w,name" || $x eq "$new,name" } {
         continue;
       }
    if { $world($x) eq "$world($new,name) (Copy)" } {
         set hasCopy 1
       } elseif { [regexp $namePtn $world($x) {} num] } {
         lappend copyCount $num
       }
  }
  if { !$hasCopy } {
       set world($new,name) "$world($new,name) (Copy)"
     } else {
       # First available number...
       set copyCount [lsort -integer $copyCount]
       for {set num 1} {$num < 100 && $num in $copyCount} {incr num} {continue}
       if { $num == 100 } {
            # We already have 99 copies. Feh, just use (Copy) again
            set world($new,name) "$world($new,name) (Copy)"
          } else {
            set world($new,name) "$world($new,name) (Copy $num)"
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

  $tree heading Name -text Name
  $tree heading Commands -text Commands
  $tree column Name -width 80 -stretch 0
  $tree column Commands -width 150 -stretch 1
  bind $tree <<TreeviewSelect>> [list ::potato::macroWindowState $w]

  pack $tframe -side top -padx 10 -pady 10 -expand 1 -fill both

  pack [set bframe [::ttk::frame $left.bframe]] -side top -anchor n -pady 13

  pack [set add [::ttk::button $bframe.add -image ::potato::img::event-new \
            -command [list potato::macroWindowAdd $w]]] -side left -padx 8
  tooltip $add [T "Add Macro"]
  pack [set edit [::ttk::button $bframe.edit -image ::potato::img::event-edit \
            -command [list potato::macroWindowEdit $w]]] -side left -padx 8
  tooltip $edit [T "Edit Macro"]
  pack [set delete [::ttk::button $bframe.delete -image ::potato::img::event-delete \
            -command [list potato::macroWindowDelete $w]]] -side top -padx 8
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

#: proc ::potato::eventConfig
#: arg w world id, defaults to ""
#: desc show the event (gag/trigger/highlight/spawn) config window for world $w, or the world of the connection currently displayed if $w is ""
#: return nothing
proc ::potato::eventConfig {{w ""}} {
  variable world;
  variable conn;
  variable eventConfig;

  if { $w eq "" } {
       set w $conn([up],world)
     }

  set win .eventConfig_$w
  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  toplevel $win
  wm withdraw $win
  if { $w == -1 } {
       wm title $win [T "Global Event Configuration"]
     } else {
       wm title $win [T "%s - Event Configuration" $world($w,name)]
     }

  pack [set frame [::ttk::frame $win.frame]] -side left -anchor nw -expand 1 -fill both

  set eventConfig($w,conf,internalList) $world($w,events)
  foreach x $eventConfig($w,conf,internalList) {
     lappend eventConfig($w,conf,displayList) "$world($w,events,$x,pattern)   ($world($w,events,$x,matchtype))"
  }

  set leftList [list]

  ::ttk::frame $frame.left
  # Holds the listbox with current g/t/h/s in
  pack [::ttk::frame $frame.left.top] -side top -expand 1 -fill both
  set lb [listbox $frame.left.top.lb \
                   -xscrollcommand [list $frame.left.top.sbX set] \
                   -yscrollcommand [list $frame.left.top.sbY set] \
                   -listvariable potato::eventConfig($w,conf,displayList) -font [list Courier 9]\
                   -selectmode single -height 10 -width 25]
  lappend leftList $lb
  set sbX [::ttk::scrollbar $frame.left.top.sbX -orient horizontal -command [list $lb xview]]
  set sbY [::ttk::scrollbar $frame.left.top.sbY -orient vertical -command [list $lb yview]]
  grid_with_scrollbars $lb $sbX $sbY

  # Move up/Move down buttons, and Add/Edit/Delete buttons
  pack [::ttk::frame $frame.left.btm] -side top -fill x -pady 5
  pack [::ttk::frame $frame.left.btm.move] -side top -fill x -pady 5
  pack [::ttk::frame $frame.left.btm.move.up] -side left -expand 1 -fill x
  pack [set up [::ttk::button $frame.left.btm.move.up.btn -image ::potato::img::uparrow \
            -command [list potato::eventMove $w -1]]] -side top -anchor center
  tooltip $up [T "Move Up"]
  lappend leftList $up
  pack [::ttk::frame $frame.left.btm.move.down] -side left -expand 1 -fill x
  pack [set down [::ttk::button $frame.left.btm.move.down.btn -image ::potato::img::downarrow \
            -command [list potato::eventMove $w 1]]] -side top -anchor center
  tooltip $down [T "Move Down"]
  lappend leftList $down

  pack [::ttk::frame $frame.left.btm.addeditdel] -side top -fill x -pady 5
  pack [::ttk::frame $frame.left.btm.addeditdel.add] -side left -expand 1 -fill x
  pack [set add [::ttk::button $frame.left.btm.addeditdel.add.btn -image ::potato::img::event-new \
            -command [list potato::eventAdd $w]]] -side top -anchor center
  tooltip $add [T "Add Event"]
  lappend leftList $add
  lappend bindings $add a
  pack [::ttk::frame $frame.left.btm.addeditdel.edit] -side left -expand 1 -fill x
  pack [set edit [::ttk::button $frame.left.btm.addeditdel.edit.btn -image ::potato::img::event-edit \
            -command [list potato::eventConfigSelect $w 1]]] -side top -anchor center
  tooltip $edit [T "Edit Event"]
  lappend leftList $edit
  pack [::ttk::frame $frame.left.btm.addeditdel.delete] -side left -expand 1 -fill x
  pack [set delete [::ttk::button $frame.left.btm.addeditdel.delete.btn -image ::potato::img::event-delete \
            -command [list potato::eventDelete $w]]] -side top -anchor center
  tooltip $delete [T "Delete Event"]
  lappend leftList $delete

  bind $lb <Double-1> [string map [list <World> $w] { if { [%W cget -state] eq "normal" } { potato::eventConfigSelect <World> 1}}]
  bind $lb <<ListboxSelect>> [list potato::eventListboxSelect $w]

  $lb selection set end

  ##########

  set rightList [list]

  ::ttk::frame $frame.right
  pack [::ttk::frame $frame.right.row01] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $frame.right.row01.l -text [T "Pattern:"] -width 10 -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::entry $frame.right.row01.e -textvariable potato::eventConfig($w,pattern)] -side left -anchor nw \
                     -padx 2 -expand 1 -fill x
  lappend rightList $frame.right.row01.e
  
  pack [::ttk::frame $frame.right.row02] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::frame $frame.right.row02.type] -side left -anchor nw
  pack [::ttk::label $frame.right.row02.type.l -text [T "Type:"] -width 10 -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::combobox $frame.right.row02.type.cb -values [list wildcard regexp contains] \
             -textvariable potato::eventConfig($w,matchtype) -state readonly] -side left -anchor nw -padx 2 -expand 1
  lappend rightList $frame.right.row02.type.cb
  pack [::ttk::frame $frame.right.row02.case] -side left -anchor nw -padx 4
  pack [::ttk::label $frame.right.row02.case.l -text [T "Case?"]] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $frame.right.row02.case.cb -variable potato::eventConfig($w,case) \
              -onvalue 1 -offvalue 0] -side left -anchor nw -padx 2
  lappend rightList $frame.right.row02.case.cb

  pack [::ttk::frame $frame.right.row03] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::frame $frame.right.row03.enabled] -side left -anchor nw
  pack [::ttk::label $frame.right.row03.enabled.l -text [T "Enabled?"] -width 10 -justify left -anchor w] \
         -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $frame.right.row03.enabled.cb -variable potato::eventConfig($w,enabled) \
              -onvalue 1 -offvalue 0] -side left -anchor nw -padx 2
  lappend rightList $frame.right.row03.enabled.cb
  pack [::ttk::frame $frame.right.row03.continue] -side left -anchor nw -padx 4
  pack [::ttk::label $frame.right.row03.continue.l -text [T "Continue?"] -justify left -anchor w] \
              -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $frame.right.row03.continue.cb -variable potato::eventConfig($w,continue) \
              -onvalue 1 -offvalue 0] -side left -anchor nw -padx 2
  lappend rightList $frame.right.row03.continue.cb

  pack [::ttk::frame $frame.right.row04] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::frame $frame.right.row04.inactive] -side left -anchor nw
  pack [::ttk::label $frame.right.row04.inactive.l -text [T "Run When:"] -width 10 -justify left -anchor w] \
              -side left -anchor nw -padx 2
  # These values not currently translatable
  pack [::ttk::combobox $frame.right.row04.inactive.cb -values [list {Always} {Not Up} {No Focus} {Inactive}] \
              -textvariable potato::eventConfig($w,inactive) -state readonly] -side left -anchor nw -padx 2
  lappend rightList $frame.right.row04.inactive.cb

  set bg [list "Don't Change" "Normal FG" "Normal BG"]
  set fg $bg
  lappend fg "ANSI Highlight"
  foreach x [list Red Green Blue Cyan Magenta Yellow Black White] {
     lappend fg $x "$x Highlight"
     lappend bg $x
  }

  pack [::ttk::frame $frame.right.row05] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $frame.right.row05.l -text [T "Change FG:"] -width 10 -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::combobox $frame.right.row05.cb -values $fg -textvariable potato::eventConfig($w,fg) -state readonly] \
              -side left -anchor nw -padx 2
  lappend rightList $frame.right.row05.cb

  pack [::ttk::frame $frame.right.row06] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $frame.right.row06.l -text [T "Change BG:"] -width 10 -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::combobox $frame.right.row06.cb -values $bg -textvariable potato::eventConfig($w,bg) -state readonly] \
              -side left -anchor nw -padx 2
  lappend rightList $frame.right.row06.cb
  unset fg bg

  pack [::ttk::frame $frame.right.row07] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $frame.right.row07.l -text [T "Omit From:"] -width 10 -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::label $frame.right.row07.dispL -text [T "Display?"]] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $frame.right.row07.dispCB -variable potato::eventConfig($w,omit) \
               -onvalue 1 -offvalue 0] -side left -anchor nw
  lappend rightList $frame.right.row07.dispCB
  pack [::ttk::label $frame.right.row07.logL -text [T "Logs?"]] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $frame.right.row07.logCB -variable potato::eventConfig($w,log) \
               -onvalue 1 -offvalue 0] -side left -anchor nw
  lappend rightList $frame.right.row07.logCB

  pack [::ttk::frame $frame.right.row08] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $frame.right.row08.l -text [T "Spawn?"] -width 10 -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $frame.right.row08.cb -variable potato::eventConfig($w,spawn) \
                -onvalue 1 -offvalue 0] -side left -anchor nw
  pack [::ttk::label $frame.right.row08.l2 -text [T "Spawn To:"] -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::entry $frame.right.row08.e -textvariable potato::eventConfig($w,spawnTo)] -side left -anchor nw \
                     -padx 2 -expand 1 -fill x
  lappend rightList $frame.right.row08.cb $frame.right.row08.e

  pack [::ttk::frame $frame.right.row09] -side top -anchor nw -expand 1 -fill x -padx 5 -pady 2
  pack [::ttk::label $frame.right.row09.l -text [T "Send:"] -width 10 -justify left -anchor w] -side left -anchor nw -padx 2
  pack [set send [text $frame.right.row09.t -width 35 -height 4]] -side left -anchor nw -expand 1 -fill x
  lappend rightList $frame.right.row09.t

  pack [::ttk::frame $frame.right.row10] -side top -anchor nw -expand 1 -fill x -padx 5 -pady 2
  pack [::ttk::frame $frame.right.row10.left] -side left -anchor nw -fill x -padx 2
  pack [::ttk::label $frame.right.row10.left.l -text [T "Input:"] -width 10 -justify left -anchor w] -side top -anchor nw
  pack [::ttk::combobox $frame.right.row10.left.cb -width 5 -values [list None One Two Focus] \
                 -textvariable potato::eventConfig($w,input,window) -state readonly] -side top -anchor nw
  lappend rightList $frame.right.row10.left.cb
  pack [::ttk::frame $frame.right.row10.right] -side left -anchor nw -expand 1 -fill both
  pack [set input [text $frame.right.row10.right.t -width 35 -height 2]] -side left -anchor nw -expand 1 -fill both
  lappend rightList $frame.right.row10.right.t

  pack [::ttk::frame $frame.right.rowBtns] -side top -anchor nw -expand 1 -fill x -padx 5 -pady 15
  pack [::ttk::frame $frame.right.rowBtns.save] -side left -anchor nw -expand 1 -fill x -padx 5
  pack [::ttk::button $frame.right.rowBtns.save.btn -text [T "Save"] -width 8 -underline 0 \
             -command [list potato::eventSave $w]] -side top -anchor e -padx 9
  bind $win <Alt-s> [list $frame.right.rowBtns.save.btn invoke]
  lappend rightList $frame.right.rowBtns.save.btn
  pack [::ttk::frame $frame.right.rowBtns.discard] -side left -anchor nw -expand 1 -fill x -padx 5
  pack [::ttk::button $frame.right.rowBtns.discard.btn -text [T "Discard"] -width 8 -underline 0 \
             -command [list potato::eventConfigClear $w]] \
             -side top -anchor w -padx 9
  bind $win <Alt-d> [list $frame.right.rowBtns.discard.btn invoke]
  lappend rightList $frame.right.rowBtns.discard.btn

  pack $frame.left -in $frame -side left -expand 1 -fill both -padx 5 -pady 5
  pack $frame.right -in $frame -side left -expand 0 -fill y -padx 5 -pady 5

  set eventConfig($w,conf,left) $leftList
  set eventConfig($w,conf,right) $rightList
  set eventConfig($w,conf,lb) $lb
  set eventConfig($w,conf,input) $input
  set eventConfig($w,conf,send) $send
  set eventConfig($w,conf,up) $up
  set eventConfig($w,conf,down) $down
  set eventConfig($w,conf,add) $add
  set eventConfig($w,conf,edit) $edit
  set eventConfig($w,conf,delete) $delete

  eventConfigClear $w
  eventListboxSelect $w

  bind $win <Destroy> [list array unset potato::eventConfig $w,*]
  bind $win <Escape> [list destroy $win]

  bind $win <F1> [list ::wikihelp::help]

  update idletasks
  center $win
  wm deiconify $win
  wm minsize $win [winfo reqwidth $win] [winfo reqheight $win]
  update
  return;

};# ::potato::eventConfig

#: proc ::potato::eventMove
#: arg w world id
#: arg dir direction to move; -1 (up) or 1 (down)
#: desc move an element in the list of gth's for world $w up or down
#: return nothing
proc ::potato::eventMove {w dir} {
  variable eventConfig;
  variable world;

  set index [$eventConfig($w,conf,lb) curselection]
  set newIndex $index
  incr newIndex $dir

  foreach x [list internalList displayList] {
     set thiselem [lindex $eventConfig($w,conf,$x) $index]
     set thatelem [lindex $eventConfig($w,conf,$x) $newIndex]
     set eventConfig($w,conf,$x) [lreplace $eventConfig($w,conf,$x) $index $index $thatelem]
     set eventConfig($w,conf,$x) [lreplace $eventConfig($w,conf,$x) $newIndex $newIndex $thiselem]
  }

  set world($w,events) $eventConfig($w,conf,internalList)
  $eventConfig($w,conf,lb) selection clear 0 end
  $eventConfig($w,conf,lb) selection set $newIndex
  eventListboxSelect $w

  return;

};# ::potato::eventMove

#: proc ::potato::eventDelete
#: arg w world id
#: desc delete the currently selected gth for world $w
#: return nothing
proc ::potato::eventDelete {w} {
  variable eventConfig;
  variable world;

  set pos [$eventConfig($w,conf,lb) curselection]
  if { $pos eq "" } {
       return;
     }

  set x [lindex $eventConfig($w,conf,internalList) $pos]
  set eventConfig($w,conf,internalList) [lreplace $eventConfig($w,conf,internalList) $pos $pos]
  set eventConfig($w,conf,displayList) [lreplace $eventConfig($w,conf,displayList) $pos $pos]
  set world($w,events) $eventConfig($w,conf,internalList)
  array unset world $w,events,$x,*
  eventListboxSelect $w

  return;

};# ::potato::eventDelete

#: proc ::potato::eventAdd
#: arg w world id
#: desc add a new event for world $w and start editing it
#: return nothing
proc ::potato::eventAdd {w} {
  variable eventConfig;
  variable world;

  set ids $eventConfig($w,conf,internalList)
  if { [llength $ids] == 0 } {
       set x 0
     } else {
       set ids [lsort -integer $ids]
       set x [lindex $ids end]
       incr x
     }

  set world($w,events,$x,pattern) ""
  set world($w,events,$x,pattern,int) "^$"
  set world($w,events,$x,enabled) 1
  set world($w,events,$x,continue) 0
  set world($w,events,$x,case) 1
  set world($w,events,$x,matchtype) "wildcard"
  set world($w,events,$x,inactive) "always"
  set world($w,events,$x,omit) 0
  set world($w,events,$x,log) 0
  set world($w,events,$x,fg) ""
  set world($w,events,$x,bg) ""
  set world($w,events,$x,send) ""
  set world($w,events,$x,spawn) 0
  set world($w,events,$x,spawnTo) ""
  set world($w,events,$x,input,window) 0
  set world($w,events,$x,input,string) ""


  lappend world($w,events) $x
  lappend eventConfig($w,conf,internalList) $x
  lappend eventConfig($w,conf,displayList) "$world($w,events,$x,pattern)   ($world($w,events,$x,matchtype))"
  set eventConfig($w,saved) 0
  $eventConfig($w,conf,lb) selection clear 0 end
  $eventConfig($w,conf,lb) selection set end
  eventListboxSelect $w
  $eventConfig($w,conf,edit) invoke

  return;

};# ::potato::eventAdd

#: proc ::potato::eventListboxSelect
#: arg w world id
#: desc configure the state of the buttons for manipulating the entries in the listbox widget when the selection changes or an entry is moved
#: return nothing
proc ::potato::eventListboxSelect {w} {
  variable eventConfig;

  if { [info exists eventConfig($w,conf,currentlyEdited)] && $eventConfig($w,conf,currentlyEdited) ne "" } {
       return; # make no changes while an entry is beind edited
     }

  set sel [$eventConfig($w,conf,lb) curselection]
  if { $sel eq "" } {
       $eventConfig($w,conf,edit) configure -state disabled
       $eventConfig($w,conf,delete) configure -state disabled
       $eventConfig($w,conf,up) configure -state disabled
       $eventConfig($w,conf,down) configure -state disabled
     } else {
       $eventConfig($w,conf,edit) configure -state normal
       $eventConfig($w,conf,delete) configure -state normal
       if { $sel == 0 } {
            $eventConfig($w,conf,up) configure -state disabled
          } else {
            $eventConfig($w,conf,up) configure -state normal
          }
       if { $sel == ([$eventConfig($w,conf,lb) index end] - 1) } {
            $eventConfig($w,conf,down) configure -state disabled
          } else {
            $eventConfig($w,conf,down) configure -state normal
          }
     }

  eventConfigSelect $w 0

  return;

};# ::potato::eventListboxSelect 

#: proc ::potato::eventSave
#: arg w world id
#: desc save the gth currently being edited for world $w, then clear the gth config window so another can be edited
proc ::potato::eventSave {w} {
  variable eventConfig;
  variable world;

  set this $eventConfig($w,conf,currentlyEdited)
  foreach x [list pattern matchtype case enabled continue omit log spawn spawnTo] {
     set world($w,events,$this,$x) $eventConfig($w,$x)
  }

  switch $eventConfig($w,inactive) {
     "Always"   { set world($w,events,$this,inactive) "always"}
     "Not Up"   { set world($w,events,$this,inactive) "world"}
     "No Focus" { set world($w,events,$this,inactive) "program"}
     "Inactive" { set world($w,events,$this,inactive) "inactive"}
  }

  foreach x [list fg bg] {
     set lower [string tolower $eventConfig($w,$x)]
     set lower [split $lower " "]
     if { $lower eq "don't change" } {
          set world($w,events,$this,$x) ""
        } elseif { [lindex $lower 0] eq "normal" } {
          set world($w,events,$this,$x) [lindex $lower 1]
        } else {
          if { [lindex $lower 0] eq "black" } {
               set world($w,events,$this,$x) "x"
             } elseif { [lindex $lower 0] eq "ansi" } {
               set world($w,events,$this,$x) "$x"
             } else {
               set world($w,events,$this,$x) [string range [lindex $lower 0] 0 0]
             }
          if { [llength $lower] == 2 && [lindex $lower 0] ne "normal" } {
               append world($w,events,$this,$x) "h"
             }
        }
  }

  set world($w,events,$this,input,window) [lsearch -exact [list None One Two Focus] $eventConfig($w,input,window)]
  
  set world($w,events,$this,input,string) [$eventConfig($w,conf,input) get 1.0 end-1c]
  set world($w,events,$this,send) [$eventConfig($w,conf,send) get 1.0 end-1c]

  set pos [lsearch -exact $eventConfig($w,conf,internalList) $this]
  set eventConfig($w,conf,displayList) [lreplace $eventConfig($w,conf,displayList) $pos $pos \
                    "$eventConfig($w,pattern)   ($eventConfig($w,matchtype))"]

  if { $world($w,events,$this,matchtype) eq "wildcard" } {
       set world($w,events,$this,pattern,int) [glob2Regexp $world($w,events,$this,pattern)]
     } else {
       set world($w,events,$this,pattern,int) ""
     }
  set eventConfig($w,saved) 1
  eventConfigClear $w
  return;

};# ::potato::eventSave

#: proc ::potato::eventConfigSelect
#: arg w world id
#: arg states Update the states of the Event Window widgets
#: desc set the eventConfig vars for world $w to the appropriate values for the element selected in the listbox, and change the state of all the widgets if appropriate
#: return nothing
proc ::potato::eventConfigSelect {w states} {
  variable eventConfig;
  variable world;

  set list $eventConfig($w,conf,internalList)
  set this [$eventConfig($w,conf,lb) curselection]

  # We turn these on, even if $states is 0, to make sure we can
  # insert into them correctly. If $states is 0, we turn them off
  # again at the end.
  foreach x $eventConfig($w,conf,right) {
     if { [winfo class $x] eq "TCombobox" } {
          $x configure -state readonly
        } else {
          $x configure -state normal
        }
  }

  if { $this eq "" } {
       # Clear all info
       foreach x [list pattern matchtype case enabled continue omit log spawn spawnTo] {
          set eventConfig($w,$x) ""
       }
       set eventConfig($w,inactive) "Always"
       set eventConfig($w,fg) ""
       set eventConfig($w,bg) ""
       set eventConfig($w,input,window) ""
       $eventConfig($w,conf,input) delete 1.0 end
       $eventConfig($w,conf,send) delete 1.0 end
       foreach x $eventConfig($w,conf,right) {
          $x configure -state disabled
        }
       # Deactivate the editing boxes again now that we've changed their values
       foreach x $eventConfig($w,conf,right) {
          $x configure -state disabled
        }
       return;
     }
  set this [lindex $list $this]

  if { $states } {
       set eventConfig($w,conf,currentlyEdited) $this
       foreach x $eventConfig($w,conf,left) {
          $x configure -state disabled
       }
     }

  # Now we have to set up all the vars.
  # This isn't as easy as [array set [array get]] because some need "special" values - namely,
  # the comboboxes, because it's too stupid to let you give a list of values to display /and/
  # a corresponding list of values to store in the variables. We also have a couple of text
  # widgets to insert stuff into.
  foreach x [list pattern matchtype case enabled continue omit log spawn spawnTo] {
     set eventConfig($w,$x) $world($w,events,$this,$x)
  }

  switch $world($w,events,$this,inactive) {
     "always"   { set eventConfig($w,inactive) "Always"}
     "world"    { set eventConfig($w,inactive) "Not Up"}
     "program"  { set eventConfig($w,inactive) "No Focus"}
     "inactive" { set eventConfig($w,inactive) "Inactive"}
  }

  set colours [list fg "Normal FG" bg "Normal BG" r "Red" g Green b Blue c Cyan m Magenta y Yellow x Black w White h " Highlight"]
  
  foreach x [list fg bg] {
     if { $world($w,events,$this,$x) eq "" } {
          set eventConfig($w,$x) "Don't Change"
        } elseif { [string length $world($w,events,$this,$x)] == 3 } {
          set eventConfig($w,$x) "ANSI Highlight"
        } else {
          set eventConfig($w,$x) [string map $colours $world($w,events,$this,$x)]
        }
  }

  unset colours

  set eventConfig($w,input,window) [lindex [list None One Two Focus] $world($w,events,$this,input,window)]

  $eventConfig($w,conf,input) delete 1.0 end
  $eventConfig($w,conf,input) insert end $world($w,events,$this,input,string)

  $eventConfig($w,conf,send) delete 1.0 end
  $eventConfig($w,conf,send) insert end $world($w,events,$this,send)
  if { $states } {
       # Put focus into the editing boxes
       focus [lindex $eventConfig($w,conf,right) 0]
     } else {
       # Deactivate the editing boxes again now that we've changed their values
       foreach x $eventConfig($w,conf,right) {
          $x configure -state disabled
        }
     }


  return;

};# ::potato::eventConfigSelect

#: proc ::potato::eventConfigClear
#: arg w world id
#: desc clear all the vars used to store gth config info for world $w, deactivate all the widgets for entering info, and activate those on the left for editing the list.
#: return nothing
proc ::potato::eventConfigClear {w} {
  variable eventConfig;

  array set temp [array get eventConfig $w,conf,*]
  if { [info exists eventConfig($w,saved)] && !$eventConfig($w,saved) } {
       set delete 1
     } else {
       set delete 0
     }
  array unset eventConfig $w,*
  set eventConfig($w,pattern) ""
  set eventConfig($w,spawnTo) ""
  # Set checkboxes to 0
  foreach x [list case enabled continue log omit spawn] {
    set eventConfig($w,$x) 0
  }
  array set eventConfig [array get temp]
  # Make sure we can edit the text widgets
  $eventConfig($w,conf,input) configure -state normal
  $eventConfig($w,conf,send) configure -state normal
  $eventConfig($w,conf,input) delete 1.0 end
  $eventConfig($w,conf,send) delete 1.0 end

  foreach x $eventConfig($w,conf,right) {
     $x configure -state disabled
  }
  foreach x $eventConfig($w,conf,left) {
     $x configure -state normal
  }

  #focus [lindex $eventConfig($w,conf,left) 0]
  unset -nocomplain eventConfig($w,conf,currentlyEdited)
  if { $delete } {
       eventDelete $w
     }
  eventConfigSelect $w 0
  return;

};# ::potato::eventConfigClear

#: proc ::potato::center
#: arg win a toplevel widget
#: desc center window $win on the screen
#: return nothing
proc ::potato::center {win} {
  # Center window $win on the screen

  set w [winfo width $win]
  set h [winfo height $win]

  set sh [winfo screenheight $win]
  set sw [winfo screenwidth $win]

  set reqX [expr {($sw-$w)/2}]
  set reqY [expr {($sh-$h)/2}]

  wm geometry $win +$reqX+$reqY
  update idletasks
  after 10
  return;

};# ::potato::center

#: proc ::potato::configureWorld
#: arg w world id, defaults to ""
#: arg autosave Automatically invoke the 'Save' button after creating the window? defaults to 0
#: desc show the configuration dialog for world $w, or the world of the connection currently displayed if $w is "". If any part of this needs to create a popup, it should be named ${worldConfigToplevel}_subToplevel_<description> - this will cause it to be automatically destroyed when the $worldConfigToplevel is destroyed. If $autosave is true, as soon as the window is correctly set up, invoke the save button to destroy it and initiate an update of the settings. Used if settings are changed programatically (via Import Settings, etc) to trigger a full update.
#: return nothing
proc ::potato::configureWorld {{w ""} {autosave 0}} {
  variable world;
  variable conn;
  variable worldconfig;
  variable potato;
  variable misc;

  if { $w eq "" } {
       set w $conn([up],world)
     }

  if { ![info exists world($w,name)] } {
       return;
     }

  set win .configure_$w
  if { [winfo exists $win] } {
       # This needs to be different when autosave is 1, some how.
       reshowWindow $win
       return;
     }
  toplevel $win
  if { $w == -1 } {
       wm title $win [T "Program Configuration for %s" $potato(name)];
     } else {
       wm title $win [T "Configuration Options for '%s'" $world($w,name)]
     }

  pack [set inner [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw

  pack [::ttk::panedwindow $inner.top -orient horizontal] -side top -expand 1 -fill both -padx 3 -pady 3
  $inner.top add [::ttk::frame $inner.top.left]
  set tree [::ttk::treeview $inner.top.left.tree -yscrollcommand [list $inner.top.left.sby set] \
             -xscrollcommand [list $inner.top.left.sbx set] -show tree -selectmode browse]
  set OPTIONTREE $tree
  ::ttk::scrollbar $inner.top.left.sby -orient vertical -command [list $inner.top.left.tree yview]
  ::ttk::scrollbar $inner.top.left.sbx -orient horizontal -command [list $inner.top.left.tree xview]
  grid_with_scrollbars $inner.top.left.tree $inner.top.left.sbx $inner.top.left.sby

  $inner.top add [::ttk::frame $inner.top.right]
  set canvas [canvas $inner.top.right.c -width 450 -height 350 \
                      -yscrollcommand [list $inner.top.right.sby set] \
                      -xscrollcommand [list $inner.top.right.sbx set] \
                      -borderwidth 0 -highlightthickness 0 -scrollregion [list 0 0 250 450]]
  catch {$inner.top.right.c configure -background [::ttk::style lookup $inner -background]}
  ::ttk::scrollbar $inner.top.right.sby -orient vertical -command [list $inner.top.right.c yview]
  ::ttk::scrollbar $inner.top.right.sbx -orient horizontal -command [list $inner.top.right.c xview]
  grid_with_scrollbars $inner.top.right.c $inner.top.right.sbx $inner.top.right.sby

  pack [::ttk::frame $inner.btm] -side top -expand 0 -fill x
  pack [::ttk::frame $inner.btm.button] -side top -pady 8 -anchor n
  pack [::ttk::button $inner.btm.button.ok -text [T "OK"] -width 8 -default active \
               -command [list ::potato::configureWorldCommit $w $win]] -side left -padx 25 -anchor n

  pack [::ttk::button $inner.btm.button.cancel -text [T "Cancel"] -width 8 \
               -command [list destroy $win]] -side left -padx 25 -anchor n

  array set worldconfig [array get world $w,*]
  array unset worldconfig $w,events* ;# handled by potato::eventConfig

  # Basics page
  set frame [configureFrame $canvas [T "Basic Settings"]]
  set confBasics [lindex $frame 0]
  set frame [lindex $frame 1]
  pack [set sub [::ttk::frame $frame.name]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "World Name:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,name) -width 50] -side left -padx 3

  pack [set sub [::ttk::frame $frame.host]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "1st Address:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,host) -width 50] -side left -padx 3  

  pack [set sub [::ttk::frame $frame.port]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "1st Port:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,port) -width 50] -side left -padx 3

  pack [set sub [::ttk::frame $frame.ssl]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Use SSL?:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,ssl) -onvalue 1 -offvalue 0] -side left -padx 3

  pack [set sub [::ttk::frame $frame.host2]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "2nd Address:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,host2) -width 50] -side left -padx 3  

  pack [set sub [::ttk::frame $frame.port2]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "2nd Port:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,port2) -width 50] -side left -padx 3

  pack [set sub [::ttk::frame $frame.ssl2]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Use SSL?:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,ssl2) -onvalue 1 -offvalue 0] -side left -padx 3

  pack [::ttk::separator $frame.sep1 -orient horizontal] -fill x -padx 20 -pady 5

  #pack [set sub [::ttk::frame $frame.charname]] -side top -pady 5 -anchor nw
  #pack [::ttk::label $sub.label -text [T "Character Name:"] -width 17 -justify left -anchor w] -side left -padx 3
  #pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,charName) -width 50] -side left -padx 3

  if { $w != -1 } {
       pack [set sub [::ttk::frame $frame.charDefault]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.label -text [T "Default Char:"] -width 17 -justify left -anchor w] -side left -padx 3
       pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig($w,charDefault) \
                  -postcommand [list ::potato::configureWorldCharsLBUpdate $w $sub.cb] \
                  -width 20 -state readonly] -side left -padx 3
       if { $worldconfig($w,charDefault) eq "" } {
            set worldconfig($w,charDefault) "No Default Character"
          }
     }

  pack [set sub [::ttk::frame $frame.desc]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Description:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,desc) -width 50] -side left -padx 3

  pack [::ttk::separator $frame.sep2 -orient horizontal] -fill x -padx 20 -pady 5

  pack [set sub [::ttk::frame $frame.proxyType]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Proxy Type:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig($w,proxy) \
             -values [list None SOCKS4] -width 20 -state readonly] -side left -padx 3
#             -values [list None HTTP SOCKS4 SOCKS5] -width 20 -state readonly] -side left -padx 3

  pack [set sub [::ttk::frame $frame.phost]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Proxy Host:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,proxy,host) -width 50] -side left -padx 3  

  pack [set sub [::ttk::frame $frame.pport]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Proxy Port:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,proxy,port) -width 50] -side left -padx 3

  pack [::ttk::separator $frame.sep3 -orient horizontal] -fill x -padx 20 -pady 5

  pack [set sub [::ttk::frame $frame.mushType]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "MU* Type:"] -width 17 -justify left -anchor w] -side left -padx 3
  pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig($w,type) \
             -values [list Auto MUD MUSH] -width 20 -state readonly] -side left -padx 3

  if { $w != -1 } {
       # Character page
       set frame [configureFrame $canvas [T "Characters"]]
       set confChar [lindex $frame 0]
       set frame [lindex $frame 1]

       pack [set sub [::ttk::frame $frame.tree]] -anchor nw -expand 1 -fill x
       set tree [ttk::treeview $sub.tree -show {} -selectmode browse -columns [list "Characters"] \
                     -xscrollcommand [list $sub.x set] \
                     -yscrollcommand [list $sub.y set] -height 5]
       $sub.tree column Characters -width 200
       ttk::scrollbar $sub.x -orient horizontal -command [list $sub.tree xview]
       ttk::scrollbar $sub.y -orient vertical -command [list $sub.tree yview]
       grid_with_scrollbars $sub.tree $sub.x $sub.y

       pack [set sub [::ttk::frame $frame.edit]] -anchor nw -expand 1 -fill x -pady 7

       ::ttk::label $sub.charL -text [T "Character:"]
       set char [::ttk::entry $sub.charE -width 30]

       ::ttk::label $sub.pwL -text [T "Password:"]
       set pw [::ttk::entry $sub.pwE -width 30 -show \u25cf]


       set save [::ttk::button $sub.save -text [T "Save"] -command [list ::potato::configureWorldCharsFinish $w 1]]
       set cancel [::ttk::button $sub.cancel -text [T "Cancel"] -command [list ::potato::configureWorldCharsFinish $w 0]]

       grid $sub.charL $sub.charE $save
       grid $sub.pwL $sub.pwE $cancel
       grid columnconfigure $sub $sub.charE -weight 1 -uniform entry
       grid columnconfigure $sub $sub.pwE -weight 1 -uniform entry
       grid columnconfigure $sub $sub.charL -uniform label
       grid columnconfigure $sub $sub.pwL -uniform label
       grid columnconfigure $sub $sub.save -uniform button
       grid columnconfigure $sub $sub.cancel -uniform button
       grid configure $sub.charE $sub.pwE -sticky ew -padx 6 -pady 6
       grid configure $sub.save $sub.cancel -sticky ew -padx 10

       pack [set sub [::ttk::frame $frame.btns]] -anchor n -expand 0 -fill none -pady 7
       set add [::ttk::button $sub.add -text [T "Add Character"] -command [list ::potato::configureWorldCharsAddEdit $w 1]]
       set edit [::ttk::button $sub.edit -text [T "Edit Character"] -command [list ::potato::configureWorldCharsAddEdit $w 0]]
       set del [::ttk::button $sub.del -text [T "Delete Character"] -command [list ::potato::configureWorldCharsDelete $w]]
       grid $sub.add $sub.edit $sub.del -padx 6

       set worldconfig($w,CONFIG,chars,saveBtn) $save
       set worldconfig($w,CONFIG,chars,cancelBtn) $cancel
       set worldconfig($w,CONFIG,chars,tree) $tree
       set worldconfig($w,CONFIG,chars,addBtn) $add
       set worldconfig($w,CONFIG,chars,delBtn) $del
       set worldconfig($w,CONFIG,chars,editBtn) $edit
       set worldconfig($w,CONFIG,chars,charEntry) $char
       set worldconfig($w,CONFIG,chars,pwEntry) $pw

       configureWorldCharsPropagate $w ""
     }


  # Connection page
  set frame [configureFrame $canvas [T "Connection Settings"]]
  set confConn [lindex $frame 0]
  set frame [lindex $frame 1]

  pack [set sub [::ttk::frame $frame.autorec]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Auto Reconnect when booted?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,autoreconnect) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.autorecTime]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Auto Reconnect after (seconds):"] \
             -width 35 -justify left -anchor w] -side left -padx 3
  pack [spinbox $sub.spin -textvariable ::potato::worldconfig($w,autoreconnect,time) -from 0 -to 3600 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.encStart]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Starting Encoding:"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig($w,encoding,start) -width 20 -state readonly] -side left -padx 3
  if { $potato::worldconfig($w,encoding,start) ni [encoding names] } {
       $sub.cb config -values [lsort -dictionary [concat [encoding names] $potato::worldconfig($w,encoding,start)]]
     } else {
       $sub.cb config -values [lsort -dictionary [encoding names]]
     }

  pack [set sub [::ttk::frame $frame.encNegotiate]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Negotiate Encoding?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,encoding,negotiate) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.loginStr]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Login Format:"] -width 35  -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,loginStr) -width 20] -side left -padx 3

  pack [set sub [::ttk::frame $frame.loginDelay]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Send Login Details after (seconds):"] \
             -width 35 -justify left -anchor w] -side left -padx 3
  pack [spinbox $sub.spin -textvariable ::potato::worldconfig($w,loginDelay) -from 0 -to 60 -increment 0.5 \
             -validate all -validatecommand {string is double %P} -width 6] -side left


  # Connection -> Telnet
  set frame [configureFrame $canvas [T "Telnet Options"]]
  set confConnTelnet [lindex $frame 0]
  set frame [lindex $frame 1]

  pack [set sub [::ttk::frame $frame.telnet]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Attempt Telnet Negotiation?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,telnet) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.encStart]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Starting Encoding:"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig($w,encoding,start) -width 20 -state readonly] -side left -padx 3
  if { $potato::worldconfig($w,encoding,start) ni [encoding names] } {
       $sub.cb config -values [lsort -dictionary [concat [encoding names] $potato::worldconfig($w,encoding,start)]]
     } else {
       $sub.cb config -values [lsort -dictionary [encoding names]]
     }

  pack [set sub [::ttk::frame $frame.encNegotiate]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Negotiate Encoding?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,encoding,negotiate) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.ssl]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Negotiate SSL?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,telnet,ssl) -onvalue 1 -offvalue 0] -side left
$sub.cb state disabled
  pack [set sub [::ttk::frame $frame.naws]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Negotiate NAWS?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,telnet,naws) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.doTerm]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Send Client Info?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,telnet,term) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.termStr]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Send Client Name As:"] -width 35  -justify left -anchor w] -side left -padx 3
  pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,telnet,term,as) -width 20] -side left -padx 3


  # Colours/Fonts page
  set frame [configureFrame $canvas [T "ANSI, Colours and Fonts"]]
  set confColours [lindex $frame 0]
  set frame [lindex $frame 1]
  pack [set sub [::ttk::frame $frame.txt]] -side top -pady 5 -expand 1 -fill x
  pack [set outText [text $sub.out -width 20 -height 10 -wrap word \
               -background $worldconfig($w,top,bg) \
               -foreground [potato::reverseColour $worldconfig($w,top,bg)] \
               -cursor {} -font $worldconfig($w,top,font)]] -side top -expand 1 -fill x
  pack [set inText [text $sub.in -width 20 -height 3 -wrap word -background $worldconfig($w,bottom,bg) \
                     -foreground [potato::reverseColour $worldconfig($w,bottom,bg)] \
                     -cursor {} -font $worldconfig($w,bottom,font)]] -side top -expand 1 -fill x
  bindtags $outText [list $outText $win all]
  bindtags $inText [list $inText $win all]

  $outText tag configure change
  $outText tag bind change <Enter> [list ::potato::configureText $w Enter $outText]
  $outText tag bind change <Leave> [list ::potato::configureText $w Leave $outText]

  $inText tag configure change
  $inText tag bind change <Enter> [list ::potato::configureText $w Enter $inText]
  $inText tag bind change <Leave> [list ::potato::configureText $w Leave $inText]

  bind $outText <1> [list ::potato::configureText $w Click $outText top,bg]
  bind $inText <1> [list ::potato::configureText $w Click $inText bottom,bg]

  foreach {x y} [list [T "Normal Colours"] "" \
                      [T "Highlight Colours"] "h"] {
     $outText insert end "\n   $x:\n      "
     foreach {letter colour} [list N fg R r G g Bl b C c M m Y y Bk x W w] {
        $outText insert end $letter [list change ansi,$colour$y] "    "
        $outText tag configure ansi,$colour$y -foreground $worldconfig($w,ansi,$colour$y)
     }
     $outText insert end "\n"
  }
  $outText insert end "\n   [T "System, Echo and Link Colours"]:\n      "
  foreach {x y} [list [T "Sys"] ansi,system \
                      [T "Echo"] ansi,echo \
                      [T "Link"] ansi,link] {
     $outText insert end $x [list change $y] "   "
     $outText tag configure $y -foreground $worldconfig($w,$y)
  }
  $outText tag configure ansi,link -underline 1

  $inText insert end "\n   [T "Input Colour:"] "
  $inText insert end [T "Text"] [list change bottom,fg]
  $inText tag configure bottom,fg -foreground $worldconfig($w,bottom,fg)

  pack [set sub [::ttk::frame $frame.fonts]] -side top -pady 5 -expand 1 -fill x
  pack [::ttk::frame $sub.output] -side left -expand 1 -fill x
  pack [::ttk::label $sub.output.l -text [T "Change Output Font"] -width 23 -justify left -anchor w] -side left -anchor center 
  pack [::ttk::button $sub.output.b -image ::potato::img::dotdotdot -command [list potato::configureFont $w $win $outText top]] -side left -anchor center
  pack [::ttk::frame $sub.input] -side left -expand 1 -fill x
  pack [::ttk::label $sub.input.l -text [T "Change Input Font"] -width 23 -justify left -anchor w] -side left -anchor center 
  pack [::ttk::button $sub.input.b -image ::potato::img::dotdotdot -command [list potato::configureFont $w $win $inText bottom]] -side left -anchor center

  pack [set sub [::ttk::frame $frame.boxes1]] -side top -pady 5 -expand 1 -fill x
  pack [::ttk::frame $sub.left] -side left -expand 1 -fill x
  pack [::ttk::label $sub.left.l -text [T "Allow ANSI Colours?"] -width 23 -anchor w -justify left] -side left -anchor w
  pack [::ttk::checkbutton $sub.left.c -variable potato::worldconfig($w,ansi,colours) -onvalue 1 -offvalue 0] -side left -anchor w
  pack [::ttk::frame $sub.right] -side left -expand 1 -fill x
  pack [::ttk::label $sub.right.l -text [T "Allow ANSI Underline?"]  -width 23 -anchor w -justify left] -side left -anchor w
  pack [::ttk::checkbutton $sub.right.c -variable potato::worldconfig($w,ansi,underline) -onvalue 1 -offvalue 0] -side left -anchor w

  pack [set sub [::ttk::frame $frame.boxes2]] -side top -pady 5 -expand 1 -fill x
  pack [::ttk::frame $sub.left] -side left -expand 1 -fill x
  pack [::ttk::label $sub.left.l -text [T "Allow ANSI Flash?"] -width 23 -anchor w -justify left] -side left -anchor w
  pack [::ttk::checkbutton $sub.left.c -variable potato::worldconfig($w,ansi,flash) -onvalue 1 -offvalue 0] -side left -anchor w
  pack [::ttk::frame $sub.right] -side left -expand 1 -fill x
  pack [::ttk::label $sub.right.l -text [T "Force ANSI Normal?"] -width 23 -anchor w -justify left] -side left -anchor w
  pack [::ttk::checkbutton $sub.right.c -variable potato::worldconfig($w,ansi,force-normal) -onvalue 1 -offvalue 0] -side left -anchor w


  # Display: Misc
  set frame [configureFrame $canvas [T "Miscellaneous Display Options"]]
  set confDisplayMisc [lindex $frame 0]
  set frame [lindex $frame 1]

  pack [set sub [::ttk::frame $frame.wrap]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Wrap text at:"] -width 20 -anchor w -justify left] -side left
  pack [spinbox $sub.spin -textvariable ::potato::worldconfig($w,wrap,at) -from 0 -to 1000 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left
  pack [::ttk::button $sub.b -text " [T "Current Window Size"] " -command [list ::potato::currentWindowSize ::potato::worldconfig($w,wrap,at) $w 1000]] -side left -padx 8

  pack [set sub [::ttk::frame $frame.indent]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Indent By:"] -width 20 -anchor w -justify left] -side left
  pack [spinbox $sub.spin -textvariable ::potato::worldconfig($w,wrap,indent) -from 0 -to 20 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.echo]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Echo Sent Commands?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.cb -variable potato::worldconfig($w,echo) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.empty]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Ignore Empty Lines?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.cb -variable potato::worldconfig($w,ignoreEmpty) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.spawnSys]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Spawn Sys Messages?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.cb -variable potato::worldconfig($w,spawnSystem) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.inputWindows]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Two Input Windows?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.cb -variable potato::worldconfig($w,twoInputWindows) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.nbsp]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Convert NBSPs?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.cb -variable potato::worldconfig($w,convertNonBreakingSpaces) -onvalue 1 -offvalue 0] -side left

  # Activity Settings
  set frame [configureFrame $canvas [T "Activity Settings"]]
  set confAct [lindex $frame 0]
  set frame [lindex $frame 1]

  pack [set sub [::ttk::frame $frame.flash]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Flash Taskbar?"] -width 30 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig($w,act,flashTaskbar) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.flashSystray]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Flash SysTray Icon?"] -width 30 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig($w,act,flashSysTray) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.actInWorld]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Show 'Activity in <World>'?"] -width 30 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig($w,act,actInWorldNotice) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.newAct]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Show 'New Activity'?"] -width 30 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig($w,act,newActNotice) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.oldNewAct]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Clear Previous 'New Activity'?"] -width 30 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig($w,act,clearOldNewActNotices) -onvalue 1 -offvalue 0] -side left

  # Misc
  set frame [configureFrame $canvas [T "Miscellaneous Options"]]
  set confMisc [lindex $frame 0]
  set frame [lindex $frame 1]

  pack [set sub [::ttk::frame $frame.output]] -side top -pady 5 -anchor nw
  pack [::ttk::frame $sub.output] -side left -anchor nw
  pack [::ttk::label $sub.output.l -text [T "Limit Output Lines?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.output.cb -variable potato::worldconfig($w,outputLimit,on) -onvalue 1 -offvalue 0] -side left
  pack [::ttk::frame $sub.output-to] -padx 5 -side left
  pack [::ttk::label $sub.output-to.l -text [T "Limit To:"] -width 5] -side left
  pack [spinbox $sub.output-to.spin -textvariable ::potato::worldconfig($w,outputLimit,to) -from 0 -to 5000 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.spawn]] -side top -pady 5 -anchor nw
  pack [::ttk::frame $sub.spawn] -side left -anchor nw
  pack [::ttk::label $sub.spawn.l -text [T "Limit Spawn Lines?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.spawn.cb -variable potato::worldconfig($w,spawnLimit,on) -onvalue 1 -offvalue 0] -side left
  pack [::ttk::frame $sub.spawn-to] -padx 5 -side left
  pack [::ttk::label $sub.spawn-to.l -text [T "Limit To:"] -width 5] -side left
  pack [spinbox $sub.spawn-to.spin -textvariable ::potato::worldconfig($w,spawnLimit,to) -from 0 -to 5000 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.input]] -side top -pady 5 -anchor nw
  pack [::ttk::frame $sub.input] -side left -anchor nw
  pack [::ttk::label $sub.input.l -text [T "Limit Input Lines?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.input.cb -variable potato::worldconfig($w,inputLimit,on) -onvalue 1 -offvalue 0] -side left
  pack [::ttk::frame $sub.input-to] -padx 5 -side left
  pack [::ttk::label $sub.input-to.l -text [T "Limit To:"] -width 5] -side left
  pack [spinbox $sub.input-to.spin -textvariable ::potato::worldconfig($w,inputLimit,to) -from 0 -to 5000 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.telnet]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Split Input Cmds?"] -width 20 -justify left -anchor w] -side left
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,splitInputCmds) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.verbose]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Show Verbose Messages?"] -width 20 -justify left -anchor w] -side left
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,verbose) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.beepShow]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Show Beeps?"] -width 20 -justify left -anchor w] -side left
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,beep,show) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.beepSound]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Play Beeps?"] -width 20 -justify left -anchor w] -side left
  pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig($w,beep,sound) \
             -values [list All Once None] -width 20 -state readonly] -side left -padx 3

  # Timers
  set frame [configureFrame $canvas [T "Timers"]]
  set confTimers [lindex $frame 0]
  set frame [lindex $frame 1]

  pack [set mc [::ttk::frame $frame.mc]] -side top -anchor nw

  pack [set sub [::ttk::frame $frame.btns]] -side top -anchor s -pady 35 -padx 25
  pack [::ttk::button $sub.add -command [list ::potato::configureTimerAddEdit $w 1 ${win}_subToplevel_timerAE] -text [T "Add Timer"]] -padx 5 -side left
  pack [set tEdit [::ttk::button $sub.edit -command [list ::potato::configureTimerAddEdit $w 0 ${win}_subToplevel_timerAE] \
                                           -text [T "Edit Timer"] -state disabled]] -padx 5 -side left
  pack [set tDel [::ttk::button $sub.del -command [list ::potato::configureTimerDelete $w] -text [T "Delete Timer"] -state disabled]] -padx 5 -side left
  set worldconfig($w,timer,edit) $tEdit
  set worldconfig($w,timer,delete) $tDel

  ::ttk::treeview $mc.tree -columns [list Every Commands Frequency] -show [list tree headings] \
              -selectmode browse -xscrollcommand [list $mc.sbx set] -yscrollcommand [list $mc.sby set]
  ::ttk::scrollbar $mc.sbx -command [list $mc.tree xview] -orient horizontal
  ::ttk::scrollbar $mc.sby -command [list $mc.tree yview] -orient vertical
  grid_with_scrollbars $mc.tree $mc.sbx $mc.sby

  set worldconfig($w,timer,tree) $mc.tree
  $mc.tree heading #0 -text "E?"
  $mc.tree heading Every -text [T "Every"]
  $mc.tree heading Commands -text [T "Commands"]
  $mc.tree heading Frequency -text [T "Frequency"]
  $mc.tree column #0 -stretch 0 -width 30
  $mc.tree column "Every" -stretch 0 -width 65
  $mc.tree column "Commands" -stretch 1 -width 240
  $mc.tree column "Frequency" -stretch 0 -width 80
  bind $mc.tree <<TreeviewSelect>> [list ::potato::configureTimerSelect $mc.tree $w $tEdit $tDel]

  # Now we need to populate the list.
  set worldconfig($w,timer) -1
  set worldconfig($w,timer,active) {}
  foreach x [array names world -regexp "$w,timer,\[0-9\]+,cmds\$"] {
    if { ![scan $x $w,timer,%d,cmds timerId] } {
         continue;
       } 
    set worldconfig($w,timer,$timerId,delay) $world($w,timer,$timerId,delay)
    set worldconfig($w,timer,$timerId,every) $world($w,timer,$timerId,every)
    set worldconfig($w,timer,$timerId,cmds) [string map [list "\n" " \b "] $world($w,timer,$timerId,cmds)]
    set worldconfig($w,timer,$timerId,count) $world($w,timer,$timerId,count)
    set worldconfig($w,timer,$timerId,continuous) $world($w,timer,$timerId,continuous)
    set worldconfig($w,timer,$timerId,enabled) $world($w,timer,$timerId,enabled)
    potato::configureTimerShowRow $w $timerId
  }

  # Notes
  set frame [configureFrame $canvas [T "Notes"]]
  set confNotes [lindex $frame 0]
  set frame [lindex $frame 1]

  pack [text $frame.txt -height 20 -width 78 -undo 0 -wrap word -font TkFixedFont] -side top -anchor nw -fill both
  $frame.txt insert end $world($w,notes)
  set worldconfig($w,CONFIG,notes) $frame.txt
  $frame.txt configure -undo 1

  # F-commands
  set frame [configureFrame $canvas [T "F-Commands"]]
  set confFcmds [lindex $frame 0]
  set frame [lindex $frame 1]

  for {set i 2} {$i < 13} {incr i} {
     pack [set sub [::ttk::frame $frame.f$i]] -side top -pady 5 -anchor nw
     pack [::ttk::label $sub.label -text "F$i:" -width 8 -justify left -anchor w] -side left -padx 3
     pack [::ttk::entry $sub.entry -textvariable ::potato::worldconfig($w,fcmd,$i) -width 50] -side left -padx 3
  }

  # Auto-Sends
  if { $w != -1 } {
       set frame [configureFrame $canvas [T "Auto-Sends"]]
       set confAutoSends [lindex $frame 0]
       set frame [lindex $frame 1]

       pack [set sub [::ttk::frame $frame.connect]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Send before Login info:"]] -side top
       pack [set sub [::ttk::frame $sub.tframe]] -side top -pady 3 -anchor nw
       pack [text $sub.txt -height 10 -width 78 -undo 0 -wrap word -font TkFixedFont \
                    -yscrollcommand [list $sub.sb set]] -side left -anchor nw -fill both
       pack [::ttk::scrollbar $sub.sb -orient vertical -command [list $sub.txt yview]] -side right -fill y
       $sub.txt insert end $world($w,autosend,connect)
       $sub.txt configure -undo 1
       set worldconfig($w,CONFIG,autosend,connect) $sub.txt

       pack [set sub [::ttk::frame $frame.login]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Send after Login info:"]] -side top
       pack [set sub [::ttk::frame $sub.tframe]] -side top -pady 3 -anchor nw
       pack [text $sub.txt -height 10 -width 78 -undo 0 -wrap word -font TkFixedFont \
                    -yscrollcommand [list $sub.sb set]] -side left -anchor nw -fill both
       pack [::ttk::scrollbar $sub.sb -orient vertical -command [list $sub.txt yview]] -side right -fill y
       $sub.txt insert end $world($w,autosend,login)
       $sub.txt configure -undo 1
       set worldconfig($w,CONFIG,autosend,login) $sub.txt
     }

  # Program settings (Non-World)
  if { $w == -1 } {

       # Misc Program Settings
       set frame [configureFrame $canvas [T "Misc Settings"]]
       set confProgMisc [lindex $frame 0]
       set frame [lindex $frame 1]

       set lW 24

       pack [set sub [::ttk::frame $frame.browser]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Browser Command:"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::entry $sub.e -textvariable potato::worldconfig(MISC,browserCmd) -width 25] -side left
       set potato::worldconfig(MISC,browserCmd) $misc(browserCmd)

       pack [set sub [::ttk::frame $frame.aspell]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "ASpell executable:"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::entry $sub.e -textvariable potato::worldconfig(MISC,aspell) -width 25] -side left
       set potato::worldconfig(MISC,aspell) $misc(aspell)

       pack [set sub [::ttk::frame $frame.clock]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Clock Format:"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::entry $sub.e -textvariable potato::worldconfig(MISC,clockFormat) -width 25] -side left
       set potato::worldconfig(MISC,clockFormat) $misc(clockFormat)

       pack [set sub [::ttk::frame $frame.sysTray]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Show SysTray Icon?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,showSysTray) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,showSysTray) $misc(showSysTray)

       pack [set sub [::ttk::frame $frame.startMaximized]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Start Maximized?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,startMaximized) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,startMaximized) $misc(startMaximized)

       pack [set sub [::ttk::frame $frame.minToTray]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Minimize to SysTray?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,minToTray) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,minToTray) $misc(minToTray)

       pack [set sub [::ttk::frame $frame.confirmExit]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Confirm Exit?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,confirmExit) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,confirmExit) $misc(confirmExit)

       pack [set sub [::ttk::frame $frame.partialName]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Allow Partial Names?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,partialWorldMatch) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,partialWorldMatch) $misc(partialWorldMatch)

       pack [set sub [::ttk::frame $frame.toggleShowMain]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Toggle to Main Window?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,toggleShowMainWindow) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,toggleShowMainWindow) $misc(toggleShowMainWindow)

       pack [set sub [::ttk::frame $frame.externalRequest]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "External Requests:"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig(MISC,outsideRequestMethod) \
                        -values [list "Quick Connect" "Use World Settings" "Prompt"] -width 20 -state readonly] \
                        -side left -padx 3
       set potato::worldconfig(MISC,outsideRequestMethod) \
              [lindex [list "Quick Connect" "Use World Settings" "Prompt"] $misc(outsideRequestMethod)]

       if { ![catch {::ttk::style theme names} styles] } {
            pack [set sub [::ttk::frame $frame.tileTheme]] -side top -pady 5 -anchor nw
            pack [::ttk::label $sub.l -text [T "Widget Theme:"] -width $lW -anchor w -justify left] -side left
            pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig(MISC,tileTheme) \
                        -values $styles -width 20 -state readonly] -side left -padx 3
            set potato::worldconfig(MISC,tileTheme) $misc(tileTheme)
          }
     }

  set tree $OPTIONTREE
  if { $w == -1 } {
       set root [$tree insert {} end -text [T "Default World Settings"]]
     } else {
       set root {}
     }

  set treeBasics [$tree insert $root end -text [T "Basics"] -tags $confBasics]
  if { $w != -1 } {
       set treeChar [$tree insert $root end -text [T "Characters"] -tags $confChar]
     }
  set treeConn [$tree insert $root end -text [T "Connection"] -tags $confConn]
  set treeConnTelnet [$tree insert $treeConn end -text [T "Telnet Options"] -tags $confConnTelnet]
  set treeDisplay [$tree insert $root end -text [T "Display"]]
  set treeColours [$tree insert $treeDisplay end -text [T "ANSI, Colours and Fonts"] -tags $confColours]
  set treeAct [$tree insert $root end -text [T "Activity Settings"] -tags $confAct]
  set treeDisplayMisc [$tree insert $treeDisplay end -text [T "Miscellaneous"] -tags $confDisplayMisc]
  set treeMisc [$tree insert $root end -text [T "Miscellaneous"] -tags $confMisc]
  set treeFcmds [$tree insert $root end -text [T "F-Commands"] -tags $confFcmds]

  if { $w == -1  } {
       set treeNotes [$tree insert $root end -text [T "Notes"] -tags $confNotes]
       set root [$tree insert {} end -text [T "Program Settings"]]
       set treeProgMisc [$tree insert $root end -text [T "Misc Settings"] -tags $confProgMisc]
       set treeTimers [$tree insert $root end -text [T "Global Timers"] -tags $confTimers]
     } else {
       set treeTimers [$tree insert $root end -text [T "Timers"] -tags $confTimers]
       set treeAutoSends [$tree insert $root end -text [T "Auto-Sends"] -tag $confAutoSends]
       set treeNotes [$tree insert $root end -text [T "Notes"] -tags $confNotes]
     }

  set helplist [list $confBasics basics \
                     $confConn conn \
                     $confColours display,colours \
                     $confAct act \
                     $confDisplayMisc display,misc \
                     $confMisc misc \
                     $confNotes notes \
                     $confFcmds fcmds \
                ]
  set helplist2 [list]
  if { $w == -1 } {
       lappend helplist2 $confProgMisc misc $confTimers timers
     } else {
       lappend helplist $confTimers timers $confAutoSends autosends
     }
  bind $win <F1> [list ::potato::configureHelp $canvas $helplist $helplist2]

  $canvas create window 0 0 -anchor nw -width 450

  bind $tree <<TreeviewSelect>> [list ::potato::configureShow $canvas $tree]
  $tree selection set $treeBasics
  $tree see $treeBasics

  wm minsize $win [winfo reqwidth $win] [winfo reqheight $win]

  # We don't bind this to $win, because then it'll be inherited by all $win's children, and we want
  # to be able to nuke them at will. The OK button will only be destroyed with the main window.
  bind $inner.btm.button.ok <Destroy> [list ::potato::configureWorldCancel $w $win]
  bind $win <Escape> [list destroy $win]

  if { $autosave } {
       $inner.btm.button.ok invoke
     } else {
       update
       reshowWindow $win 0
     }

  return;

};# ::potato::configureWorld

interp alias {} !! {} ::potato::configureWorld 19

#: proc ::potato::configureWorldCharsLBUpdate
#: arg w world id
#: arg widget Widget path
#: desc Configure the -values of the Default Char combobox.
#: return nothing
proc ::potato::configureWorldCharsLBUpdate {w widget} {
  variable worldconfig;

  set list [list "No Default Character"]
  foreach x $worldconfig($w,charList) {
    lappend list [lindex $x 0]
  }

  $widget configure -values $list;

};# ::potato::configureWorldCharsLBUpdate

#: proc ::potato::configureWorldCharsDelete
#: arg w world id
#: desc Delete the selected char from world $w's Char config list
#: return nothing
proc ::potato::configureWorldCharsDelete {w} {
  variable worldconfig;

  set tree $worldconfig($w,CONFIG,chars,tree)
  set sel [lindex [$tree selection] 0]
  if { $sel eq "" } {
       return;
     }
  set id [lsearch -index 0 $worldconfig($w,charList) $sel]
  if { $id == -1 } {
       return;
     }
  set worldconfig($w,charList) [lreplace $worldconfig($w,charList) $id $id]
  if { $worldconfig($w,charDefault) eq $sel } {
       set worldconfig($w,charDefault) "No Default Character"
     }

  configureWorldCharsPropagate $w

  return;


};# ::potato::configureWorldCharsDelete

#: proc ::potato::configureWorldCharsFinish
#: arg w world id
#: arg save Should we save (1) or just cancel (0)
#: desc Possibly save the currently added/edited char in world $w's Char Config screen, then reset the widget states for browsing
#: return nothing
proc ::potato::configureWorldCharsFinish {w save} {
  variable worldconfig;

  set charEntry $worldconfig($w,CONFIG,chars,charEntry)
  set pwEntry $worldconfig($w,CONFIG,chars,pwEntry)

  if { $worldconfig($w,CONFIG,chars,editing) eq "" } {
       set old -1
     } else {
       set old [lsearch -index 0 $worldconfig($w,charList) $worldconfig($w,CONFIG,chars,editing)]
     }
  if { $save } {
       set newChar [$charEntry get]
       set newPw [$pwEntry get]
       if { [string trim $newChar] eq "" } {
            tk_messageBox -icon error -title [T "Save Character"] -parent [winfo toplevel $charEntry] \
                           -message [T "You must enter a character name."]
            return;
          } elseif { $newChar eq "No Default Character" || $newChar eq "none" } {
            tk_messageBox -icon error -title [T "Save Character"] -parent [winfo toplevel $charEntry] \
                          -message [T "Sorry, that's not a valid character name."]
            return;
          }
       if { $newChar ne $worldconfig($w,CONFIG,chars,editing) && \
            [set existing [lsearch -index 0 $worldconfig($w,charList) $newChar]] > -1 } {
            set ans [tk_messageBox -icon question -title [T "Save Character"] -type yesno\
                 -parent [winfo toplevel $charEntry] \
                 -message [T "There is already a character with that name. Overwrite?"]]
            if { $ans ne "yes" } {
                 return;
               }
            set worldconfig($w,charList) [lreplace $worldconfig($w,charList) $existing $existing];# remove one we're replacing
            if { $worldconfig($w,CONFIG,chars,editing) ne "" } {
                 # Update $old in case removing $existing has shifted its position
                 set old [lsearch -index 0 $worldconfig($w,charList) $worldconfig($w,CONFIG,chars,editing)]
               }
          }
       if { $old == -1 } {
            lappend worldconfig($w,charList) [list $newChar $newPw]
          } else {
            set worldconfig($w,charList) [lreplace $worldconfig($w,charList) $old $old [list $newChar $newPw]]
            if { $worldconfig($w,charDefault) eq $worldconfig($w,CONFIG,chars,editing) } {
                 set worldconfig($w,charDefault) $newChar
               }
          }
     }

  $worldconfig($w,CONFIG,chars,charEntry) delete 0 end
  $worldconfig($w,CONFIG,chars,pwEntry) delete 0 end

  if { $save } {
       configureWorldCharsPropagate $w $newChar ;# Propagate sets State automatically
       if { $worldconfig($w,CONFIG,chars,editing) eq "" && \
            $worldconfig($w,CONFIG,chars,editing) eq $worldconfig($w,charDefault) } {
            set worldconfig($w,charDefault) $newChar
          }
     } else {
       configureWorldCharsState $w
     }

  return;

};# ::potato::configureWorldCharsFinish

#: proc ::potato::configureWorldCharsAddEdit
#: arg w world id
#: arg adding Are we adding (1) or editing (0)
#: desc Set up the Char list in World $w's Config window for adding/editing a char
#: return nothing
proc ::potato::configureWorldCharsAddEdit {w adding} {
  variable worldconfig;

  set tree $worldconfig($w,CONFIG,chars,tree)
  if { !$adding } {
       set sel [lindex [$tree selection] 0]
       if { $sel eq "" } {
            return;
          }
       set info [lsearch -inline -index 0 $worldconfig($w,charList) $sel]
       set char [lindex $info 0]
       set pw [lindex $info 1]
     } else {
       set sel ""
       set char ""
       set pw ""
     }

  configureWorldCharsState $w 2
  set worldconfig($w,CONFIG,chars,editing) $sel
  $worldconfig($w,CONFIG,chars,charEntry) insert end $char
  $worldconfig($w,CONFIG,chars,pwEntry) insert end $pw

  return;

};# ::potato::configureWorldCharsAddEdit

#: proc ::potato::configureWorldCharsPropagate
#: arg w world id
#: arg sel Item to select
#: desc Propagate the tree that displays chars in the config window for world $w, and select char $sel if given/possible
#: return nothing
proc ::potato::configureWorldCharsPropagate {w {sel ""}} {
  variable worldconfig;

  set tree $worldconfig($w,CONFIG,chars,tree)

  $tree state !disabled
  $tree delete [$tree children {}]
  if { [llength $worldconfig($w,charList)] } {
       foreach x [lsort -index 0 $worldconfig($w,charList)] {
          set char [lindex $x 0]
          $tree insert {} end -id $char -values $char
       }
       if { $sel eq "" || ![$tree exists $sel] } {
            set sel [lindex [$tree children {}] 0]
          }
       $tree selection set [list $sel]
       $tree focus $sel
       configureWorldCharsState $w 1
     } else {
       configureWorldCharsState $w 0
     }

  return;

};# ::potato::configureWorldCharsPropagate

#: proc ::potato::configureWorldCharsState 
#: arg w world id
#: arg state state (0 = empty tree, 1 = tree with values, 2 = adding/editing, "" = check for empty tree and do 0/1 accordingly
#: desc Set the buttons in the Char config for world $w to the appropriate states
#: return nothing
proc ::potato::configureWorldCharsState {w {state ""}} {
  variable worldconfig;

  if { $state eq "" } {
       set state [expr {min(1,[llength [$worldconfig($w,CONFIG,chars,tree) selection]])}]
     }
  if { $state == 2 } {
       $worldconfig($w,CONFIG,chars,tree) state disabled
       $worldconfig($w,CONFIG,chars,addBtn) state disabled
       $worldconfig($w,CONFIG,chars,editBtn) state disabled
       $worldconfig($w,CONFIG,chars,delBtn) state disabled
       $worldconfig($w,CONFIG,chars,saveBtn) state !disabled
       $worldconfig($w,CONFIG,chars,cancelBtn) state !disabled
       $worldconfig($w,CONFIG,chars,charEntry) state !disabled
       $worldconfig($w,CONFIG,chars,pwEntry) state !disabled
     } else {
       $worldconfig($w,CONFIG,chars,tree) state !disabled
       $worldconfig($w,CONFIG,chars,addBtn) state !disabled
       set sel [expr {min(1,[llength [$worldconfig($w,CONFIG,chars,tree) selection]])}]
       $worldconfig($w,CONFIG,chars,editBtn) state [lindex [list disabled !disabled] $sel]
       $worldconfig($w,CONFIG,chars,delBtn) state [lindex [list disabled !disabled] $sel]
       $worldconfig($w,CONFIG,chars,saveBtn) state disabled
       $worldconfig($w,CONFIG,chars,cancelBtn) state disabled
       $worldconfig($w,CONFIG,chars,charEntry) state disabled
       $worldconfig($w,CONFIG,chars,pwEntry) state disabled
     }

  return;

};# ::potato::configureWorldCharsState 

#: proc ::potato::configureWorldCancel
#: arg w world id
#: arg win main configure window
#: desc Called when the Configure window for a world is destroyed. Close all sub-windows, and unset the vars used by the config window. This is called both when the Configure World is cancelled, but also when the window is destroyed after the settings are saved (via a <Destroy> binding), so everything from the vars must be saved before the window is destroyed! ($win is already going when this is called)
#: return nothing
proc ::potato::configureWorldCancel {w win} {
  variable worldconfig;

  array unset potato::worldconfig $w,*
  foreach x [lsearch -inline -glob [winfo children .] "${win}_subToplevel_*"] {
    destroy $x
  }

  return;

};# ::potato::configureWorldCancel

#: proc ::potato::currentWindowSize
#: arg _var Variable to store result in
#: arg w World whose font we should use for measurement
#: arg max Maximum number of chars
#: desc Measure how many chars, for world $w, it would take to fill the main window at current size (capping at $max). Set result in $var. NOTE: This is really quite skin dependant, and needs recoding better to interface with the skin, instead of cheating and assuming the default skin. Not that I'm ever likely to get around to writing another one. #abc
#: return nothing
proc ::potato::currentWindowSize {_var w max} {
  variable world;

  upvar #0 $_var var
  set t [::potato::activeTextWidget]
  pack $t -expand 1 -fill both
  update
  set window_width [winfo width $t];# hack alert #abc
  pack $t -expand 0 -fill y
  set font_width [font measure $world($w,top,font) "0"]
  set total [expr {min($max,($window_width / $font_width))}]
  set var $total

  return;

};# ::potato::currentWindowSize

#: proc ::potato::configureTimerSelect
#: arg tree Treeview widget
#: arg w world id
#: arg edit Edit button
#: arg del Delete button
#: desc Mark the currently selected item, if any, as active, and set button states appropriately
#: return nothing
proc ::potato::configureTimerSelect {tree w edit del} {
  variable worldconfig;

  set sel [$tree selection]
  set worldconfig($w,timer,active) $sel
  if { $sel eq "" } {
       $edit state disabled
       $del state disabled
     } else {
       $edit state !disabled
       $del state !disabled
     }

  return;

};# ::potato::configureTimerSelect

#: proc ::potato::configureTimerAddEdit
#: arg w world id
#: arg add 1 to add a new timer, 0 to edit the currently selected one
#: arg win The window path to use
#: desc Show the window to allow the user to add a new timer for world $w, or edit a current timer (depending on $add)
#: return nothing
proc ::potato::configureTimerAddEdit {w add win} {
  variable worldconfig;
  variable world;

  if { [winfo exists $win] } {
       reshowWindow $win
       return;
     }

  if { !$add && (![info exists worldconfig($w,timer,active)] || $worldconfig($w,timer,active) eq "") } {
       bell -displayof .
       return;
     }

  toplevel $win
  wm withdraw $win
  if { $add } {
       if { $w == -1 } {
            wm title $win [T "Add Global Timer"]
          } else {
            wm title $win [T "Add Timer for %s" $world($w,name)]
          }
       set worldconfig($w,timer,ae) ""
       set worldconfig($w,timer,ae,enabled) 1
       set worldconfig($w,timer,ae,delay) 0
       set worldconfig($w,timer,ae,every) 60
       set worldconfig($w,timer,ae,cmds) ""
       set worldconfig($w,timer,ae,count) 0
       set worldconfig($w,timer,ae,continuous) 1
     } else {
       set timerId $worldconfig($w,timer,active)
       if { $w == -1 } {
            wm title $win [T "Edit Global Timer"]
          } else {
            wm title $win [T "Edit Timer for %s" $world($w,name)]
          }
       set worldconfig($w,timer,ae) $timerId
       set worldconfig($w,timer,ae,enabled) $worldconfig($w,timer,$timerId,enabled)
       set worldconfig($w,timer,ae,delay) $worldconfig($w,timer,$timerId,delay)
       set worldconfig($w,timer,ae,every) $worldconfig($w,timer,$timerId,every)
       set worldconfig($w,timer,ae,cmds) $worldconfig($w,timer,$timerId,cmds)
       set worldconfig($w,timer,ae,count) $worldconfig($w,timer,$timerId,count)
       set worldconfig($w,timer,ae,continuous) $worldconfig($w,timer,$timerId,continuous)
     }

  set styles [list -side top -anchor nw -fill x -padx 8 -pady 5]

  pack [set frame [::ttk::frame $win.frame]] -side left -expand 1 -fill both -anchor nw

  pack [::ttk::frame $frame.delay] {*}$styles
  pack [::ttk::label $frame.delay.l1 -text [T "After connecting, wait"]] -side left -anchor w
  pack [spinbox $frame.delay.sb -from 0 -to 18000 -increment 1 -width 5 -justify right -validate key -validatecommand {string is integer %P} -textvariable potato::worldconfig($w,timer,ae,delay)] -side left -anchor w -padx 5
  pack [::ttk::label $frame.delay.l2 -text [T "seconds"]] -side left -anchor w

  pack [::ttk::frame $frame.cmds] {*}$styles -expand 1 -fill both
  pack [::ttk::label $frame.cmds.l -text [T "Run the commands:"]] -side top -anchor nw
  pack [set text [text $frame.cmds.t -height 5 -width 40]] -side top -anchor nw -expand 1 -fill both
  $text insert end [string map [list " \b " "\n"] $worldconfig($w,timer,ae,cmds)]
  bind $text <Tab> [bind PotatoInput <Tab>]
  bind $text <Shift-Tab> [bind PotatoInput <Shift-Tab>]

  pack [::ttk::frame $frame.every] {*}$styles
  pack [::ttk::label $frame.every.l1 -text [T "And repeat every"]] -side left -anchor w
  pack [spinbox $frame.every.sb -from 0 -to 18000 -increment 1 -width 5 -justify right -validate key -validatecommand {string is integer %P} -textvariable potato::worldconfig($w,timer,ae,every)] -side left -anchor w -padx 5
  pack [::ttk::label $frame.every.l2 -text [T "seconds"]] -side left -anchor w

  pack [::ttk::frame $frame.howmany] {*}$styles
  pack [::ttk::label $frame.howmany.l -text [T "Run:"]] -side top -anchor w
  pack [::ttk::frame $frame.howmany.continuous] -side top -anchor w
  pack [::ttk::radiobutton $frame.howmany.continuous.rb -variable ::potato::worldconfig($w,timer,ae,continuous) \
                   -value 1 -command [list $frame.howmany.count.sb configure -state disabled] \
                   -text [T "Continuously"]] -side left -anchor w
  pack [::ttk::frame $frame.howmany.count] -side top -anchor w -fill x;
  pack [::ttk::radiobutton $frame.howmany.count.rb -variable ::potato::worldconfig($w,timer,ae,continuous) \
                   -value 0 -command [list $frame.howmany.count.sb configure -state normal] \
                   -text [T "Exactly"]] -side left -anchor w
  pack [spinbox $frame.howmany.count.sb -from 0 -to 10000 -increment 1 -width 5 -justify right \
                        -validate key -validatecommand {string is integer %P} \
                        -textvariable potato::worldconfig($w,timer,ae,count)] \
                        -side left -anchor w -padx 5
  pack [::ttk::label $frame.howmany.count.l2 -text [T "Times"]] -side left -anchor w

  $frame.howmany.count.sb configure -state [expr {$worldconfig($w,timer,ae,continuous) ? "disabled" : "normal"}]

  pack [::ttk::frame $frame.enabled] -in $frame.howmany.count -side right;#{*}$styles
  pack [::ttk::label $frame.enabled.l -text [T "Enable this timer?"]] -side right -anchor w
  pack [::ttk::checkbutton $frame.enabled.cb -variable ::potato::worldconfig($w,timer,ae,enabled)] \
               -side right -anchor w

  pack [::ttk::frame $frame.buttons] {*}$styles -fill x -pady 10
  pack [::ttk::frame $frame.buttons.ok] -side left -expand 1 -fill x
  pack [::ttk::button $frame.buttons.ok.btn -text [T "OK"] -width 8 -default active -command [list potato::configureTimerSave $w $text]] -side right -padx 8 -anchor e
  pack [::ttk::frame $frame.buttons.cancel] -side left -expand 1 -fill x
  pack [::ttk::button $frame.buttons.cancel.btn -text [T "Cancel"] -width 8 -command [list destroy $win]] -side left -padx 8 -anchor w
  
  bind $win <Escape> [list $frame.buttons.cancel.btn invoke]
  bind $win <Destroy> [list array unset potato::worldconfig $w,timer,ae,*]

  update idletasks
  center $win
  reshowWindow $win 0

  return;

};# ::potato::configureTimerAddEdit

#: proc ::potato::configureTimerSave
#: arg w world id
#: arg text path to text widget containing command string
#: desc For world $w, use the info saved in worldconfig($w,timer,ae,*) and the text in the $text widget (which holds the cmds to run for the timer), save the timer info. worldconfig($w,timer,ae) is the id of the timer to edit, or the empty string to add a timer. We must also update the info displayed
#: return nothing
proc ::potato::configureTimerSave {w text} {
  variable worldconfig;

# This was:   if { ![info exists $worldconfig($w,timer,ae)] ** $worldconfig($w,timer,ae) eq "" }
# which seems absurdly wrong to me.

  if { ![info exists worldconfig($w,timer,ae)] || $worldconfig($w,timer,ae) eq "" } {
       set timerId $worldconfig($w,timer)
       incr worldconfig($w,timer) -1
     } else {
       set timerId $worldconfig($w,timer,ae)
     }

  set worldconfig($w,timer,ae,cmds) [string map [list "\n" " \b "] [$text get 1.0 end-1char]]
  foreach {var max} [list delay 18000 every 18000 count 10000] {
    if { ![string is integer -strict $worldconfig($w,timer,ae,$var)] } {
         set worldconfig($w,timer,ae,$var) 0
       } elseif { $worldconfig($w,timer,ae,$var) < 0 } {
         set worldconfig($w,timer,ae,$var) 0
       } elseif { $worldconfig($w,timer,ae,$var) > $max } {
         set worldconfig($w,timer,ae,$var) $max
       }
  }
  foreach x [list every delay count continuous cmds enabled] {
    set worldconfig($w,timer,$timerId,$x) $worldconfig($w,timer,ae,$x)
  }
  destroy [winfo toplevel $text]
  potato::configureTimerShowRow $w $timerId

  return;

};# ::potato::configureTimerSave

#: proc ::potato::configureTimerDelete
#: arg w world id
#: desc For world $w's configure window, delete the row showing timer info for the currently selected timer(and unset the associated vars)
#: return nothing
proc ::potato::configureTimerDelete {w} {
  variable worldconfig;

  if { ![info exists worldconfig($w,timer,active)] || $worldconfig($w,timer,active) eq "" } {
       bell -displayof .
       return;
     }

  set timer $worldconfig($w,timer,active)
  set worldconfig($w,timer,active) ""
  $worldconfig($w,timer,edit) configure -state disabled
  $worldconfig($w,timer,delete) configure -state disabled

  array unset worldconfig $w,timer,$timer,*
  $worldconfig($w,timer,tree) delete $timer

  return;

};# ::potato::configureTimerDelete

#: proc ::potato::configureTimerShowRow
#: arg w world id
#: arg timer timer id
#: desc For world $w's configure window, add (or update, if it exists) the treeview row for timer $timer, using the info in the $worldconfig($w,timer,$timer,*) vars
#: return nothing
proc ::potato::configureTimerShowRow {w timer} {
  variable worldconfig;

  set values [list [timeFmt $worldconfig($w,timer,$timer,every) 0] $worldconfig($w,timer,$timer,cmds)]
  if { $worldconfig($w,timer,$timer,continuous) } {
       lappend values "Continuous"
     } else {
       lappend values "$worldconfig($w,timer,$timer,count) Times"
     }
  set img [expr {$worldconfig($w,timer,$timer,enabled) ? "::potato::img::tick" : ""}]
  if { [$worldconfig($w,timer,tree) exists $timer] } {
       $worldconfig($w,timer,tree) item $timer -values $values -image $img
     } else {
       $worldconfig($w,timer,tree) insert {} end -id $timer -values $values -image $img
     }

  return;

  if { ![catch {winfo rgb SystemHighlight}] && ![catch {winfo rgb SystemHighlightText}] } {
       set activeBg SystemHighlight
       set activeFg SystemHighlightText
     } else {
       set activeBg #0a246a
       set activeFg white
     }
  set commonStyles [list -padx 2 -pady 2 -background white -foreground black -activebackground $activeBg -activeforeground $activeFg -state normal]

  if { ![winfo exists $worldconfig($w,timer,parents-enabled).t$timer] } {
       pack [label $worldconfig($w,timer,parents-enabled).t$timer {*}$commonStyles -text " " -compound center] -side top -fill x -padx 1 -pady 1
       pack [label $worldconfig($w,timer,parents-every).t$timer -width 10 -anchor e  {*}$commonStyles] \
            -side top -padx 1 -pady 1
       pack [label $worldconfig($w,timer,parents-cmds).t$timer -width 40 -anchor w  {*}$commonStyles] -side top -padx 1 -pady 1
       pack [label $worldconfig($w,timer,parents-freq).t$timer -width 12 -anchor w  {*}$commonStyles] \
            -side top -padx 1 -pady 1
       foreach x [list $worldconfig($w,timer,parents-every).t$timer $worldconfig($w,timer,parents-enabled).t$timer \
                       $worldconfig($w,timer,parents-cmds).t$timer $worldconfig($w,timer,parents-freq).t$timer] {
         bind $x <Button-1> [list ::potato::configureTimerSelect $w $timer $worldconfig($w,timer,edit) \
                                   $worldconfig($w,timer,delete)]
         bind $x <Double-Button-1> [list $worldconfig($w,timer,edit) invoke]
       }
  }

  if { $worldconfig($w,timer,$timer,enabled) } {
       $worldconfig($w,timer,parents-enabled).t$timer configure -image ::potato::img::tick
     } else {
       $worldconfig($w,timer,parents-enabled).t$timer configure -image ""
     }
  if { $worldconfig($w,timer,$timer,continuous) } {
       $worldconfig($w,timer,parents-freq).t$timer configure -text [T "Continuous"]
     } else {
       $worldconfig($w,timer,parents-freq).t$timer configure -text [T "%d Times" $worldconfig($w,timer,$timer,count)]
     }
  $worldconfig($w,timer,parents-every).t$timer configure -text [timeFmt $worldconfig($w,timer,$timer,every) 0]
  $worldconfig($w,timer,parents-every).t$timer configure -text [timeFmt $worldconfig($w,timer,$timer,every) 0] 
  $worldconfig($w,timer,parents-cmds).t$timer configure -text $worldconfig($w,timer,$timer,cmds) 

  return;

};# ::potato::configureTimerShowRow

#: proc ::potato::configureHelp
#: arg canvas The canvas widget in the help dialog
#: arg helplist A list of frames and matching helpfile topics
#: arg helplist2 A list of frames and helpfile topics for non-world configs (ie, program options for 'world -1')
#: desc Display the related helpfile for the configure frame currently on display in $canvas
#: return nothing
proc ::potato::configureHelp {canvas helplist helplist2} {

  set current [$canvas itemcget 1 -window]
  foreach {frame help} $helplist {
     if { $frame eq $current } {
          ::wikihelp::help worldconfig,$help
          return;
        }
  }

  foreach {frame help} $helplist2 {
     if { $frame eq $current } {
          ::wikihelp::help appconfig,$help
          return;
        }
  }

  bell -displayof $canvas

  return;

};# ::potato::configureHelp

#: proc ::potato::configureFont
#: arg w world id
#: arg parent the parent window that the font dialog should be a transient of
#: arg text the text widget to reconfigure for display purposes
#: arg where one of "top" or "bottom"
#: desc pop up a font selection dialog so the $where font for world $w can be changed. If a new one is selected, update the worldconfig var and configure the font for $text to show it. Make the dialog a transient of $parent.
#: return nothing
proc ::potato::configureFont {w parent text where} {
  variable worldconfig;
  variable world;

  if { $where eq "top" } {
       set where2 [T "Output"]
     } else {
       set where2 [T "Input"]
     }
  if { $w == -1 } {
       if { $where eq "top" } {
            set title [T "Choose Default Output Font"]
          } else {
            set title [T "Choose Default Input Font"]
          }
     } else {
       if { $where eq "top" } {
            set title [T "Choose Output Font for %s" $world($w,name)]
          } else {
            set title [T "Choose Input Font for %s" $world($w,name)]
          }
     }
  set new [::font::choose $parent ${parent}_subToplevel_font-$where [$text cget -font] $title]
  if { $new eq "" } {
       return;
     }
  set worldconfig($w,$where,font) $new
  # caught so we don't throw an error when the font-chooser is closed b/c the Configure window was cancelled
  catch {$text configure -font $new}

};# ::potato::configureFont

#: proc ::potato::configureText
#: arg w world id
#: arg event the event triggering the proc
#: arg text the text widget the event is happening in
#: arg colour the colour name to be configured, if any. Defaults to "" (none)
#: desc for Enter or Leave events, reconfigure $text's cursor. For Click events, pop up a colourchoose dialog to change $color, and if a new one is selected, update the worldconfig var for the world.
#: return nothing
proc ::potato::configureText {w event text {colour ""}} {
  variable worldconfig;

  if { $event eq "Enter" } {
       $text configure -cursor "hand2"
     } elseif { $event eq "Leave" } {
       $text configure -cursor {}
     } elseif { $event eq "Click" } {
       set tags [$text tag names "current"]
       if { "change" in $tags } {
            set colour [lsearch -inline -glob $tags *,*]
          }
       array set titleColours [list ansi,fg "Normal Foreground" \
                                   ansi,fgh "Bright Foreground" \
                                   ansi,r "ANSI Red" \
                                   ansi,rh "ANSI Bright Red" \
                                   ansi,g "ANSI Green" \
                                   ansi,gh "ANSI Bright Green" \
                                   ansi,b "ANSI Blue" \
                                   ansi,bh "ANSI Bright Blue" \
                                   ansi,c "ANSI Cyan" \
                                   ansi,ch "ANSI Bright Cyan" \
                                   ansi,m "ANSI Magenta" \
                                   ansi,mh "ANSI Bright Magenta" \
                                   ansi,y "ANSI Yellow" \
                                   ansi,yh "ANSI Bright Yellow" \
                                   ansi,x "ANSI Black" \
                                   ansi,xh "ANSI Bright Black" \
                                   ansi,w "ANSI White" \
                                   ansi,wh "ANSI Bright White" \
                                   top,bg "Background" \
                                   bottom,bg "Input Background" \
                                   bottom,fg "Input Foreground" \
                                   ansi,echo "Echo" \
                                   ansi,system "System" \
                                   ansi,link "Link" \
                               ];# array set titleColours
       if { [info exists titleColours($colour)] } {
            set title [T "Choose %s Colour" $titleColours($colour)]
          } else {
            set title [T "Choose Colour"]
          }

       set newcol [tk_chooseColor -title $title -parent $text -initialcolor $worldconfig($w,$colour)]
       if { $newcol ne "" } {
            if { $colour eq "top,bg" || $colour eq "bottom,bg" } {
                 $text configure -background $newcol
                 $text configure -foreground [::potato::reverseColour $newcol]
               } else {
                 $text tag configure $colour -foreground $newcol
               }
            set worldconfig($w,$colour) $newcol
          }
     }
  return;

};# ::potato::configureText

#: proc ::potato::configureWorldCommit
#: arg w world id
#: arg win config window
#: desc save all the settings for world $w, destroy the config window used for changing them, change the tags, etc, for any connections using this world, and if the currently-shown connection uses it, tell the skin to re-show.
#: return nothing
proc ::potato::configureWorldCommit {w win} {
  variable world;
  variable worldconfig;
  variable conn;
  variable potato;
  variable misc;

  array set fonts [array get worldconfig $w,*,font]
  set notes [$worldconfig($w,CONFIG,notes) get 1.0 end-1char]
  if { $w != -1 } {
       set autosend(connect) [$worldconfig($w,CONFIG,autosend,connect) get 1.0 end-1char]
       set autosend(login) [$worldconfig($w,CONFIG,autosend,login) get 1.0 end-1char]
     }
  array unset worldconfig $w,*,font
  array unset worldconfig $w,CONFIG,*

  array unset worldconfig $w,timer,ae*
  array set timers [array get worldconfig $w,timer,*,*]
  array unset worldconfig $w,timer,*
  array unset worldconfig $w,timer

  foreach x [array names timers -regexp "^$w,timer,\[^,\]+,cmds\$"] {
    scan $x $w,timer,%d,cmds timerId
    if { $timerId > 0 } {
         lappend timersPos $timerId
       } else {
         lappend timersNeg $timerId
       }
  }

  # Generate list of timers
  set newTimers [list]
  foreach x [array names world -regexp "^$w,timer,\[^,\]+,enabled\$"] {
    scan $x $w,timer,%d,enabled timerId
    if { ![info exists timers($x)] || !$timers($x) } {
         # cancel deleted timer
         timerCancel $w $timerId
       } elseif { !$world($x) && $timers($x) } {
         # Start re-enabled timer
         lappend newTimers $timerId
       }
  }
  array unset world $w,timer,*
  if { [info exists timersPos] } {
       foreach x [set timersPos [lsort -integer $timersPos]] {
         array set world [array get timers $w,timer,$x,*]
       }
     }
  if { [info exists timersNeg] } {
       if { [info exists timersPos] } {
            set timerNext [lindex $timersPos end]
          } else {
            set timerNext 0
          }
       foreach x [lsort -integer -decreasing $timersNeg] {
         incr timerNext
         foreach y [array names timers $w,timer,$x,*] {
           set world([string map [list ",$x," ",$timerNext,"] $y]) $timers($y)
         }
         lappend newTimers $timerNext
       }
     }

  # Set Combobox values correctly, and hope someone changes the ttk::combobox eventually so that it can

  array set world [array get worldconfig $w,*]
  set world($w,notes) $notes
  array unset worldconfig $w,*
  if { $w == -1 } {
       array set MISC [array get worldconfig MISC,*]
       array unset worldconfig MISC,*
     } else {
       set world($w,autosend,connect) $autosend(connect)
       set world($w,autosend,login) $autosend(login)
     }

  if { [info exists world($w,charDefault)] && $world($w,charDefault) eq "No Default Character" } {
       set world($w,charDefault) ""
     }

  # A <Destroy> binding on $win triggers potato::configureWorldCancel, which unsets vars, destroys configure pop-ups, etc
  destroy $win

  # Validate the spinbox values. Note: these maxes are hard-coded into spinbox widgets above,
  # so if they're changed here, they should be changed there, too.
  foreach {varname type max} [list autoreconnect,time integer 3600 wrap,at integer 1000 \
             wrap,indent integer 20 loginDelay double 60] {
     if { ![string is $type -strict $world($w,$varname)] } {
          set world($w,$varname) 0
        } elseif { $world($w,$varname) < 0 } {
          set world($w,$varname) 0
        } elseif { $world($w,$varname) > $max } {
          set world($w,$varname) $max
        }
  }

  # Configure the fonts
  foreach where [list top bottom] {
     if { ![catch {font actual $fonts($w,$where,font)} ACKFOO] } {
          set world($w,$where,font) $fonts($w,$where,font)
        }
     if { [info exists world($w,$where,font,created)] } {
          font configure $world($w,$where,font,created) {*}[font actual $world($w,$where,font)]
        }
  }

  # Update the text widgets for all currently connected instances of the world
  foreach c [connIDs] {
     if { $conn($c,world) == $w } {
          if { [hasProtocol $c telnet,NAWS] } {
               # Tell the server we've changed size
               ::potato::telnet::do_NAWS $c
             }
          # Display settings (colours, etc)
          configureTextWidget $c $conn($c,textWidget)
          $conn($c,input1) configure -background $world($w,bottom,bg) \
                   -foreground $world($w,bottom,fg) -insertbackground [reverseColour $world($w,bottom,bg)]
          $conn($c,input2) configure -background $world($w,bottom,bg) \
                   -foreground $world($w,bottom,fg) -insertbackground [reverseColour $world($w,bottom,bg)]
          # Update spawn displays
          foreach s [arraySubelem conn $c,spawns] {
             configureTextWidget $c $conn($s)
          }
          if { [winfo exists .debug_packet_$c.txt.t] } {
               configureTextWidget $c .debug_packet_$c.txt.t
             }
          ::skin::$potato(skin)::status $c
        }
     if { $conn($c,world) == $w || $w == -1 } {
          foreach timerId $newTimers {
            timersStartOne $c $w $timerId
          }
        }
  }


  # For global settings, update the misc (non-world) settings
  if { $w == -1 } {
       set showSysTray $misc(showSysTray)
       set tileTheme $misc(tileTheme)
       set MISC(MISC,outsideRequestMethod) [lsearch -exact [list "Quick Connect" "Use World Settings" "Prompt"] $MISC(MISC,outsideRequestMethod)]
       foreach x [array names MISC] {
         set misc([string range $x 5 end]) $MISC($x)
       }
       if { $showSysTray && !$misc(showSysTray) } {
            winicoUnmap
          } elseif { !$showSysTray && $misc(showSysTray) } {
            winicoMap
          }
       if { $tileTheme ne $misc(tileTheme) } {
            setTheme
          }
       if { [wm state .] == "withdrawn" && (!$misc(minToTray) || !$misc(showSysTray)) } {
            wm deiconify .
          }
     }

  # Have the skin re-show it, if it's up atm, so the skin reconfigures properly.
  #if { $conn([up],world) == $w } {
  #     if { $skinchanged } {
  #          # Remove the old skin, pack the new one...
  #          ::skin::$potato(skin)::unpackskin
  #          showSkin $newskin
  #          #set potato(skin) $newskin;# this now handled by showSkin anyway
  #        }
  #     ::skin::$potato(skin)::show [up]
  #   }
  #abc#xyz#999
  ::skin::$potato(skin)::show [up]
  setAppTitle

  manageWorldsUpdateWorlds

  saveWorlds

  return;

};# ::potato::configureWorldCommit

#: proc ::potato::configureFrame
#: arg canvas path to canvas widget
#: arg title string to display as title
#: desc creates a frame to display inside the scrolled canvas $canvas to contain config options. Then creates a subframe, packed inside with some padding, and a label to display $title as a heading for the "page".
#: return [list] of the outer frame (for embedding in the canvas) and inner frame (for packing widgets in)
proc ::potato::configureFrame {canvas title} {

  set num [llength [winfo children $canvas]]
  set outer [::ttk::frame $canvas.sub_$num]
  set inner [::ttk::frame $canvas.sub_$num.inner]
  pack $inner -padx 4 -pady 8 -expand 1 -fill both

  set label [::ttk::label $inner.internal_title_label -text $title]
  $label configure -font [concat [font actual [::ttk::style lookup TLabel -font [$label state]]] [list -size 15]] -justify left
  pack $label -side top -padx 15 -pady 5 -anchor nw

  return [list $outer $inner];

};# ::potato::configureFrame

#: proc ::potato::configureShow
#: arg canvas the scrolled canvas widget
#: arg frame the frame to embed
#: desc change the embedded window in $canvas to be $frame
#: return nothing
proc ::potato::configureShow {canvas tree} {

  set item [$tree selection]
  set frame [lindex [$tree item $item -tags] 0]
  if { $frame eq "" } {
       catch {$tree item $item -open [expr {![$tree item $item -open]}]}
       return;
     }
  catch {bind [$canvas itemcget 1 -window] <Configure> {}}
  $canvas itemconfigure 1 -window $frame
  bind $frame <Configure> "$canvas configure -scrollregion \"0 0 250 \[winfo reqheight $frame\]\""
  #after idle "$canvas xview moveto 0 ; $canvas yview moveto 1 ; $canvas yview moveto 0"
  #after idle "[$canvas cget -yscrollcommand] \{*\}\[$canvas yview\]"
  $canvas configure -scrollregion [list 0 0 250 [winfo reqheight $frame]]
  return;

};# ::potato::configureShow

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
       return idle;
     } else {
       return normal;
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
#: return string containining the $type info for the connection
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
    input1 { return $conn($c,input1);}
    input2 { return $conn($c,input2);}
    input3 { return $conn($c,input[connInfo $c inputFocus]);}
    inputFocus { return [expr {[focus -displayof $conn($c,input2)] eq $conn($c,input2) ? 2 : 1}]; }
    autoreconnect { return [expr {$world($conn($c,world),autoreconnect) && $conn($c,reconnectId) ne ""}]; }
    world {return $conn($c,world);}
    spawns {return [removePrefix [arraySubelem conn $c,spawns] $c,spawns];}
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

  if { [focus -displayof .] ne "" } {
       set conn([up],idle) 0
     }

  if { $winico(loaded) && $winico(flashing) } {
       winicoFlashOff
     }

  #abc might need to do a "linunflash ." here when using that package?

  return;

};# ::potato::focusIn

#: proc ::potato::setClock
#: desc set potato(clock) to the current time, formatted according to misc(clockFormat), and queue an update in 1 second. Also set the formatted connection stats.
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

#: proc ::potato::main
#: desc called when the program starts, to do some basic init
#: return nothing
proc ::potato::main {} {
  variable potato;
  variable path;
  variable skins;
  variable misc;

  set potato(name) "Potato MU* Client"
  set potato(version) [source [file join [file dirname [info script]] "potato-version.tcl"]]
  set potato(contact) "talvo@talvo.com"
  set potato(webpage) "http://www.potatomushclient.com/"
  set potato(windowingsystem) [tk windowingsystem]

  if { [info exists ::starkit::mode] && $::starkit::mode eq "starpack" } {
       set potato(homedir) [file dirname [info nameofexecutable]]
       set potato(vfsdir) [info nameofexecutable]
       set potato(wrapped) 1
     } else {
       set potato(homedir) [file join [file dirname [info script]] .. ..]
       set potato(vfsdir) [file join [file dirname [info script]] ..]
       set potato(wrapped) 0
     }
  # Number of connections made
  set potato(conns) 0
  # Number of saved worlds
  set potato(worlds) 0
  set potato(nextWorld) 1
  # The current skin on display
  set potato(skin) ""
  # The current connection on display
  set potato(up) ""

  # Regexp which spawn names must match
  set potato(spawnRegexp) {^[A-Za-z][A-Za-z0-9_!+="*#@'-]{0,49}$}

  set potato(skinMinVersion) "1.3" ;# The minimum version of the skin spec this Potato supports.
                                   ;# All skins must be at least this to be usable.

  set potato(skinCurrVersion) "1.2" ;# The current version of the skin spec. If changes made aren't
                                    ;# incompatible, this may be higher than skinMinVersion
  cd $potato(homedir)

  treeviewHack;# hackily fix the fact that Treeviews can still be played with when disabled

  set path(log) $potato(homedir)
  set path(upload) $potato(homedir)
  if { $::tcl_platform(platform) eq "windows" } {
       set path(world) [file join $potato(homedir) worlds]
       set path(skins) [file join $potato(homedir) skins]
       set path(lib) [file join $potato(homedir) lib]
       set path(preffile) [file join $potato(homedir) potato.ini]
       set path(custom) [file join $potato(homedir) potato.custom]
       set path(startupCmds) [file join $potato(homedir) potato.startup]
       set path(i18n) [file join $potato(homedir) i18n]
     } else {
       set path(world) [file join ~ .potato worlds]
       set path(skins) [file join ~ .potato skins]
       set path(lib) [file join ~ .potato lib]
       set path(preffile) [file join ~ .potato config]
       set path(custom) [file join ~ .potato potato.custom]
       set path(startupCmds) [file join ~ .potato potato.startup]
       set path(i18n) [file join ~ .potato i18n]
     }
  set path(help) [file join $potato(vfsdir) lib help]
  catch {source [file join $potato(homedir) potato.dev]}
  foreach x [list world skins lib] {
     catch {file mkdir $path($x)}
  }
  lappend ::auto_path $path(lib)

  # We need to set the prefs before we load anything...
  setPrefs 1

  # Now set up translation stuff
  i18nPotato

  tasksInit

  # Load TLS if available, for SSL connections
  set potato(hasTLS) [expr {![catch {package require tls}]}]

  # Set the ttk theme to use
  setTheme
  loadSkins
  loadWorlds
  createImages

  tooltipInit

  if { $misc(windowSize) eq "zoomed" || $misc(startMaximized) } {
       set zoom 1
     } else {
       set zoom 0
     }
  if { !$zoom || [catch {wm state . zoomed}] } {
       catch {wm geometry . $misc(windowSize)}
     }
  wm protocol . WM_DELETE_WINDOW "::potato::chk_exit"
  setUpMenu

  if { $misc(skin) in $skins(int) } {
       set potato(skin) $misc(skin)
     } else {
       set potato(skin) "potato";# default skin
     }
  showSkin $potato(skin)

  setClock

  ::help::readFile [file join $::potato::potato(vfsdir) lib potato-help.txt]

  newConnection -1
  # We do this after newConnection, or the <FocusIn> binding comes up wrong
  setUpBindings

  # setUpWinico must be run before setUpFlash
  setUpWinico
  setUpFlash

  if { $::tcl_platform(platform) eq "windows" && $potato(wrapped) } {
       if { ![catch {package require dde 1.3}] } {
            # Start the DDE server in case we're the default telnet app. Only do this on Windows when
            # DDE is available, and we're running as a wrapped app, not a script.
            ::potato::ddeStart
          }
     }

  catch {source $path(custom)}
  if { [file exists $path(startupCmds)] && ![catch {open $path(startupCmds) r} fid] } {
       while { [gets $fid startupCmd] >= 0 } {
               send_to "" $startupCmd "" 0
             }
     }

  # Attempt to parse out connection paramaters
  switch $::argc {
    0 {}
    1 {handleOutsideRequest cl [lindex $::argv 0]}
    default {parseCommandLine $::argv $::argc}
  }


  after idle [list ::potato::autoConnect]

  return;

};# ::potato::main

#: proc ::potato::i18nPotato
#: desc Set up the translation stuff.
#: return nothing
proc ::potato::i18nPotato {} {
  variable misc;
  variable path;

  if { [catch {package require msgcat 1.4.2} err] } {
       # We should probably log this somewhere #abc
       return;
     }

  # Set our preferred locale
  ::msgcat::mclocale $misc(locale)

  # Some English "translations".
  # This is where we've used more verbose messages in some places to make phrases which are repeated in English, but with
  # different context, translatable as different strings in other languages. In English we convert the verbose form back to
  # the shorter version. NOTE: Must be done before we load translations, otherwise we may clobber the user's preferred translation.
  namespace eval :: {::msgcat::mcmset en [list "Convert To:" "To:" "Recipient:" "To:" "Limit To:" "To:" "Spawn To:" "To:"]}

  # Load translation files. We do this in two steps:
  # 1) Load *.ptf files using [::potato::loadTranslationFile]. These are just message catalogues.
  # 2) Use ::msgcat::mcload, which loads *.msg files containing Tcl code for translations
  foreach x [glob -nocomplain -dir $path(i18n) -- *.ptf] {
    loadTranslationFile $x
  }
  ::msgcat::mcload $path(i18n)

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

#: ::potato::loadTranslationFile
#: arg file The filename to load
#: desc Load translation strings from the file $file
#: return locale on success, empty string on failure
proc ::potato::loadTranslationFile {file} {

  # The format for these files is:
  # LOCALE: <locale>
  # ENCODING: <encoding>  (optional)
  # <originalMsg>
  # <translatedMsg>
  # <originalMsg>
  # <translatedMsg>
  # etc. 
  # The ENCODING: line is optional. Where present, Potato attempts to change file encoding to <encoding> when 
  # reading the file in.
  #
  # Any empty lines, lines containing only white space, and lines starting with '#' will
  # be ignored as comments/whitespace to make the .ptf file clearer. A <translatedMsg> containing
  # the single character "-" will cause that original message to be skipped, so I can build a template
  # of translatable messages which will "work" but do nothing.

  if { [catch {open $file r} fid] } {
       # Should probably report this somewhere. #abc
       return;
     }

  if { [catch {gets $fid line} count] || $count < 0 } {
       catch {close $fid}
       return;
     }

  if { ![string match "LOCALE: *" $line] } {
       # Malformed translation file
       catch {close $fid}
       return;
     }

  set locale [string trim [string range $line 8 end]]
  if { $locale eq "" } {
       catch {close $fid}
       return;
     }

  if { [catch {gets $fid line} count] || $count < 0 } {
       catch {close $fid}
       return;
     }
  if { [string match "ENCODING: *" $line] } {
       # Process for encoding
       catch {fconfigure $fid -encoding [string range $line 10 end]}
       if { [catch {gets $fid line} count] || $count < 0 } {
            catch {close $fid}
            return;
          }
    }

  set i 0
  set multi ""
  while { 1 } {
    if { [string trim $line] ne "" && [string range $line 0 0] ne "#" } {
            if { $i } {
              set i 0;
              if { $line ne "-" } {
                   namespace eval :: [list ::msgcat::mcset $locale $msg [string map [list "\\n" "\n"] $line]]
                 }
            } else {
              set msg [string map [list "\\n" "\n"] $line]
              set i 1
            }
       }
    if { [catch {gets $fid line} count] || $count < 0 } {
         break;
       }
  }
  close $fid;

  return $locale;

};# ::potato::loadTranslationFile

#: proc ::potato::treeviewHack
#: desc Fix the fact that Treeview widgets can be played with when disabled.
#: return nothing
proc ::potato::treeviewHack {} {

  foreach x [list Control-Button-1 Shift-Button-1 Key-space Key-Return Key-Left Key-Right \
                  Key-Down Key-Up B1-Motion Double-Button-1 ButtonRelease-1 Button-1] {
     bind Treeview <$x> [format {if { ![%%W instate disabled] } { %s }} [bind Treeview <$x>]]
  }

  return;

};# ::potato::treeviewHack

#: proc ::potato::setTheme
#: desc Set the ttk/tile theme
#: return nothing
proc ::potato::setTheme {} {
  variable misc;

  if { [catch {::ttk::style theme use $misc(tileTheme)}] } {
       catch {::ttk::setTheme $misc(tileTheme)}
     }

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

  set stamp [$widget tag prevrange timestamp $index]
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

  if { [winfo containing {*}[winfo pointerxy $widget]] != $widget } {
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


  $tree heading Variable -text Variable -anchor w
  $tree heading Value -text Value -anchor w
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
  scrollbar $sb -orient vertical -command [list potato::multiscroll $listboxes yview]

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
  variable potato;
  variable misc;

  set winico(loaded) 0
  set winico(mapped) 0
  set winico(flashing) 0
  if { $::tcl_platform(platform) ne "windows" || [catch {package require Winico 0.6}] } {
       return;
     }

  set dir [file join $potato(vfsdir) lib app-potato windows]
  #set mainico [file join $dir potato2.ico]
  set mainico [file join $dir stpotato.ico]
  if { ![file exists $dir] || ![file isdirectory $dir] || ![file exists $mainico] || ![file isfile $mainico] } {
       return;
     }
 
  if { [catch {set winico(main) [winico createfrom $mainico]}] } {
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

  if { $winico(mapped) } {
       return;
     }

  if { [catch {winico taskbar add $winico(main) -text $potato(name) -pos 0 \
                        -callback [list ::potato::winicoCallback %m %x %y]}] } {
       destroy $winico(menu)
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
  set winico(after) [after 750 {potato::winicoFlashOn}]
  set winico(flashing) 1
  return;

};#

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
}

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

  ::ttk::frame $frame.cmds
  pack $frame.cmds -side top -padx 10 -pady 5 -expand 1 -fill both
  set tree [::ttk::treeview $frame.cmds.lb -height 15 -show headings -selectmode browse \
          -yscrollcommand [list $frame.cmds.sby set] -xscrollcommand [list $frame.cmds.sbx set] \
          -columns [list ID Command]]
  $tree heading ID -text "[T "ID"] " -anchor e
  $tree heading Command -text [T "Command"]
  $tree column ID -anchor e -stretch 0 -width 25
  $tree column Command -anchor w -stretch 1
  foreach x $conn($c,inputHistory) {
     $tree insert {} end -id [lindex $x 0] -values $x
  }
  ::ttk::scrollbar $frame.cmds.sby -orient vertical -command [list $frame.cmds.lb yview]
  ::ttk::scrollbar $frame.cmds.sbx -orient horizontal -command [list $frame.cmds.lb xview]
  grid_with_scrollbars $frame.cmds.lb $frame.cmds.sbx $frame.cmds.sby
  pack $frame.cmds -expand 1 -fill both

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
  if { $cmd == "" } {
       return;
     }

  if { $key == 1 || $key == 2 } {
       showInput $c $key [string map [list \b \n] $cmd] 0
       destroy $top
     } elseif { $key == 3 } {
       send_to $c $cmd \b 1
       destroy $top
     } elseif { $key == 4 } {
       clipboard clear -displayof $top
       clipboard append -displayof $top [string map [list \b \n] $cmd]
       bell -displayof $top
     }

  return;

};# ::potato::historySub

#: proc ::potato::createImages
#: desc create the images, in the ::potato::img namespace, used by the app
#: return nothing
proc ::potato::createImages {} {
  variable potato;

  set imgPath [file join $potato(vfsdir) lib images]

  image create photo ::potato::img::uparrow -file [file join $imgPath uparrow.gif]
  image create photo ::potato::img::downarrow -file [file join $imgPath downarrow.gif]

  image create photo ::potato::img::dotdotdot -file [file join $imgPath dotdotdot.gif]
  image create photo ::potato::img::tick -file [file join $imgPath tick.gif]

  image create photo ::potato::img::event-new -file [file join $imgPath event-new.gif]
  image create photo ::potato::img::event-delete -file [file join $imgPath event-delete.gif]
  image create photo ::potato::img::event-edit -file [file join $imgPath event-edit.gif]

  image create photo ::potato::img::logo -file [file join $imgPath potato.gif]
  image create photo ::potato::img::logoSmall -file [file join $imgPath potato-small.gif]

  image create photo ::potato::img::globe -file [file join $imgPath globe.gif]
  image create photo ::potato::img::folder -file [file join $imgPath folder.gif]

  image create photo ::potato::img::cb-ticked -file [file join $imgPath cb-ticked.gif]
  image create photo ::potato::img::cb-unticked -file [file join $imgPath cb-unticked.gif]

  return;

};# ::potato::createImages

#: proc ::potato::setUpFlash
#: desc Set up the ::potato::flash proc, which flashes the taskbar icon and systray icon for the app. If we're on Windows, we try to load the potato-winflash package and use that. On Linux, we try potato-linflash. Else, we just "wm deiconify .". For Win we also try and flash the Winico systray icon if requested.
#: return nothing
proc ::potato::setUpFlash {} {
  variable winico;

  if { $::tcl_platform(platform) eq "windows" } {
       if { ![catch {package require potato-winflash}] } {
            set taskbarCmd {winflash . -count 3 -appfocus 1}
          } else {
            set taskbarCmd {wm deiconify .}
          }
       if { $winico(loaded) } {
            set sysTrayCmd {winicoFlashOn}
          } else {
            set sysTrayCmd {# nothing}
          }
     } elseif { ![catch {package require potato-linflash}] } {
       set taskbarCmd {linflash .}
       set sysTrayCmd {# nothing}
     } else {
       set taskbarCmd {wm deiconify .}
       set sysTrayCmd {# nothing}
     }
  proc ::potato::flash {w} [format {
   variable world;
   variable winico;
   if { $world($w,act,flashTaskbar) } {
        %s
      }
   if { !$winico(flashing) && $world($w,act,flashSysTray) && $winico(mapped) } {
        %s
      }
   return;
  } $taskbarCmd $sysTrayCmd];# ::potato::flash

  return;

};# ::potato::setUpFlash

#: proc ::potato::chk_exit
#: arg prompt If 0, do not prompt. If 1, prompt. If -1, prompt only if there are open (meaning "not closed", as opposed to "connected") connections. NOTE: We always prompt if there are still active connections
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
#: desc Parse $str and return a -label and -underline option. The -label is $str with the first "&" removed, and the -underline is the position of that first & (or -1 if there is none).
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
  $m add checkbutton {*}[menu_label [T "Input1 Multi-Line Mode?"]] \
              -variable ::potato::conn($c,input1,mode) -onvalue "multi" -offvalue "single"
  $m add checkbutton {*}[menu_label [T "Input2 Multi-Line Mode?"]] \
              -variable ::potato::conn($c,input2,mode) -onvalue "multi" -offvalue "single"

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
  createMenuTask $m about
  $m add command {*}[menu_label [T "Visit Potato &Website"]] -command [list ::potato::launchWebPage $::potato::potato(webpage)]

  return;

};# ::potato::build_menu_help

#: proc ::potato::setUpMenu
#: desc set up the menu in the main window
#: return nothing
proc ::potato::setUpMenu {} {
  variable menu;

  menu .m -tearoff 0
  . configure -menu .m
  set menu(file,path) [menu .m.file -tearoff 0 -postcommand [list ::potato::build_menu_file .m.file]]
  set menu(edit,path) [menu .m.edit -tearoff 0 -postcommand [list ::potato::build_menu_edit .m.edit]]
  set menu(connect,path) [menu .m.file.connect -tearoff 0 -postcommand [list ::potato::rebuildConnectMenu .m.file.connect]]
  set menu(view,path) [menu .m.view -tearoff 0 -postcommand [list ::potato::build_menu_view .m.view]]
  set menu(log,path) [menu .m.log -tearoff 0 -postcommand [list ::potato::build_menu_log .m.log]]
  set menu(log,stop,path) [menu .m.log.stop -tearoff 0 -postcommand [list ::potato::build_menu_log_stop .m.log.stop]]
  set menu(options,path) [menu .m.options -tearoff 0 -postcommand [list ::potato::build_menu_options .m.options]]
  set menu(tools,path) [menu .m.tools -tearoff 0 -postcommand [list ::potato::build_menu_tools .m.tools]]
  set menu(help,path) [menu .m.help -tearoff 0 -postcommand [list ::potato::build_menu_help .m.help]]

  .m add cascade -menu .m.file {*}[menu_label [T "&File"]]
  set menu(file) [.m index end]
  .m add cascade -menu .m.edit {*}[menu_label [T "&Edit"]]
  set menu(edit) [.m index end]
  .m add cascade -menu .m.view {*}[menu_label [T "&View"]]
  set menu(view) [.m index end]
  .m add cascade -menu .m.log {*}[menu_label [T "&Logging"]]
  set menu(logging) [.m index end]
  .m add cascade -menu .m.options {*}[menu_label [T "&Options"]]
  set menu(options) [.m index end]
  .m add cascade -menu .m.tools {*}[menu_label [T "&Tools"]]
  set menu(tools) [.m index end]
  .m add cascade -menu .m.help {*}[menu_label [T "&Help"]]
  set menu(help) [.m index end]

  return;

};# ::potato::setUpMenu

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
  $m add command {*}[menu_label [T "&Copy"]] -accelerator Ctrl+C -command [list tk_textCopy $input] -state $state
  $m add command {*}[menu_label [T "C&ut"]] -accelerator Ctrl+X -command [list tk_textCut $input] -state $state

  if { ![catch {::tk::GetSelection $input CLIPBOARD} txt] && [string length $txt] } {
       set state normal
     } else {
       set state disabled
     }
  $m add command {*}[menu_label [T "&Paste"]] -accelerator Ctrl+V -command [list tk_textPaste $input] -state $state

  tk_popup $m $x $y

  return;

};# ::potato::inputWindowRightClickMenu

#: proc ::potato::setUpBindings
#: desc set up bindings used throughout Potato, including those for input and output text widgets, and bindings on "." which aren't done elsewhere
#: return nothing
proc ::potato::setUpBindings {} {

  catch {tcl_endOfWord}
  set ::tcl_wordchars {[a-zA-Z0-9' ]}
  set ::tcl_nonwordchars {[^a-zA-Z0-9']}

  bind . <FocusIn> [list ::potato::focusIn %W]
  bind . <Unmap> [list ::potato::minimizeToTray %W]

  # bindtags:
  # PotatoOutput displays output from the MUSH, and replaces Text in the bindtags.
  # PotatoInput is used for entering input, and comes before Text in the bindtags.
  # PotatoUserBindings have user-defined bindings on, and are included in the bindtags before both the above

  # Control-<num> shows connection <num>
  for {set i 1} {$i < 10} {incr i} {
     bind PotatoInput <Control-Key-$i> [list ::potato::showConn $i]
  }

  bind PotatoInput <Button-3> [list ::potato::inputWindowRightClickMenu %W %X %Y]

  # Stop the user being able to select the last newline in the text widget. When it's selected,
  # it causes "bleed" of the selection tag if new text is inserted.
  bind Text <<Selection>> {%W tag remove sel end-1c end}

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
  bind PotatoInput <End> {if { [%W compare insert == end-1char] } {[::potato::activeTextWidget] see end; #break}}

  # Scroll output window by a page
  bind PotatoInput <Prior> {[::potato::activeTextWidget] yview scroll -1 pages}
  bind PotatoInput <Next> {[::potato::activeTextWidget] yview scroll 1 pages}
  bind PotatoInput <Control-Prior> [bind Text <Prior>]
  bind PotatoInput <Control-Next> [bind Text <Next>]


  bind PotatoInput <Tab> "[bind Text <Control-Tab>] ; break"
  bind PotatoInput <Shift-Tab> "[bind Text <Control-Shift-Tab>] ; break"
  bind PotatoInput <Control-Tab> {potato::toggleConn 1 ; break}
  bind PotatoInput <Control-Shift-Tab> {potato::toggleConn -1 ; break}
  foreach x [list "" Shift- Control- Control-Shift-] {
     bind PotatoOutput <${x}Tab> [bind PotatoInput <${x}Tab>]
  }

  bind PotatoInput <MouseWheel> {}
  bind PotatoOutput <MouseWheel> {}
  bind all <MouseWheel> [list potato::mouseWheel %W %D]

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
  # This should probably use "focus" not "active", but at least on Windows, that has no effect.
  bind TButton <FocusIn> {%W instate !disabled {%W state active}}
  bind TButton <FocusOut> {%W instate !disabled {%W state !active}}

  # Copy some bindings from Text to PotatoOutput, so we can remove the 'Text' bindtags from it.
  # (safer to copy those we want than block those we don't, as more we don't want might be added later)
  foreach x [list B2-Motion Button-2 Meta-Key-greater Meta-Key-less Meta-f Meta-b Control-t Control-p Control-n Control-f Control-e Control-b Control-a Escape Control-Key Alt-Key <Copy> Control-backslash Control-slash Shift-Select Control-Shift-End Control-End Control-Shift-Home Control-Home Shift-End Shift-Home Home End Next Prior Shift-Next Shift-Prior Control-Shift-Up Control-Shift-Left Control-Shift-Right Control-Down Control-Up Control-Right Control-Left Up Down Left Right Shift-Up Shift-Down Shift-Left Shift-Right Control-Button-1 ButtonRelease-1 B1-Enter B1-Leave Triple-Shift-Button-1 Double-Shift-Button-1 Shift-Button-1 Triple-Button-1 Double-Button-1 B1-Motion Button-1 <Selection>] {
     bind PotatoOutput <$x> [bind Text <$x>]
  }
  bind PotatoOutput <<Copy>> [list ::potato::textCopy %W]
  bind PotatoOutput <<Cut>> [list ::potato::textCopy %W]

  bind PotatoOutput <Motion> [list ::potato::showMessageTimestamp %W %x %y]

  # Use Control-Return for a newline, and Return to send text
  bind PotatoInput <Control-Return> "[bind Text <Return>] ; break"
  bind PotatoInput <Return> "::potato::send_mushage %W 0 ; break"
  bind PotatoInput <Shift-Return> "::potato::send_mushage %W 1; break"

  # Counteract the annoying case-sensitiveness of bindings
  foreach x [list Text PotatoInput PotatoOutput] {
     foreach y [bind $x] {
        if { [regexp {^<.+-[a-z]>$} $y] } {
                  set char [string index $y end-1]
                  bind $x "[string range $y 0 end-2][string toupper $char]>" [bind $x $y]
           }
     }
  }
  setUpUserBindings

  return;

};# ::potato::setUpBindings

#: proc ::potato::textCopy
#: arg w widget path
#: desc Perform a 'Copy' on the text widget $w, skipping elided characters. Based on Tk's built-in tk_textCopy
#: return nothing
proc ::potato::textCopy {w} {

  if { ![catch {$w get -displaychars -- sel.first sel.last} data]} {
       clipboard clear -displayof $w
       clipboard append -displayof $w $data
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
  foreach x [arraySubelem conn $c,spawns] {
    if { $conn($x) eq $text } {
         return [removePrefix $x $c,spawns];
       }
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

  # The "Mac" key symbol is [format %c 8984]

  # A frame we don't pack which we set bindings for
  set bindingsWin [frame $win.bindings]

  unset -nocomplain keyShortsTmp

  foreach x [array names keyShorts] {
    set keyShortsTmp($x) $keyShorts($x)
    bind $bindingsWin <$keyShortsTmp($x)> $x
  }
  set keyShortsTmp(key,shift) 0
  set keyShortsTmp(key,control) 0
  set keyShortsTmp(key,alt) 0
  set keyShortsTmp(key,command) 0;# The "Mac" key

  pack [::ttk::label $win.l -text [T "Select a command, then click a button to edit it's binding"]] \
          -side top -padx 4 -pady 8

  pack [::ttk::frame $win.tree] -side top -anchor nw -fill both
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
    if { [info exists keyShortsTmp($task)] } {
         set binding [keysymToHuman $keyShortsTmp($task)]
       } else {
         set binding ""
       }
    $tree insert {} end -id $task -values [list $label $binding] -tags [list $task]
  }

  $tree selection set [lindex $allTasks 0 1]

  pack [::ttk::frame $win.btns] -side top -pady 8
  pack [::ttk::button $win.btns.clear -text [T "Clear"] -width 8 \
             -command [list ::potato::keyboardShortcutClear $tree $bindingsWin]] -side left -padx 4
  set subWin .keyShortsInput
  pack [::ttk::button $win.btns.change -text [T "Change"] -width 8 \
            -command [list ::potato::keyboardShortcutInput $subWin $win $tree $bindingsWin]] -side left -padx 4
  pack [::ttk::button $win.btns.save -text [T "Save"] -width 8 -command [list ::potato::keyboardShortcutWinSave $win]] -side left -padx 4
  pack [::ttk::button $win.btns.close -text [T "Cancel"] -width 8 -command [list destroy $win]] -side left -padx 4


  bind $win <Destroy> "destroy $subWin"

  reshowWindow $win 0
  focus $tree;

  return;

};# ::potato::keyboardShortcutWin

#: proc ::potato::keyboardShortcutWinSave
#: arg win Toplevel window
#: desc Save the changes to the Keyboard Shortcuts and then destroy $win
#: return nothing
proc ::potato::keyboardShortcutWinSave {win} {
  variable keyShorts;
  variable keyShortsTmp;

  array unset keyShortsTmp key,*
  destroy $win

  # Clear off current bindings
  foreach x [bind PotatoUserBindings] {
     bind PotatoUserBindings $x ""
  }
  array unset keyShorts
  foreach task [array names keyShortsTmp] {
     if { $keyShortsTmp($task) ne "" } {
          set keyShorts($task) $keyShortsTmp($task)
        }
  }
  setUpUserBindings

  return;

};# ::potato::keyboardShortcutWinSave

#: proc ::potato::keyboardShortcutClear
#: arg tree Treeview widget to check selection of
#: arg bindingsWin The window which has copies of all the [bind]ings on.
#: desc Prompt the user for comfirmation, then clear the keyboard shortcut for the task selected in $tree
#: return nothing
proc ::potato::keyboardShortcutClear {tree bindingsWin} {
  variable tasks;
  variable keyShortsTmp;

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

  bind $bindingsWin <$keyShortsTmp($task)> ""
  set keyShortsTmp($task) ""
  $tree item $task -values [list [taskLabel $task] ""]
  
  return;

};# ::potato::keyboardShortcutClear

#: proc ::potato::keyboardShortcutInput
#: arg win Toplevel window to create
#: arg parent The parent window
#: arg tree Treeview widget to check selection of
#: arg bindingsWin A widget which has bindings set for the current configuration
#: desc Show a window ($win) allowing the user to edit the keyboard binding for the task currently selected in $tree
#: return nothing
proc ::potato::keyboardShortcutInput {win parent tree bindingsWin} {
  variable keyShortsTmp;

  # We don't reshow, as it's probably presented for a different task,
  # and we don't want them to not realise it's still shown for that task, not the most-recently-selected
  if { [winfo exists $win] } {
        destroy $win
     }

  toplevel $win
  wm transient $win $parent
  set task [$tree selection]
  set taskLabel [taskLabel $task]
  wm title $win [T "Keyboard Shortcut for \"%s\"" $taskLabel]

  bind $win <KeyPress-Shift_L> [list set ::potato::keyShortsTmp(key,shift) 1]
  bind $win <KeyPress-Shift_R> [list set ::potato::keyShortsTmp(key,shift) 1]
  bind $win <KeyRelease-Shift_L> [list set ::potato::keyShortsTmp(key,shift) 0]
  bind $win <KeyRelease-Shift_R> [list set ::potato::keyShortsTmp(key,shift) 0]  

  bind $win <KeyPress-Control_L> [list set ::potato::keyShortsTmp(key,control) 1]
  bind $win <KeyPress-Control_R> [list set ::potato::keyShortsTmp(key,control) 1]
  bind $win <KeyRelease-Control_L> [list set ::potato::keyShortsTmp(key,control) 0]
  bind $win <KeyRelease-Control_R> [list set ::potato::keyShortsTmp(key,control) 0] 

  bind $win <KeyPress-Alt_L> [list set ::potato::keyShortsTmp(key,alt) 1]
  bind $win <KeyPress-Alt_R> [list set ::potato::keyShortsTmp(key,alt) 1]
  bind $win <KeyRelease-Alt_L> [list set ::potato::keyShortsTmp(key,alt) 0]
  bind $win <KeyRelease-Alt_R> [list set ::potato::keyShortsTmp(key,alt) 0]

  #abc No bindings for the Mac "Command" key yet.
  set text [T "Press the desired keyboard shortcut for '%s'.\nWhen the correct shortcut is displayed below, click Accept,\nor click Cancel to keep the current shortcut." $taskLabel]
  pack [::ttk::label $win.l -text $text] -side top -padx 4 -pady 6

  pack [set disp [::ttk::label $win.disp -text [T "<None>"]]] -side top -padx 4 -pady 10

  pack [::ttk::frame $win.btns] -side top
  set cmd {if { [::potato::keyboardShortcutSave %s %s %s %s] } {destroy %s}}
  pack [::ttk::button $win.btns.accept -text [T "Accept"] -width 8 \
                 -command [format $cmd $task $disp $bindingsWin $tree $win]] \
                 -side left -padx 7
  pack [::ttk::button $win.btns.cancel -text [T "Cancel"] -width 8 -command [list destroy $win]] -side left -padx 7

  bind $win <KeyPress> [list ::potato::keyboardShortcutInputProcess $win %K $disp]

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
proc ::potato::keyboardShortcutSave {task disp bindingsWin tree} {
  variable keyShortsTmp;

  set userBind [$disp cget -text]
  if { $userBind eq "<None>" } {
       bell -displayof $disp
       return 0;
     }

  set keysym [humanToKeysym $userBind]
  set current [bind $bindingsWin "<$keysym>"]
  if { $current ne "" && $current ne $task } {
       set message [T "The Keyboard Shortcut '%s' is already in use by the task '%s'. Do you want to override it?" $userBind [taskLabel $current]]
       set ans [tk_messageBox -parent [winfo toplevel $disp] \
                   -title [T "Keyboard Shortcut"] -type yesno -icon question -message $message]
        if { $ans ne "yes" } {
             return 0;
           }
        set keyShortsTmp($current) ""
        $tree item $current -values [list [taskLabel $current] ""]
     }

  if { [info exists keyShortsTmp($task)] && $keyShortsTmp($task) ne "" } {
        bind $bindingsWin <$keyShortsTmp($task)> ""
     }
  bind $bindingsWin "<$keysym>" $task
  set keyShortsTmp($task) $keysym
  $tree item $task -values [list [taskLabel $task] $userBind]

  return 1;

};# ::potato::keyboardShortcutSave

#: proc ::potato::keyboardShortcutInputProcess
#: arg win Toplevel window with the KeyPress bindings
#: arg key The keysym for the key that was pressed (%K)
#: arg disp The label widget to display the keysym in.
#: desc Process the keypress. This involves checking which modifiers are pressed, validating the keysym, and displaying it if valid.
#: return nothing
proc ::potato::keyboardShortcutInputProcess {win key disp} {
  variable keyShortsTmp;

  # Can be used with no mods
  set mod(0) [list F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 Prior Next Escape]
  # Must have a modifier "shift"
  set mod(1) [list plus minus asterisk slash]
  # Must have at least "Alt" or "Control"
  set mod(2) [list A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9 0 Up Down Left Right]

  if { [string length $key] == 1 } {
       set key [string toupper $key]
     }

  foreach x {shift control alt} {set $x $keyShortsTmp(key,$x)}
  if { ($key in $mod(1) && ![expr {$shift+$control+$alt}]) || ($key in $mod(2) && ![expr {$control+$alt}]) \
       || ($key ni $mod(0) && $key ni $mod(1) && $key ni $mod(2)) } {
       bell -displayof $win
       return;
     }

  set str [keysymToHuman $key]
  foreach {x y} [list alt Alt shift Shift control Control] {
     if { $keyShortsTmp(key,$x) } {
          set str "$y+$str"
        }
  }

  $disp configure -text $str

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
       if { $x ne "Key" && $x ne "KeyPress" && $x ne "KeyRelease" } {
            lappend list $x
          }
     }
  set last [lindex $list end]
  array set map [list Prior "Page Up" Next "Page Down" plus Plus minus Minus asterisk Asterisk slash "Forward Slash"]
  if { [info exists map($last)] } {
       set list [lreplace $list end end $map($last)]
     } elseif { [string length $last] == 1 && $last ne [string toupper $last] } {
       set list [lreplace $list end end [string toupper $last]]
     }

  set human [join $list $joinchar]
  if { $short } {
       set human [string map [list "Control$joinchar" "Ctrl$joinchar"] $human]
     }

  return $human;

};# ::potato::keysymToHuman

#: proc ::potato::humanToKeysym
#: arg keysym The Human-form keysym to translate
#: arg short Does the keysym use short names (Ctrl) instead of long names (Control)? Defaults to 0
#: arg joinchar Character keysym is joined with. Defaults to +.
#: desc Translate a human-readable key name into a keysym (valid for [bind])
#: return The keysym for [bind]
proc ::potato::humanToKeysym {keysym {short 0} {joinchar +}} {

  set list [split $keysym $joinchar]
  
  set last [lindex $list end]
  array set map [list "Page Up" Prior "Page Down" Next Plus plus Minus minus Asterisk asterisk "Forward Slash" slash]
  if { [info exists map($last)] } {
       set list [lreplace $list end end $map($last)]
     }
  set list [linsert $list end-1 "KeyPress"]

  return [join $list -];

};# ::potato::humanToKeysym

#: proc ::potato::setUpUserBindings
#: desc Set up the user-defined key bindings. If there are none, load the defaults first, then set them up.
#: return nothing
proc ::potato::setUpUserBindings {} {
  variable keyShorts;

  if { ![info exists keyShorts] || [array size keyShorts] == 0 } {
       loadDefaultUserBindings
     }

  foreach task [array names keyShorts] {
     if { [string match "*,*" $task] } {
          continue;
        }
     bind PotatoUserBindings <$keyShorts($task)> "[list ::potato::taskRun $task] ; break"
     set list [split $keyShorts($task) -]
     set last [lindex $list end]
     if { [string length $last] == 1 && $last ne [string tolower $last] } {
          bind PotatoUserBindings \
                  <[join [lreplace $list end end [string tolower $last]] -]> \
                  "[list ::potato::taskRun $task] ; break"
        }
  }

  return;

};# ::potato::setUpUserBindings

#: proc ::potato::loadDefaultUserBindings
#: desc Load the default user-configurable bindings, when none are set or when the user requests the defaults.
#: return nothing
proc ::potato::loadDefaultUserBindings {} {
  variable keyShorts;

  # Clear off current ones, if any
  array unset keyShorts;
  foreach x [bind PotatoUserBindings] {
     bind PotatoUserBindings $x ""
  }

  set keyShorts(close) "Control-KeyPress-F4"
  set keyShorts(config) "Control-KeyPress-W"
  set keyShorts(disconnect) "Control-Alt-KeyPress-D"
  set keyShorts(events) "Control-KeyPress-E"
  set keyShorts(exit) "Alt-KeyPress-F4"
  set keyShorts(find) "Control-KeyPress-F"
  set keyShorts(inputHistory) "Control-KeyPress-H"
  set keyShorts(log) "Control-KeyPress-L"
  set keyShorts(nextConn) "Control-KeyPress-N"
  set keyShorts(prevConn) "Control-KeyPress-P"
  set keyShorts(reconnect) "Control-KeyPress-R"
  set keyShorts(twoInputWins) "Control-KeyPress-I"
  set keyShorts(upload) "Control-KeyPress-U"
  set keyShorts(mailWindow) "Control-KeyPress-M"
  set keyShorts(prevHistCmd) "Control-KeyPress-Up"
  set keyShorts(nextHistCmd) "Control-KeyPress-Down"
  set keyShorts(spellcheck) "Control-KeyPress-S"
  set keyShorts(help) "F1"
  set keyShorts(fcmd2) "F2"
  set keyShorts(fcmd3) "F3"
  set keyShorts(fcmd4) "F4"
  set keyShorts(fcmd5) "F5"
  set keyShorts(fcmd6) "F6"
  set keyShorts(fcmd7) "F7"
  set keyShorts(fcmd8) "F8"
  set keyShorts(fcmd9) "F9"
  set keyShorts(fcmd10) "F10"
  set keyShorts(fcmd11) "F11"
  set keyShorts(fcmd12) "F12"

  return;

};# ::potato::loadDefaultUserBindings

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

  if { $delta >= 0 } {
       set cmd [list yview scroll [expr {-$delta/3}] pixels]
     } else {
       set cmd [list yview scroll [expr {(2-$delta)/3}] pixels]
     }
  set over [winfo containing -displayof $widget {*}[winfo pointerxy $widget]]
  if { $over eq "" || [catch {$over {*}$cmd}] } {
       catch {$widget {*}$cmd}
     }

  #abc Update so Treeviews can have their <Mousewheel> binding removed and replaced with this
  # Requires checking widget class and scrolling the appropriate amount.

  return;

};# ::potato::mouseWheel

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

  if { [$window count -chars 1.0 end-1c] == 0 && $conn($c,connected) == 0 } {
       reconnect [up]
       return;
     }

  set w $conn($c,world)

  if { $window eq $conn($c,input1) } {
       set mode $conn($c,input1,mode)
     } elseif { $window eq $conn($c,input2) } {
       set mode $conn($c,input2,mode)
     } else {
       set mode "multi" ;# shouldn't happen
     }

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
    foreach x $windows {
      if { ![info exists world($w,prefixes,$x)] || ![lindex $world($w,prefixes,$x) 1] } {
           continue;
         }
      !set prefix [lindex $world($w,prefixes,$x) 0]
      break;
    }
  }
  !set prefix ""

  set txt [$window get 1.0 end-1char]
  $window edit separator
  $window replace 1.0 end ""
  if { $mode eq "multi" } {
       if { $saveonly } {
            foreach x [split $txt "\n"] {
              addToInputHistory $c $x ""
            }
          } else {
            send_to "" $txt \n 1 $prefix
          }
     } else {
       if { $saveonly } {
            addToInputHistory $c $txt ""
          } else {
            send_to "" $txt "" 1 $prefix
          }
     }
  set inputSwap($window,count) -1
  set inputSwap($window,backup) ""

  return;

};# ::potato::send_mushage

#: proc ::potato::send_to
#: arg c connection id
#: arg string string to process
#: arg sep separator character
#: arg history add commands to history?
#: arg prefix Prefix (auto-say) to add, if text isn't a /command. Defaults to nothing.
#: desc for every line in $string (lines are delimited by $sep), parse (it may be a /command) and send to connection $c (or current connection, if $c is "") with prefix. If $sep is "" (empty string), treat as one line.
#: return nothing
proc ::potato::send_to {c string sep history {prefix ""}} {
  variable conn;
  variable world;

  if { $c eq "" } {
       set c [up]
     }

  if { $sep eq "" } {
       send_to_sub $c $string $prefix
     } else {
       foreach x [split $string $sep] {
          send_to_sub $c $x $prefix
       }
     }

  if { $history } {
       if { $sep ne "" && [info exists conn($c,world)] && $world($conn($c,world),splitInputCmds) } {
            foreach x [split $string $sep] {
               addToInputHistory $c $x ""
            }
          } else {
            addToInputHistory $c $string $sep
          }
     }
  return;

};# ::potato::send_to

#: proc ::potato::send_to_sub
#: arg c connection id
#: arg string string to process
#: arg prefix Prefix to add to non-/command lines. Defaults to "".
#: desc parse $string to see if it's a /command, and send to connection $c
#: return nothing
proc ::potato::send_to_sub {c string {prefix ""}} {

  if { [string index $string 0] ne "/" } {
       send_to_real $c "$prefix$string"
     } elseif { [string index $string 1] eq "/" } {
       send_to_real $c "$prefix[string range $string 1 end]"
     } else {
       process_slash_command $c $string
     }

  return;

};# ::potato::send_to_sub

#: proc ::potato::send_to_real
#: arg c connection id
#: arg string string to send
#: arg echostr If not "", use this string for output echo instead of $string. Meant for strings containing passwords. Defaults to "".
#: desc send the string $string to connection $c, after protocol escaping. Do not parse for /commands.
#: return nothing
proc ::potato::send_to_real {c string {echostr ""}} {
  variable conn;
  variable world;

  if { $c == 0 || ![info exists conn($c,connected)] || $conn($c,connected) != 1 } {
       return;
     }

  if { [hasProtocol $c telnet] } {
       set string [::potato::telnet::escape $string]
     }

  sendRaw $c $string 0
  if { $world($conn($c,world),echo) } {
       if { $echostr eq "" } {
            outputSystem $c $string [list "echo"]
          } else {
            outputSystem $c $echostr [list "echo"]
          }
     }

  return;

};# ::potato::send_to_real

#: proc ::potato::addToInputHistory
#: arg c connection id
#: arg cmd command to add
#: arg sep the character separating multiple commands in the string, or "" if none
#: desc add the given command to the input history for connection $c. If $sep != "", the command is a list of commands with each individual command separated by the character $sep
#: return nothing
proc ::potato::addToInputHistory {c cmd sep} {
  variable conn;
  variable world;

  if { $c == 0 || ![info exists conn($c,inputHistory)] } {
       return;
     }
  if { $sep eq "" } {
       lappend conn($c,inputHistory) [list [incr conn($c,inputHistory,count)] $cmd]
     } else {
       lappend conn($c,inputHistory) [list [incr conn($c,inputHistory,count)] [string map [list $sep \b] $cmd]]
     }
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
#: desc Unset the (possibly global) user-defined variable $varName, if it exists and isn't a pre-defined one. Attempting to set a variable that doesn't exist (including ones with invalid names) is not an error. Attempting to unset a pre-defined var (ie, one starting with an underscore) is, but we fail silently.
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

#: proc ::potato::parseUserVars
#: arg c connection id
#: arg str string to parse
#: desc Parse the string $str, expanding any user-defined variables in it.
#: return Modified string
proc ::potato::parseUserVars {c str} {
  variable conn;
  variable world;

  set return ""
  set inVar 0
  set varMarkerChar {$}
  if { [info exists conn($c,world)] } {
       set w $conn($c,world)
       # $_chr$ was a typo, but is left as an alias for $_char$ for backwards compatability
       array set masterVars [list _u [up] \
                                  _c $c \
                                  _w $w \
                                  _name $world($w,name) \
                                  _host $world($w,host) \
                                  _port $world($w,port) \
                                  _char $conn($c,char) \
                                  _chr $conn($c,char) \
                            ] ;# array set masterVars
     } else {
       set w -1;
       array set masterVars [list _u [up] \
                                  _c 0 \
                                  _w -1 \
                                  _name "Potato" \
                                  _host "unknown" \
                                  _port 0 \
                                  _char "" \
                                  _chr "" \
                            ] ;# array set masterVars
     }

  while { [set varMarker [string first $varMarkerChar $str]] > -1 } {
          if { !$inVar } {
               # Copy everything up to the varMarkerChar to $return and trim it from $str
               append return [string range $str 0 [expr {$varMarker - 1}]]
               set str [string range $str [expr {$varMarker + 1}] end]
               set inVar 1
             } else {
               # Everything up to the next varMarkerChar is the varname
               set varName [string range $str 0 [expr {$varMarker-1}]]
               set str [string range $str [expr {$varMarker+1}] end]
               if { [string length $varName] == 0 } {
                    # Literal varMarkerChar
                    append return $varMarkerChar
                  } elseif { [info exists masterVars($varName)] } {
                    append return $masterVars($varName)
                  } elseif { [info exists conn($c,uservar,$varName)] } {
                    # Local var
                    append return $conn($c,uservar,$varName)
                  } elseif { [info exists conn(0,uservar,$varName)] } {
                    # Global var
                    append return $conn(0,uservar,$varName)
                  }
                set inVar 0
              }
         }

  if { $inVar } {
       # Someone didn't close a varname (did "somestring$varname"). Options:
       # 1. append '$varname' as literal text
       # 2. append 'varname' as literal text
       # 3. attempt to append the value of the variable 'varname'
       # 4. do nothing
       # Current choice: 4

     } else {
       # Copy rest of string
       append return $str
     }

  return $return;

};# ::potato::parseUserVars

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
#: desc A custom slash command was being edited (or added), but we're done with the changes made (either we've already saved them, or we don't want to because "Discard" was clicked), so clear them out and set up for tree selection again.
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
#: desc The "Edit /command" button has been clicked. De/re-activate the appropriate widgets. We don't need to check for a selection (as the button is disabled when there isn't one), or set the vars to the /command's current values (that's already done on selection), but we do need to record that we're now editing, and which.
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
#: desc The "Add /command" button has been clicked. De/re-activate the appropriate widgets, set default values for the /command, and set vars to show we're editing a new /command
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

#: proc ::potato::process_slash_command
#: arg c connection id
#: arg str the string entered ("/command arg arg arg")
#: arg silent Suppress confirmation/error system messages from /command?
#: desc process $str as a slash command and perform the necessary action
#: return nothing
proc ::potato::process_slash_command {c str {silent 0}} {
  variable conn;
  variable world;

  if { ![info exists conn($c,id)] } {
       return; # Running a /command for a closed connection - maybe on a timer that didn't cancel?
     }
  set cmd [string range $str 1 end]
  if { $cmd eq "" } {
       if { $c != 0 && !$silent } {
            outputSystem $c [T "Which /command?"]
          } else {
            bell -displayof .
          }
       return;
     }
  set space [string first " " $cmd]
  if { $space == -1 } {
       set cmdArgs ""
     } else {
       set cmdArgs [string range $cmd [expr {$space+1}] end]
       # Parse variables in arg
       set cmdArgs [parseUserVars $c $cmdArgs]
       set cmd [string range $cmd 0 [expr {$space-1}]]
     }

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
            customSlashCommand $c $custom $exact $cmdArgs
          } else {
            # Built-in /command
            $exact $c 1 $cmdArgs $silent
          }
       return;
     } elseif { [llength $partial] == 1 } {
       [lindex $partial 0] $c 0 $cmdArgs $silent
       return;
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
       if { [info exists world(-1,slashcmd)] } {
            foreach x $world(-1,slashcmd) {
               if { [string equal -nocase -length [string length $cmd] $cmd $x] } {
                    lappend partial $x
                    set custom -1
                  }
            }
          }
       if { [llength $partial] == 0 } {
            if { $c != 0 && !$silent } {
                 outputSystem $c [T "Unknown /command \"%s\". Use /slash for a list. Use //command to send directly to MU*." $cmd]
               } else {
                 bell -displayof .
               }
            return;
          } elseif { [llength $partial] > 1 } {
            if { $silent } {
                 bell -displayof .
               } else {
                 outputSystem $c [T "Ambiguous /command \"%s\"." $cmd]
               }
            return;
          }
       customSlashCommand $c $custom [lindex $partial 0] $cmdArgs
     } else {
       if { $c != 0 } {
            if { $silent } {
                 bell -displayof .
               } else {
                 outputSystem $c [T "Ambiguous /command \"%s\"." $cmd]
               }
          }
       return;
     }

};# ::potato::process_slash_command

#: proc ::potato::define_slash_cmd
#: arg cmd Name of /command
#: arg code body of /command
#: desc Add a new ::potato::slash_cmd_$cmd proc with the appropriate args, and a body of $code.
#: return nothing.
proc ::potato::define_slash_cmd {cmd code} {

  # c = connection id, full = was the command name typed in full?, str = the arg given to the /command,
  # silent = suppress messages?
  proc ::potato::slash_cmd_$cmd {c full str {silent 0}} $code;

  return;

};# ::potato::define_slash_cmd

#: proc ::potato::customSlashCommand
#: arg c connection id
#: arg w world id
#: arg cmd /command name
#: arg str args to /command
#: desc Try and run the custom slash command $cmd, defined in world $w, for connection $c, using args $str. We pass $w rather than checking $c's world b/c the command might be defined in -1
#: return nothing
proc ::potato::customSlashCommand {c w cmd str} {
  variable conn;
  variable world;

  if { $world($w,slashcmd,$cmd,type) == "regexp" } {
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
       return;
     }

  set send $world($w,slashcmd,$cmd,send)
  set send [string map [list %% % %0 $a(0) %1 $a(1) %2 $a(2) %3 $a(3) %4 $a(4) \
                             %5 $a(5) %6 $a(6) %7 $a(7) %8 $a(8) %9 $a(9)] $send]
  
  send_to $c $send "" 0

  return;

};# ::potato::customSlashCommand

#: /silent <slashcmd>
#: Run the /command <slashcmd> without producing errors/confirmations
::potato::define_slash_cmd silent {

  if { [string index $str 0] ne "/" || [string index $str 1] eq "/" } {
       bell -displayof .
       return;
     } else {
       process_slash_command $c $str 1
     }

};# /silent

#: /input [1|2] <stuff> - print <stuff> to input window [1|2]
::potato::define_slash_cmd input {

  set str [string trimleft $str]
  set list [split $str " "]
  # We use string comparison, not numerical, otherwise "/input 3.0 foo" will pass, but will fail
  # as we don't have conn($c,input3.0) vars.
  if { [lindex $list 0] ne 1 && [lindex $list 0] ne 2 && [lindex $list 0] ne 3 } {
       if { !$silent } {
            outputSystem $c [T "Invalid input window \"%s\": must be 1, 2 or 3" [lindex $list 0]]
          }
       return;
     }
  
  showInput $c [lindex $list 0] [join [lrange $list 1 end] " "] 1

  return;

};# /input

#: /setprefix [[<window>]=<prefix>]
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
       return;
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
     } elseif { ![regexp $potato(spawnRegexp) $window] } {
       beep -displayof .
       return;
     }

  if { $str eq "" } {
       # Clear prefix
       unset -nocomplain world($w,prefixes,$window)
     } else {
       # Update prefix. We enable the new prefix, even if there
       # was an existing, disabled one.
       set world($w,prefixes,$window) [list $str 1]
     }

  return;

};# /setprefix

#: /print <str>
#: Print <str> as a system message
::potato::define_slash_cmd print {

  outputSystem $c $str
  return;

};# /print

#: /at <time>=<action>
#: At [clock scan <time>] send <action> to the MUSH
::potato::define_slash_cmd at {
  variable conn;

  set equals [string first "=" $str]
  if { $equals == -1 } {
       outputSystem $c [T "Format: /at <time>=<string>"]
       return;
     }
  set time [string range $str 0 $equals-1]
  set action [string range $str $equals+1 end]
  if { [catch {clock scan $time} inttime] } {
       outputSystem $c "/at: $inttime"
       return;
     }

  set now [clock seconds]
  if { $now >= $inttime } {
       if { $silent } {
            bell -display of .
          } else {
            outputSystem $c [T "/at: Time must be in the future."]
          }
       return;
     }
  set when [expr {($inttime - [clock scan "now"]) * 1000}]
  lappend conn($c,userAfterIDs) [set afterid [after $when [list ::potato::send_to $c $action "\n" 0 ""]]]
  if { !$silent } {
       outputSystem $c [T "Command will run at %s, id %s" [clock format $inttime -format "%D %T"] $afterid]
     }
  after [expr {$when + 1200}] [list ::potato::cleanup_afters $c]

  return;
};# /at

#: /debug [--on | --off | --toggle]
#: Show the Debug Packets window
::potato::define_slash_cmd debug {
  variable conn;

  if { $c == 0 } {
       bell -displayof .
       return;
     }

  if { $str eq "--on" } {
       set conn($c,debugPackets) 1
     } elseif { $str eq "--off" } {
       set conn($c,debugPackets) 0
     } else {
       set conn($c,debugPackets) [lindex [list 1 0] $conn($c,debugPackets)]
     }

  return;

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
       if { $silent } {
            bell -displayof .
          } else {
            outputSystem $c [T "No such macro \"%s\"." $str]
          }
       return;
     }

  send_to $c $world($do) "\n" 0 ""

  return;
};# /runmacro

#: /cancelat <id>
#: Cancel a previous /at using the after id given by /at
::potato::define_slash_cmd cancelat {
  variable conn;

  if { $str ni $conn($c,userAfterIDs) } {
       if { $silent } {
            bell -displayof .
          } else {
            outputSystem $c [T "Invalid /at ID."]
          }
       return;
     }

  after cancel $str
  if { !$silent } {
       outputSystem $c [T "/at cancelled."]
     }
  cleanup_afters $c

  return;
};# /cancelat

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

#: /addspawn <spawn>[ <spawnN>]
#: Add each of the space-separated list of spawns to the spawn-all list for the connection
::potato::define_slash_cmd addspawn {
  variable conn;

  set spawns [split $conn($c,spawnAll) " "]
  set str [split $str " "]
  foreach x $str {
    if { $x eq "" || $x in $spawns } {
         continue;
       }
    lappend spawns $x
  }
  set conn($c,spawnAll) [join $spawns " "]
  return;

};# /addspawn

#: /delspawn <spawn>[ <spawnN>]
#: Delete each of the space-separated list of spawns from the spawn-all list for the connection
::potato::define_slash_cmd delspawn {
  variable conn;

  set spawns [split $conn($c,spawnAll) " "]
  set str [split $str " "]
  foreach x $str {
    if { $x eq "" || $x ni $spawns } {
         continue;
       }
    set pos [lsearch -exact $spawns $x]
    set spawns [lreplace $spawns $pos $pos]
  }
  set conn($c,spawnAll) [join $spawns " "]
  return;

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
       default {outputSystem $c [T "Invalid option \"%s\" to /limit" $x] ; return;}
    }
    set list [lrange $list 1 end]
  }

  set str [join $list " "]
  if { $str eq "" } {
       return;
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
         if { $silent } {
              bell -displayof .
            } else {
              outputSystem $c [T "Invalid %s pattern \"%s\": %s" $matchType $str $match]
            }
         return;
       }
    if { ($invert ? $match : !$match) } {
         $t tag add limited $i.0 "$i.0 lineend+1char"
       }
  }

  set conn($c,limited) [list $matchType $invert $case $str]

  return;

};# /limit

#: /unlimit
#: Show all output, when output is reduced by /limit
::potato::define_slash_cmd unlimit {
  variable conn;

  if { [info exists conn($c,textWidget)] && [winfo exists $conn($c,textWidget)] } {
       $conn($c,textWidget) tag remove limited 1.0 end
     }

  set conn($c,limited) [list]

  return;

};# /unlimit

#: /cls [<c>]  |  /cls [<c>.][<window>]
#: Clear the <window> output window for conn <c>, defaulting to _main and the current connection respectively
::potato::define_slash_cmd cls {
  variable conn;

  if { !$full } {
       bell -displayof .
       return;# too risky to allow an abbreviation
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
       return;# invalid window name
     }

  if { ![info exists conn($c,textWidget)] } {
       bell -displayof .
       return;# bad connection
     }

  if { $window eq "_main" || $window eq "" } {
       $conn($c,textWidget) delete 1.0 end
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
       $conn($c,textWidget) delete 1.0 2.0;# remove leading newline 
     } elseif { [info exists conn($c,spawns,$window)] } {
       $conn($c,spawns,$window) delete 1.0 end
     } else {
       bell -displayof . ;# no such spawn window
     }

  return;

};# /cls

#: /send <str>
#: Send <str> to the connection
::potato::define_slash_cmd send {

  send_to_real $c $str
  return;

};# /send

#: /all <str>
#: Send <str> to all connections
::potato::define_slash_cmd all {

  foreach x [connList] {
    send_to_real [lindex $x 0] $str
  }
  return;

};# /all

#: /show <c>  |  /show [<c>.]<window>
#: Show <window> in connection <c>, defaulting to <main> and current connection
::potato::define_slash_cmd show {
  variable conn;


  if { [string trim $str] eq "" } {
       bell -displayof .
       return;
     }

  if { [string is integer -strict $str] } {
       # Just got a connection number
       showConn $str
     } elseif { [regexp -nocase {^(?:([0-9]+)\.)?(_main|[a-zA-Z][a-zA-Z0-9_-]{0,49})?$} $str {} c2 window] } {
       # We have an optional connection number, and a valid spawn name
       if { $c2 eq "" } {
            set c2 $c
          }
       # $window may signify the main text widget, but by using showSpawn not showConn we
       # request the skin show the main text widget, if it's not already doing so.
       showSpawn $c2 $window
       return;
     } else {
       # Invalid arg
       bell -displayof .
       return;
     }

};# /show

#: /slash
#: Print a list of all /commands
::potato::define_slash_cmd slash {
  variable world;

  set list [list]
  foreach x [info procs ::potato::slash_cmd_*] {
     lappend list [string range $x 20 end]
  }
  outputSystem $c [T "Available slash commands: %s" [itemize [lsort -dictionary $list]]]
  set w [connInfo $c world]
  if { $w != -1 && [llength $world($w,slashcmd)] } {
       outputSystem $c [T "User-defined commands for this world: %s" [itemize [lsort -dictionary $world($w,slashcmd)]]]
     }
  if { [llength $world(-1,slashcmd)] } {
       outputSystem $c [T "Global User-defined commands: %s" [itemize [lsort -dictionary $world(-1,slashcmd)]]]
     }

  return;

};# /slash

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

#: /set <varname>=<value>
#: Set a connection-local variable <varname> (accessed in /commands as $<varname>$ to <value>
::potato::define_slash_cmd set {

  setUserVar $c 0 $str
  return;

};# /set

#: /unset <varname>
#: Unset the connection-local variable <varname>
::potato::define_slash_cmd unset {

  unsetUserVar $c 0 $str
  return;

};# /unset

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
         if { $silent } {
              bell -displayof .
            } else {
              outputSystem $c "/vars: Invalid arg \"$x\": Must be one of -all, -global or -local"
            }
         return;
       }
  }

  if { !($global || $local) } {
       set local 1
       set global 1
     }
       
  if { $local && $c != 0 } {
       outputSystem $c "World vars:"
       foreach x [lsort -dictionary [removePrefix [array names conn $c,uservar,*] $c,uservar]] {
         outputSystem $c "\t$x\t$conn($c,uservar,$x)"
       }
       if { $global } {
            outputSystem $c ""
          }
     }

  if { $global || ($local && $c == 0) } {
       outputSystem $c "Global vars:"
       foreach x [lsort -dictionary [removePrefix [array names conn 0,uservar,*] 0,uservar]] {
         outputSystem $c "\t$x\t$conn(0,uservar,$x)"
       }
     }

};# /vars

#: /setglobal <varname>=<value>
#: Set a global (all connections) variable <varname> to <value>
::potato::define_slash_cmd setglobal {

  setUserVar $c 1 $str
  return;

};# /setglobal

#: /unsetglobal <varname>
#: Unset global var <varname>
::potato::define_slash_cmd unsetglobal {

  unsetUserVar $c 1 $str
  return;

};# /unsetglobal

#: /edit
#: Show the Edit Settings window
::potato::define_slash_cmd edit {
  variable conn;

  if { $c == 0 } {
       taskRun programConfig
     } else {
       taskRun config $c $c
     }
  return;

};# /edit

#: /tcl
#: Show the Tcl code console if available
::potato::define_slash_cmd tcl {

  if { [catch {console show}] } {
       bell -displayof .
       return;
     }

};# /tcl

#: /eval <code>
#: Evaluate the Tcl code <code> and print the result to the output window
::potato::define_slash_cmd eval {

  set err [catch {uplevel #0 $str} msg]
  if { $silent } {
       if { $err } {
            bell -displayof .
          }
       return;
     }

  if { $err } {
       outputSystem $c [T "Error (%d): %s" [string length $msg] $msg]
     } else {
       outputSystem $c [T "Return (%d): %s" [string length $msg] $msg]
     }

};# /eval

#: /speedwalk <dirs>
#: Speedwalk in the given directions. <dirs> is a string in the format [<number>][ ]<direction>[[ ][<numberN>][ ]<directionN>]
::potato::define_slash_cmd speedwalk {

  if { ![regexp {^ *([0-9]+ *([ns][ew]|[nsweudo]) *)+ *$} $str] } {
       if { $silent } {
            bell -displayof .
          } else {
            outputSystem $c [T "Invalid speedwalk command"]
          }
       return;
     }

  set sendStr ""
  set dirs [list n north s south w west e east nw northwest ne northeast sw southwest se southeast \
                 u up d down o out]
  foreach {all num dir} [regexp -all -inline -- { *([0-9]+)? *((?:[ns][ew]|[nsewudo])) *} $str] {
     set which [expr {[lsearch -exact $dirs $dir] + 1}]
     append sendStr [string repeat "[lindex $dirs $which]\n" $num]
  }
  return;
  send_to $c [string range $sendStr 0 end-1] \n 1

  return;

};# /speedwalk

# Create a /sw alias for /speedwalk
interp alias {} ::potato::slash_cmd_sw {} ::potato::slash_cmd_speedwalk

#: /log  |  /log -close [<path>] |  /log [-options] <path>
#: Either show the logging window, close open log(s) or start logging to a new file
::potato::define_slash_cmd log {
  variable conn;

  if { $c == 0 } {
       bell -displayof .
       return;
     }

  # Check for no options given
  if { [string trim $str] eq "" } {
       taskRun log $c $c
       return;
     }

  # Check for "/log -close"
  set argv [split $str " "]
  set argc [llength $argv]
  if { [lsearch -exact -nocase [list -close -stop -off] [lindex $argv 0]] != -1 } {
       # Close an open log file, or all open log files
       set res [taskRun logStop $c $c [join [lrange $argv 1 end] " "]]
       if { $res < 1 && $silent } {
            bell -displayof .
          } elseif { $res == 0 } {
            bell -displayof .
          } elseif { $res == -1 } {
            outputSystem $c [T "Log file \"%s\" not found." [join [lrange $argv 1 end] " "]]
          } elseif { $res == -2 } {
            outputSystem $c [T "Log file \"%s\" is ambiguous." [join [lrange $argv 1 end] " "]]
          }
       return;
     }

  # Try and parse out options...
  array set options [list -buffer 0 -append 1 -leave 1]
  set error ""
  set finished 0
  set file [list]
  set needOpt 1
  set i 0
  foreach x $argv {
     incr i
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
                if { $match eq "-append" || $match eq "-leave" } {
                     if { [string is boolean -strict $x] } {
                          set options($match) [string is true -strict $x]
                        } else {
                          set error [T "Invalid setting \"%s\" for \"%s\"" $x $match]
                          break;
                        }
                   } elseif { $match eq "-buffer" } {
                     if { [string equal $x "_none"] } {
                          set options(-buffer) "No Buffer"
                        } elseif { [string equal $x "_main"] } {
                          set options(-buffer) "Main Window"
                        } else {
                          set options(-buffer) $x;# name of a spawn window
                        }
                   }
                set needOpt 1
              }
        }
     }

  if { $error ne "" } {
       if { $silent } {
            bell -displayof .
          } else {
            outputSystem $c "/log: $error"
          }
       return;
     }

  set file [join $file " "]
  if { $file eq "" } {
       # Gahhhh. Why did I write all that parsing code if you DIDN'T GIVE A FILE?!
       taskRun log $c $c
       return;
     }

  doLog $c $file $options(-append) $options(-buffer) $options(-leave)
  return;     

};# /log

#: /close
#: Close the current connection
::potato::define_slash_cmd close {

  taskRun close $c $c

  return;

};# /close

#: /connect <worldname>
#: Connect to the saved world <worldname>
::potato::define_slash_cmd connect {
  variable world;
  variable misc;

  set str [string trim $str]
  set len [string length $str]
  if { $len == 0 } {
       slash_cmd_reconnect $c $full $str
       return;
     }
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
       return;
     } elseif { [llength $partial] == 0 } {
       if { $c != 0 && !$silent } {
            outputSystem $c [T "No such world \"%s\". Use \"/quick host port\" to connect to a world that isn't in the address book." $str]
          } else {
            bell -displayof .
          }
       return;
     } elseif { [llength $partial] == 1 || $misc(partialWorldMatch) } {
       newConnectionDefault [lindex $partial 0]
       return;
     } else {
       if { $c != 0 && !$silent } {
            outputSystem $c [T "Ambiguous world name \"%s\"." $str]
          } else {
            bell -displayof .
          }
       return;
     }

};# ::potato::slash_cmd_connect

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

  return;

};# /quick

#: /exit
::potato::define_slash_cmd exit {

  if { $full } {
       set prompt 0
     } else {
       set prompt -1
     }
  taskRun exit $c $prompt
  return;

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
            if { $silent } {
                 bell -displayof .
               } else {
                 outputSystem $c [T "Ambiguous character name \"%s\"" $str]
               }
          } else {
            set conn($c,char) [lindex $world($w,charList) [list $chars 0]]
            taskRun reconnect
          }
     } else {
       if { $silent } {
            bell -displayof .
          } else {
            outputSystem $c [T "Invalid connection id/character name"]
          }
     }

  return;

};# /reconnect

#: /disconnect
#: Disconnect the current connection
::potato::define_slash_cmd disconnect {

  taskRun disconnect
  return;

};# /disconnect

#: /toggle [<direction>]
#: Toggle the shown connection forward/backwards one connection
::potato::define_slash_cmd toggle {

  if { $str eq "down" || $str == -1 } {
       taskRun prevConn
     } else {
       taskRun nextConn
     }
  return;

};# /toggle

#: /web <address>
#: Launch a web browser to show <address>
::potato::define_slash_cmd web {

  launchWebPage $str
  return;

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
                 bell -displayof .
                 return;
               }
          } elseif { [set pos [lsearch -index 0 $conn($c,inputHistory) $num]] == -1 } {
            bell -displayof .
            return;
          }
       if { [focus -displayof $conn($c,input2)] eq $conn($c,input2) } {
            set input 2
          } else {
            set input 1
          }
       showInput $c $input [string map [list \b \n] [lindex $conn($c,inputHistory) $pos 1]] 1
     }
      
  return;

};# /history

#: proc ::potato::timeFmt
#: arg seconds a number of seconds
#: arg full show full words instead of single letter abbreviations?
#: desc format a number of seconds into days, hours, minutes and seconds
#: return formatted result
proc ::potato::timeFmt {seconds full} {
  set timeList [list]
  if { $full } {
       set words [list " day" " hour" " minute" " second"]
     } else {
       set words [list d h m s]
     }
  foreach div {86400 3600 60 1} mod {0 24 60 60} name $words {
     set n [expr {$seconds / $div}]
     if {$mod > 0} {
         set n [expr {$n % $mod}]
        }
     if { $n > 0 } {
          if { $n > 1 && $full } {
               append name s
             }
          lappend timeList "$n$name"
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

  set str [T "%s Version %s.\nA MU* Client written in Tcl/Tk by\nMike Griffiths (%s)\n\n%s" $potato(name) $potato(version) $potato(contact) $potato(webpage)]

  pack [::ttk::label $frame.top.img -image ::potato::img::logoSmall] -side left -padx 15
  pack [::ttk::label $frame.top.txt -text $str] -side left -padx 5
  $frame.top.txt configure -font [list {*}[font actual "TkDefaultFont"] -size 12]
  

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

  dde servername -handler [list potato::handleOutsideRequest dde] -- potatoMUClient
  return;

};# ::potato::ddeStart

#: proc ::potato::parseTelnetAddress
#: arg addr the address to parse
#: desc Attempt to parse $addr as a world address. Ignore the optional "telnet://" prefix, then attempt to match a string (host), followed by either a space or a colon, then a group of ints (port).
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
#: desc $addr is an address we've been asked to connect to, either via DDE on Windows or on the command line. Attempt to do so, respecting the potato::misc(outsideRequestMethod) var
#: return nothing
proc ::potato::handleOutsideRequest {src addr {isWorld 0}} {
  variable world;
  variable misc;
  variable potato;

  # If $isWorld is 1, $addr is a world name. Else, it's either telnet://host:port, host:port or "host port".
  if { $isWorld } {
       # This is basically identical to using "/connect <world>", so we'll just trigger that.
       slash_cmd_connect [up] 1 $addr
       return;
     }

  # OK, let's do it the hard way...

  # Let's see if what we have is a valid host and port
  set hostAndPort [parseTelnetAddress $addr]
  if { [llength $hostAndPort] == 0 } {
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
#: desc Launch a text editor window for connection $c (or current connection if $c is "")
#: return nothing
proc ::potato::textEditor {{c ""}} {
  variable potato;
  variable conn;
  variable world;

  if { $c == "" } {
       set c [up]
     }

  set i 1
  while { [winfo exists [set win .textEditor_${c}_$i]] } {
          incr i;
          if { $i > 5 } {
               tk_messageBox -title $potato(name) -message [T "You can't open any more text editor windows for that world."] \
                             -icon info -type ok
               return;
             }
        }

  toplevel $win
  registerWindow $c $win
  wm withdraw $win
  if { $c == 0 } {
       wm title $win "TextEd $i ($potato(name))"
     } else {
       wm title $win "TextEd $i \[$c. $world($conn($c,world),name)\]"
     }

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both -side left -anchor nw

  pack [::ttk::frame $frame.main -relief sunken -borderwidth 2] -expand 1 -fill both -padx 1 -pady 1
  set text [text $frame.main.text -width 40 -height 20 -wrap word -undo 1]
  set sbY [::ttk::scrollbar $frame.main.sbY -orient vertical -command [list $text yview]]
  set sbX [::ttk::scrollbar $frame.main.sbX -orient horizontal -command [list $text xview]]
  $text configure -yscrollcommand [list $sbY set] -xscrollcommand [list $sbX set]
  grid_with_scrollbars $text $sbX $sbY

  set menu [menu $win.menu -tearoff 0]
  $win configure -menu $win.menu
  set menuAction [menu $menu.action -tearoff 0]
  set menuConvert [menu $menu.convert -tearoff 0]
  # set menuColour [menu $menu.colour -tearoff 0]
  # set menuColourBG [menu $menu.colourBG -tearoff 1]
  # set menuColourFG [menu $menu.colourFG -tearoff 1]
  $menu add cascade {*}[menu_label [T "&Action"]] -menu $menuAction

  set allTxt [format {[%s get 1.0 end-1char]} $text]
  $menuAction add command {*}[menu_label [T "Send to &World"]] \
          -command [format {::potato::send_to %s %s \n 1} $c $allTxt]
  $menuAction add command {*}[menu_label [T "Place in &Top Input Window"]] \
          -command [format {::potato::showInput %s 1 %s 1} $c $allTxt]
  $menuAction add command {*}[menu_label [T "Place in &Bottom Input Window"]] \
          -command [format {::potato::showInput %s 2 %s 1} $c $allTxt]
  $menuAction add separator
  $menuAction add cascade {*}[menu_label [T "&Convert..."]] -menu $menuConvert
  # $menuAction add cascade {*}[menu_label [T "&ANSI Colour..."] -menu $menuColour]
  $menuAction add separator
  $menuAction add command {*}[menu_label [T "&Open..."]] -command [list ::potato::textEditorOpen $text]
  $menuAction add command {*}[menu_label [T "&Save As..."]] -command [list ::potato::textEditorSave $text]

  $menuConvert add command {*}[menu_label [T "&Returns to %r"]] \
           -command [list ::potato::textFindAndReplace $text [list \n %r]]
  $menuConvert add command {*}[menu_label [T "&Spaces to %b"]] \
           -command [list ::potato::textFindAndReplace $text [list " " %b]]
  $menuConvert add command {*}[menu_label [T "&Escape Special Characters"]] \
           -command [format {::potato::textFindAndReplace %s {"%c" %%t %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c %c \\%c \%c \\\%c \%c \\\%c \%c \\\%c}} $text 9 37 37 59 59 91 91 93 93 40 40 41 41 44 44 94 94 36 36 123 123 125 125 92 92]
  # $menuConvert add comand {*}[menu_label [T "&ANSI Colours to Tags"]] -command [list ::potato::textEditorConvertANSI $text]
  
  # Allow for saving to a file, including hard-wrapping and auto-indenting! #abc
  # Do ANSI Colour conversion stuff! #abc


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
  ::skin::$potato(skin)::inputWindows [expr {$conn($c,twoInputWindows) + 1}]

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
            set def "None"
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

  send_to $c $cmd "" 1

  return;

};# ::potato::fcmd

#: proc ::potato::tasksInit
#: desc Initialise the list of tasks which can be keyboard-bound, appear in menus, etc.
#: return Nothing
proc ::potato::tasksInit {} {
  variable tasks;

  # Set map of task names and commands
  array set tasks [list \
       inputHistory,name   [T "Show Input &History Window"] \
       inputHistory,cmd    "::potato::history" \
       inputHistory,state  notZero \
       goNorth,name        [T "Go &North"] \
       goNorth,cmd         [list ::potato::send_to {} north {} 1] \
       goNorth,state       connected \
       goSouth,name        [T "Go &South"] \
       goSouth,cmd         [list ::potato::send_to {} south {} 1] \
       goSouth,state       connected \
       goEast,name         [T "Go &East"] \
       goEast,cmd          [list ::potato::send_to {} east {} 1] \
       goEast,state        connected \
       goWest,name         [T "Go &West"] \
       goWest,cmd          [list ::potato::send_to {} west {} 1] \
       goWest,state        connected \
       find,name           [T "&Find"] \
       find,cmd            "::potato::findDialog" \
       find,state          notZero \
       disconnect,name     [T "&Disconnect"] \
       disconnect,cmd      "::potato::disconnect" \
       disconnect,state    {$c != 0 && ($conn($c,connected) != 0 || ($conn($c,connected) == 0 && $conn($c,reconnectId) ne ""))} \
       reconnect,name      [T "&Reconnect"] \
       reconnect,cmd       "::potato::reconnect" \
       reconnect,state     {$c != 0 && $conn($c,connected) == 0} \
       close,name          [T "&Close Connection"] \
       close,cmd           "::potato::closeConn" \
       close,state         notZero \
       nextConn,name       [T "&Next Connection"] \
       nextConn,cmd        [list ::potato::toggleConn 1] \
       nextConn,state      {[llength [connIDs]] > 1} \
       prevConn,name       [T "&Previous Connection"] \
       prevConn,cmd        [list ::potato::toggleConn -1] \
       prevConn,state      {[llength [connIDs]] > 1} \
       config,name         [T "Configure &World"] \
       config,cmd          "::potato::configureWorld" \
       config,state        notZero \
       programConfig,name  [T "Configure Program &Settings"] \
       programConfig,cmd   [list ::potato::configureWorld -1] \
       programConfig,state always \
       events,name         [T "Configure &Events"] \
       events,cmd          "::potato::eventConfig" \
       events,state        notZero \
       globalEvents,name   [T "&Global Events"] \
       globalEvents,cmd    [list ::potato::eventConfig -1] \
       globalEvents,state  always \
       slashCmds,name      [T "Customise &Slash Commands"] \
       slashCmds,cmd       "::potato::slashConfig" \
       slashCmds,state     notZero \
       globalSlashCmds,name [T "Global S&lash Commands"] \
       globalSlashCmds,cmd [list ::potato::slashConfig -1] \
       globalSlashCmds,state always \
       log,name            [T "Show &Log Window"] \
       log,cmd             "::potato::logWindow" \
       log,state           notZero \
       logStop,name        [T "Close &All Logs"] \
       logStop,cmd         "::potato::stopLog" \
       logStop,state       {[llength [array names ::potato::conn $c,log,*]] > 0} \
       upload,name         [T "&Upload File"] \
       upload,cmd          "::potato::uploadWindow" \
       upload,state        always \
       help,name           [T "Show &Helpfiles"] \
       help,cmd            "::wikihelp::help" \
       help,state          always \
       about,name          [T "&About Potato"] \
       about,cmd           "::potato::about" \
       about,state         always \
       exit,name           [T "E&xit"] \
       exit,cmd            "::potato::chk_exit" \
       exit,state          always \
       textEd,name         [T "&Text Editor"] \
       textEd,cmd          "::potato::textEditor" \
       textEd,state        always \
       twoInputWins,name   [T "Show Two Input Windows?"] \
       twoInputWins,cmd    "::potato::toggleInputWindows" \
       twoInputWins,state  always \
       connectMenu,name    [T "&Connect To..."] \
       connectMenu,cmd     "::potato::connectMenuPost" \
       connectMenu,state   always \
       customKeyboard,name [T "Customize Keyboard Shortcuts"] \
       customKeyboard,cmd  "::potato::keyboardShortcutWin" \
       customKeyboard,state always \
       mailWindow,name     [T "Open &Mail Window"] \
       mailWindow,cmd      "::potato::mailWindow" \
       mailWindow,state    notZero \
       prevHistCmd,name    [T "Previous History Command"] \
       prevHistCmd,cmd     "::potato::inputHistoryScroll -1" \
       prevHistCmd,state   always \
       nextHistCmd,name    [T "Next History Command"] \
       nextHistCmd,cmd     "::potato::inputHistoryScroll 1" \
       nextHistCmd,state   always \
       escHistCmd,name     [T "Clear History Command"] \
       escHistCmd,cmd      "::potato::inputHistoryReset" \
       escHistCmd,state    always \
       manageWorlds,name   [T "&Address Book"] \
       manageWorlds,cmd    "::potato::manageWorlds" \
       manageWorlds,state  always \
       autoConnects,name   [T "Manage &Auto-Connects"] \
       autoConnects,cmd    "::potato::autoConnectWindow" \
       autoConnects,state  always \
       fcmd2,cmd           "::potato::fcmd 2" \
       fcmd2,name          [T "Run F2 Command"] \
       fcmd2,state         always \
       fcmd3,cmd           "::potato::fcmd 3" \
       fcmd3,name          [T "Run F3 Command"] \
       fcmd4,state         always \
       fcmd4,cmd           "::potato::fcmd 4" \
       fcmd4,name          [T "Run F4 Command"] \
       fcmd5,state         always \
       fcmd5,cmd           "::potato::fcmd 5" \
       fcmd5,name          [T "Run F5 Command"] \
       fcmd6,state         always \
       fcmd6,cmd           "::potato::fcmd 6" \
       fcmd6,name          [T "Run F6 Command"] \
       fcmd7,state         always \
       fcmd7,cmd           "::potato::fcmd 7" \
       fcmd7,name          [T "Run F7 Command"] \
       fcmd8,state         always \
       fcmd8,cmd           "::potato::fcmd 8" \
       fcmd8,name          [T "Run F8 Command"] \
       fcmd9,state         always \
       fcmd9,cmd           "::potato::fcmd 9" \
       fcmd9,name          [T "Run F9 Command"] \
       fcmd10,state        always \
       fcmd10,cmd          "::potato::fcmd 10" \
       fcmd10,name         [T "Run F10 Command"] \
       fcmd11,state        always \
       fcmd11,cmd          "::potato::fcmd 11" \
       fcmd11,name         [T "Run F11 Command"] \
       fcmd12,state        always \
       fcmd12,cmd          "::potato::fcmd 12" \
       fcmd12,name         [T "Run F12 Command"] \
       spellcheck,name     [T "Check &Spelling"] \
       spellcheck,cmd      "::potato::spellcheck" \
       spellcheck,state    {[file exists $::potato::misc(aspell)]} \
       macroWindow,name    [T "&Macro Window"] \
       macroWindow,cmd     "::potato::macroWindow" \
       macroWindow,state   notZero \
       globalMacros,name   [T "Global &Macro Window"] \
       globalMacros,cmd    "::potato::macroWindow -1" \
       globalMacros,state  always \
  ]

  return;

};# ::potato::tasksInit

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

  if { ![info exists tasks($task,state)] } {
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

  if { ![info exists tasks($task,cmd)] } {
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

  if { ![info exists tasks($task,name)] } {
       return;
     }

  if { $menu } {
       return $tasks($task,name);
     } else {
       return [string map [list & ""] $tasks($task,name)];
     }

};# ::potato::taskLabel

#: proc ::potato::spellcheck
#: desc Launch the spellchecker for the current input window. Note: the actual spellchecking code is in potato-spell.tcl, this simply launches it with the correct text and processes the result.
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
  regsub -all {\?} $temp {(.)} temp
  regsub -all {\*} $temp {(.*)} temp

  return "^$temp\$";

};# ::potato::glob2Regexp

#: proc ::potato::inputHistoryScroll
#: arg dir Direction to scroll, either -1 (older commands), or 1 (newer commands)
#: arg Win Window to do stuff in. Defaults to ""
#: desc Scroll the text in the input window $win (or the window with focus if $win is "") to show the prev/next input history command. If window with focus isn't an input window, do nothing
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
#: desc If input window $win (or the window with focus if $win is "") is showing an input history cmd, reset it to the stored cmd. If window with focus isn't an input window, do nothing
#: return nothing
proc ::potato::inputHistoryReset {{win ""}} {
  variable inputSwap;

  if { $win eq "" } {
       set win [focus -displayof .]
     }
  if { ![info exists inputSwap($win,conn)] } {
       # bell -displayof .
       return;
     }
  if { $inputSwap($win,count) == -1 } {
       bell -displayof $win
       return;
     }
  $win replace 1.0 end $inputSwap($win,backup)
  set inputSwap($win,count) -1

  return;

};# ::potato::inputHistoryReset

#: proc ::potato::T
#: arg msgformat A message format string to pass to msgcat
#: arg args Args to insert into the message format string
#: desc This is a wrapper func for using msgcat to translate Potato's messages
#: return A localized string
proc ::potato::T {msgformat args} {

  if { [catch {::msgcat::mc $msgformat {*}$args} i18n] } {
       # We should probably report this error somewhere, but not sure where. #abc
       if { [llength $args] && ![catch {format $msgformat {*}$args} formatted] } {
            return $formatted;
          } else {
            return $msgformat;
          }
     } else {
       return $i18n;
     }

};# ::potato::T

namespace eval ::potato {
  namespace export T
}

##################################
# Everything below this should be somewhere more sensible, please. Thank you. #abc
package require Tcl 8.5 ; package require Tk 8.5; # this should be redone more elegantly #abc
option add *Listbox.activeStyle dotbox
option add *TEntry.Cursor xterm

package require potato-telnet 1.1
package require potato-proxy
package require potato-wikihelp
package require potato-help
package require potato-font
package require potato-spell

::potato::main

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

parray potato::world *,name




