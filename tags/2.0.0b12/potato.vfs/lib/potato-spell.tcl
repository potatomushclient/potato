namespace eval ::potato::spellcheck {
  variable options;
  variable spellcheck;

  set options(aspell) "c:/progra~1/aspell/bin/aspell.exe -a"
  set options(aspell) "%s -a";# command format for aspell command. The %s is replaced with the cmd to run, via [format] (so literal %'s must be escaped)
  set options(grab) 1
}

namespace import ::potato::T

proc ::potato::spellcheck::spellcheck {string} {
  variable spellcheck;
  variable options;

  array unset spellcheck;

  set win .spellcheck
  if { [winfo exists $win] } {
       raise $win
       bell -displayof $win;
       return;
     }

  set spellcheck(win) $win
  set spellcheck(string) $string

  toplevel $win
  wm title $win [T "Spellchecker"]
  pack [set frame [::ttk::frame $win.frame]] -side left -anchor nw -expand 1 -fill both -pady 8
  if { $options(grab) } {
       grab set $win
       bind $frame <Destroy> [list grab release $win];# don't think this is necessary, but better safe than sorry
     }


  pack [::ttk::label $frame.top_label -text [T "Words:"]] -side top -anchor nw

  set left [::ttk::frame $frame.left]
  pack [set top [::ttk::frame $left.top]] -expand 1 -fill both
  pack [set input [text $top.txt -width 50 -height 7 -wrap word -yscrollcommand "$top.sb set"]] -side left -expand 1 -fill both
  pack [::ttk::scrollbar $top.sb -command "$input yview"] -side left -fill y

  ::ttk::label $frame.bottom_label -text [T "Suggestions:"]
  pack [set bottom [::ttk::frame $frame.bottom]] -side top -expand 1 -fill both
  pack [set tree [::ttk::treeview $bottom.tree -style "Spell.Treeview" -columns Suggestion -show {} -yscrollcommand "$bottom.sb set" -height 6 -selectmode browse]] -side left -anchor nw -expand 1 -fill both
  $tree column Suggestion -width 50
  pack [::ttk::scrollbar $bottom.sb -command "$tree yview"] -side left -fill y

  ::frame $frame.absbottom
  pack [::ttk::label $frame.absbottom.l -text [T "Replacement:"]] -side left -anchor w
  pack [set replacement [::ttk::entry $frame.absbottom.e -textvariable ::potato::spellcheck::spellcheck(newword)]] -side left -anchor w -expand 1 -fill x


  set right [::ttk::frame $frame.right]
  foreach {btn letter} [list "Done" d "Cancel" c "Replace" r "Ignore" i] {
    grid [::ttk::frame $right.frame$btn] -sticky ew -padx 2 -pady 8
    pack [::ttk::frame $right.frame$btn.sub] -side left -anchor center
    pack [::ttk::button $right.frame$btn.sub.b -text [T $btn] -underline 0] -anchor center
    bind $win <Control-$letter> [list $right.frame$btn.sub.b invoke]
  }
  # Make sure these are included for translation:
  # [T "Done"]
  # [T "Cancel"]
  # [T "Replace"]
  # [T "Ignore"]
  $right.frameDone.sub.b configure -command [list ::potato::spellcheck::finish 1]
  $right.frameCancel.sub.b configure -command [list ::potato::spellcheck::finish 0]
  $right.frameReplace.sub.b configure -command [list ::potato::spellcheck::replaceWord 1]
  $right.frameIgnore.sub.b configure -command [list ::potato::spellcheck::replaceWord 0]
  bind $replacement <Return> [list $right.frameReplace.sub.b invoke]

  $right.frameReplace.sub.b state disabled
  $right.frameIgnore.sub.b state disabled
  $replacement state disabled

  grid $frame.top_label -sticky w -padx 6
  grid $left $right -sticky nsew -pady 4 -padx 6
  grid $frame.bottom_label -sticky w -padx 6
  grid $bottom -sticky nsew -pady 4 -padx 6
  grid $frame.absbottom -sticky we -pady 4 -padx 6
  grid rowconfigure $frame $left -weight 1
  grid rowconfigure $frame $bottom -weight 1
  grid rowconfigure $frame $frame.absbottom -weight 1
  grid columnconfigure $frame 0 -weight 1

  set spellcheck(replace) $right.frameReplace.sub.b
  set spellcheck(ignore) $right.frameIgnore.sub.b
  set spellcheck(tree) $tree
  set spellcheck(input) $input
  set spellcheck(replacement) $replacement

  $tree tag configure wrong -font [list {*}[font actual [ttk::style lookup Treeview -font]] -slant italic]
  $tree state disabled

  $input tag configure checking -background darkblue
  $input tag configure wrong -underline 1 -foreground red
  $input insert end $string
  $tree insert {} end -values [list [T "Please wait. Checking spelling..."]] -tags wrong
  bind $tree <ButtonPress-3> {if {[%W instate !disabled]} {::potato::spellcheck::rightClickTree %X %Y %x %y}}
  bind $tree <Double-1> {if {[%W instate !disabled]} {::potato::spellcheck::doubleClickTree %x %y}}
  bind $tree <<TreeviewSelect>> {if {[%W instate !disabled]} {::potato::spellcheck::selectWord %X %Y}}

  wm minsize $win [winfo reqwidth $win] [winfo reqheight $win]

  set lineNum 1
  set total 0
  set wroung 0
  foreach line [split $string "\n"] {
    set corrections [checkSpelling $line]
    foreach {count corrections} $corrections {break;}
    if { $count == 0 } {
         $tree delete [$tree children {}]
         if { $spellcheck(error) eq "" } {
              set spellcheck(error) "An unknown error occurred with ASpell."
            }
         $tree insert {} end -values [list [T "Unable to spell-check text: %s" $spellcheck(error)]] -tags wrong
         set total -1
         $right.frameDone.sub.b state disabled
         break;
       } else {
         foreach x $corrections {
           incr total
           foreach {start word suggestions} $x {break;}
           incr start -1
           $input tag add wrong "$lineNum.0 + $start chars" "$lineNum.0 + [expr {$start + [string length $word]}] chars"
           set spellcheck(suggestions,$word) $suggestions
       }
    }
    incr lineNum
  }
  $input configure -state disabled
  if { $total == 0 } {
       tk_messageBox -title [T "Spellcheck"] -icon info -parent $top -message [T "All words are spelled correctly."]
       destroy $win;
       return [list 0 $spellcheck(string)];
     } elseif { $total > 0 } {
       $tree delete [$tree children {}]
       $tree insert {} end -values [list [T "Click a misspelled word to begin"]] -tags wrong
       $input tag bind wrong <Button-1> [list ::potato::spellcheck::suggest]
       $input tag bind wrong <Enter> [list $input configure -cursor hand2]
       $input tag bind wrong <Leave> [list $input configure -cursor xterm]
     }

  bind $win <Destroy> [list ::potato::spellcheck::finish 0]

  vwait ::potato::spellcheck::spellcheck(string)

  catch {bind $win <Destroy> ""}

  destroy $win;

  return $spellcheck(string);

};# ::potato::spellcheck::spellcheck

proc ::potato::spellcheck::selectWord {x y} {
  variable spellcheck;

  set tree $spellcheck(tree)
  set word [lindex [$tree item [$tree selection] -values] 0]
  if { $word eq "" } {
       return;
     }
  set spellcheck(newword) $word
  return;

};# ::potato::spellcheck::selectWord

proc ::potato::spellcheck::doubleClickTree {x y} {
  variable spellcheck;

  set what [lindex [$spellcheck(tree) identify $x $y] 0]
  if { $what eq "cell" } {
       ::potato::spellcheck::replaceWord 1
     }

};# ::potato::spellcheck::doubleClickTree

proc ::potato::spellcheck::rightClickTree {X Y x y} {
  variable spellcheck;

  event generate $spellcheck(tree) <ButtonPress-1> -rootx $X -rooty $Y -x $x -y $y
  set m .spellcheckmenu
  catch {destroy $m}
  menu $m -tearoff 0
  $m add command -label "Use this word" -command [list ::potato::spellcheck::replaceWord 1]
  $m add command -label "Copy word to Clipboard" -command [list ::potato::spellcheck::copyTreeWord]

  tk_popup $m $X $Y

};# ::potato::spellcheck::rightClickTree

proc ::potato::spellcheck::copyTreeWord {} {
  variable spellcheck;

  set word [lindex [$spellcheck(tree) item [$spellcheck(tree) selection] -value] 0]
  clipboard clear -displayof $spellcheck(tree)
  clipboard append -displayof $spellcheck(tree) $word

};# ::potato::spellcheck::copyTreeWord

proc ::potato::spellcheck::suggest {{index "current"}} {
  variable spellcheck;

  $spellcheck(input) tag remove checking 1.0 end

  # Get word
  set range [$spellcheck(input) tag prevrange "wrong" "$index + 1 char"]
  $spellcheck(input) tag add "checking" {*}$range
  set word [$spellcheck(input) get checking.first checking.last]

  $spellcheck(tree) delete [$spellcheck(tree) children {}]

  $spellcheck(ignore) state !disabled
  $spellcheck(replacement) state !disabled

  if { ![info exists spellcheck(suggestions,$word)] || ![llength $spellcheck(suggestions,$word)] } {
       $spellcheck(tree) insert {} end -values [list [T "None"]] -tags wrong
       $spellcheck(tree) state disabled
       $spellcheck(replace) state disabled
       set spellcheck(newword) $word
       focus $spellcheck(replacement)
     } else {
       $spellcheck(tree) state !disabled
       foreach x $spellcheck(suggestions,$word) {
         $spellcheck(tree) insert {} end -values [list "$x"]
       }
       set first [lindex [$spellcheck(tree) children {}] 0]
       $spellcheck(tree) see $first
       $spellcheck(tree) selection set $first
       $spellcheck(tree) focus $first
       $spellcheck(replace) state !disabled
       ::potato::spellcheck::selectWord 5 5
     }

  return;

};# ::potato::spellcheck::suggest

proc ::potato::spellcheck::replaceWord {replace} {
  variable spellcheck;

  $spellcheck(input) configure -state normal
  set index [$spellcheck(input) index checking.first]
  if { $replace } {
       set orig [$spellcheck(input) get checking.first checking.last]
       #set new [lindex [$spellcheck(tree) item [$spellcheck(tree) selection] -values] 0]
       set new $spellcheck(newword)
       $spellcheck(input) delete checking.first checking.last
       $spellcheck(input) insert $index $new
     } else {
       $spellcheck(input) tag remove wrong checking.first checking.last
       $spellcheck(input) tag remove checking checking.first checking.last
     }
  $spellcheck(input) configure -state disabled
  $spellcheck(replace) state disabled
  $spellcheck(ignore) state disabled
  set spellcheck(newword) ""
  $spellcheck(replacement) state disabled
  if { ![llength [set next [$spellcheck(input) tag nextrange wrong $index end]]] && ![llength [set next [$spellcheck(input) tag nextrange wrong 1.0 $index]]] } {
       # All words now spelled correctly
       set ans [tk_messageBox -parent $spellcheck(win) -icon info -title [T "Spellcheck"] -type ok \
                     -message [T "All words are now spelled correctly."]]
       ::potato::spellcheck::finish 1
       return;
     } else {
       $spellcheck(tree) delete [$spellcheck(tree) children {}]
       $spellcheck(tree) insert {} end -values [list [T "Click a misspelled word to begin"]] -tags wrong
       suggest [lindex $next 0]
     }

  return;

};# ::potato::spellcheck::replaceWord

proc ::potato::spellcheck::finish {use} {
  variable spellcheck;

  if { $use } {
       set spellcheck(string) [list 1 [$spellcheck(input) get 1.0 end-1c]]
     } else {
       set spellcheck(string) [list 0 $spellcheck(string)]
     }

  return;

};# ::potato::spellcheck::finish

proc ::potato::spellcheck::checkSpelling {string} {
  variable options;
  variable spellcheck;

  set cmd [format $options(aspell) "\"[file normalize $::potato::misc(aspell)]\""]
  if { [catch {open "|$cmd" r+} pipe] } {
       set spellcheck(error) $pipe
       return [list 0 [list]];
     }
  set spellcheck(error) ""
  fconfigure $pipe -buffering line
  gets $pipe ;# skip version line
  fconfigure $pipe -blocking 0

  set return [list]

  puts $pipe "^$string"

  after 500 [list ::potato::spellcheck::checkSpellingSub $pipe]
  vwait ::potato::spellcheck::spellcheck(result)

  return $::potato::spellcheck::spellcheck(result);
};# ::potato::spellcheck::checkSpelling

proc ::potato::spellcheck::checkSpellingSub {pipe} {

  set i 0
  set return [list]
  while { [set count [gets $pipe line]] >= 0 } {
    incr i
    if { $count == 0 || $line eq "*" } {
         continue; # nothing of interest
       }
    set list [split $line " "]
    if { [lindex $list 0] eq "#" } {
         # No suggestions
         lappend return [list [lindex $list 2] [lindex $list 1]]
       } else {
         lappend return [list [string range [lindex $list 3] 0 end-1] [lindex $list 1] [split [string map [list "," ""] [join [lrange $list 4 end] " "]] " "]]
       }
  }

  close $pipe

  set ::potato::spellcheck::spellcheck(result) [list $i $return];
  return;

};# ::potato::spellcheck::checkSpellingSub

package provide potato-spell 0.1
