#!/usr/bin/tclsh

  lappend auto_path [file normalize [file join [file dirname [info script]] lib]]

  if { ![catch {package require starkit}] } {
       starkit::startup
     }
  package require app-potato

