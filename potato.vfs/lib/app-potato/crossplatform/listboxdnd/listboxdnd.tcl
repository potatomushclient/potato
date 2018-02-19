namespace eval ::ListboxDnD {
	variable data;
}

bind ListboxDnD <1> [list ::ListboxDnD::start %W %x %y]
bind ListboxDnD <Escape> [list ::ListboxDnD::cancel %W %x %y]
bind ListboxDnD <B1-Motion> [list ::ListboxDnD::drag %W %x %y]
bind ListboxDnD <ButtonRelease-1> [list ::ListboxDnD::stop %W %x %y]

proc ::ListboxDnD::enable {lb} {
	if { ![winfo exists $lb] || [winfo class $lb] ne "Listbox" } {
		return 0;
	}
	set bt [bindtags $lb]
	if { [set bti [lsearch -exact $bt "Listbox"]] < 0 } {
		return 0;
	}
	if { "ListboxDnD" in $bt } {
		return 1;# already done
	}
	bindtags $lb [linsert $bt $bti+1 "ListboxDnD"]
	return 1;
};#enable

proc ::ListboxDnD::start {lb x y} {
	variable data;
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
	
	set data($lb,list) $listvar
	set data($lb,startindex) [$lb index @$x,$y]
	set data($lb,currindex) $data($lb,startindex)
	set data($lb,startsel) [$lb curselection]
	
	return;
};# start

proc ::ListboxDnD::drag {lb x y} {
	variable data;
	
	set _listvar [$lb cget -listvariable]
	if { $_listvar eq "" || ![info exists data($lb,list)] } {
		return;
	}
	upvar #0 $_listvar listvar
	
	set newpos [$lb nearest $y]
	set oldpos $data($lb,currindex)
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
	set data($lb,currindex) $newpos

	return;
};# drag

proc ::ListboxDnD::cancel {lb x y} {
	variable data;
	
	if { ![info exists data($lb,list)] } {
		return;
	}
	
	set _listvar [$lb cget -listvariable]
	if { $_listvar eq "" } {
		return;
	}
	upvar #0 $_listvar listvar
	set listvar $data($lb,list)
	$lb selection clear 0 end
	foreach x $data($lb,startsel) {
		$lb selection set $x
	}
	
	array unset data $lb,*
	
	return;
};# cancel

proc ::ListboxDnD::stop {lb x y} {
	variable data;
	
	array unset data $lb,*
	
	return;
};# stop

package provide ListboxDnD 1.0
	