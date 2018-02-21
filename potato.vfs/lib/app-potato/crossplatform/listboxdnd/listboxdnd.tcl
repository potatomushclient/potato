namespace eval ::ListboxDnD {
	variable data;
	variable state;
}

bind ListboxDnD <1> [list ::ListboxDnD::start %W %x %y]
bind ListboxDnD <Escape> "[list ::ListboxDnD::cancel %W %x %y];break"
bind ListboxDnD <B1-Motion> [list ::ListboxDnD::drag %W %x %y]
bind ListboxDnD <ButtonRelease-1> [list ::ListboxDnD::stop %W %x %y]

# Enable listbox $lb to be re-ordered with drag and drop
# Possible args:
#	-command $cmd   -   run $cmd after the list has been rearranged, replacing %W with the window path
proc ::ListboxDnD::enable {lb {args}} {
	variable data;
	if { ![winfo exists $lb] || [winfo class $lb] ne "Listbox" } {
		return 0;
	}
	set bt [bindtags $lb]
	if { [set bti [lsearch -exact $bt "Listbox"]] < 0 } {
		return 0;
	}
	foreach {x y} $args {
		if { $x eq "-command" } {
			if { $y eq "" } {
				unset -nocomplain data($lb,-command)
			} else {
				set data($lb,-command) $y
			}
		} else {
			error "Invalid option $x: Must be -command"
		}
	}
	if { "ListboxDnD" in $bt } {
		return 1;# already done
	}
	bindtags $lb [linsert $bt $bti+1 "ListboxDnD"]
	return 1;
};#enable

# Called on B1 press to set up for a drag
proc ::ListboxDnD::start {lb x y} {
	variable state;
	if { [$lb cget -state] ne "normal" || [$lb cget -selectmode] ni [list "single" "multiple"] } {
		return;
	}
	
	set _listvar [$lb cget -listvariable]
	if { $_listvar eq "" } {
		return;
	}
	upvar #0 $_listvar listvar
	if { ![info exists listvar] || [llength $listvar] < 2 } {
		return;
	}
	
	set state($lb,list) $listvar
	set state($lb,startindex) [$lb index @$x,$y]
	set state($lb,currindex) $state($lb,startindex)
	set state($lb,startsel) [$lb curselection]
	
	return;
};# start

# Called on B1 motion, as an item is being dragged
proc ::ListboxDnD::drag {lb x y} {
	variable state;
	
	set _listvar [$lb cget -listvariable]
	if { $_listvar eq "" || ![info exists state($lb,list)] } {
		return;
	}
	upvar #0 $_listvar listvar
	
	set newpos [$lb nearest $y]
	set oldpos $state($lb,currindex)
	if { $newpos == $oldpos } {
		return;
	}
	set sel [$lb curselection]
	if { $oldpos in $sel && $newpos ni $sel } {
		$lb selection clear $oldpos
		$lb selection set $newpos
	} elseif { $oldpos ni $sel && $newpos in $sel } {
		$lb selection clear $newpos
		$lb selection set $oldpos
	}
	set newlist $listvar
	set oldval [lindex $newlist $oldpos]
	set newval [lindex $newlist $newpos]
	set newlist [lreplace $newlist $oldpos $oldpos $newval]
	set newlist [lreplace $newlist $newpos $newpos $oldval]
	set listvar $newlist
	set state($lb,currindex) $newpos

	return;
};# drag

# Called when Escape is pressed; cancel a drag
proc ::ListboxDnD::cancel {lb x y} {
	variable state;
	
	if { ![info exists state($lb,list)] } {
		return;
	}
	
	set _listvar [$lb cget -listvariable]
	if { $_listvar eq "" } {
		return;
	}
	upvar #0 $_listvar listvar
	set listvar $state($lb,list)
	$lb selection clear 0 end
	foreach x $state($lb,startsel) {
		$lb selection set $x
	}
	
	array unset state $lb,*
	
	return;
};# cancel

# Called on B1 release; finalise a drag
proc ::ListboxDnD::stop {lb x y} {
	variable state;
	variable data;
	
	if { ![info exists state($lb,startindex)] } {
		return; # drag was cancelled
	}
	
	set start $state($lb,startindex)
	set curr $state($lb,currindex)
	array unset state $lb,*
	if { $start == $curr } {
		return;# Wasn't dragged anyway
	}
		
	if { [info exists data($lb,-command)] } {
		catch {uplevel #0 [string map [list %W $lb %s $start %c $curr] $data($lb,-command)]}
	}
	
	return;
};# stop

package provide ListboxDnD 1.2

