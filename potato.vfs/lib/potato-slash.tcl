#: /prompt
#: Set (or clear) the prompt
::potato::define_slash_cmd prompt {

  if { $c == 0 } {
       return [list 0];
     }
  setPrompt $c $str

  return [list 1];
};# /prompt

#: /rename [<name>]
#: Set (or clear) the custom name for a connection
::potato::define_slash_cmd rename {
  variable conn;

  if { $c == 0 } {
       bell -displayof .
       return [list 0];
     }

  set name [string trim $str]
  if { $name eq "" } {
       set conn($c,name) [list 0 ""]
     } else {
       set conn($c,name) [list 1 $str]
     }
  updateConnName $c
  skinStatus $c

  return [list 1];

};# /rename

#: /null <input>
#: Return nothing; for eating the return values of other /commands.
::potato::define_slash_cmd null {

  return [list 1];

};# /null

#: /input [1|2] <stuff> - print <stuff> to input window [1|2]
::potato::define_slash_cmd input {

  set str [string trimleft $str]
  set list [split $str " "]
  # We use string comparison, not numerical, otherwise "/input 3.0 foo" will pass, but will fail
  # as we don't have conn($c,input3.0) vars.
  if { [lindex $list 0] ni [list "1" "2" "3"] } {
       return [list 0 [T "Invalid input window \"%s\": must be 1, 2 or 3" [lindex $list 0]]];
     }

  showInput $c [lindex $list 0] [join [lrange $list 1 end] " "] 1

  return [list 1];

};# /input

# /tinyurl <url> - print a TinyURL'd version of <url>
# /tinyurl <string> - replace all URLs in <string> with TinyURLs, and send modified <string> to MUSH
::potato::define_slash_cmd tinyurl {

  if { [up] == 0 } {
       bell -displayof .
       return [list 0];
     }

  set re {\m(?:(?:(?:f|ht)tps?://)|www\.)(?:(?:[a-zA-Z_\.0-9%+/@~=&,;-]*))?(?::[0-9]+/)?(?:[a-zA-Z_\.0-9%+/@~=&,;!:()-]*)(?:\?(?:[a-zA-Z_\.0-9%+/@~=&,;:!-]*))?(?:#[a-zA-Z_\.0-9%+/@~=&,;:!-]*)?}
  set where [regexp -inline -indices -all $re $str]
  if { [llength $where] == 0 } {
       send_to_real [up] $str
       return [list 0];
     }
  set all_url [regexp "^$re\$" $str]
  for {set i 0} {$i < [llength $where]} {incr i} {
    set indices [lindex $where end-$i]
    foreach {start end} $indices {break}
    set url [string range $str $start $end]
    if { [string range $url 0 2] ni [list "htt" "ftp"] } {
         set url "http://$url"
       }
    if { ![catch {TinyURL $url} result] } {
         set str [string replace $str $start $end $result]
       } else {
         errorLog "Unable to launch TinyURL at \"$url\": $result" warning
         if { !$all_url } {
              send_to_real $c $str
            }
         return [list 0 [T "Unable to launch TinyURL at \"%s\": %s" $url $result]];
       }
  }
  if { $all_url} {
       return [list 1 $str]
     } else {
       send_to_real [up] $str
     }

  return [list 1];

};# /tinyurl

#: /setprefix [[<window>=]<prefix>]
#: Set the prefix for <window>, or the current output window (if not given) to <prefix>.
::potato::define_slash_cmd setprefix {
  variable potato;
  variable conn;
  variable world;

  set w $conn($c,world)

  # Just check the Prefix Window isn't open. For simplicity, disallow
  # setting prefixes when it is.
  if { [winfo exists .prefixWin$w] } {
       bell -displayof .
       return [list 0];
     }

  # Parse str
  set window ""
  if { [string match "*=*" $str] } {
       set equals [string first "=" $str]
       set window [string range $str 0 $equals-1]
       set str [string range $str $equals+1 end]
     }
  # Validate window name
  if { $window eq "" } {
       set window [textWidgetName [activeTextWidget] $c]
     } elseif { [set window [validSpawnName $c $window]] ne "" } {
       bell -displayof .
       return [list 0];
     }

  if { $str eq "" } {
       # Clear prefix
	   set curr [lsearch -exact -nocase -index 0 $world($w,prefixes) $window]
	   if { $curr != -1 } {
	        set world($w,prefixes) [lreplace $world($w,prefixes) $curr $curr]
		  }
     } else {
       # Update prefix. We enable the new prefix, even if there
       # was an existing, disabled one.
       set curr [lsearch -exact -nocase -index 0 $world($w,prefixes) $window]
       if { $curr == -1 } {
            lappend world($w,prefixes) [list $window $str 1]
          } else {
            set world($w,prefixes) [lreplace $world($w,prefixes) $curr $curr [list $window $str 1]]
          }
     }

  return [list 1];

};# /setprefix

#: /print <str>
#: Print <str> as a system message
::potato::define_slash_cmd print {

  outputSystem $c $str
  return [list 1];

};# /print

#: /at <time>=<action>
#: At [clock scan <time>] send <action> to the MUSH
::potato::define_slash_cmd at {
  variable conn;

  set equals [string first "=" $str]
  if { $equals == -1 } {
       return [list 0 [T "Format: /at <time>=<string>"]];
     }
  set time [string range $str 0 $equals-1]
  set action [string range $str $equals+1 end]
  if { [catch {clock scan $time} inttime] } {
       return [list 0 "/at: $inttime"];
     }

  set now [clock seconds]
  if { $now >= $inttime } {
       return [list 0 [T "/at: Time must be in the future."]];
     }
  set when [expr {($inttime - [clock scan "now"]) * 1000}]
  lappend conn($c,userAfterIDs) [set afterid [after $when [list ::potato::send_to $c $action]]]

  after [expr {$when + 1200}] [list ::potato::cleanup_afters $c]
  if { $recursing } {
       return [list 1 $afterid]
     }
  return [list 1 [T "Command will run at %s, id %s" [clock format $inttime -format "%D %T"] $afterid]]

};# /at

#: /debug [--on | --off | --toggle]
#: Show the Debug Packets window
::potato::define_slash_cmd debug {
  variable conn;

  if { $c == 0 } {
       bell -displayof .
       return [list 0];
     }

  if { $str eq "--on" } {
       set conn($c,debugPackets) 1
     } elseif { $str eq "--off" } {
       set conn($c,debugPackets) 0
     } else {
       set conn($c,debugPackets) [lindex [list 1 0] $conn($c,debugPackets)]
     }

  return [list 1];

};# /debug

#: /runmacro <macro>
#: Run the given macro
::potato::define_slash_cmd runmacro {
  variable world;
  variable conn;

  set w $conn($c,world)

  set argList [list]
  set onearg ""
  if { [set equals [string first "=" $str]] == -1 } {
       set macro $str
     } elseif { 1 } {
       set macro $str
     } else {
       set macro [string range $str 0 $equals-1]
       set argstr [string range $str $equals+1 end]
       while { [string length $argstr] } {
         break;
       }
     }

  if { [info exists world($w,macro,$macro)] } {
       set do $w,macro,$macro
     } elseif { [info exists world(0,macro,$macro)] } {
       set do 0,macro,$macro
     } else {
       return [list 0 [T "No such macro \"%s\"." $str]];
     }

  send_to $c $world($do)

  return [list 1];

};# /runmacro

#: /cancelat <id>
#: Cancel a previous /at using the after id given by /at
::potato::define_slash_cmd cancelat {
  variable conn;

  if { $str ni $conn($c,userAfterIDs) } {
       return [list 0 [T "Invalid /at ID."]];
     }

  after cancel $str
  cleanup_afters $c
  return [list 1 [T "/at cancelled."]];

};# /cancelat

#: /addspawn <spawn>
#: Add the specified spawn to the spawn-all list for the connection
::potato::define_slash_cmd addspawn {
  variable conn;

  set lc [string tolower $str]
  if { [string length $lc] && $lc ni $conn($c,spawnAll) } {
       lappend conn($c,spawnAll) $lc
     }
  return [list 1];

};# /addspawn

#: /delspawn <spawn>
#: Delete the specified spawn from the spawn-all list for the connection
::potato::define_slash_cmd delspawn {
  variable conn;

  set pos [lsearch -exact -nocase $conn($c,spawnAll) $str]
  if { $pos != -1 } {
       set conn($c,spawnAll) [lreplace $conn($c,spawnAll) $pos $pos]
     }
  return [list 1];

};# /delspawn

#: /limit [-<options>][ -- ]<pattern>
#: Filter output based on the given options and pattern
::potato::define_slash_cmd limit {
  variable conn;

  if { ![info exists conn($c,textWidget)] || ![winfo exists $conn($c,textWidget)]} {
       bell -displayof .
       return;
  }

  set t $conn($c,textWidget)

  if { ![string length $str] } {
       # Just report whether we have a /limit atm
       if { [llength [$conn($c,textWidget) tag nextrange limited 1.0 end]] } {
            return [list 1 1];
          } else {
            return [list 1 0];
          }
     }

  $t tag remove "limited" 1.0 end
  set conn($c,limited) [list]

  set invert 0
  set matchType "glob"
  set case 1

  set list [split $str " "]
  set len [llength $list]

  # Parse off args
  set cont 0
  set i 0
  for {set i 0} {$i < $len} {incr i} {
    if { $cont } {
         set cont 0
         continue;
       }
    set x [lindex $list $i]
    if { ![string match "-*" $x] } {
         break; # not an "-option"
       }
    switch -nocase -exact -- $x {
       -v {set invert 1}
       -a {# in TF, -a means "lines that have attributes". Whatever that is. Be nice to TF users and ignore it}
       -msimple -
       -literal {set matchType literal}
       -mglob -
       -glob -
       -wildcard {set matchType glob}
       -mregexp -
       -regexp {set matchType regexp}
       -nocase {set case 0}
       -spawn {incr i ; set spawn [lindex $list $i]}
       -- {incr i ; break;}
       default {return [list 0 [T "Invalid option \"%s\" to /limit" $x]];}
    }
  }

  set str [join [lrange $list $i end] " "]
  if { $str eq "" } {
       return [list 1];
     }

  if { [info exists spawn] } {
       # Spawn matching text to a new window
      if { [set spawn [validSpawnName $spawn 1]] eq "" } {
           return [list 0 [T "Invalid Spawn Name"]];
         } elseif { [set find [findSpawn $c $spawn]] != -1 } {
           return [list 0 [T "Spawn already exists."]];
         } else {
           # Create the spawn window
           set sinfo [createSpawnWindow $c $spawn]
           set sout [lindex $sinfo 1]
           set invert [expr {!$invert}]
         }
    }

  set case [lindex [list -nocase] $case]

  switch -exact -- $matchType {
    regexp  {set command [list regexp]}
    literal {set command [list string equal]}
    glob    {set command [list string match]}
  }

  # OK, do limiting.
  for { set i [$t count -lines 1.0 end]} {$i > 0} {incr i -1} {
    if { "system" in [$t tag names $i.0] } {
         continue;
       }
    set line [$t get -displaychars $i.0 "$i.0 lineend"]
    if { [catch {{*}$command {*}$case $str $line} match] } {
         return [list 0 [T "Invalid %s pattern \"%s\": %s" $matchType $str $match]];
       }
    if { ($invert ? $match : !$match) } {
         if { [info exists sout] } {
              # Copy to new spawn window
              puts "Copying $line"
              set dump [$t dump -text -tag $i.0 "$i.0 lineend+1char"]
              set tags [$t tag names $i.0]
              foreach {type data pos} $dump {
                switch -exact $type {
                  tagon  { if { $data ni $tags } { lappend tags $data }}
                  tagoff { set tags [lreplace $tags [set ind [lsearch -exact $tags $data]] $ind] }
                  text   { $sout insert 1.0 $data $tags}
                }
              }
            } else {
              $t tag add limited $i.0 "$i.0 lineend+1char"
            }
       }
  }

  if { ![info exists sout] } {
       set conn($c,limited) [list $matchType $invert $case $str]
     }

  return [list 1];

};# /limit

#: /unlimit
#: Show all output, when output is reduced by /limit
::potato::define_slash_cmd unlimit {
  variable conn;

  if { [info exists conn($c,textWidget)] && [winfo exists $conn($c,textWidget)] } {
       $conn($c,textWidget) tag remove limited 1.0 end
     }

  set conn($c,limited) [list]

  return [list 1];

};# /unlimit

#: /cls [<c>]  |  /cls [<c>.][<window>]
#: Clear the <window> output window for conn <c>, defaulting to _main and the current connection respectively
::potato::define_slash_cmd cls {
  variable conn;

  if { !$full } {
       bell -displayof .
       return [list 0 [T "/cls cannot be abbreviated."]];# too risky to allow an abbreviation
     }

  if { $str eq "" } {
       set window "_main"
     } elseif { [string is integer -strict $str] } {
       set c $str
       set window "_main"
     } elseif { [regexp -nocase {^(?:([0-9]+)\.)?\.?(_main|[a-zA-Z][a-zA-Z0-9_-]{0,49})?$} $str {} c2 window] } {
       # (Yes, this regexp actually allows for two '.'s between world num and window name. This is because I'm
       #  too lazy to rewrite it more neatly at present to match 'X.Y', 'X.', '.Y' or 'Y'. Maybe later.) #abc
       if { $c2 ne "" } {
            set c $c2
          }
     } else {
       bell -displayof .
       return [list 0 [T "/cls: Invalid window name."]];# invalid window name
     }

  if { ![info exists conn($c,textWidget)] } {
       bell -displayof .
       return [list 0 [T "/cls: Invalid connection."]];# bad connection
     }

  if { $window eq "_main" || $window eq "" || [set pos [findSpawn $c $window]] != -1 } {
       if { ![info exists pos] } {
            set t $conn($c,textWidget)
          } else {
            set t [lindex $pos 1]
          }
       clearOutputWindow $c $t
     } else {
       return [list 0 [T "/cls: No such window."]]
     }

  return [list 1];

};# /cls

#: /send <str>
#: Send <str> to the connection
::potato::define_slash_cmd send {

  send_to_real $c $str
  return [list 1];

};# /send

#: /all <str>
#: Send <str> to all connections
::potato::define_slash_cmd all {

  foreach x [connList] {
    send_to_real [lindex $x 0] $str
  }
  return [list 1];

};# /all

#: /show <c>  |  /show [<c>.]<window>
#: Show <window> in connection <c>, defaulting to <main> and current connection
::potato::define_slash_cmd show {
  variable conn;


  if { [string trim $str] eq "" } {
       return [list 0];
     }

  if { [string is integer -strict $str] } {
       # Just got a connection number
       showConn $str
       return [list 1];
     } elseif { [regexp -nocase {^(?:([0-9]+)\.)?(.+?)$} $str {} c2 window] } {
       # We have an optional connection number, and a valid spawn name
       if { $c2 eq "" } {
            set c2 $c
          }
       set str $window
     } else {
       set c2 $c
     }
  if { [set window [validSpawnName $window]] eq "" || [findSpawn $c2 $window] == -1 } {
       return [list 0]
     }
  # $window may signify the main text widget, but by using showSpawn not showConn we
  # request the skin show the main text widget, if it's not already doing so.
  showSpawn $c2 $window
  return [list 1];

};# /show

#: /slash
#: Print a list of all /commands
::potato::define_slash_cmd slash {
  variable world;

  set list [list]
  foreach x [info procs ::potato::slash_cmd_*] {
     lappend list [string range $x 20 end]
  }
  set return [T "Available slash commands: %s" [itemize [lsort -dictionary $list]]]
  set w [connInfo $c world]
  if { $w != 0 && [llength $world($w,slashcmd)] } {
       append return "\n" [T "User-defined commands for this world: %s" [itemize [lsort -dictionary $world($w,slashcmd)]]]
     }
  if { [llength $world(0,slashcmd)] } {
       append return "\n" [T "Global User-defined commands: %s" [itemize [lsort -dictionary $world(0,slashcmd)]]]
     }

  return [list 1 $return];

};# /slash

#: /set <varname>=<value>
#: Set a connection-local variable <varname> (accessed in /commands as $<varname>$ to <value>
::potato::define_slash_cmd set {

  setUserVar $c 0 $str
  return [list 1];

};# /set

#: /unset <varname>
#: Unset the connection-local variable <varname>
::potato::define_slash_cmd unset {

  unsetUserVar $c 0 $str
  return [list 1];

};# /unset

#: /get [-all|-global|-local] <varname>
#: Return the value of the given variable
::potato::define_slash_cmd get {
  variable world;
  variable conn;

  set local 1
  set global 1

  if { [info exists conn($c,world)] } {
       set w $conn($c,world)
       array set masterVars [list _u [up] \
                                  _c $c \
                                  _w $w \
                                  _name $world($w,name) \
                                  _host $world($w,host) \
                                  _port $world($w,port) \
                                  _char $conn($c,char) \
                            ] ;# array set masterVars
     } else {
       array set masterVars [list _u [up] \
                                  _c 0 \
                                  _w 0 \
                                  _name "Potato" \
                                  _host "unknown" \
                                  _port 0 \
                                  _char "" \
                            ] ;# array set masterVars
     }

  upvar 1 $_vars vars;
  if { [info exists vars] && [array exists vars] } {
       array set masterVars [array get vars]
     }

  if { [set space [string first " " $str]] != -1 } {
       set switch [string range $str 0 $space-1]
       set str [string range $str $space+1 end]
       if { $x eq "-local" } {
            set global 0
          } elseif { $x eq "-global" } {
            set local 0
          } elseif { $x ne "-all" } {
            return [list 0 "/get: Invalid switch \"$switch\": Must be one of -all, -global or -local"];
          }
     }

  if { [info exists masterVars($str)] } {
       return [list 1 $masterVars($str)];
     } elseif { $local && [info exists conn($c,uservar,$str)] } {
       return [list 1 $conn($c,uservar,$str)];
     } elseif { $global && [info exists conn(0,uservar,$str)] } {
       return [list 1 $conn(0,uservar,$str)];
     } else {
       return [list 0];
     }

};# /get

#: /time [<format>]
::potato::define_slash_cmd time {

  set cmd [list clock format [clock seconds]]
  if { [string length $str] } {
       lappend cmd -format $str
     }

  if { [catch {{*}$cmd} output] } {
       return [list 0 ???];
     } else {
       return [list 1 $output];
     }

};# /time

#: /vars [-all|-global|-local]
#: Print a list of all, global or local vars
::potato::define_slash_cmd vars {
  variable conn;

  set local 0
  set global 0

  foreach x [split $str " "] {
    if { $x eq "-all" } {
         set local 1
         set global 1
       } elseif { $x eq "-local" } {
         set local 1
       } elseif { $x eq "-global" } {
         set global 1
       } else {
         return [list 0 "/vars: Invalid arg \"$x\": Must be one of -all, -global or -local"];
       }
  }

  set return ""

  if { !($global || $local) } {
       set local 1
       set global 1
     }

  if { $local && $c != 0 } {
       append return "World vars:"
       foreach x [lsort -dictionary [removePrefix [array names conn $c,uservar,*] $c,uservar]] {
         append return "\n\t$x\t$conn($c,uservar,$x)"
       }
       if { $global } {
            append return "\n"
          }
     }

  if { $global || ($local && $c == 0) } {
       append return "Global vars:"
       foreach x [lsort -dictionary [removePrefix [array names conn 0,uservar,*] 0,uservar]] {
         append return "\n\t$x\t$conn(0,uservar,$x)"
       }
     }

  return [list 1 $return];

};# /vars

#: /setglobal <varname>=<value>
#: Set a global (all connections) variable <varname> to <value>
::potato::define_slash_cmd setglobal {

  setUserVar $c 1 $str
  return [list 1];

};# /setglobal

#: /unsetglobal <varname>
#: Unset global var <varname>
::potato::define_slash_cmd unsetglobal {

  unsetUserVar $c 1 $str
  return [list 1];

};# /unsetglobal

#: /edit
#: Show the Edit Settings window
::potato::define_slash_cmd edit {
  variable conn;

  if { $c == 0 } {
       taskRun programConfig
     } else {
       taskRun config $conn($c,world) $conn($c,world)
     }
  return [list 1];

};# /edit

#: /tcl
#: Show the Tcl code console if available
::potato::define_slash_cmd tcl {

  if { [catch {console show}] } {
       return  [list 0];
     }

  return [list 1];

};# /tcl

#: /reload
#: Reload the main Potato code file and the custom file.
::potato::define_slash_cmd reload {
  variable path;

  if { [catch {source [file join $path(vfsdir) lib potato.tcl]} err] } {
       return [list 0 $err];
     }
  set files [list potato.tcl]
  if { [file exists $path(custom)] } {
       if { [catch {source $path(custom)} err] } {
            return [list 0 $err];
          } else {
            lappend files [file tail $path(custom)]
          }
     }

  return [list 1 [T "%s reloaded successfully." [itemize $files]]];

};# /reload

#: /eval <code>
#: Evaluate the Tcl code <code> and print the result to the output window
::potato::define_slash_cmd eval {

  set err [catch {uplevel #0 $str} msg]
  if { $err } {
       bell -displayof .
       if { !$recursing } {
            set msg [T "Error (%d): %s" [string length $msg] $msg]
          }
       return [list 0 $msg];
     }

  if { !$recursing } {
       set msg [T "Return (%d): %s" [string length $msg] $msg]
     }
  return [list 1 $msg];

};# /eval

#: /speedwalk <dirs>
#: Speedwalk in the given directions. <dirs> is a string in the format [<number>][ ]<direction>[[ ][<numberN>][ ]<directionN>]
::potato::define_slash_cmd speedwalk {

  if { ![regexp {^ *([0-9]+ *([ns][ew]|[nsweudo]) *)+ *$} $str] } {
       return [list 0 [T "Invalid speedwalk command"]];
     }

  set dirs [list n north s south w west e east nw northwest ne northeast sw southwest se southeast \
                 u up d down o out]
  foreach {all num dir} [regexp -all -inline -- { *([0-9]+)? *((?:[ns][ew]|[nsewudo])) *} $str] {
     set which [expr {[lsearch -exact $dirs $dir] + 1}]
     for {set i 0} {$i < $num} {incr i} {
       send_to_real $c [lindex $dirs $which]
     }
  }

  return [list 1];

};# /speedwalk

#: /log  |  /log -close [<path>] |  /log [-options] <path>
#: Either show the logging window, close open log(s) or start logging to a new file
::potato::define_slash_cmd log {
  variable conn;

  if { $c == 0 } {
       return [list 0];
     }

  # Check for no options given
  if { [string trim $str] eq "" } {
       taskRun log $c $c
       return [list 1];
     }

  # Check for "/log -close"
  set argv [split $str " "]
  set argc [llength $argv]

  if { [lsearch -exact -nocase [list -close -stop -off] [lindex $argv 0]] != -1 } {
       # Close an open log file, or all open log files
       set res [taskRun logStop $c $c [join [lrange $argv 1 end] " "] 1]
       if { $res == 0 } {
            return [list 0];
          } elseif { $res == -1 } {
            return [list 0 [T "Log file \"%s\" not found." [join [lrange $argv 1 end] " "]]];
          } elseif { $res == -2 } {
            return [list 0 [T "Log file \"%s\" is ambiguous." [join [lrange $argv 1 end] " "]]];
          } else {
            return [list 1 $res];
          }
     }

  # Try and parse out options...
  array set options [list -buffer "_main" -append 1 -leave 1 -timestamps 0 -html 0 -input 0]
  set error ""
  set finished 0
  set file [list]
  set needOpt 1
  set i 0
  foreach x $argv {
     incr i
     if { [string length $error] } {
          break;
        }
     if { $finished } {
          lappend file $x
        } else {
          if { $needOpt } {
               # Looking for an -option, not a value
               if { $x eq "--" } {
                    set finished 1
                    continue;
                  } elseif { $x eq "" } {
                    continue;
                  } else {
                    set match [array names options "$x*"]
                    if { [llength $match] == 0 } {
                         if { $i == $argc || ![string match "-*" $x] } {
                              set finished 1
                              lappend file $x
                            } else {
                              set error [T "Unknown option \"%s\"" $x]
                              break;
                            }
                       } elseif { [llength $match] > 1 } {
                         set error [T "Ambiguous option \"%s\"" $x]
                       } else {
                         set needOpt 0
                       }
                  }
              } else {
                # Looking for a value to the option $match
                if { $match in [list "-append" "-leave" "-timestamps" "-html" "-input"] } {
                     if { [string is boolean -strict $x] } {
                          set options($match) [string is true -strict $x]
                        } else {
                          set error [T "Invalid setting \"%s\" for \"%s\"" $x $match]
                          break;
                        }
                   } elseif { $match eq "-buffer" } {
                     set options(-buffer) $x;# name of a spawn window
                   }
                set needOpt 1
              }
        }
     }

  if { $error ne "" } {
       return [list 0 "/log: $error"];
     }

  set file [join $file " "]
  if { $file eq "" } {
       # Gahhhh. Why did I write all that parsing code if you DIDN'T GIVE A FILE?!
       taskRun log $c $c
       return [list 1];
     }

  doLog $c $file $options(-append) $options(-buffer) $options(-leave) $options(-timestamps) $options(-html) $options(-input)
  return [list 1];

};# /log

#: /close
#: Close the current connection
::potato::define_slash_cmd close {

  taskRun close $c $c

  return [list 1];

};# /close

#: /connect <worldname>
#: Connect to the saved world <worldname>
::potato::define_slash_cmd connect {
  variable world;
  variable misc;

  if { [string trim $str] eq "" } {
       if { $c == 0 } {
            return [list 0];
          } else {
            taskRun $c reconnect
          }
       return [list 1];
     }
  switch [parseConnectRequest $str] {
     1 {return [list 1];}
     0 {return [list 0 [T "No such world \"%s\". Use \"/quick host port\" to connect to a world that isn't in the address book." $str]];}
    -1 {return [list 0 [T "Ambiguous world name \"%s\"." $str]];}
  }

};# /connect

#: /quick [<host>:<port>]
#: Connect to the given address, or show the Quick Connect window
::potato::define_slash_cmd quick {

  set hostAndPort [parseTelnetAddress $str]
  if { [llength $hostAndPort] == 2 } {
       # Make the new world, and connect to it.
       set host [lindex $hostAndPort 0]
       set port [lindex $hostAndPort 1]
       newConnection [addNewWorld "$host:$port" $host $port 1]
     } else {
       # Pop up the "quick connect" dialog.
       potato::newWorld 1
     }

  return [list 1];

};# /quick

#: /exit
::potato::define_slash_cmd exit {

  if { $full } {
       set prompt 0
     } else {
       set prompt -1
     }
  taskRun exit $c $prompt
  return [list 1];

};# /exit

#: /reconnect [<character>]  |  /reconnect <connection>
#: Reconnect the current, possibly as <character>, or reconnect in connection <connection>
::potato::define_slash_cmd reconnect {
  variable conn;
  variable world;

  set w $conn($c,world)
  if { $str eq "" } {
       taskRun reconnect
     } elseif { [string is integer -strict $str] && [info exists conn($str,id)] && $str > 0 } {
       taskRun reconnect $c $str
     } elseif { $str eq "none" } {
       set conn($c,char) ""
       taskRun reconnect
     } elseif { [set chars [lsearch -exact -index 0 $world($w,charList) $str]] != -1 ||
                [set chars [lsearch -exact -nocase -index 0 $world($w,charList) $str]] != -1 } {
       if { [llength $chars] != 1 } {
            return [list 0 [T "Ambiguous character name \"%s\"" $str]];
          } else {
            set conn($c,char) [lindex $world($w,charList) [list $chars 0]]
            taskRun reconnect
          }
     } else {
       return [list 0 [T "Invalid connection id/character name"]];
     }

  return [list 1];

};# /reconnect

#: /disconnect
#: Disconnect the current connection
::potato::define_slash_cmd disconnect {

  taskRun disconnect
  return [list 1];

};# /disconnect

#: /toggle [<direction>]
#: Toggle the shown connection forward/backwards one connection
::potato::define_slash_cmd toggle {

  if { $str in [list "down" "-1"] } {
       taskRun prevConn
     } else {
       taskRun nextConn
     }
  return [list 1];

};# /toggle

#: /web <address>
#: Launch a web browser to show <address>
::potato::define_slash_cmd web {

  launchWebPage $str
  return [list 1];

};# /web

#: /history [<number>]
#: Show the history window, or place the <number>th history item into the input window
::potato::define_slash_cmd history {
  variable conn;

  if { [string trim $str] eq "" } {
       after idle [list ::potato::taskRun inputHistory $c $c]
     } elseif { [string is integer -strict [set num [string trim $str]]] } {
       if { $num < 1 } {
            if { [llength $conn($c,inputHistory)] > [expr {abs($num)}] } {
                 # use "end-abs($num)" rather than end$num in case $num is 0
                 set pos "end-[expr {abs($num)}]"
               } else {
                 return [list 0 [T "/history: Invalid position"]];
               }
          } elseif { [set pos [lsearch -index 0 $conn($c,inputHistory) $num]] == -1 } {
            return [list 0 [T "/history: Invalid position"]];
          }
       if { [focus -displayof $conn($c,input2)] eq $conn($c,input2) } {
            set input 2
          } else {
            set input 1
          }
       showInput $c $input [string map [list \b \n] [lindex $conn($c,inputHistory) $pos 1]] 1
     }

  return [list 1];

};# /history
