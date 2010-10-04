namespace eval ::wikihelp {
  variable info;   # General help info
  variable path;   # Widget paths
  variable index;  # File and topic names

  set info(defaultTopic) "WelcomeToPotato"
  set info(TOC) "ContentsPage"
  set info(win) .wikihelp
  #set info(path) $::potato::path(help)
  set info(indexed) 0

  namespace import ::potato::T
}

#: proc ::wikihelp::help
#: arg topic Topic to show. Defaults to "".
#: desc Show the Help window, and display the given topic. If $topic is "", show the default topic.
#: return nothing
proc ::wikihelp::help {{topic ""}} {
  variable info;
  variable path;

  if { [::potato::reshowWindow $info(win)] } {
       # Window already exists
       if { $topic ne "" } {
            showTopic $topic
          }
       return;
     }

  if { $topic eq "" } {
       set topic $info(defaultTopic)
     }

  if { !$info(indexed) } {
       index
     }

  toplevel $info(win)
  wm title $info(win) [T "%s - Help" "Potato"]

  pack [set frame [ttk::frame $info(win).frame]] -expand 1 -fill both
  pack [set path(pane) [::ttk::panedwindow $frame.pane -orient horizontal]] -side top -expand 1 -fill both
  $path(pane) add [set left [::ttk::frame $path(pane).left -relief ridge]]
  $path(pane) add [set right [::ttk::frame $path(pane).right -relief ridge -borderwidth 2]]

  set tree [::ttk::treeview $left.tree -padding [list 0 0 0 0] -selectmode browse -yscrollcommand [list $left.sb set] -show [list tree]]
  bind $tree <MouseWheel> "[bind Treeview <MouseWheel>];break"
  $tree tag configure link -foreground blue
  $tree tag configure badlink
  $tree tag configure wikilink;# used for internal links
  $tree tag configure weblink;# used for external links
  $tree tag bind wikilink <1> [list ::wikihelp::clickTopic %W %x %y]
  set treeSB [::ttk::scrollbar $left.sb -orient vertical -command [list $tree yview]]
  grid $tree $treeSB -sticky nsew
  grid rowconfigure $left $tree -weight 1
  grid $tree $treeSB -sticky nsew

  set text [text $right.text -font TkDefaultFont -width 80 -wrap word \
                             -yscrollcommand [list $right.sbY set] \
                             -xscrollcommand [list $right.sbX set] \
                             -state disabled]
  set margin1 10
  set margin2 [expr {[font measure TkDefaultFont -displayof $text "  \u2022  "] + $margin1}]
  $text tag configure margins -lmargin1 $margin1 -lmargin2 $margin2
  set listIndent [font measure TkDefaultFont -displayof $text "  \u2022  "]
  incr listIndent 5
  for {set i 0} {$i < 5} {incr i} {
      $text tag configure "marginList[expr {$i+1}]" \
           -lmargin1 [expr {$margin1 + ($listIndent*$i)}] \
           -lmargin2 [expr {$margin2 + ($listIndent*$i)}]
  }
  $text tag configure bold -font [list {*}[font actual TkDefaultFont] -weight bold]
  $text tag configure bolditalic -font [list {*}[font actual TkDefaultFont] -weight bold -slant italic]
  $text tag configure italic -font [list {*}[font actual TkDefaultFont] -slant italic]
  $text tag configure header1 -font [list {*}[font actual TkDefaultFont] -size 22]
  $text tag configure header2 -font [list {*}[font actual TkDefaultFont] -size 18]
  $text tag configure header3 -font [list {*}[font actual TkDefaultFont] -size 15]
  $text tag configure hr -overstrike 1 -justify center -spacing1 15 -spacing3 15
  $text tag configure link -foreground blue
  $text tag configure badlink -foreground red
  $text tag bind link <Enter> [list $text configure -cursor hand2]
  $text tag bind link <Leave> [list $text configure -cursor {}]
  $text tag bind wikilink <1> [list ::wikihelp::clickTopic %W %x %y]
  $text tag bind weblink <1> [list ::wikihelp::webLink %W]
  set textSBY [::ttk::scrollbar $right.sbY -orient vertical -command [list $text yview]]
  set textSBX [::ttk::scrollbar $right.sbX -orient horizontal -command [list $text xview]]
  grid $text $textSBY -sticky nsew
  grid $textSBX -sticky nswe
  grid rowconfigure $right $text -weight 1
  grid columnconfigure $right $text -weight 1

  set path(tree) $tree
  set path(text) $text

  populateTOC
  if { ![showTopic $topic] && ![showTopic $info(defaultTopic)]} {
        showTopic $info(TOC)
     }

  return;
};# ::wikihelp::help

#: proc ::wikihelp::webLink
#: arg widget widget path
#: desc Process the click of a web link in $widget
#: return nothing
proc ::wikihelp::webLink {widget} {

  set tags [$widget tag names current]
  if { [set where [lsearch -glob $tags "linkTo:*"]] >= 0 } {
       set link [string range [lindex $tags $where] 7 end]
     } else {
       set link [$widget get {*}[$widget tag prevrange weblink "current + 1 char"]]
     }
  
  ::potato::launchWebPage $link
  return;

};# ::wikihelp::webLink

#: proc ::wikihelp::clickTopic
#: arg widget The widget clicked
#: arg x x-coord of click
#: arg y y-coord of click
#: desc Process a click in $widget (either text or tree) and show the topic being clicked at $x,$y
#: return nothing
proc ::wikihelp::clickTopic {widget x y} {

  if { [winfo class $widget] eq "Text" } {
       # Link in the text widget
       set tags [$widget tag names current]
       if { [set where [lsearch -glob $tags "linkTo:*"]] >= 0 } {
            set topic [string range [lindex $tags $where] 7 end]
          } else {
            set topic [$widget get {*}[$widget tag prevrange wikilink "current + 1 char"]]
          }
     } else {
       # Link in the TOC Tree
       set tags [$widget item [$widget identify row $x $y] -tags]
       set topic [string range [lsearch -inline -glob $tags "linkTo:*"] 7 end]
     }
  showTopic $topic

  return;

};# ::wikihelp::clickTopic

#: proc ::wikihelp::showTopic
#: arg topic The topic to display
#: desc Show the given $topic in the text window
#: return 1 if showed the topic successfully, 0 if not
proc ::wikihelp::showTopic {topic} {
  variable index;
  variable path;
  variable info;

  if { [info exists index(file,$topic)] } {
       # Fine
     } elseif { [info exists index(summary,$topic)] } {
       set topic $index(summary,$topic);# we want the filename
     } else {
       # Not found
       return 0;
     }

  if { [catch {open [file join $::potato::path(help) $topic.wiki] r} fid] } {
       return 0;# can't open file
     }

  $path(text) configure -state normal
  $path(text) delete 1.0 end
  $path(text) insert end {*}[parse [read $fid]]
  $path(text) configure -state disabled

  # Show the topic in the tree
  set curr [lindex [$path(tree) selection] 0]
  if { [info exists index(list,$topic)] && ($curr eq "" || $curr ni $index(list,$topic)) } {
       set new [lindex $index(list,$topic) 0]
       $path(tree) see $new
       $path(tree) selection set $new
       $path(tree) focus $new
     }

  return 1;

};# ::wikihelp::showTopic

#: proc ::wikihelp::parse
#: arg input String of text to parse
#: desc Parse $input, which is a Wiki page, and return a list of text/tags for insertion into a text widget
#: return list of text/tag pairs for [$textWidget insert]
proc ::wikihelp::parse {input} {

  set italic 0
  set bold 0
  set noparse 0
  set multinoparse 0
  set linkparse 0
  set headerparse 0
  set values [list]
  set input [string map [list \r\n \n \r \n] $input]
  set buffer ""

  foreach line [split $input "\n"] {
     set marginTag "margins"
     if { !$multinoparse && [string equal $line "\{\{\{"] } {
          set multinoparse 0
          continue;
        } elseif { $multinoparse && [string equal $line "\}\}\}"] } {
          set multinoparse 1
          continue;
        } elseif { $multinoparse } {
          # Don't parse this line
          lappend values "$line\n" [parseTags [list $marginTag] $bold $italic]
          continue;
        } elseif { [regexp {^#(summary|labels|sidebar)} $line] } {
          continue;
        } elseif { [regexp {^.*----+.*$} $line] } {
          # Horizontal rule
          lappend values "                             " hr "\n" ""
          continue;
        } elseif { [regexp {^( {2,})([*#]) *(.+)$} $line -> newlistdepth newlisttype rest] } {
          # List
          #abc set marginTag to list-depth tag with extra indents, insert better list chars, etc
          set newlistdepth [expr { [string length $newlistdepth] / 2}]
          if { ![info exists list($newlistdepth,type)] || $list($newlistdepth,type) ne $newlisttype } {
               set list($newlistdepth,type) $newlisttype
               if { $newlisttype eq "#" } {
                    set list($newlistdepth,count) 0

                  }
             }
          if { $list($newlistdepth,type) eq "#" } {
               set listchar [incr $list($newlistdepth,count)]
             } else {
               set listchar \u2022
             }
          if { $newlistdepth > 5 } {
               set marginTag "marginList5"
             } else {
               set marginTag "marginList$newlistdepth"
             }
          lappend values "  $listchar  " [list $marginTag]
          set line $rest
        } else {
        }
     # Get all non-special chars
     while { [string length $line]} {
       if { $noparse } {
            regexp {^([^`]*)(.)?(.*?)$} $line -> easy char line
          } elseif { $linkparse } {
            regexp {^([^]]*)(.)?(.*?)$} $line -> easy char line
          } else {
            regexp {^([^*_`=[]*)(.)?(.*?)$} $line -> easy char line
          }
       if { $easy ne "" } {
            if { $linkparse || $headerparse } {
                 append buffer $easy
               } else {
                 # insert everything up to our special char
                 lappend values $easy [parseTags [list $marginTag] $bold $italic]
               }
          }
       if { $char eq "" } {
            continue; # nothing special to parse
          }
       switch -exact -- $char {
          *  {set bold [expr {!$bold}]}
          _  {set italic [expr {!$italic}]}
          `  {set noparse [expr {!$noparse}]}
          \[ {set linkparse 1}
          \] {set linkparse 0
              set link [parseLink $buffer]
              lappend values [lindex $link 1] [parseTags [list $marginTag [lindex $link 2]] $bold $italic]
              set buffer ""
             }
           = {if { [string length $buffer] } {
                   # Closing the header
                   if { ![info exists headersize] } {
                        set headersize $headerparse
                      }
                   incr headerparse -1
                   if { !$headerparse } {
                        # Finished the close
                        lappend values [string trim $buffer] [parseTags [list $marginTag header$headersize] $bold $italic]
                        unset headersize
                        set buffer ""
                      }
                 } else {
                   incr headerparse
                 }
             }
        }
     }

     if { $linkparse } {
          # We'll allow multi-line links
        } elseif { $headerparse } {
          # But not multiline headers
          if { $headerparse > 3 } {
               set headerparse 3
             }
          if { [string length $buffer] } {
               lappend values [string trim $buffer] [parseTags [list $marginTag header$headerparse] $bold $italic]
             }
          set headerparse 0
          set buffer ""
        } elseif { $noparse } {
          set noparse 0
        }
     lappend values "\n" ""
  }

  # OK, end of the file. Let's see what we didn't close...
  if { $linkparse } {
       # OK, we left a link open. We almost certainly didn't mean to. Hrm. Let's just ignore it. :P
     }
  # OK, actually, links are the only multi-line markup that buffers the text, so we're good.

  return $values;

};# ::wikihelp::parse

#: proc ::wikihelp::parseLink
#: arg str String to parse
#: desc Parse out WikiLink text, which will be in the format "<linkto>[ <name>]". (If no <name>, it defaults to <linkto>.)
#: return [list <linkto> <name> [list <tags>]] where <tags> are the appropriate text widget tags (badlink, or link + weblink/wikilink, possibly + linkTo:<linkto>)
proc ::wikihelp::parseLink {str} {
  variable index;

  if { [set space [string first " " $str]] > -1 } {
       set linkto [string range $str 0 $space-1]
       set name [string trim [string range $str $space+1 end]]
     } else {
       set linkto $str
       set name ""
     }
  if { $name eq $linkto } {
       set name ""
     }
  if { [regexp {^(f|ht)tps?://.+} $linkto] } {
       set tags [list weblink link "linkTo:$linkto"]
     } else {
       if { [info exists index(file,$linkto)] } {
            set tags [list link wikilink]
            if { $name ne "" } {
                 lappend tags "linkTo:$linkto"
               }
          } else {
            set tags [list badlink]
          }
     }
  if { $name eq "" } {
       set name $linkto
     }
  return [list $linkto $name $tags];

};# ::wikihelp::parseLink

#: proc ::wikihelp::parseTags
#: arg tags Starting tags
#: arg bold Should we bold?
#: arg italics Should we italicize?
#: desc Append "bolditalic", "bold" or "italic" tags, if appropriate, to $tags, and return result
#: return New list of tags
proc ::wikihelp::parseTags {tags bold italic} {

  set str "[lindex [list "" "bold"] $bold][lindex [list "" "italic"] $italic]"
  if { $str ne "" } {
       lappend tags $str
     }

  return $tags;

};# ::wikihelp::parseTags

#: proc ::wikihelp::populateTOC
#: desc Populate the Table of Contents treeview widget. It's in the format of a Wiki nested list, but uses special-case code b/c we need to insert into a treeview, not display in the textwidget.
#: return nothing
proc ::wikihelp::populateTOC {} {
  variable info;
  variable path;
  variable index;

  set tree $path(tree)

  $tree delete [$tree children {}]
  array unset index list,*

  # If possible, we'll use the designated Table of Contents file.
  if { [info exists info(TOC)] && [file exists [set file [file join $::potato::path(help) $info(TOC).wiki]]] && [file readable $file] } {
       # We have a TOC file, use that.
       if { ![catch {open $file r} fid] } {
            set parents [list {}]
            set indents [list 1]
            set parent {}
            set indent 1
            set last {}
            while { [gets $fid line] >= 0 && ![eof $fid] } {
              if { ![regexp {^( {2,})\* *(.+)$} $line -> spaces topic] } {
                   continue;
                 }
              set count [expr {[string length $spaces] / 2}]
              if { $count > $indent } {
                   lappend indents $count
                   lappend parents $last
                   set parent $last
                   set indent $count
                 } elseif { $count < $indent } {
                   set cutoff [lsearch $indents $count]
                   if { $cutoff == -1 } {
                        set cutoff [expr {[llength $indents]-2}]
                      }
                   set indents [lrange $indents 0 $cutoff]
                   set parents [lrange $parents 0 $cutoff]
                   set indent [lindex $indents end]
                   set parent [lindex $parents end]
                 }
               if { [string match {\[*\]} $topic] } {
                    set topic [string range $topic 1 end-1]
                    if { [set space [string first " " $topic]] > -1 } {
                         set summary [string range $topic $space+1 end]
                         set topic [string range $topic 0 $space-1]
                         if { [string trim $summary] eq "" } {
                              set summary $topic
                            }
                       } else {
                         set summary $topic
                       }
                    if { [info exists index(file,$topic)] } {
                         set tags [list link wikilink linkTo:$topic]
                       } else {
                         set tags [list badlink]
                       }
                  } elseif { [info exists index(file,$topic)] } {
                    set file $topic
                    set summary $index(file,$topic)
                    set tags [list link wikilink linkTo:$file]
                  } elseif { [info exists index(summary,$topic)] } {
                    set file $index(summary,$topic)
                    set summary $topic
                    set tags [list link wikilink linkTo:$file]
                  } else {
                    set file $topic
                    set summary $topic
                    set tags [list badlink]
                  }
              set last [$tree insert $parent end -text $summary -tags $tags]
              lappend index(list,$file) $last
            }
            close $fid
            return;
          }
     }

  
  # If we get here, we can't find the TOC file, so we'll just list every page we have.
  foreach x [lsort -dictionary [array names index filename,]] {
    set last [$tree insert {} end -text $index($x) -tags [list link "linkTo:[string range $x 9 end]"]]
    lappend index(list,[string range $x 9 end]) $last
  }

  return;

};# ::wikihelp::populateTOC

#: proc ::wikihelp::index
#: desc Index the available files, storing the filename and the "#summary" line (if present) to use as a title.
#: return nothing
proc ::wikihelp::index {} {
  variable info;
  variable path;
  variable index;

  set dir $::potato::path(help)
  foreach x [glob -nocomplain -dir $dir *.wiki] {
    if { [catch {open $x r} fid] } {
          continue; # Don't even track the filename, since we can't open it to read
       }
    set filename [file rootname [file tail $x]]
    set summary $filename ;# default in case no summary is present
    while { [gets $fid line] >= 0 && ![eof $fid] } {
      if { [string match "#summary *" $line] } {
           set summary [string trim [string range $line 9 end]]
           break;
         }
    }
    set index(file,$filename) $summary
    set index(summary,$summary) $filename
    close $fid
  }

  set info(indexed) 1

  return;

};# ::wikihelp::index

package provide potato-wikihelp 2.0.0

