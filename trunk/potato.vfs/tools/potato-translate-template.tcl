# This script builds a new Translation Template for Potato.
set VERSION "1.2"

proc main {} {


  pack [set frame [::ttk::frame .txt]] -side top -anchor nw -fill both

  wm title . "Potato Translation Template Generator, Version $::VERSION"

  set sbX $frame.x
  set sbY $frame.y
  set text [text $frame.t -width 80 -wrap none -yscrollcommand [list $sbY set] -xscrollcommand [list $sbX set] -state disabled]
  ::ttk::scrollbar $sbX -orient horizontal -command [list $text xview]
  ::ttk::scrollbar $sbY -orient vertical -command [list $text yview]

  grid $text $sbY -sticky nsew
  grid $sbX -sticky nswe
  grid rowconfigure $frame $text -weight 1
  grid columnconfigure $frame $text -weight 1

  pack [set frame [ttk::frame .output]] -side top -fill both -anchor nw
  pack [ttk::label $frame.l -textvariable ::outputfile -width 60] -side left
  pack [ttk::button $frame.b -text "Select Output File" -command setOutputFile] -side left

  pack [set frame [ttk::frame .btns]] -side top -fill both -anchor nw
  pack [ttk::button $frame.add -text "Add files!" -command [list addFiles $text]] -side left
  pack [ttk::button $frame.reset -text "Reset files" -command [list resetFiles $text]] -side left
  pack [ttk::button $frame.go -text "Go!" -command buildNewTemplate] -side left

  set files [glob -nocomplain -dir $::initialdir *.tcl]
  if { $files ne "" } {
       addFiles $text $files
     }
}

proc setOutputFile {{file ""}} {
  global outputfile

  if { $file eq "" } {
       set file [tk_getSaveFile -initialfile $outputfile -initialdir [file dirname $outputfile]]
     }
  if { $file eq ""} {
       return;
     }
  set outputfile [file native [file normal $file]]
}

proc resetFiles {t} {
  global inputfiles

  set inputfiles [list]
  $t config -state normal
  $t delete 1.0 end
  $t config -state disabled
}

proc addFiles {t {files ""}} {
  global inputfiles;
  global initialdir;

  if { $files ne "" } {
       foreach x $files {
         lappend inputfiles [file native [file normal $x]]
       }
     } else {
       set files [tk_getOpenFile -initialdir $initialdir -multiple 1]
       if { $files eq "" } {
            return;
          }
       foreach x $files {
         lappend inputfiles [file native $x]
       }
       set inputfiles [lsort -unique $inputfiles]
     }
  $t config -state normal
  $t delete 1.0 end
  $t insert end [join $inputfiles "\n"]
  $t config -state disabled
}

proc countSharedDirs {files} {

  set i 1
  set sep [file sep]
  set done 0
  while 1 {
    set list [list]
    foreach x $files {
      set split [lrange [split $x $sep] 0 end-1]
      if { [llength $split] == [expr {$i-1}] } {
           set done 1
           break;
         }
      lappend list [file join [lrange $split 0 $i]]
    }
    if { $done } {
         incr i -1
         break;
       }
    set list [lsort -unique $list]
    if { [llength $list] > 1 } {

         return $i;
       }
    incr i
  }
  return $i;
}

proc stripDirs {file num} {

  return [join [lrange [split $file [file sep]] $num end] [file sep]];

}


proc buildNewTemplate {} {
  global inputfiles;
  global outputfile;

  if { [catch {open $outputfile w} fout] } {
       tk_messageBox -message "Unable to open output file:\n[file nativename [file normalize $outputfile]]\nError: $fout" -icon error -title "Potato-Translate"
       return;
     }
  fconfigure $fout -translation lf
  set msgs 0
  foreach x $inputfiles {
    if { [catch {open $x r} fin] } {
         set ans [tk_messageBox -title "Potato-Translate" -icon error -type yesno -message "Unable to open input file:\n[file nativename [file normalize $x]]\nError: $fin\nAbort?]
         if { $ans eq "yes" } {
              close $fout
              return;
            }
       }
    incr msgs [processFile $x $fin potatoMessages]
    close $fin
    incr files
  }

  set stripby [countSharedDirs $inputfiles]

  foreach x [array names potatoMessages] {
    set c "#"
    puts $fout ""
    foreach {fname proc lineNum} $potatoMessages($x) {
      puts -nonewline $fout "$c [stripDirs $fname $stripby], line $lineNum [expr {($proc ne "" ? " ($proc)" : "")}]"
      set c ","
    }
    puts $fout ""
    puts $fout [string map [list "\n" "\\n"] $x]
    puts $fout "-\n"
  }
  close $fout

  tk_messageBox -title "Build Template" -icon info -type ok \
                -message "Built template with $msgs messages from $files files to:\n[file nativename [file normalize $outputfile]]"
}

proc processFile {fname fin var} {
  upvar 1 $var _textvar

  set lineNum 0
  set msgs 0
  set proc ""
  while { [gets $fin line] >= 0 } {
    incr lineNum
    if { [regexp {^proc +(\S+) } $line -> tmp] } {
         set proc $tmp
       } elseif { [regexp {.+?\[(?:\:\:potato\:\:)?[TX] +(.+)$} $line -> tmp] } {
         # Now we need to parse out the message, as it may contain escaped quotes and Tcl doesn't do lookbehind regexps.
         if { [string match {"*} $tmp] } {
              # Quoted string
              set tmp [string range $tmp 1 end] ;# skip opening quote
              for {set i 0} {$i < [string length $tmp]} {incr i} {
                if { [string index $tmp $i] == {"}} {
                     if { [string index $tmp $i-1] == "\\" } {
                          continue;
                        }
                     set tmp [string range $tmp 0 $i-1]
                     break;
                   }
              }
            } elseif { [regexp {\$[a-zA-Z0-9]+\]} $tmp] } {
              continue;
            } else {
              for {set i 0} {$i < [string length $tmp]} {incr i} {
                if { [string index $tmp $i] in [list " " "\]"] } {
                     if { [string index $tmp $i-1] == "\\" } {
                          continue;
                        }
                     set tmp [string range $tmp 0 $i]
                     break;
                   }
              }
            }
         lappend _textvar($tmp) $fname $proc $lineNum
         incr msgs
       }
  }

  return $msgs;

}

package require Tk
cd [file dirname [info script]]
set initialdir ../lib
set outputdir .
setOutputFile [file join $outputdir potato-template.txt]
main
bind . <F2> {console show}

