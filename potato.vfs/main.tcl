#!/usr/bin/tclsh

  cd [file dirname [info script]]
  if { [catch {package require starkit}] } {
       lappend auto_path [file normalize [file join [file dirname [info script]]] lib app-potato]]
     } else {
       starkit::startup
     }
  package require app-potato

