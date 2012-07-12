
# Initial init of fonts
namespace eval ::font {
  variable S

  set S(fonts) [lsort -dictionary [font families]]
  set S(styles) [list Regular Italic Bold "Bold Italic"]

  set S(sizes) [list 8 9 10 11 12 14 16 18 20 22 24 26 28 36 48 72]

  set S(fonts,lcase) {}
  foreach font $S(fonts) {
    lappend S(fonts,lcase) [string tolower $font]
  }
  set S(styles,lcase) [list regular italic bold "bold italic"]
  set S(sizes,lcase) $S(sizes)

};# namespace eval ::font

#: proc ::font::chose
#: arg parent Parent window (for transients); currently unused
#: arg win Path for font dialog toplevel
#: arg defaultFont The default selected font to display. Defaults to TkFixedFont
#: arg title Title for the dialog; defaults to "Font"
#: desc Show a font dialog $win, using the initial font $defaultFont.
#: return The chosen font (note: does not return immediately)
proc ::font::choose {parent win {defaultFont "TkFixedFont"} {title ""}} {
  variable S

  if { [winfo exists $win] } {
       potato::reshowWindow $win
       return;
     }
  if { $title eq "" } {
       set title [::potato::T "Font"]
     }
  toplevel $win -padx 5 -pady 5
  wm withdraw $win
  wm title $win $title
  pack [set frame [::ttk::frame $win.frame]] -expand 1 -fill both -anchor nw

  set S($win,strike) 0
  set S($win,under) 0
  set S($win,first) 1

  ::ttk::label $frame.font -text [::potato::T "Font:"]
  ::ttk::label $frame.style -text [::potato::T "Font style:"]
  ::ttk::label $frame.size -text [::potato::T "Size:"]
  ::ttk::entry $frame.efont -textvariable ::font::S($win,font) ;# -state disabled
  ::ttk::entry $frame.estyle -textvariable ::font::S($win,style) ;# -state disabled
  ::ttk::entry $frame.esize -textvariable ::font::S($win,size) -width 0 \
        -validate key -validatecommand {string is double %P}

  ::ttk::scrollbar $frame.sbfonts -command [list $frame.lfonts yview]
  listbox $frame.lfonts -listvariable ::font::S(fonts) -height 7 \
      -yscroll [list $frame.sbfonts set] -height 7 -exportselection 0
  listbox $frame.lstyles -listvariable ::font::S(styles) -height 7 \
      -exportselection 0
  ::ttk::scrollbar $frame.sbsizes -command [list $frame.lsizes yview]
  listbox $frame.lsizes -listvariable ::font::S(sizes) \
      -yscroll [list $frame.sbsizes set] -width 6 -height 7 -exportselection 0

  bind $frame.lfonts <<ListboxSelect>> [list ::font::click $win font]
  bind $frame.lstyles <<ListboxSelect>> [list ::font::click $win style]
  bind $frame.lsizes <<ListboxSelect>> [list ::font::click $win size]

  set WE $frame.effects
  ::ttk::labelframe $WE -text [::potato::T "Effects"]
  ::ttk::checkbutton $WE.strike -variable ::font::S($win,strike) \
      -text Strikeout -command [list ::font::click $win strike]
  ::ttk::checkbutton $WE.under -variable ::font::S($win,under) \
      -text Underline -command [list ::font::click $win under]

  ::ttk::button $frame.ok -text [::potato::T "OK"] -width 8 -default active -command [list ::font::done $win 1]
  bind $win <Return> [list $frame.ok invoke]
  ::ttk::button $frame.cancel -text [::potato::T "Cancel"] -width 8 -command [list ::font::done $win 0]
  wm protocol $win WM_DELETE_WINDOW [list ::font::done $win 0]

  grid $frame.font - x $frame.style - x $frame.size - x -sticky w
  grid $frame.efont - x $frame.estyle - x $frame.esize - x $frame.ok -sticky ew
  grid $frame.lfonts $frame.sbfonts x \
      $frame.lstyles - x \
      $frame.lsizes $frame.sbsizes x \
      $frame.cancel -sticky news
  grid config $frame.cancel -sticky n -pady 5
  grid columnconfigure $frame {2 5 8} -minsize 10
  grid columnconfigure $frame {0 3 6} -weight 1

  grid $WE.strike -sticky w -padx 10
  grid $WE.under -sticky w -padx 10
  grid columnconfigure $WE 1 -weight 1
  grid $WE - x -sticky news -row 100 -column 0

  set WS $frame.sample
  ::ttk::labelframe $WS -text [::potato::T "Sample"]
  label $WS.fsample -bd 2 -relief sunken
  label $WS.fsample.sample -text [::potato::T "AaBbYyZz"]
  set S($win,sample) $WS.fsample.sample
  pack $WS.fsample -fill both -expand 1 -padx 10 -pady 10 -ipady 15
  pack $WS.fsample.sample -fill both -expand 1
  pack propagate $WS.fsample 0

  grid rowconfigure $frame 2 -weight 1
  grid rowconfigure $frame 99 -minsize 30
  grid $WS - - - - -sticky news -row 100 -column 3
  grid rowconfigure $frame 101 -minsize 30

  ::font::init $win $defaultFont

  trace variable ::font::S($win,size) w [list ::font::tracer $win]
  trace variable ::font::S($win,style) w [list ::font::tracer $win]
  trace variable ::font::S($win,font) w [list ::font::tracer $win]

  update idletasks
  potato::center $win
  wm deiconify $win
  raise $win
  focus $win
  tkwait window $win

  return $S($win,result);

};# ::font::font

#: proc ::font::done
#: arg win The toplevel font window
#: arg ok Has a font been chosen (1), or is the dialog being cancelled (0)?
#: desc If the dialog is cancelled, set the chosen font empty. Destroy the dialog.
#: return nothing
proc ::font::done {win ok} {
  variable S;

  if { !$ok } {
       set ::font::S($win,result) ""
     }

  destroy $win
  return;

};# font::done

#: proc ::font::init
#: arg win Toplevel font dialog window
#: arg defaultFont The default font to init. Defaults to "".
#: desc Set up the initial font dialog settings for font $defaultFont.
#: return nothing
proc ::font::init {win {defaultFont ""}} {
  variable S

  if { $S($win,first) || $defaultFont ne "" } {
       if { $defaultFont eq "" } {
          set defaultFont [[entry .___e] cget -font]
          destroy .___e
       }
       array set F [font actual $defaultFont]
       set S($win,font) $F(-family)
       set S($win,size) $F(-size)
       set S($win,strike) $F(-overstrike)
       set S($win,under) $F(-underline)
       set S($win,style) "Regular"
       if { $F(-weight) eq "bold" && $F(-slant) eq "italic" } {
            set S($win,style) "Bold Italic"
          } elseif { $F(-weight) eq "bold" } {
            set S($win,style) "Bold"
          } elseif {$F(-slant) eq "italic" } {
            set S($win,style) "Italic"
          }
        set S($win,first) 0
     }

  ::font::tracer $win a b c
  ::font::show $win

  return;

};# font::init

#: proc ::font::click
#: arg win Toplevel font dialog window
#: arg what What was clicked; one of "font", "style" or "size"
#: desc Handle a listbox click in the font dialog
#: return nothing
proc ::font::click {win what} {
  variable S

  if { $what eq "font" } {
       set S($win,font) [$win.frame.lfonts get [$win.frame.lfonts curselection]]
     } elseif { $what eq "style" } {
       set S($win,style) [$win.frame.lstyles get [$win.frame.lstyles curselection]]
    } elseif { $what eq "size" } {
        set S($win,size) [$win.frame.lsizes get [$win.frame.lsizes curselection]]
    }
  ::font::show $win

  return;

};# font::click

#: proc ::font::tracer
#: arg win Toplevel font dialog window
#: arg var1 Passed by [trace]; unused
#: arg var2 Passed by [trace]; unused
#: arg op Passed by [trace]; unused
#: desc Called via a [trace] when the font changes; update the dialog based on the changes made
#: return nothing
proc ::font::tracer {win var1 var2 op} {
  variable S

  set bad 0
  set nstate "!disabled"
  # Make selection in each listbox
  foreach var {font style size} {
    set value [string tolower $S($win,$var)]
    $win.frame.l${var}s selection clear 0 end
    set n [lsearch -exact $S(${var}s,lcase) $value]
    $win.frame.l${var}s selection set $n
    if {$n != -1} {
         set S($win,$var) [lindex $S(${var}s) $n]
         $win.frame.e$var icursor end
         $win.frame.e$var selection clear
       } else {                                ;# No match, try prefix
         # Size is weird: valid numbers are legal but don't display
         # unless in the font size list
         set n [lsearch -glob $S(${var}s,lcase) "$value*"]
         set bad 1
         if {$var ne "size" || ! [string is double -strict $value]} {
              set nstate disabled
            }
       }
    $win.frame.l${var}s see $n
  }
  if { !$bad } {
       ::font::show $win
     }
  $win.frame.ok config -state $nstate

  return;

};# font::tracer

#: proc ::font::show
#: arg win The toplevel font dialog window
#: desc Update the font dialog's display (the sample text) based on the font chosen.
#: return nothing
proc ::font::show {win} {
  variable S

  set S($win,result) [list $S($win,font) $S($win,size)]
  foreach x [list Bold Italic] {
    if { $x in $S($win,style) } {
         lappend S($win,result) [string tolower $x]
       }
  }
  if { $S($win,strike) } {
       lappend S($win,result) overstrike
     }
  if { $S($win,under) } {
       lappend S($win,result) underline
     }

  $S($win,sample) config -font $S($win,result)

  return;

};# font::show

package provide potato-font 1.0
