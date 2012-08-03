# Attempt to merge a Potato translation template with an older translation file
set VERSION "1.2"

proc main {} {

  wm title . "Potato Translation File Merger, Version $::VERSION"

  pack [set frame [frame .template]] -side top -pady 8
  pack [label $frame.l -text "Template:" -justify left -width 14] -side left -padx 4
  pack [entry $frame.e -textvariable files(template) -width 35] -side left -padx 4
  pack [button $frame.b -command [list setFile template 1] -text "..."] -side left -padx 4

  pack [set frame [frame .trans]] -side top -pady 8
  pack [label $frame.l -text "Translation:" -justify left -width 14] -side left -padx 4
  pack [entry $frame.e -textvariable files(translation) -width 35] -side left -padx 4
  pack [button $frame.b -command [list setFile translation 1] -text "..."] -side left -padx 4

  pack [set frame [frame .output]] -side top -pady 8
  pack [label $frame.l -text "Ouput To:" -justify left -width 14] -side left -padx 4
  pack [entry $frame.e -textvariable files(output) -width 35] -side left -padx 4
  pack [button $frame.b -command [list setFile output 0] -text "..."] -side left -padx 4

  pack [set frame [frame .btns]] -side top -pady 15 -fill x
  pack [button $frame.go -text "Go!" -width 8 -command mergeFiles]
}

proc mergeFiles {} {
  global files;
  global global fid;
  global templateStrings;
  global translationStrings;
  global encoding;

  # Meh. ;)

  set fid(template) [open $files(template) r]
  set encoding [fconfigure $fid(template) -encoding]
  set fid(translation) [open $files(translation) r]
  set fid(output) [open $files(output) w]

  unset -nocomplain templateStrings;
  unset -nocomplain translationStrings;

  # OK, first we need to read in all of the template messages.
  # Then we need to read in all the translation file ones.
  # Then, we'll output:
  #  * Messages in the Template which aren't in our translation (do these first!)
  #  * Messages in the Translation that aren't in the template (obsolete and could be deleted?)
  #  * Correctly translated messages
  if { ![loadFile template] } {
       tk_messageBox -message "Template file $files(template) doesn't seem to be a valid translation file!"
       finishMergeFiles
       return;
     }
  if { ![loadFile translation] } {
       tk_messageBox -message "Translation file $files(translation) doesn't seem to be a valid translation file!"
       finishMergeFiles
       return;
     }
  # OK, we loaded successfully. So, now we need to write. Make sure we use the right encoding
  fconfigure $fid(output) -encoding $encoding

  set done [list]

  puts $fid(output) "\n# Untranslated strings:"
  set untranslated 0
  foreach x [array names templateStrings] {
    if { ![info exists translationStrings($x)] || $translationStrings($x) eq "-" } {
         puts $fid(output) "\n$x"
         puts $fid(output) $templateStrings($x)
         lappend done $x
         incr untranslated
       }
  }

  puts $fid(output) "\n# Obsolete strings:"
  set obsolete 0
  foreach x [array names translationStrings] {
    if { ![info exists templateStrings($x)] && $translationStrings($x) ne "-" } {
         puts $fid(output) "\n$x"
         puts $fid(output) $translationStrings($x)
         lappend done $x
         incr obsolete
       }
  }

  puts $fid(output) "\n# Existing translations:"
  set repeats 0
  foreach x [array names translationStrings] {
    if { $x ni $done } {
         puts $fid(output) "\n$x"
         puts $fid(output) $translationStrings($x)
         incr repeats
       }
  }

  # Done!
  finishMergeFiles
  tk_messageBox -message "Done! There were $untranslated untranslated strings, $obsolete obsolete strings, and $repeats strings already translated."
  return;

};# mergeFiles

proc loadFile {type} {
  global fid;
  global encoding;
  global ${type}Strings;

  if { ![getLine $fid($type) line] } {
       return 0;
     }

  set count 0;
  set i 0
  set beyond 500000
  while { $beyond } {
    incr beyond -1
    if { [string trim $line] eq "" || [string index $line 0] eq "#" } {
         if { [getLine $fid($type) line] } {
              continue;
            } else {
              break;
            }
       }
    if { $i == 0 } {
         set msg $line
         set i 1
       } else {
         set [set type]Strings($msg) $line
         set i 0
         incr count
       }
    if { ![getLine $fid($type) line] } {
         break;
       }
  }
  return $count;

};# loadFile

proc getLine {fid var} {

  upvar 1 $var _var
  if { [catch {gets $fid _var} count] || $count < 0 } {
       return 0;
     }

  return 1;

};# getLine

proc finishMergeFiles {} {
  global fid;

  foreach x [array names fid] {
    close $fid($x)
    unset fid($x)
  }

};# finishMergeFiles

proc setFile {type existing} {
  global files

  set initial [list -initialdir ../lib/i18n]
  if { [info exists files($type)] && $files($type) ne "" } {
       set initial [list -initialfile $files($type)]
     }

  if { $existing } {
       set file [tk_getOpenFile {*}$initial -title "Choose $type file"]
     } else {
       set file [tk_getSaveFile {*}$initial -title "Choose $type file"]
     }
  if { $file eq "" } {
       return;
     }
  set files($type) $file
};# setFile
package require Tk
main
bind . <F2> {console show}

cd [file dirname [info script]]
