# Contents:
# ::treeviewUtils::HeaderSort - A modified version of Keith Vetter's code
#   from http://wiki.tcl.tk/20930 for sorting Treeviews when the
#   header is clicked

# ::treeviewUtils::KeyPress - handle keypresses in Treeview widgets to
#   allow typing to select a matching row

namespace eval ::treeviewUtils {}

##+##########################################################################
##+##########################################################################
namespace eval ::treeviewUtils::HeaderSort {}

image create bitmap ::treeviewUtils::HeaderSort::arrow(0) -data {
    #define arrowUp_width 7
    #define arrowUp_height 4
    static char arrowUp_bits[] = {
        0x08, 0x1c, 0x3e, 0x7f
    };
}
image create bitmap ::treeviewUtils::HeaderSort::arrow(1) -data {
    #define arrowDown_width 7
    #define arrowDown_height 4
    static char arrowDown_bits[] = {
        0x7f, 0x3e, 0x1c, 0x08
    };
}
image create bitmap ::treeviewUtils::HeaderSort::arrowBlank -data {
    #define arrowBlank_width 7
    #define arrowBlank_height 4
    static char arrowBlank_bits[] = {
        0x00, 0x00, 0x00, 0x00
    };
}


##+##########################################################################
#
# ::treeviewUtils::HeaderSort::SortBy -- Code to sort tree content when clicked on a header
#
proc ::treeviewUtils::HeaderSort::SortBy {tree col direction {tagprefix ""}} {
    # Build something we can sort
    set type -integer
    set data {}
    foreach row [$tree children {}] {
        if { $tagprefix eq "" } {
             set this [$tree set $row $col]
           } else {
             set this [lsearch -inline [$tree item $row -tags] "$tagprefix*"]
             if { ![llength $this] } {
                  set this [$tree set $row $col]
                } else {
                  set this [string range $this [string length $tagprefix] end]
                }
           }
        if { ![string is integer -strict $this] } {
             set type -dictionary
           }
        lappend data [list $this $row]
    }
    set dir [expr {$direction ? "-decreasing" : "-increasing"}]
    set r -1

    # Now reshuffle the rows into the sorted order
    foreach info [lsort $type -index 0 $dir $data] {
        $tree move [lindex $info 1] {} [incr r]
    }

    # Switch the heading so that it will sort in the opposite direction
    set cmd [list [namespace which SortBy] $tree $col [expr {!$direction}] $tagprefix]
    $tree heading $col -command $cmd
    ArrowHeadings $tree $col $direction
    set sel [$tree selection]
    if { [llength $sel] } {
         $tree see [lindex $sel 0]
       }
}
##+##########################################################################
#
# ::treeviewUtils::HeaderSort::ArrowHeadings -- Puts in up/down arrows to show sorting
#
proc ::treeviewUtils::HeaderSort::ArrowHeadings {tree sortCol dir} {
    set idx -1
    set ns [namespace current]
    foreach col [$tree cget -columns] {
        incr idx
        set img [join [list $ns arrowBlank] ::]
        if {$col == $sortCol} {
            set img [join [list $ns arrow($dir)] ::]
        }
        $tree heading $idx -image $img
    }
}



##+##########################################################################
##+##########################################################################
namespace eval ::treeviewUtils::KeyPress {}

#: proc ::treeviewUtils::KeyPress::press
#: arg tree Treeview widget
#: arg char The character typed; may be empty
#: arg keysym The keysym for the key pressed
#: desc Handle a keypress in a Treeview to allow typing to select an entry
#: return nothing
proc ::treeviewUtils::KeyPress::press {tree char keysym} {
  variable tvkp;

  if { $keysym in $tvkp(ignore) } {
       return;
     }

  if { $char in [list "" " " "\t" "\n"] || $keysym eq "space"} {
       reset;
       return;
     }

  catch {after cancel $tvkp(afterid)}

  if { $tvkp(error) } {
       bell -displayof $tree
     } elseif { $tvkp(reset) } {
       # set everything up
       set tvkp(reset) 0
       set sel [$tree selection]
       if { ![llength $sel] } {
            set tvkp(startid) ""
          } else {
            set tvkp(startid) [lindex $sel 0]
          }
       set tvkp(str) $char
       set tvkp(ids) [recursiveListIDs $tree ""]
       if { ![llength $tvkp(ids)] } {
            set tvkp(error) 1
            bell -displayof $tree
          }
       set inc 0
     } else {
       append tvkp(str) $char
       set inc 1
     }

  $tree selection set [list]
  $tree focus {}
  if { !$tvkp(error) } {
       set len [string length $tvkp(str)]
       if { $tvkp(startid) eq "" } {
            set index 0
          } else {
            set index [lsearch -exact $tvkp(ids) $tvkp(startid)]
            if { !$inc } {
                 incr index
                 if { $index == [llength $tvkp(ids)] } {
                      set index 0
                    }
               }
          }
       set ids [concat [lrange $tvkp(ids) $index end] [lrange $tvkp(ids) 0 $index-1]]
       set match ""
       foreach x $ids {
         if { [set text [$tree item $x -text]] eq "" } {
              set text [lsearch -inline -glob [$tree item $x -values] "?*"]
            }
         if { $text eq "" } {
              continue;
            }
         if { [string equal -nocase -length $len $tvkp(str) $text] } {
              set match $x
              break;
            }
       }
       if { $match ne "" } {
            $tree sel set [list $x]
            $tree focus $x
            $tree see $x
            set tvkp(startid) $x
          } else {
            set tvkp(error) 1
            bell -displayof $tree
          }
     }

  set tvkp(afterid) [after $tvkp(aftertime) [namespace which reset]]

  return;


};# ::treeviewUtils::KeyPress::press

#: proc ::treeviewUtils::KeyPress::reset
#: arg char Character generated if this was triggered by a key release; only reset for non-printable keys ($char eq "")
#: arg keysym The keysysm for the key pressed
#: desc Reset the $tvkp array used to hold state data for treeview keypresses
#: return nothing
proc ::treeviewUtils::KeyPress::reset {{char ""} {keysym ""}} {
  variable tvkp;

  if { $char ne "" || $keysym in $tvkp(ignore)} {
       return;
     }

  set tvkp(str) ""
  set tvkp(startid) ""
  set tvkp(ids) [list]
  set tvkp(reset) 1
  set tvkp(error) 0
  if { [info exists tvkp(afterid)] } {
       catch {after cancel $tvkp(afterid)}
     }
  set tvkp(afterid) ""
  set tvkp(aftertime) 1300

  return;

};# ::treeviewUtils::KeyPress::reset

#: proc ::treeviewUtils::KeyPress::recursiveListIDs
#: arg tree Tree widget
#: arg id parent id
#: desc Return a list of $id and all its children in the tree widget $tree. Used
#: desc recursively for building a list of all IDs in order
#: return list of ids
proc ::treeviewUtils::KeyPress::recursiveListIDs {tree {id ""}} {

  if { ![winfo exists $tree] || ![$tree exists $id] } {
       return;
     }

  set res [list]
  if { $id ne "" } {
       lappend res $id
     }
  foreach x [$tree children $id] {
    lappend res {*}[recursiveListIDs $tree $x]
  }

  return $res;

};# ::treeviewUtils::KeyPress::recursiveListIDs

#: proc :treeviewUtils::KeyPress::init
#: desc Set up the vars and bindings necessary for the KeyPress add-on
#: return nothing
proc ::treeviewUtils::KeyPress::init {} {
  variable tvkp;

  set tvkp(ignore) \
    [list \
      Control_L Control_R \
      Alt_L Alt_R \
      Shift_L Shift_R \
      Command Option \
      Mod1 Mod2 Mod3 Mod4 Mod5 \
    ]
  bind Treeview <KeyPress> [list ::treeviewUtils::KeyPress::press %W %A %K]
  bind Treeview <KeyRelease> [list ::treeviewUtils::KeyPress::reset %A %K]
  bind Treeview <FocusIn> [list ::treeviewUtils::KeyPress::reset]
  bind Treeview <FocusOut> [list ::treeviewUtils::KeyPress::reset]

  ::treeviewUtils::KeyPress::reset

  return;

};# ::treeviewUtils::KeyPress::init

::treeviewUtils::KeyPress::init



##+##########################################################################
##+##########################################################################



package provide treeviewUtils 1.0


