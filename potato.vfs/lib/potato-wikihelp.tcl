namespace eval ::wikihelp {
  variable info;     # General help info
  variable path;     # Widget paths
  variable index;    # File and topic names

  set info(defaultTopic) "Home"
  set info(TOC) "_Sidebar"
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
  set wikiImages "https://github.com/talvo/potato/wiki/"
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

  set tree [::ttk::treeview $left.tree -padding [list 0 0 0 0] -selectmode browse -yscrollcommand [list $left.sb set] -show [list tree] -takefocus 0]
  if { ![package vsatisfies [package present Tk] 8.6-] } {
       bind $tree <MouseWheel> "[bind Treeview <MouseWheel>];break"
     }
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

  bind $info(win) <Destroy> [list ::wikihelp::cleanupImages %W]

  focus $info(win)

  return;
};# ::wikihelp::help

#: proc ::wikihelp::cleanupImages
#: arg win window that triggered the event
#: desc If $win == $info(win), destroy all the wikihelp images
#: return nothing
proc ::wikihelp::cleanupImages {win} {
  variable info;

  if { $info(win) ne $win } {
       return;
     }

  catch {image delete {*}[lsearch -all -inline [image names] ::wikihelp::images::*]}

  return;
};# ::wikihelp::cleanupImages

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

#: proc ::wikihelp::findTopic
#: arg topic The topic to search for
#: desc Return the internal name (file name) of the given topic, if any, or empty string if not found
#: return topic name or empty string
proc ::wikihelp::findTopic {topic} {
  variable index;
  variable info;
  
  if { !$info(indexed) } {
       index
     }
  
  if { [info exists index(file,$topic)] } {
       return $topic;
     } elseif { [info exists index(summary,$topic)] } {
       return $index(summary,$topic);
     } else {
       return;
     }
};# ::wikihelp::findTopic

#: proc ::wikihelp::showTopic
#: arg topic The topic to display
#: desc Show the given $topic in the text window
#: return 1 if showed the topic successfully, 0 if not
proc ::wikihelp::showTopic {topic} {
  variable index;
  variable path;
  variable info;
  variable history;

  set topic [findTopic $topic]
  if { $topic eq "" } {
       return 0;
     }

  if { [catch {open [file join $info(filepath) $topic.md] r} fid] } {
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
  if { [info exists index(list,$topic)] } {
       set new [lindex $index(list,$topic) 0]
       if { $curr eq "" || $curr ni $index(list,$topic) } {
            $path(tree) see $new
            $path(tree) selection set $new
            $path(tree) focus $new
          }
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

  set italic ""
  set bold ""
  set noparse 0
  set multinoparse ""
  set values [list]
  set input [string map [list \r\n \n \r \n] $input]
  set ilen [string length $input]

  set html_entity_names [list lt gt copy nbsp amp]
  set html_entity_chars [list "<" ">" [format %c 169] " " "&"];# <-- this uses a regular space for &nbsp; since we don't squish anyway

  foreach line [split $input "\n"] {
    set marginTag margins
    if { $multinoparse ne "" } {
         if { $line eq $multinoparse } {
              set multinoparse ""
              continue;
            } else {
              lappend values $line "margins noparse"
            }
       } elseif { $line eq "```" || $line eq "~~~" } {
         set multinoparse $line
         continue;
       } elseif { $line eq "" } {
       } elseif { [regexp {^(#{1,6}) +(.+?) *?( #* *)?$} $line - hlen htext] } {
         set hlen [string length $hlen]
         lappend values {*}[subparse $htext noparse bold italic "$marginTag header$hlen"]
       } elseif { [regexp {^ {0,3}([-_*])( *\1){2,} *$} $line] } {
         lappend values "                             " hr
       } elseif { [regexp {^( {2,})([-+*]|\\d+[).] ) *(.+)$} $line -> newlistdepth newlisttype rest] } {
          # List
          #abc set marginTag to list-depth tag with extra indents, insert better list chars, etc
          set newlistdepth [expr { [string length $newlistdepth] / 2}]
          if { ![info exists list($newlistdepth,type)] || $list($newlistdepth,type) ne $newlisttype } {
               if { $newlisttype ni [list "-" "*" "+"] } {
                    set newlisttype "#" ;# numerical / ordered list
                  }
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
          lappend values {*}[subparse $rest noparse bold italic $marginTag]
        } else {
          lappend values {*}[subparse $line noparse bold italic $marginTag]
        }

     lappend values "\n" ""
  }
  
  return $values;
};# ::wikihelp::parse

proc ::wikihelp::subparse {text _noparse _bold _italic {extra_tags ""}} {
  upvar $_noparse noparse $_bold bold $_italic italic;
  
  set esc 0
  set last ""
  set retlist [list]
  set curr ""
  set linktext ""
  set link 0

  set tlen [string length $text]
  for {set i 0} {$i < $tlen} {incr i} {
    set x [string index $text $i]
    if { $x eq "`" && (!$esc || $noparse) } {
         # Noparse
         if { !$link } {
              lappend retlist $curr [parseTags $extra_tags $bold $italic $noparse]
              set curr ""
            }
         set noparse [expr {!$noparse}]
	   } elseif { $noparse } {
	     if { $link } {
		      append linktext $x
			} else {
			  append curr $x
			}
       } elseif { $esc } {
         if { $link } {
              append linktext $x
            } else {
              append curr $x
            }
         set esc 0
       } elseif { $x eq "\\" } {
         set esc 1
       } elseif { $x eq "*" || $x eq "_" } {
         if { [string index $text $i+1] eq $x } {
              # Got ** or __, for bold
              # Skip over the second one
              incr i
              if { $bold ne "" && $bold ne "$x$x" } {
                   # Our opening bold was ** but now we have __ (or vice versa) - 
                   # treat as literal text
                   if { $link } {
                        append linktext "$x$x"
                      } else {
                        append curr "$x$x"
                      }
                 } else {
                   # Toggle bold
                   if { !$link } {
                        lappend retlist $curr [parseTags $extra_tags $bold $italic $noparse]
                        set curr ""
                      }
                   if { $bold eq "" } {
                        set bold "$x$x"
                      } else {
                        set bold ""
                      }
                 }
            } else {
              # Got a single * or _, for italic
              if { $italic ne "" && $italic ne $x } {
                   # Got the wrong closing char, treat as literal
                   if { $link } {
                        append linktext $x
                      } else {
                        append curr $x
                      }
                 } else {
                   # Toggle italic
                   if { !$link } {
                        lappend retlist $curr [parseTags $extra_tags $bold $italic $noparse]
                        set curr ""
                      }
                   if { $italic eq "" } {
                        set italic $x
                      } else {
                        set italic ""
                      }
                 }
            }
       } elseif { $x eq "\[" || ($x eq "!" && [string index $text $i+1] eq "\[") } {
         # An image or a link
         if { $x eq "!" } {
              incr i
              set linktext "!\["
            } else {
              set linktext "\["
            }
         set link 1
         lappend retlist $curr [parseTags $extra_tags $bold $italic $noparse]
         set curr ""
       } elseif { $link == 1 && $x eq "]" } {
         if { [string index $text $i+1] eq "(" } {
              set link 2
              incr i
              append linktext "]("
            } else {
              # Parse $linktext
              append linktext "]"
              set plink [parseLink $linktext]
            }
       } elseif { $link == 2 && $x eq ")" } {
         # Parse $linktext
         append linktext ")"
         set plink [parseLink $linktext]
       } else {
         if { $link } {
              append linktext $x
            } else {
              append curr $x
            }
       }
    if { [info exists plink] } {
        set linktext ""
        set link 0
        if { [lindex $plink 0] eq "link" } {
             lappend retlist [lindex $plink 2] [parseTags [concat $extra_tags [lindex $plink 3]] $bold $italic $noparse]
           } elseif { [lindex $plink 0] eq "image" } {
             lappend retlist [list "<<IMAGE>>"] [list [lindex $plink 2]]
           } elseif { [lindex $plink 0] eq "plain" } {
             # Was probably an anchor which we don't support, but are good enough to ignore gracefully
             lappend retlist [lindex $plink 2] [parseTags $extra_tags $bold $italic $noparse]
           }
        unset plink
      }
  }

  if { $link } {
       # open link. Let's just input as raw text
       set curr $linktext
     }
     
  if { $curr ne "" } {
       lappend retlist $curr [parseTags $extra_tags $bold $italic $noparse]
     }

  return $retlist;

};# ::wikihelp::subparse

#: proc ::wikihelp::parseLink
#: arg str String to parse, in the format "[url]" or "[link-text](url)"
#: desc Parse out WikiLink text. If the link is to a Wiki-hosted image, try and convert to display the image instead. Otherwise, link as normal.
#: return [list <type> <linkto> <name> [list <tags>]] where <type> is "text" or "image", and where <tags> are the appropriate text widget tags (badlink, or link + weblink/wikilink, possibly + linkTo:<linkto>)
proc ::wikihelp::parseLink {str} {
  variable index;
  variable info;

  if { [string index $str 0] eq "!" } {
       set image 1
       set str [string range $str 1 end]
     } else {
       set image 0
     }
  if { [string index $str end] eq "]" } {
       # We just have [URL]
       set linkto [string range $str 1 end-1]
       set name ""
     } else {
       # We have [text](URL)
       regexp {^\[(.+?)\]\((.+)\)$} $str - name linkto
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
  if { $image && [string equal -length $::wikihelp::images::wikiImagesLen $::wikihelp::images::wikiImages $linkto] } {
       # Looks like we have one.
       set imagename [file tail $linkto]
       set exts [list ".gif"]
       if { [package vsatisfies [package present Tk] 8.6-] } {
            lappend exts ".png"
          }
       if { [file extension $imagename] in $exts && [file exists [file join $info(filepath) $imagename]] } {
            if { "::wikihelp::images::$imagename" ni [image names] } {
                 image create photo ::wikihelp::images::$imagename -file [file join $info(filepath) $imagename]
               }
            return [list "image" $linkto ::wikihelp::images::$imagename];
          }
       # If we get here, we didn't find the image or couldn't display it, so we continue as normal with a link.
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

  set str ""
  if { $noparse } {
       append str "noparse"
     }
  if { $bold ne "" } {
       append str "bold"
     }
  if { $italic ne "" } {
       append str "italic"
     }
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
  if { [info exists info(TOC)] && [file exists [set file [file join $info(filepath) $info(TOC).md]]] && [file readable $file] } {
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
              set topic [regsub -all -- "`(.+?)`" $topic {\1}];# Since we don't parse this, strip out any backticks protecting text
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
               if { [regexp {^\[(.+?)\]\((.+?)\)$} $topic - summary topic] || [regexp {^\[((.+?))\]$} $topic - summary topic]} {
                    if { [set summary [string trim $summary]] eq "" } {
                         set summary $topic
                       }
                    regsub -all {\\(.)} $summary \\1 summary
                    regsub -all {\\(.)} $topic \\1 topic
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
#: desc Index the available files, storing the filename to use as a title.
#: return nothing
proc ::wikihelp::index {} {
  variable info;
  variable path;
  variable index;

  foreach x [glob -nocomplain -dir $info(filepath) *.md] {
    set filename [file rootname [file tail $x]]
    set summary $filename ;# default in case no summary is present
    set index(file,$filename) $summary
    set index(summary,$summary) $filename
  }

  set info(indexed) 1

  return;

};# ::wikihelp::index

