# This file contains the code used by Potato for matching, triggering, and configuring Events.

#: proc ::potato::eventsMatch
#: args c connection id
#: args _tagged name of variable to upvar, holding tagged characters to match
#: args _lineNoansi name of variable to upvar, holding the line to match with no ANSI
#: args _eventInfo name of variable to upvar, holding array of event match data
#: desc Match all events for connection $c against the given text, altering the values of _tagged, _lineNoansi and _eventInfo to reflect changes made by the events.
#: return nothing
proc ::potato::eventsMatch {c _tagged _lineNoansi _eventInfo} {
  variable conn;
  variable world;
  upvar 1 $_tagged tagged;
  upvar 1 $_lineNoansi str;
  upvar 1 $_eventInfo eventInfo;

  set w $conn($c,world)
  set up [up]
  set focus [focus -displayof .]
  set strL [string tolower $str]

  if { $w == 0 } {
       set worlds [list 0]
     } else {
       set worlds [list $w 0]
     }

  set eventInfo(matched) 0

  set done 0
  foreach w $worlds {
    if { $done } {
         break;
       }
    foreach event $world($w,events) {
      set replaceOffset 0
      if { !$world($w,events,$event,enabled) } {
           continue;
         }
      if { ($up == $c) && ($world($w,events,$event,inactive) eq "world") } {
           continue;
         }
      if { ($focus ne "") && ($world($w,events,$event,inactive) eq "program") } {
           continue;
         }
      if { ($focus ne "") && ($up == $c) && ($world($w,events,$event,inactive) eq "inactive") } {
           continue;
         }
      unset -nocomplain arg
      set all 0
      switch $world($w,events,$event,matchtype) {
          "regexp" -
          "wildcard" {
                    set failStr 0
                    set matchCmd [list regexp -all -indices]
                    if { !$world($w,events,$event,case) } {
                         lappend matchCmd "-nocase"
                       }
                    if { $world($w,events,$event,matchAll) } {
                         set all 1
                       }
                    lappend matchCmd "--"
                    if { $world($w,events,$event,matchtype) eq "wildcard" } {
                         lappend matchCmd $world($w,events,$event,pattern,int)
                       } else {
                         lappend matchCmd $world($w,events,$event,pattern)
                       }
                    lappend matchCmd $str
                    set matchCmdArgs [list startAndEnd arg(0) arg(1) arg(2) arg(3) \
                             arg(4) arg(5) arg(6) arg(7) arg(8) arg(9)]
                   }
          "contains" {
                    set failStr -1
                    set matchCmd [list string first]
                    if { $world($w,events,$event,case) } {
                         lappend matchCmd $world($w,events,$event,pattern) $str
                       } else {
                         lappend matchCmd [string tolower $world($w,events,$event,pattern)] $strL
                       }
                   }
      };# switch
      if { [catch {{*}$matchCmd} result] || $result == $failStr } {
           continue;
         }
      if { $world($w,events,$event,matchtype) eq "contains" } {
           set start $result
           set reslen [expr {[string length $world($w,events,$event,pattern)] - 1}]
           set end [expr {$result + $reslen}]
           set arg(0) [list $start $end]
           set allMatches [list [list $start $end [array get arg]]]
         } elseif { $all && $result > 1} {
           set matchCmd [list regexp -all -inline -indices]
           if { !$world($w,events,$event,case) } {
                lappend matchCmd "-nocase"
              }
           if { $world($w,events,$event,matchtype) eq "wildcard" } {
                lappend matchCmd $world($w,events,$event,pattern,int)
              } else {
                lappend matchCmd $world($w,events,$event,pattern)
              }
           lappend matchCmd $str
           set allPositions [{*}$matchCmd]
           set len [llength $allPositions]
           set each [expr {$len / $result}]
           set allMatches [list]
           for {set i 0} {$i < $result} {incr i} {
                set curr [lrange $allPositions 0 $each-1]
                set allPositions [lrange $allPositions $each end]
                set start [expr {[lindex $curr 0 0] - $replaceOffset}]
                set end [expr {[lindex $curr 0 1] - $replaceOffset}]
                set args [lrange $curr 1 end]
                set maxarg [expr {min($each-1, 10)}]
                unset -nocomplain arg
                for {set j 0} {$j < $maxarg} {incr j} {
                  if { [lindex $curr $j+1] ni [list "" [list -1 -1]] } {
                       set arg($j) [lindex $curr $j+1]
                     }
                }
                if { [info exists arg] } {
                     lappend allMatches [list $start $end [array get arg]]
                   } else {
                     lappend allMatches [list $start $end [list]]
                   }
               }
         } else {
           # We need to re-run to capture the single set of args, without -all
           set matchCmd [lreplace $matchCmd 1 1]
           {*}$matchCmd {*}$matchCmdArgs
           foreach {start end} $startAndEnd {break}
           set allMatches [list [list $start $end [array get arg]]]
         }
      foreach oneMatch $allMatches {
        foreach {start end arglist} $oneMatch {break}
        unset -nocomplain arg
        array set arg $arglist;
        set mapList [list "%%" "%"]
        for {set i 0} {$i < 10} {incr i} {
             lappend mapList %$i
             if { [info exists arg($i)] && [llength $arg($i)] == 2 && $arg($i) ne [list -1 -1] } {
                  set realArgs($i) [string range $str {*}$arg($i)]
                  lappend mapList $realArgs($i)
                } else {
                  lappend mapList ""
                }
            };# for

        incr eventInfo(matched)

        if { $world($w,events,$event,spawn) && $world($w,events,$event,spawnTo) ne "" } {
             set spawnTo $world($w,events,$event,spawnTo)
             !set eventInfo(spawnTo) [process_slash_cmd $c spawnTo 2 realArgs]
           }

        !set eventInfo(omit) $world($w,events,$event,omit)

        if { [info exists world($w,events,$event,noActivity)] } {
             !set eventInfo(noActivity) $world($w,events,$event,noActivity)
           }

        !set eventInfo(log) $world($w,events,$event,log)

        if { $world($w,events,$event,fg) ne "" } {
             for {set i $start} {$i <= $end} {incr i} {
               lset tagged [list $i 1 0] ANSI_fg_$world($w,events,$event,fg)
             }
           }

        if { $world($w,events,$event,bg) ne "" } {
             for {set i $start} {$i <= $end} {incr i} {
               lset tagged [list $i 1 1] ANSI_bg_$world($w,events,$event,bg)
             }
           }

        if { $world($w,events,$event,input,window) != 0 } {
             set input $world($w,events,$event,input,string)
             set input [process_slash_cmd $c input 2 realArgs]
             if { $input ne "" } {
                  lappend eventInfo(input) [list $world($w,events,$event,input,window) $input]
                }
           }

        set send $world($w,events,$event,send)
        set send [process_slash_cmd $c send 2 realArgs]
        if { $send ne "" } {
             lappend eventInfo(send) $send
           }

        if { $world($w,events,$event,replace) } {
             set replacement $world($w,events,$event,replace,with);# destructively modified
             set replaceText [process_slash_cmd $c replacement 2 realArgs]
             set replaceList [list]
             set tags [lindex $tagged $start 1]
             foreach x [split $replaceText ""] {
               lappend replaceList [list $x $tags]
             }
             set tagged [lreplace $tagged $start $end {*}$replaceList]
             incr replaceOffset [expr {[string length $replaceText] - ($end - $start)}]
             set str [string replace $str $start $end $replaceText]
           }

      };# foreach oneMatch allMatches

      if { !$world($w,events,$event,continue) } {
           set done 1
           break;
         }
    };# foreach event events
  };# foreach w worlds

  set matchLinks {\m(?:(?:(?:f|ht)tps?://)|www\.)(?:(?:[a-zA-Z_\.0-9%+/@~=&,;-]*))?(?::[0-9]+/)?(?:[a-zA-Z_\.0-9%+/@~=&,;!-]*)(?:\?(?:[a-zA-Z_\.0-9%+/@~=&,;:!-]*))?(?:#[a-zA-Z_\.0-9%+/@~=&,;:!-]*)?}
  set tmp [regexp -all -inline -indices -- $matchLinks $str]

  foreach x $tmp {
    foreach {start end} $x {break}
    for {set i $start} {$i <= $end} {incr i} {
      lset tagged [list $i 1 2] [concat [lindex $tagged [list $i 1 2]] link weblink]
    }
  }

  set eventDefaults [list matched 0 omit 0 log 0 spawn 0 spawnTo "" noActivity 0]
  array set eventInfo [dict merge $eventDefaults [array get eventInfo]]

  return;

};# ::potato::eventsMatch

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
  if { $w == 0 } {
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

  set lwidth 13

  pack [set row [::ttk::frame $frame.right.name]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $row.l -text [T "Event Name:"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::entry $row.e -textvariable potato::eventConfig($w,name)] -side left -anchor nw \
                     -padx 2 -expand 1 -fill x
  lappend rightList $row.e

  pack [set row [::ttk::frame $frame.right.pattern]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $row.l -text [T "Pattern:"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::entry $row.e -textvariable potato::eventConfig($w,pattern)] -side left -anchor nw \
                     -padx 2 -expand 1 -fill x
  lappend rightList $row.e

  pack [set row [::ttk::frame $frame.right.type_case]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::frame $row.type] -side left -anchor nw
  pack [::ttk::label $row.type.l -text [T "Type:"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::combobox $row.type.cb -values [list wildcard regexp contains] \
             -textvariable potato::eventConfig($w,matchtype) -state readonly] -side left -anchor nw -padx 2 -expand 1
  lappend rightList $row.type.cb
  pack [::ttk::frame $row.case] -side left -anchor nw -padx 4
  pack [::ttk::label $row.case.l -text [T "Case?"]] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.case.cb -variable potato::eventConfig($w,case) \
              -onvalue 1 -offvalue 0] -side left -anchor nw -padx 2
  lappend rightList $row.case.cb

  pack [set row [::ttk::frame $frame.right.enabled_continue_matchall]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::frame $row.enabled] -side left -anchor nw
  pack [::ttk::label $row.enabled.l -text [T "Enabled?"] -width $lwidth -justify left -anchor w] \
         -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.enabled.cb -variable potato::eventConfig($w,enabled) \
              -onvalue 1 -offvalue 0] -side left -anchor nw -padx 2
  lappend rightList $row.enabled.cb
  pack [::ttk::frame $row.continue] -side left -anchor nw -padx 4
  pack [::ttk::label $row.continue.l -text [T "Continue?"] -justify left -anchor w] \
              -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.continue.cb -variable potato::eventConfig($w,continue) \
              -onvalue 1 -offvalue 0] -side left -anchor nw -padx 2
  lappend rightList $row.continue.cb
  pack [::ttk::frame $row.matchAll] -side left -anchor nw -padx 4
  pack [::ttk::label $row.matchAll.l -text [T "Match All?"] -justify left -anchor w] \
              -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.matchAll.cb -variable potato::eventConfig($w,matchAll) \
              -onvalue 1 -offvalue 0] -side left -anchor nw -padx 2
  lappend rightList $row.matchAll.cb


  pack [set row [::ttk::frame $frame.right.runwhen]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::frame $row.inactive] -side left -anchor nw
  pack [::ttk::label $row.inactive.l -text [T "Run When:"] -width $lwidth -justify left -anchor w] \
              -side left -anchor nw -padx 2
  # These values not currently translatable
  pack [::ttk::combobox $row.inactive.cb -values [list {Always} {Not Up} {No Focus} {Inactive}] \
              -textvariable potato::eventConfig($w,inactive) -state readonly] -side left -anchor nw -padx 2
  lappend rightList $row.inactive.cb

  set bg [list "Don't Change" "Normal FG" "Normal BG"]
  set fg $bg
  lappend fg "ANSI Highlight"
  foreach x [list Red Green Blue Cyan Magenta Yellow Black White] {
     lappend fg $x "$x Highlight"
     lappend bg $x
  }

  pack [set row [::ttk::frame $frame.right.fg]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $row.l -text [T "Change FG:"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::combobox $row.cb -values $fg -textvariable potato::eventConfig($w,fg) -state readonly] \
              -side left -anchor nw -padx 2
  lappend rightList $row.cb

  pack [set row [::ttk::frame $frame.right.bg]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $row.l -text [T "Change BG:"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::combobox $row.cb -values $bg -textvariable potato::eventConfig($w,bg) -state readonly] \
              -side left -anchor nw -padx 2
  lappend rightList $row.cb
  unset fg bg

  pack [set row [::ttk::frame $frame.right.omit]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $row.l -text [T "Omit From:"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::label $row.dispL -text [T "Display?"]] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.dispCB -variable potato::eventConfig($w,omit) \
               -onvalue 1 -offvalue 0] -side left -anchor nw
  lappend rightList $row.dispCB
  pack [::ttk::label $row.logL -text [T "Logs?"]] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.logCB -variable potato::eventConfig($w,log) \
               -onvalue 1 -offvalue 0] -side left -anchor nw
  lappend rightList $row.logCB
  pack [::ttk::label $row.actL -text [T "Activity?"]] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.actCB -variable potato::eventConfig($w,noActivity) \
               -onvalue 1 -offvalue 0] -side left -anchor nw
  lappend rightList $row.actCB

  pack [set row [::ttk::frame $frame.right.spawn]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $row.l -text [T "Spawn?"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.cb -variable potato::eventConfig($w,spawn) \
                -onvalue 1 -offvalue 0] -side left -anchor nw
  pack [::ttk::label $row.l2 -text [T "Spawn To:"] -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::entry $row.e -textvariable potato::eventConfig($w,spawnTo)] -side left -anchor nw \
                     -padx 2 -expand 1 -fill x
  lappend rightList $row.cb $row.e

  pack [set row [::ttk::frame $frame.right.replace]] -side top -anchor nw -fill x -padx 5 -pady 2
  pack [::ttk::label $row.l -text [T "Replace?"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::checkbutton $row.cb -variable potato::eventConfig($w,replace) \
                -onvalue 1 -offvalue 0] -side left -anchor nw
  pack [::ttk::label $row.l2 -text [T "With:"] -justify left -anchor w] -side left -anchor nw -padx 2
  pack [::ttk::entry $row.e -textvariable potato::eventConfig($w,replace,with)] -side left -anchor nw \
                     -padx 2 -expand 1 -fill x
  lappend rightList $row.cb $row.e

  pack [set row [::ttk::frame $frame.right.send]] -side top -anchor nw -expand 1 -fill x -padx 5 -pady 2
  pack [::ttk::label $row.l -text [T "Send:"] -width $lwidth -justify left -anchor w] -side left -anchor nw -padx 2
  pack [set send [text $row.t -width 35 -height 4]] -side left -anchor nw -expand 1 -fill x
  lappend rightList $row.t

  pack [set row [::ttk::frame $frame.right.input]] -side top -anchor nw -expand 1 -fill x -padx 5 -pady 2
  pack [::ttk::frame $row.left] -side left -anchor nw -fill x -padx 2
  pack [::ttk::label $row.left.l -text [T "Input:"] -width $lwidth -justify left -anchor w] -side top -anchor nw
  pack [::ttk::combobox $row.left.cb -width 5 -values [list None One Two Focus] \
                 -textvariable potato::eventConfig($w,input,window) -state readonly] -side top -anchor nw
  lappend rightList $row.left.cb
  pack [::ttk::frame $row.right] -side left -anchor nw -expand 1 -fill both
  pack [set input [text $row.right.t -width 35 -height 2]] -side left -anchor nw -expand 1 -fill both
  lappend rightList $row.right.t

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

  set world($w,events,$x,name) ""
  set world($w,events,$x,pattern) ""
  set world($w,events,$x,pattern,int) "^$"
  set world($w,events,$x,enabled) 1
  set world($w,events,$x,continue) 0
  set world($w,events,$x,case) 1
  set world($w,events,$x,matchtype) "wildcard"
  set world($w,events,$x,inactive) "always"
  set world($w,events,$x,omit) 0
  set world($w,events,$x,noActivity) 0
  set world($w,events,$x,log) 0
  set world($w,events,$x,fg) ""
  set world($w,events,$x,bg) ""
  set world($w,events,$x,send) ""
  set world($w,events,$x,spawn) 0
  set world($w,events,$x,spawnTo) ""
  set world($w,events,$x,input,window) 0
  set world($w,events,$x,input,string) ""
  set world($w,events,$x,matchAll) 0
  set world($w,events,$x,replace) 0
  set world($w,events,$x,replace,with) ""

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
  foreach x [list name pattern matchtype case enabled continue omit log noActivity spawn spawnTo matchAll replace replace,with] {
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
               set world($w,events,$this,$x) [string index [lindex $lower 0] 0]
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
  saveWorlds
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
       foreach x [list name pattern matchtype case enabled continue omit log noActivity spawn spawnTo matchAll replace replace,with] {
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
  foreach x [list name pattern matchtype case enabled continue omit log noActivity spawn spawnTo matchAll replace replace,with] {
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
  set eventConfig($w,name) ""
  set eventConfig($w,pattern) ""
  set eventConfig($w,spawnTo) ""
  set eventConfig($w,replace,with) ""
  # Set checkboxes to 0
  foreach x [list case enabled continue log omit spawn matchAll replace] {
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
