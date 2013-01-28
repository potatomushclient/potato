# This file contains things related to configuring Potato.

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
  variable tinyurl;
  variable gameMail;

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
  set world(-1,ansi,xterm) 1

  # Defaults about the world
  set world(-1,name) [T "New World"]
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
  set world(-1,type) "MUSH"
  set world(-1,telnet) 1
  set world(-1,telnet,ssl) 0
  set world(-1,telnet,naws) 1
  set world(-1,telnet,term) 1
  set world(-1,telnet,term,as) ""
  set world(-1,telnet,keepalive) 0
  set world(-1,telnet,prompts) 1
  set world(-1,telnet,promptsPersist) 1
  set world(-1,telnet,prompt,ignoreNewline) 1
  set world(-1,encoding,start) iso8859-1
  set world(-1,encoding,negotiate) 1
  set world(-1,groups) [list]
  set world(-1,prefixes) [list]
  set world(-1,nbka) 0

  set world(-1,proxy) "None"
  set world(-1,proxy,host) ""
  set world(-1,proxy,port) ""

  set world(-1,echo) 0
  set world(-1,echo,timers) 0
  set world(-1,ignoreEmpty) 0

  set world(-1,outputLimit,on) 0
  set world(-1,outputLimit,to) 500
  set world(-1,spawnLimit,on) 1
  set world(-1,spawnLimit,to) 250
  set world(-1,inputLimit,on) 1
  set world(-1,inputLimit,to) 250
  set world(-1,splitInputCmds) 0

  set world(-1,beep,show) 1
  set world(-1,beep,sound) "Once" ;# All, Once or None

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
  set world(-1,selectToCopy) 0

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

  set world(-1,slashcmd) [list]

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
  set world(-1,autosend,firstconnect) ""
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
  set misc(tinyurlProvider) "TinyURL"

  set misc(autoConnect) 1 ;# should we run autoconnects?

  set misc(checkForUpdates) 1

  set misc(selectToCopy) 0

  # misc(locale) is the user's preferred locale. potato(locale), set in main/i18nPotato is
  # the locale that's actually currently being used
  set misc(locale) "en_us";# most people probably want this default

  # Default skin
  set misc(skin) "potato";# Hah. Not that there will ever be another skin this century.

  # Path to ASpell. Try to guess a default. Probably won't work on Windows.
  set misc(aspell) [auto_execok aspell]

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

  # These are static, but this is still probably the best place to set them
  set tinyurl(TinyURL,post) "url"
  set tinyurl(TinyURL,address) "http://tinyurl.com/create.php"
  set tinyurl(TinyURL,regexp) {<blockquote><b>(\S+?)</b>}

  set tinyurl(AltURL,post) "longurl"
  set tinyurl(AltURL,address) "http://alturl.com/make_url.php"
  set tinyurl(AltURL,regexp) {<input .*?id="txtfld".*?\s+value *= *"(.+?)">}

  set tinyurl(NotLong,post) "url"
  set tinyurl(NotLong,address) "http://notlong.com/"
  set tinyurl(NotLong,regexp) {<blockquote>\s*<a href="(.+?)">\1</a>}

  set gameMail(MUSH\ @mail) "@mail %to%=%subject%/%body%"
  set gameMail(MUX\ @mail) "@mail %to%=%subject% ;; -%body% ;; --"
  set gameMail(Multi-Command\ +mail) "+mail %to%=%subject% ;; -%body% ;; --"
  set gameMail(MUSE\ +mail) "+mail %to%=%body%"
  set gameMail(Myrddin's\ BB) "+bbpost %to%/%subject%=%body%"

  if { $readfile } {
       array set prefFlags [prefFlags]
       if { ![catch {source $path(preffile)} retval] } {
            set retval [split $retval .]
            managePrefVersion [lindex $retval 0]
            manageWorldVersion -1 [lindex $retval 1]
          } else {
            errorLog "Unable to load prefs from \"[file nativename [file normalize $path(preffile)]]\": $retval" error
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

  if { $misc(aspell) eq "" } {
       set misc(aspell) [auto_execok aspell]
     }

  set misc(locale) [string tolower $misc(locale)]

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

#: proc ::potato::managePrefVersion
#: arg version The version of the pref file, or an empty string if none was present (ie, the pref file pre-dates versions)
#: desc Prefs were loaded from a version $version pref  file; make any changes necessary to bring it up to date with a
#: desc current pref file. NOTE: Does not manage "world -1", the default world settings, as they're generally identical to normal world settings
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

#: proc ::potato::configureWorld
#: arg w world id, defaults to ""
#: arg autosave Automatically invoke the 'Save' button after creating the window? defaults to 0
#: desc show the configuration dialog for world $w, or the world of the connection currently displayed if $w is "".
#: desc If any part of this needs to create a popup, it should be named ${worldConfigToplevel}_subToplevel_<description> -
#: desc this will cause it to be automatically destroyed when the $worldConfigToplevel is destroyed.
#: desc If $autosave is true, as soon as the window is correctly set up, invoke the save button to destroy it and initiate an
#: desc update of the settings. Used if settings are changed programatically (via Import Settings, etc) to trigger a full update.
#: return nothing
proc ::potato::configureWorld {{w ""} {autosave 0}} {
  variable world;
  variable conn;
  variable worldconfig;
  variable potato;
  variable misc;
  variable tinyurl;

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
             -values [list MUD MUSH] -width 20 -state readonly] -side left -padx 3

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
  pack [pspinbox $sub.spin -textvariable ::potato::worldconfig($w,autoreconnect,time) -from 0 -to 3600 \
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
  pack [pspinbox $sub.spin -textvariable ::potato::worldconfig($w,loginDelay) -from 0 -to 60 -increment 0.5 \
             -validate all -validatecommand {string is double %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.nbka]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Send null-byte keepalives?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,nbka) -onvalue 1 -offvalue 0] -side left

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

  pack [set sub [::ttk::frame $frame.keepalive]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Use NOP Keepalive?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,telnet,keepalive) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.prompts]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Handle GA/EOR Prompts?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,telnet,prompts) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.promptsPersist]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Persist Prompts?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,telnet,promptsPersist) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.promptNL]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.label -text [T "Ignore NL after Prompts?"] -width 35 -justify left -anchor w] -side left -padx 3
  pack [::ttk::checkbutton $sub.cb -variable ::potato::worldconfig($w,telnet,prompt,ignoreNewline) -onvalue 1 -offvalue 0] -side left

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

  pack [set sub [::ttk::frame $frame.boxes3]] -side top -pady 5 -expand 1 -fill x
  pack [::ttk::frame $sub.left] -side left -expand 1 -fill x
  pack [::ttk::label $sub.left.l -text [T "Show XTERM Colours?"] -width 23 -anchor w -justify left] -side left -anchor w
  pack [::ttk::checkbutton $sub.left.c -variable potato::worldconfig($w,ansi,xterm) -onvalue 1 -offvalue 0] -side left -anchor w


  # Display: Misc
  set frame [configureFrame $canvas [T "Miscellaneous Display Options"]]
  set confDisplayMisc [lindex $frame 0]
  set frame [lindex $frame 1]

  pack [set sub [::ttk::frame $frame.wrap]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Wrap text at:"] -width 20 -anchor w -justify left] -side left
  pack [pspinbox $sub.spin -textvariable ::potato::worldconfig($w,wrap,at) -from 0 -to 1000 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left
  pack [::ttk::button $sub.b -text " [T "Current Window Size"] " -command [list ::potato::currentWindowSize ::potato::worldconfig($w,wrap,at) $w 1000]] -side left -padx 8

  pack [set sub [::ttk::frame $frame.indent]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Indent By:"] -width 20 -anchor w -justify left] -side left
  pack [pspinbox $sub.spin -textvariable ::potato::worldconfig($w,wrap,indent) -from 0 -to 20 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.echo]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Echo Sent Commands?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.cb -variable potato::worldconfig($w,echo) -onvalue 1 -offvalue 0] -side left

  pack [set sub [::ttk::frame $frame.echoTimers]] -side top -pady 5 -anchor nw
  pack [::ttk::label $sub.l -text [T "Echo Timer Commands?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.cb -variable potato::worldconfig($w,echo,timers) -onvalue 1 -offvalue 0] -side left

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
  pack [pspinbox $sub.output-to.spin -textvariable ::potato::worldconfig($w,outputLimit,to) -from 0 -to 5000 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.spawn]] -side top -pady 5 -anchor nw
  pack [::ttk::frame $sub.spawn] -side left -anchor nw
  pack [::ttk::label $sub.spawn.l -text [T "Limit Spawn Lines?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.spawn.cb -variable potato::worldconfig($w,spawnLimit,on) -onvalue 1 -offvalue 0] -side left
  pack [::ttk::frame $sub.spawn-to] -padx 5 -side left
  pack [::ttk::label $sub.spawn-to.l -text [T "Limit To:"] -width 5] -side left
  pack [pspinbox $sub.spawn-to.spin -textvariable ::potato::worldconfig($w,spawnLimit,to) -from 0 -to 5000 \
             -validate all -validatecommand {string is integer %P} -width 6] -side left

  pack [set sub [::ttk::frame $frame.input]] -side top -pady 5 -anchor nw
  pack [::ttk::frame $sub.input] -side left -anchor nw
  pack [::ttk::label $sub.input.l -text [T "Limit Input Lines?"] -width 20 -anchor w -justify left] -side left
  pack [::ttk::checkbutton $sub.input.cb -variable potato::worldconfig($w,inputLimit,on) -onvalue 1 -offvalue 0] -side left
  pack [::ttk::frame $sub.input-to] -padx 5 -side left
  pack [::ttk::label $sub.input-to.l -text [T "Limit To:"] -width 5] -side left
  pack [pspinbox $sub.input-to.spin -textvariable ::potato::worldconfig($w,inputLimit,to) -from 0 -to 5000 \
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
  foreach x [array names world -regexp "^$w,timer,\[0-9\]+,cmds\$"] {
    if { [scan $x $w,timer,%d,cmds timerId] < 1 } {
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

       pack [set sub [::ttk::frame $frame.firstconnect]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Send upon first connect, before Login info:"]] -side top
       pack [set sub [::ttk::frame $sub.tframe]] -side top -pady 3 -anchor nw
       pack [text $sub.txt -height 10 -width 78 -undo 0 -wrap word -font TkFixedFont \
                    -yscrollcommand [list $sub.sb set]] -side left -anchor nw -fill both
       pack [::ttk::scrollbar $sub.sb -orient vertical -command [list $sub.txt yview]] -side right -fill y
       $sub.txt insert end $world($w,autosend,firstconnect)
       $sub.txt configure -undo 1
       set worldconfig($w,CONFIG,autosend,firstconnect) $sub.txt

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

       set lW 29

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

       set temp [array names tinyurl *,post]
       foreach x $temp {
         lappend tinyurls [string range $x 0 end-5]
       }
       unset temp x
       pack [set sub [::ttk::frame $frame.tinyurl]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "TinyURL Provider:"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig(MISC,tinyurlProvider) \
                        -values $tinyurls -width 20 -state readonly] \
                        -side left -padx 3
       set potato::worldconfig(MISC,tinyurlProvider) $misc(tinyurlProvider)

       unset tinyurls

       if { ![catch {::ttk::style theme names} styles] } {
            pack [set sub [::ttk::frame $frame.tileTheme]] -side top -pady 5 -anchor nw
            pack [::ttk::label $sub.l -text [T "Widget Theme:"] -width $lW -anchor w -justify left] -side left
            pack [::ttk::combobox $sub.cb -textvariable ::potato::worldconfig(MISC,tileTheme) \
                        -values $styles -width 20 -state readonly] -side left -padx 3
            set potato::worldconfig(MISC,tileTheme) $misc(tileTheme)
          }

       pack [set sub [::ttk::frame $frame.autoConnect]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Allow Auto-Connects?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,autoConnect) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,autoConnect) $misc(autoConnect)

       pack [set sub [::ttk::frame $frame.checkForUpdates]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Check for Updates on Startup?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,checkForUpdates) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,checkForUpdates) $misc(checkForUpdates)

       pack [set sub [::ttk::frame $frame.selectToCopy]] -side top -pady 5 -anchor nw
       pack [::ttk::label $sub.l -text [T "Select to Copy?"] -width $lW -anchor w -justify left] -side left
       pack [::ttk::checkbutton $sub.c -variable ::potato::worldconfig(MISC,selectToCopy) \
                          -onvalue 1 -offvalue 0] -side left
       set potato::worldconfig(MISC,selectToCopy) $misc(selectToCopy)


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
#: desc Called when the Configure window for a world is destroyed. Close all sub-windows, and unset the vars used by the config window.
#: desc This is called both when the Configure World is cancelled, but also when the window is destroyed after the settings are saved
#: desc (via a <Destroy> binding), so everything from the vars must be saved before the window is destroyed! ($win is already going when this is called)
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
#: desc Measure how many chars, for world $w, it would take to fill the main window at current size (capping at $max). Set result in $var.
#: desc NOTE: This is really quite skin dependant, and needs recoding better to interface with the skin, instead of cheating and assuming the
#: desc default skin. Not that I'm ever likely to get around to writing another one. #abc
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
  pack [pspinbox $frame.delay.sb -from 0 -to 18000 -increment 1 -width 5 -justify right -validate key \
                                 -validatecommand {string is integer %P} \
                                 -textvariable potato::worldconfig($w,timer,ae,delay)] -side left -anchor w -padx 5
  pack [::ttk::label $frame.delay.l2 -text [T "seconds"]] -side left -anchor w

  pack [::ttk::frame $frame.cmds] {*}$styles -expand 1 -fill both
  pack [::ttk::label $frame.cmds.l -text [T "Run the commands:"]] -side top -anchor nw
  pack [set text [text $frame.cmds.t -height 5 -width 40]] -side top -anchor nw -expand 1 -fill both
  $text insert end [string map [list " \b " "\n"] $worldconfig($w,timer,ae,cmds)]
  bind $text <Tab> [bind PotatoInput <Tab>]
  bind $text <Shift-Tab> [bind PotatoInput <Shift-Tab>]

  pack [::ttk::frame $frame.every] {*}$styles
  pack [::ttk::label $frame.every.l1 -text [T "And repeat every"]] -side left -anchor w
  pack [pspinbox $frame.every.sb -from 0 -to 18000 -increment 1 -width 5 -justify right \
                                -validate key -validatecommand {string is integer %P} \
                                -textvariable potato::worldconfig($w,timer,ae,every)] -side left -anchor w -padx 5
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
  pack [pspinbox $frame.howmany.count.sb -from 0 -to 10000 -increment 1 -width 5 -justify right \
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
  pack [::ttk::button $frame.buttons.ok.btn -text [T "OK"] -width 8 -default active  \
                                   -command [list potato::configureTimerSave $w $text]] -side right -padx 8 -anchor e
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
#: desc For world $w, use the info saved in worldconfig($w,timer,ae,*) and the text in the $text widget
#: desc (which holds the cmds to run for the timer), save the timer info. worldconfig($w,timer,ae) is the id of the timer to edit,
#: desc or the empty string to add a timer. We must also update the info displayed
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
#: desc For world $w's configure window, add (or update, if it exists) the treeview row for
#: desc timer $timer, using the info in the $worldconfig($w,timer,$timer,*) vars
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
#: desc pop up a font selection dialog so the $where font for world $w can be changed. If a new one
#: desc is selected, update the worldconfig var and configure the font for $text to show it. Make the dialog a transient of $parent.
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
  if { ![package vsatisfies [package present Tk] 8.6-] } {
       set new [::font::choose $parent ${parent}_subToplevel_font-$where [$text cget -font] $title]
       if { $new eq "" } {
            return;
          }
       set worldconfig($w,$where,font) $new
       # caught so we don't throw an error when the font-chooser is closed b/c the Configure window was cancelled
       catch {$text configure -font $new}
     } else {
       if { [tk fontchooser configure -visible] } {
            # Font chooser already open for something else
            bell -displayof $parent
            return;
          }
       # Updating the font is handled via a callback.
       tk fontchooser configure -parent $parent -title $title \
         -font [$text cget -font] -command [list ::potato::configureFontUpdate $text]
       tk fontchooser show
    }

  return;

};# ::potato::configureFont

#: proc ::potato::configureFontUpdate
#: arg t text widget to update the font of
#: arg font Font to use
#: arg args Not used
#: desc Wrapper for the -command option to [tk fontchooser] to update the font when specified.
#: return nothing
proc ::potato::configureFontUpdate {t font args} {

  if { [winfo exists $t] && ![catch {font actual $font} act] } {
       $t configure -font $act
     }

  return;

};# ::potato::configureFontUpdate

#: proc ::potato::configureText
#: arg w world id
#: arg event the event triggering the proc
#: arg text the text widget the event is happening in
#: arg colour the colour name to be configured, if any. Defaults to "" (none)
#: desc for Enter or Leave events, reconfigure $text's cursor. For Click events, pop up a colourchoose dialog to change $color,
#: desc and if a new one is selected, update the worldconfig var for the world.
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
#: desc save all the settings for world $w, destroy the config window used for changing them, change the tags, etc,
#: desc for any connections using this world, and if the currently-shown connection uses it, tell the skin to re-show.
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
       set autosend(firstconnect) [$worldconfig($w,CONFIG,autosend,firstconnect) get 1.0 end-1char]
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
       set world($w,autosend,firstconnect) $autosend(firstconnect)
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
          updateConnName $c
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

  if { [up] == 0 } {
       connZero
     }

  return;

};# ::potato::configureWorldCommit

#: proc ::potato::configureFrame
#: arg canvas path to canvas widget
#: arg title string to display as title
#: desc creates a frame to display inside the scrolled canvas $canvas to contain config options. Then creates a subframe, packed
#: desc inside with some padding, and a label to display $title as a heading for the "page".
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

#: proc ::potato::pickLocale
#: desc Show the window for changing Potato's locale/language
#: return nothing
proc ::potato::pickLocale {} {
  variable misc;
  variable potato;
  variable path;
  variable locales;

  set win .chooseLocale
  if { [reshowWindow $win] } {
       return;
     }

  toplevel $win
  wm withdraw $win
  wm title $win [T "Language Selection"]

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both -anchor nw
  pack [::ttk::label $frame.l -text [T "Please select your desired language below and click Save\n\nNote that changes may not take effect until after you reboot."]] -padx 8 -pady 5 -anchor nw
  pack [set lf [::ttk::frame $frame.langs]] -padx 15 -pady 5 -anchor nw

  image create photo ::potato::img::locale_none -height 32 -width 32
  set images [list "none"]

  set loclist [list]
  foreach x [array names locales -regexp {^[^,]+$}] {
    lappend loclist [list $x $locales($x)]
  }
  set loclist [lsort -index 1 $loclist]

  if { [lsearch -nocase  [::msgcat::mcpreferences] $misc(locale)] == -1} {
       if { [info exists locales(map,$misc(locale))] } {
            set name "$locales(map,$misc(locale)) ($misc(locale))"
          } elseif { [info exists "locales(map,[lindex [split $misc(locale) "_"] 0])"] } {
            set name "$locales(map,[lindex [split $misc(locale) "_"] 0]) ($misc(locale))"
          } else {
            set name $misc(locale)
          }
       lappend loclist [list $misc(locale) "$name (Current setting - not available)"]
       set locales(conf,curr) $misc(locale)
     } else {
       set locales(conf,curr) $potato(locale)
     }


  foreach x $loclist {
    set code [lindex $x 0]
    set name [lindex $x 1]
    set shortcode [lindex [split $code "_"] 0]
    foreach img [list $code $shortcode none] {
      if { $img in $images } {
           break;
       } elseif { [file exists [set file [file join $path(vfsdir) lib images flags $img.gif]]] } {
         image create photo ::potato::img::locale_$img -file $file
         lappend images $img
         break;
       }
    }
    pack [::ttk::radiobutton $lf.r_$code -text $name -takefocus 0 -image "::potato::img::locale_$img" -compound left -variable ::potato::locales(conf,curr) -value $code] -anchor nw
  }

  pack [::ttk::frame $frame.btns] -fill x -pady 5 -anchor nw
  set save [::ttk::button $frame.btns.save -text [T "Save"] -command [list ::potato::saveLocale $win]]
  set cancel [::ttk::button $frame.btns.cancel -text [T "Cancel"] -command [list destroy $win]]
  grid $save $cancel -padx 5
  grid configure $save -sticky e
  grid configure $cancel -sticky w

  grid columnconfigure $frame.btns 0 -weight 1 -uniform x
  grid columnconfigure $frame.btns 1 -weight 1 -uniform x

  update
  center $win
  wm deiconify $win

  bind $win <Escape> [list destroy $win]
  bind $win <Destroy> [list array unset ::potato::locales conf,*]

};# ::potato::pickLocale

#: proc ::potato::saveLocale
#: arg win Path of locale-config toplevel
#: desc Save the newly selected locale, update the locale being used, destroy $win
#: return nothing
proc ::potato::saveLocale {win} {
  variable locales;
  variable misc;
  variable potato;

  set new $locales(conf,curr)
  array unset locales conf,*

  if { $new ne $misc(locale) } {
       set misc(locale) $new
       setLocale
     }

  destroy $win;

  return;

};# ::potato::saveLocale
