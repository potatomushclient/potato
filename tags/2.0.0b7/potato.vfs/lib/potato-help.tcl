
package provide potato-help 2.0.0

namespace eval ::help {
  variable widgets; array unset widgets 
  variable pages; array unset pages
  variable titles; array unset titles
  variable aot; set aot 0
  variable current; set current ""

};# namespace eval ::help

#: proc ::help::showTopic
#: arg topic Title of topic to show.
#: desc Show help topic $topic. If no such topic, [bell].
#: return 1 if the topic is shown successfully, 0 otherwise
proc ::help::showTopic {topic} {
  variable widgets;
  variable pages;
  variable titles;
  variable current;

  if { $topic ne "Search" } {
       if { $current eq $topic } {
            return 1;
          }
       if { ![info exists titles($topic)] } {
            bell -displayof $widgets(toplevel)
            return 0;
          }
     }

  set text $widgets(pane,help,text)

  $text configure -state normal
  $text delete 1.0 end
  if { [info exists titles($topic)] } {
       set title $titles($topic)
     } else {
       set title $topic
     }
  $text insert end $title hdr \n
  if { $topic eq "Search" } {
       ::help::search
       set current ""
       return 1;
     }
  ::help::showTopicSub $text $topic
  set current $topic

  $text insert end "\n" "" [string repeat " " 65] [list div center] "\n"
  $text insert end "TOC" [list center link name:TOC] "   \u2022   " {center} "Search" [list center link name:Search] "\n\n"
  $text configure -state disabled

  # Try and find it in the TOC tree. Only deactivate the current item if we can find this one.
  set tree $widgets(pane,toc,tree)
  set treeItems [$tree children {}]
  set match ""
  set i 0
  while { [llength $treeItems] } {
    set this [lindex $treeItems 0]
    set treeItems [lrange $treeItems 1 end]
    set thisName [lsearch -inline -glob [$tree item $this -tags] "name:*"]
    if { "name:$topic" eq $thisName } {
         set match $this
         break;
       } elseif { [llength [$tree children $this]] != 0 } {
         lappend treeItems {*}[$tree children $this]
       }
   }
  if { $match ne "" && [lindex [$tree selection] 0] ne $match} {
       set binding [bind $tree <<TreeviewSelect>>]
       bind $tree <<TreeviewSelect>> {}
       $tree selection set $match
       $tree see $match
       $tree focus $match
       bind $tree <<TreeviewSelect>> $binding
     }
  return 1;

};# help::showTopic

#: proc ::help::help
#: arg topic Topic to show, or empty for the default page
#: desc Create (or reshow) the help window, and show topic $topic in it
#: return nothing
proc ::help::help {{topic ""}} {
  variable widgets;

  if { ![info exists widgets(toplevel)] || ![winfo exists $widgets(toplevel)] } {
      makeWindow
      showTopic intro
     } else {
       ::potato::reshowWindow $widgets(toplevel) 0
     }

  if { $topic ne "" } {
       showTopic $topic
     }

  return;

};# ::help::help

#: proc help::readFile
#: arg file The file to read from.
#: desc Read help-files in the correct format from the file $file.
#: return nothing
proc ::help::readFile {file} {

  set fid [open $file r]
  set data [read $fid]
  close $fid

  regsub -all -line {^-+$} $data \x01 data
  regsub -all -line {^\#.*$\n} $data {} data
  foreach section [split $data \x01] {
    set n [regexp -line {^name:\s*(.+)\s*$} $section => name]
    if { !$n } {
         continue
       }
    set n [regexp -line {^title:\s*(.+?)\s*$} $section => title]
    if { !$n } {
         set title $name
       }

    regsub -all -line {^(title|name):.*$\n} $section {} section
    set DOLLAR {$}
    ::help::addTopic $name $title [subst -nobackslashes -nocommands $section]
  }
  ::help::buildTOC

  return;

};# help::readFile

#: proc help::addTopic
#: arg name Internal (unique) name of topic
#: arg title Title of topic to add (non-unique, human-readable) 
#: arg body The body of the help topic
#: desc Add a new help topic named (interally) $name with the title $title which reads $body.
#: return nothing
proc ::help::addTopic {name title body} {
  variable titles;
  variable pages;

  set title [string trim $title]
  set body [string trim $body "\n"]
  regsub -all {\\\n} $body {} body            ;# Remove escaped lines
  regsub -all {[ \t]+\n} $body "\n" body      ;# Remove trailing spaces
  regsub -all {([^\n])\n([^\s])} $body {\1 \2} body ;# Unwrap paragraphs

  set pages($name) $body
  set titles($name) $title

  return;

};# help::addTopic

#: proc help::makeWindow
#: desc Make the help window.
#: return nothing
proc ::help::makeWindow {} {
  variable widgets;

  if { [info exists widgets(toplevel)] && [winfo exists $widgets(toplevel)] } {
       potato::reshowWindow $widgets(toplevel)
       return;
     }

  set win [set widgets(toplevel) .helpToplevel]
  toplevel $win
  bind $win <Destroy> [list set ::help::current ""]
  wm withdraw $win
  wm title $win "$::potato::potato(name) Help"

  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both -side left -anchor nw

  pack [set widgets(pane) [::ttk::panedwindow $frame.pane -orient horizontal]] -side top -expand 1 -fill both
  $widgets(pane) add [set widgets(pane,toc) [::ttk::frame $widgets(pane).toc -relief ridge]]
  $widgets(pane) add [set widgets(pane,help) [::ttk::frame $widgets(pane).help -relief ridge -borderwidth 2]]

  pack [set widgets(pane,toc,tree) [::ttk::treeview $widgets(pane,toc).tree -padding [list 0 0 0 0] -selectmode browse]] \
         -side left -expand 1 -fill both
  pack [set widgets(pane,toc,ysb) [::ttk::scrollbar $widgets(pane,toc).ysb -orient vertical \
         -command [list $widgets(pane,toc,tree) yview]]] -side left -fill y
  $widgets(pane,toc,tree) configure -yscrollcommand [list $widgets(pane,toc,ysb) set]
  
  $widgets(pane,toc,tree) heading #0 -text "Table of Contents"
  $widgets(pane,toc,tree) tag configure link -foreground blue
  bind $widgets(pane,toc,tree) <<TreeviewSelect>> [list ::help::select]


  pack [set widgets(pane,help,text) [text $widgets(pane,help).txt -border 5 -relief flat -wrap word \
         -state disabled -width 60 -padx 5 -font TkTextFont]] -side left -expand 1 -fill both
  pack [set widgets(pane,help,ysb) [::ttk::scrollbar $widgets(pane,help).ysb -orient vertical \
         -command [list $widgets(pane,help,text) yview]]] -side left -fill y
  $widgets(pane,help,text) configure -yscrollcommand [list $widgets(pane,help,ysb) set]

  set text $widgets(pane,help,text)
  $text tag configure link -foreground blue -underline 1
  $text tag bind link <Enter> [list $text configure -cursor hand2]
  $text tag bind link <Leave> [list $text configure -cursor {}]
  $text tag bind link <Button-1> [list ::help::click %W]
  $text tag configure fix -font TkFixedFont
  $text tag configure bold -font [list {*}[font actual TkTextFont] -weight bold]
  $text tag configure italic -font [list {*}[font actual TkTextFont] -slant italic]
  $text tag configure hdr -font TkHeadingFont
  $text tag configure hdr -font [list -size [expr {round(2.5*[font actual TkTextFont -size])}]]
  $text tag configure searchResults
  $text tag configure div -overstrike 1
  $text tag configure center -justify center

  set l1 [font measure TkTextFont "   "]
  set l2 [font measure TkTextFont  "   \u2022   "]
  set l3 [font measure TkTextFont  "       \u2013   "]
  set l3 [expr {$l2 + ($l2 - $l1)}]
  $text tag config bullet -lmargin1 $l1 -lmargin2 $l2
  $text tag config number -lmargin1 $l1 -lmargin2 $l2
  $text tag config dash -lmargin1 $l1 -lmargin2 $l2

  set oneChar [font measure [$text cget -font] "0"]
  for {set lvl 0} {$lvl < 5} {incr lvl} {
       $text tag configure indentList$lvl -lmargin1 [expr {$oneChar*5*($lvl+1)}] -lmargin2 [expr {($oneChar*5*($lvl+1))+3}]
  }


  pack [::ttk::frame $frame.bottom -borderwidth 2 -relief ridge -padding 8] -side top -expand 0 -fill x -padx 0 -pady 2
  pack [::ttk::button $frame.bottom.close -text "Close" -width 8 \
                   -command [list destroy $win] -default active] -side top -anchor center
  if { ![catch {wm attributes $win -topmost 0}] } {
       set ::help::aot 0
       place [::ttk::checkbutton $frame.bottom.aot -text "Always on Top?" -variable ::help::aot -command "wm attributes $win -topmost \$::help::aot"] -relx 1 -rely .5 -anchor e
     }
  
  ::help::buildTOC

  bind $win <Escape> [list destroy $win]

  update idletasks
  potato::center $win
  wm deiconify $win
  raise $win
  focus $win

  return;

};# help::makeWindow

#: proc help::click
#: arg text Text widget
#: desc Handle the clicking of a link in the help text widget $text
#: return nothing
proc ::help::click {text} {

  set range [$text tag prevrange link "current + 1 char"]
  if { [llength $range] } {
       if { [lsearch -exact [$text tag names [lindex $range 0]] weblink] != -1 } {
            potato::launchWebPage [$text get {*}$range]
          } else {
            set name [lsearch -inline -glob [$text tag names current] "name:*"]
            ::help::showTopic [string range $name 5 end]
          }
     }

  return;

};# help::click

#: proc help::search
#: desc Show the search page
#: return nothing
proc ::help::search {} {
  variable widgets;

  set text $widgets(pane,help,text) 
  $text insert end "\nSearch phrase:     "
  entry $text.e -textvariable ::help::search
  $text window create end -window $text.e
  focus $text.e
  $text.e select range 0 end
  bind $text.e <Return> ::help::doSearch
  button $text.b -text "Search" -command ::help::doSearch
  $text window create end -window $text.b

  return;

};# help::search

#: proc help::doSearch
#: desc Run a search and display the results
#: return nothing
proc ::help::doSearch {} {
  variable widgets;
  variable search;
  variable pages;
  variable titles;

  set text $widgets(pane,help,text) 
  $text configure -state normal
  catch {$text delete searchResults.first searchResults.last}
  $text insert end "\n\nSearch results: \n" searchResults
  set i 0
  foreach x [array names pages] {
    if { [string match -nocase *$search* $x] } {
         # Match in title
         $text insert end "\n" searchResults $titles($x) [list link searchResults name:$x]
         incr i
       } elseif { [string match -nocase *$search* $pages($x)] } {
         $text insert end "\n" searchResults $titles($x) [list link searchResults name:$x]
         incr i
       }
  }
  if { $i == 0 } {
       $text insert end "\nNo matches." searchResults
     }

  $text configure -state disabled

  return;

};# help::doSearch

#: proc ::help::showTopicSub
#: arg text text widget
#: arg topic topic to show
#: desc Parse the markup of help topic $topic and print it to the text widget $text 
proc ::help::showTopicSub {text topic} {
  variable pages;
  variable titles;

  $text insert end "\n"

  set endash \u2013
  set emdash \u2014
  set bullet \u2022
  foreach line [split $pages($topic) \n] {
    set tag [list]
    set op1 ""
    set passOn [list]
    if { [regexp {^ +([1*-]+)\s*(.*)} $line -> op txt] } {
         set op1 [string index $op 0]
         set lvl [expr {[string length $op] - 1}]
         set indent [string repeat "     " $lvl]
         #set indent ""
         lappend passOn indentList$lvl
         if { $op1 eq "1" } {
              # Number
              if { ![info exists number($lvl)] } { 
                   set number($lvl) 0
                 }
              lappend tag number
              incr number($lvl)
              $text insert end "$indent $number($lvl)" $tag
            } elseif {$op1 eq "*"} {
              # Bullet
              lappend tag bullet
              $text insert end "$indent $bullet " $tag
            } elseif {$op1 eq "-"} {
              # Dash
              lappend tag dash
              $text insert end "$indent $endash " $tag
            }
         set line $txt
       } elseif { [string match " *" $line] } {
         # Line beginning w/ a space
         $text insert end $line\n fix
         unset -nocomplain number
         continue;
       }
    if { $op1 ne "1" } {
         unset -nocomplain number
       }

     $text insert end {*}[showTopicSubParse $line $passOn] \n ""
  }

  return;

};# help::showTopicSub

proc help::showTopicSubParse {line {tags ""}} {
  variable titles;

  set hasLink [regexp {^(.*?)\[(.+?)\](.*?)$} $line => preLink Link postLink]
  set hasMarkup [regexp {^(.*?)('''?)(.*?)\2(?!')(.*?)$} $line => preMarkup MarkupType Markup postMarkup]
  if { !$hasLink && !$hasMarkup } {
       return [list $line $tags];
     }

  if { !$hasMarkup || $hasLink && [string length $preLink] < [string length $preMarkup] } {
       # We have a link, unless the first char is [
       set linkTags link
       if { [string equal -length 1 $Link {[}] } {
            # Not a link. Woops.
            set Link [concat [list {[} $tags] [showTopicSubParse "[string range $Link 1 end]]" $tags]]
          } else {
            if { [string match "w:*" $Link] } {
                 lappend linkTags "weblink"
                 set Link [string range $Link 2 end]
               } elseif { [string match "*//*" $Link] } {
                 set tmp $Link
                 set slashes [string first // $tmp]
                 set Link [string range $tmp $slashes+2 end]
                 set name [string range $tmp 0 $slashes-1]
                 if { $Link eq "" } {
                      set Link $titles($name)
                    }
                 lappend linkTags name:$name
               } else {
                 lappend linkTags name:$Link
               }
            set Link [list $Link [concat $tags $linkTags]]
          }
       return [concat [list $preLink $tags] $Link [showTopicSubParse $postLink $tags]];
     }

  # We have markup
  if { [string length $MarkupType] == 2 } {
       set MarkupTag "italic"
     } else {
       set MarkupTag "bold"
     }
  return [concat [list $preMarkup $tags] [showTopicSubParse $Markup [concat $tags $MarkupTag]] [showTopicSubParse $postMarkup $tags]];

};# help::showTopicSubParse

#: proc help::buildTOC
#: desc Build the TOC tree from the TOC help topic page.
#: return nothing
proc ::help::buildTOC {} {
  variable widgets;
  variable pages;
  variable titles;

  if { ![info exists widgets(pane,toc,tree)] || ![winfo exists $widgets(pane,toc,tree)] } {
       return;
     }
  set tree $widgets(pane,toc,tree)
  if { ![info exists pages(TOC)] } {
       return;
     }
  set tocData $pages(TOC)

  $tree delete [$tree child {}]
  unset -nocomplain parent
  set parent() {}

  regsub -all {'{2,}} $tocData {} tocData
  foreach line [split $tocData \n] {
    set n [regexp {^\s*([-*]+)\s*(.*)} $line => dashes txt]
    if { !$n } {
         continue;
       }

    set isLink [regexp {^\[(.*)\]$} $txt => txt]
    set pDashes [string range $dashes 1 end]
    if { $isLink } {
         regexp {^(.+?)(//.*)?$} $txt => txt
         set tags [list link name:$txt]
         if { [info exists titles($txt)] } {
              set txt $titles($txt)
            }
       } else {
         set tags [list]
       }
    set parent($dashes) [$tree insert $parent($pDashes) end -text $txt -tags $tags]

  }

  return;

};# help::buildTOC

#: proc help::select
#: desc Handle the selecting of a topic from the tree in the help window
#: return nothing
proc ::help::select {} {
  variable widgets;

  set tree $widgets(pane,toc,tree)

  set id [$tree selection]
  set title [$tree item $id -text]
  set tags [$tree item $id -tags]
  if { "link" in $tags  } {
       set page [lsearch -glob -inline $tags "name:*"]
       ::help::showTopic [string range $page 5 end]
     } else {
       $tree item $id -open [expr {![$tree item $id -open]}]
     }
  return;

};# help::select

