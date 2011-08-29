namespace eval ::wikihelp {
  variable info;     # General help info
  variable path;     # Widget paths
  variable index;    # File and topic names

  set info(defaultTopic) "WelcomeToPotato"
  set info(TOC) "ContentsPage"
  set info(win) .wikihelp
  set info(indexed) 0
  set info(disppath) "Potato Help"
  set info(sb) $info(disppath)
  set info(filepath) $::potato::path(help)

  namespace import ::potato::T
}

namespace eval ::wikihelp::images {
  variable wikiImages;
  variable wikiImagesLen;
  
  # Path that Wiki images are stored in
  set wikiImages "http://potatomushclient.googlecode.com/svn/wiki/"
  set wikiImagesLen [string length $wikiImages]
}

# Current, known limitations:
#  * Does not parse markup in link names
#  * Contents Page in Tree displays nothing but ul-list elements
#  * Contents Page in Tree does nothing but link and nested ul-list parsing (no bold, etc)
#  * Very little HTML support. There is some handling of entities, but parsing (and ignoring) tags too would be good.

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
  pack [::ttk::frame $frame.sb] -side top -fill x -padx 3 -pady 2
  pack [set path(sb) [ttk::label $frame.sb.l -textvariable ::wikihelp::info(sb) -width 75]] -side left -expand 0 -fill none
  $path(pane) add [set left [::ttk::frame $path(pane).left -relief ridge]]
  $path(pane) add [set right [::ttk::frame $path(pane).right -relief ridge -borderwidth 2]]

  set tree [::ttk::treeview $left.tree -padding [list 0 0 0 0] -selectmode browse -yscrollcommand [list $left.sb set] -show [list tree]]
  bind $tree <MouseWheel> "[bind Treeview <MouseWheel>];break"
  $tree tag configure link -foreground black
  $tree tag configure badlink -foreground red
  $tree tag configure wikilink;# used for internal links
  $tree tag configure weblink;# used for external links
  $tree tag bind wikilink <ButtonRelease-1> [list ::wikihelp::clickTopic %W %x %y]
  set treeSB [::ttk::scrollbar $left.sb -orient vertical -command [list $tree yview]]
  grid $tree $treeSB -sticky nsew
  grid rowconfigure $left $tree -weight 1
  grid $tree $treeSB -sticky nsew

  set text [text $right.text -font TkDefaultFont -width 115 -height 30 -wrap word \
                             -yscrollcommand [list $right.sbY set] \
                             -xscrollcommand [list $right.sbX set] \
                             -state disabled]
  set margin 20
  $text tag configure margins -lmargin1 $margin -lmargin2 $margin
  set listIndent [font measure TkDefaultFont -displayof $text "  \u2022 "];# deliberately missing 1 trailing space
  incr listIndent 5
  for {set i 1} {$i <= 16} {incr i} {
      $text tag configure "marginList$i" \
           -lmargin1 [expr {$margin + ($listIndent*($i-1))}] \
           -lmargin2 [expr {$margin + ($listIndent*$i)}]
  }
  $text tag configure bold -font [list {*}[font actual TkDefaultFont] -weight bold]
  $text tag configure bolditalic -font [list {*}[font actual TkDefaultFont] -weight bold -slant italic]
  $text tag configure italic -font [list {*}[font actual TkDefaultFont] -slant italic]
  $text tag configure noparse -font TkFixedFont
  $text tag configure noparsebold -font [list {*}[font actual TkFixedFont] -weight bold]
  $text tag configure noparseitalic -font [list {*}[font actual TkFixedFont] -slant italic]
  $text tag configure noparsebolditalic -font [list {*}[font actual TkFixedFont] -weight bold -slant italic]
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
  $text tag bind weblink <Enter> [list ::wikihelp::linkHover $text 1]
  $text tag bind weblink <Leave> [list ::wikihelp::linkHover $text 0]
  $text tag bind wikilink <Enter> [list ::wikihelp::linkHover $text 2]
  $text tag bind wikilink <Leave> [list ::wikihelp::linkHover $text 0]
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

#: proc ::wikihelp::linkHover
#: arg widget widget path
#: arg type 1 = hovering web link, 2 = hovering wiki link, 0 = leaving link
#: desc When hovering a link, set the status bar appropriately. (When leaving a link, set to the path of the current page.)
#: return nothing
proc ::wikihelp::linkHover {widget type} {
  variable path;
  variable info;

  if { !$type } {
       $path(sb) configure -textvariable ::wikihelp::info(disppath)
       return;
     }
  if { $type == 1 } {
       set type "weblink"
     } elseif { $type == 2 } {
       set type "wikilink"
     } else {
       return;
     }
  set tags [$widget tag names current]
  if { [set where [lsearch -glob $tags "linkTo:*"]] >= 0 } {
       set topic [string range [lindex $tags $where] 7 end]
     } else {
       set topic [$widget get {*}[$widget tag prevrange $type "current + 1 char"]]
     }
  if { $type eq "weblink" } {
       set info(sb) [T "Go to webpage: %s" $topic]
     } else {
       set info(sb) [T "View helpfile '%s'" $topic]
     }
  $path(sb) configure -textvariable ::wikihelp::info(sb)

  return;

};# ::wikihelp::linkHover

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
  variable history;

  if { [info exists index(file,$topic)] } {
       # Fine
     } elseif { [info exists index(summary,$topic)] } {
       set topic $index(summary,$topic);# we want the filename
     } else {
       # Not found
       return 0;
     }

  if { [catch {open [file join $info(filepath) $topic.wiki] r} fid] } {
       return 0;# can't open file
     }

  fconfigure $fid -encoding utf-8
  $path(text) configure -state normal
  $path(text) delete 1.0 end
  foreach {text tags} [parse [read $fid]] {
    if { $text eq "<<IMAGE>>" } {
         $path(text) insert end "\n"
         $path(text) image create end -image $tags -padx 20
       } else {
         $path(text) insert end $text $tags
       }
  }
  $path(text) configure -state disabled

  catch {close $fid}

  # Show the topic in the tree
  set curr [lindex [$path(tree) selection] 0]
  if { [info exists index(list,$topic)] && ($curr eq "" || $curr ni $index(list,$topic)) } {
       set new [lindex $index(list,$topic) 0]
       $path(tree) see $new
       $path(tree) selection set $new
       $path(tree) focus $new
       set join ""
       set disppath ""
       while { $new ne "" } {
         set text [$path(tree) item $new -text]
         set disppath "$text$join$disppath"
         set join " [format %c 8594] "
         set new [$path(tree) parent $new]
       }
       set info(disppath) $disppath
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
  set past_pragma 0

  set html_entity_names [list lt gt copy nbsp amp]
  set html_entity_chars [list "<" ">" [format %c 169] " " "&"];# <-- this uses a regular space for &nbsp; since we don't squish anyway 

  foreach line [split $input "\n"] {
     set marginTag "margins"
     if { !$past_pragma } {
          if { [string index $line 0] eq "#" } {
               continue; # skip #pragma lines like #summary
             } else {
               set past_pragma 1
             }
        }
     if { !$multinoparse && [string equal $line "\{\{\{"] } {
          set multinoparse 1
          continue;
        } elseif { $multinoparse && [string equal $line "\}\}\}"] } {
          set multinoparse 0
          continue;
        } elseif { $multinoparse } {
          # Don't parse this line
          lappend values "$line\n" [parseTags [list $marginTag] $bold $italic 1]
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
               set listchar [lindex [list \u2022 \u25e6 \u25a0 \u25a1 \u25c6 \u25c7 \u25b6 \u25b7] [expr {($newlistdepth-1) % 8}]]
             }
          if { $newlistdepth > 16 } {
               set marginTag "marginList16"; # We only have indent tags configured up to marginList16.
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
                 lappend values $easy [parseTags [list $marginTag] $bold $italic $noparse]
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
              if { [lindex $link 0] eq "link" } {
                   lappend values [lindex $link 2] [parseTags [concat $marginTag [lindex $link 3]] $bold $italic $noparse]
                 } elseif { [lindex $link 0] eq "image" } {
                   lappend values [list "<<IMAGE>>"] [list [lindex $link 2]]
                 } elseif { [lindex $link 0] eq "plain" } {
                   # Was probably an anchor which we don't support, but are good enough to ignore gracefully
                   lappend values [lindex $link 1] [parseTags $marginTag $bold $italic $noparse]
                 }
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
                        lappend values [string trim $buffer] [parseTags [list $marginTag header$headersize] $bold $italic $noparse]
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
               lappend values [string trim $buffer] [parseTags [list $marginTag header$headerparse] $bold $italic $noparse]
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
#: desc If the link is to a Wiki-hosted image, try and convert to display the image instead. Otherwise, link as normal.
#: return [list <type> <linkto> <name> [list <tags>]] where <type> is "text" or "image", and where <tags> are the appropriate text widget tags (badlink, or link + weblink/wikilink, possibly + linkTo:<linkto>)
proc ::wikihelp::parseLink {str} {
  variable index;
  variable info;

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
  if { [string index $linkto 0] eq "#" } {
       # An anchor on the current page - abort!
       if { $name eq "" } {
            set name [string range $linkto 1 end]
          }
       return [list "plain" $name];
     }       
  # Check for a Wiki Image
  if { [string equal -length $::wikihelp::images::wikiImagesLen $::wikihelp::images::wikiImages $linkto] } {
       # Looks like we have one.
       set imagename [file tail $linkto]
       if { [file extension $imagename] eq ".gif" && [file exists [file join $info(filepath) $imagename]] } {
            if { "::wikihelp::images::$imagename" ni [image names] } {
                 image create photo ::wikihelp::images::$imagename -file [file join $info(filepath) $imagename]
               }
            return [list "image" $linkto ::wikihelp::images::$imagename];
          }
       # If we get here, we didn't find the image, so we continue as normal with a link.
     }
  if { [regexp {^(f|ht)tps?://.+} $linkto] } {
       set tags [list weblink link "linkTo:$linkto"]
     } else {
       # Check for an anchor, and strip it if found
       if { [set anchor [string first "#" $linkto]] > -1 } {
            set linkto [string range $linkto 0 $anchor-1]
          }
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
  return [list "link" $linkto $name $tags];

};# ::wikihelp::parseLink

#: proc ::wikihelp::parseTags
#: arg tags Starting tags
#: arg bold Should we bold?
#: arg italics Should we italicize?
#: arg noparse Display fixed-width?
#: desc Append "bolditalic", "bold" or "italic" tags, and/or "noparse", if appropriate, to $tags, and return result
#: return New list of tags
proc ::wikihelp::parseTags {tags bold italic noparse} {

  set str "[lindex [list "" "noparse"] $noparse][lindex [list "" "bold"] $bold][lindex [list "" "italic"] $italic]"
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
  if { [info exists info(TOC)] && [file exists [set file [file join $info(filepath) $info(TOC).wiki]]] && [file readable $file] } {
       # We have a TOC file, use that.
       if { ![catch {open $file r} fid] } {
            set parents [list {}]
            set indents [list 1]
            set parent {}
            set indent 1
            set last {}
            while { [gets $fid line] >= 0 && ![eof $fid] } {
              if { ![regexp {^( {2,})\* *(.+?) *$} $line -> spaces topic] } {
                   continue; # Skip non-list items
                 }
              set topic [regsub -all -- "`(.+?)`" $topic {\1}];# Since we don't parse this (but Google does), strip out any backticks protecting text
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
                    set file $topic
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
                    set tags [list];# don't badlink things that weren't linked anyway [list badlink]
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

  foreach x [glob -nocomplain -dir $info(filepath) *.wiki] {
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

