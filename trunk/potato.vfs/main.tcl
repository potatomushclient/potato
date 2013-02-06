#!/usr/bin/tclsh

  if { [catch {package require starkit}] } {
       lappend auto_path [file normalize [file join [file dirname [info script]] lib app-potato]]
      lappend auto_path [file normalize [file join [file dirname [info script]] lib treeviewUtils]]
     } else {
       starkit::startup
     }
  package require app-potato

