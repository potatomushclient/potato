# A modified version of Keith Vetter's code
# from http://wiki.tcl.tk/20930

namespace eval ::treeviewUtils {}

image create bitmap ::treeviewUtils::arrow(0) -data {
    #define arrowUp_width 7
    #define arrowUp_height 4
    static char arrowUp_bits[] = {
        0x08, 0x1c, 0x3e, 0x7f
    };
}
image create bitmap ::treeviewUtils::arrow(1) -data {
    #define arrowDown_width 7
    #define arrowDown_height 4
    static char arrowDown_bits[] = {
        0x7f, 0x3e, 0x1c, 0x08
    };
}
image create bitmap ::treeviewUtils::arrowBlank -data {
    #define arrowBlank_width 7
    #define arrowBlank_height 4
    static char arrowBlank_bits[] = {
        0x00, 0x00, 0x00, 0x00
    };
}


##+##########################################################################
#
# ::treeviewUtils::SortBy -- Code to sort tree content when clicked on a header
#
proc ::treeviewUtils::SortBy {tree col direction {tagprefix ""}} {
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
    set cmd [list ::treeviewUtils::SortBy $tree $col [expr {!$direction}] $tagprefix]
    $tree heading $col -command $cmd
    ::treeviewUtils::ArrowHeadings $tree $col $direction
    set sel [$tree selection]
    if { [llength $sel] } {
         $tree see [lindex $sel 0]
       }
}
##+##########################################################################
#
# ::treeviewUtils::ArrowHeadings -- Puts in up/down arrows to show sorting
#
proc ::treeviewUtils::ArrowHeadings {tree sortCol dir} {
    set idx -1
    foreach col [$tree cget -columns] {
        incr idx
        set img ::treeviewUtils::arrowBlank
        if {$col == $sortCol} {
            set img ::treeviewUtils::arrow($dir)
        }
        $tree heading $idx -image $img
    }
}


package provide treeviewUtils 1.0
