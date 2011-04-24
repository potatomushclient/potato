package provide potato-telnet 1.1

namespace eval ::potato::telnet {}

#: proc ::potato::telnet::init
#: desc Set up the initial vars used by telnet negotiation
#: return nothing
proc ::potato::telnet::init {} {
  variable tCmd;
  variable tOpt;
  variable subCmd;

  foreach {name int} [list IAC 255 DONT 254 DO 253 WONT 252 WILL 251 \
                      SB 250 GA 249 EL 248 EC 247 AYT 246 AO 244 \
                      IP 244 BRK 243 DM 242 NOP 241 SE 240 EOR 239 \
                      ABORT 238 SUSP 237 EOF 236] {
     set tCmd($int) $name
     set tCmd($name) [format %c $int]
     set tCmd($name,int) $int
  }

  foreach {x} [list \
                 [list ECHO 1 0] \
                 [list SGA  3 1] \
                 [list STATUS 5 0] \
                 [list TMRK 6 0] \
                 [list TERM 24 1] \
                 [list EOR 25 0] \
                 [list NAWS 31 1] \
                 [list TSPEED 32 0] \
                 [list FLOW 33 0] \
                 [list LINE 34 0] \
                 [list XDISP 35 0] \
                 [list ENV 36 0] \
                 [list NEWENV 39 0] \
                 [list CHARSET 42 1] \
                 [list STARTTLS 46 0] \
                 [list MSSP 70 1] \
                 [list MCP 86 0] \
                 [list MSP 90 0] \
                 [list MXP 91 0] \
               ] {
      foreach {name int will} $x {break}
      set tOpt($int) $name
      set tOpt($name) [format %c $int]
      set tOpt($int,will) $will
  }

  # Subnegotiation commands used by several options
  set subCmd(,SEND) [binary format c 1]
  set subCmd(,IS) [binary format c 0]

  # Subnegotiation commands used by CHARSET
  foreach {name int} [list REQUEST 1 ACCEPTED 2 REJECTED 3 \
                      TTABLE-IS 4 TTABLE-REJECTED 5 \
                      TTABLE-ACK 6 TTABLE-NAK 7] {
     set subCmd(CHARSET,$name) [binary format c $int]
  }

  # Subnegotiation commands used by MSSP
  foreach {name int} [list MSSP_VAR 1 MSSP_VAL 2] {
     set subCmd(MSSP,$name) [binary format c $int]
  }
  return;

};# ::potato::telnet::init

#: proc ::potato::telnet::unescape
#: arg str string to unescape
#: desc replace all double-IAC sequences with single IACs
#: return string with replacement made
proc ::potato::telnet::unescape {str} {
  variable tCmd;

  return [string map [list "$tCmd(IAC)$tCmd(IAC)" $tCmd(IAC)] $str];

};# ::potato::telnet::unescape

#: proc ::potato::telnet::escape
#: arg str string to unescape
#: desc replace all IACs with double-IACs
#: return string with replacement made
proc ::potato::telnet::escape {str} {
  variable tCmd;

  return [string map [list $tCmd(IAC) "$tCmd(IAC)$tCmd(IAC)"] $str];

};# ::potato::telnet::escape

#: proc ::potato::telnet::process
#: arg c connection id
#: arg str string received
#: desc $str has been received from connection $c. Parse out and reply to any telnet commands, and return any plain text for output. May have to buffer some of $str and wait for more input, if an incomplete telnet code is received.
#: return string with telnet commands removed
proc ::potato::telnet::process {c str} {
  upvar ::potato::conn conn;
  variable tCmd;

  if { $conn($c,telnet,state) == 0 && [string first $tCmd(IAC) $str] == -1 } {
       return $str; # We're not currently in a telnet cmd, and we don't have a new one
     }

  ::potato::addProtocol $c "telnet"

  return [process_sub_$conn($c,telnet,state) $c $str];

};# ::potato::telnet::process

#: proc ::potato::telnet::process_sub_0
#: arg c connection id
#: arg str string received
#: desc Process $str (which contains an IAC) for connection $c, possibly buffering some to wait for a complete telnet command. We're not currently processing a telnet command.
#: return The processed portions of $str for displaying
proc ::potato::telnet::process_sub_0 {c str} {
  upvar ::potato::conn conn;
  variable tCmd;

  set iac [string first $tCmd(IAC) $str]
  set len [string length $str]
  set return [string range $str 0 [expr {$iac - 1}]]
  set telnet [string range $str [expr {$iac + 1}] end]

  set conn($c,telnet,state) 1

  return "$return[process_sub_1 $c $telnet]";

};# ::potato::telnet::process_sub_0

#: proc ::potato::telnet::process_sub_1
#: arg c connection id
#: arg str string received
#: desc We've received a single IAC on connection $c. Check $str; if it's empty, return. If it starts with an IAC, return an IAC and the result of re-processing the rest of the string. If it doesn't start with an IAC, process the command it contains.
#: return Processing portions of the string to display.
proc ::potato::telnet::process_sub_1 {c str} {
  upvar ::potato::conn conn;
  variable tCmd;

  if { [string length $str] == 0 } {
       return; # can't do anything until we have more string
     }

  set cmdChar [string index $str 0]
  set remainder [string range $str 1 end]
  if { $cmdChar eq $tCmd(IAC) } {
       # We have a literal IAC. Return the literal IAC, and recurse to process the rest of the string.
       set conn($c,telnet,state) 0;# reset
       return "$tCmd(IAC)[process $c $remainder]";
     }

  # See if we recognise the first character.
  scan $cmdChar %c cmdCharCode
  if { ![info exists tCmd($cmdCharCode)] } {
       # This isn't a known telnet command. We'll just ignore it.
       set conn($c,telnet,state) 0
       return [process $c $remainder];
     }

  # We have a known telnet command. But we only do something for DO, DONT, WILL, WONT, and SB,
  # so for any other known commands, just skip them.
  if { [lsearch -exact [list $tCmd(DO) $tCmd(DONT) $tCmd(WILL) $tCmd(WONT) $tCmd(SB)] $cmdChar] == -1 } {
       set conn($c,telnet,state) 0
       return [process $c $remainder];
     }

  if { $cmdChar eq $tCmd(SB) } {
       # We have a subnegotiation
       set conn($c,telnet,state) 3
       return [process_sub_3 $c $remainder];
     } else {
       # We have a do/dont/will/wont
       set conn($c,telnet,state) 2
       set conn($c,telnet,buffer) $cmdChar
       return [process_sub_2 $c $remainder];
     }  

};# ::potato::telnet::process_sub_1

#: proc ::potato::telnet::process_sub_2
#: arg c connection id
#: arg str string to parse
#: desc We've previously received a telnet do/dont/will/wont (which is stored in the buffer for the connection). Process the command to run from $str.
#: return The remainder of $str with telnet commands parsed out
proc ::potato::telnet::process_sub_2 {c str} {
  upvar ::potato::conn conn;
  upvar ::potato::world world;
  variable tCmd;
  variable tOpt;
  variable subCmd;

  if { [string length $str] == 0 } {
       return; # nothing to process yet
     }

  set w $conn($c,world)

  set cmdChar $conn($c,telnet,buffer)
  set optChar [string index $str 0]
  set optCharCode [scan $optChar %c]
  set remainder [string range $str 1 end]

  if { $optChar == $tOpt(CHARSET) } {
       set will $world($w,encoding,negotiate)
     } elseif { $optChar == $tOpt(NAWS) } {
       set will $world($w,telnet,naws)
     } elseif { $optChar == $tOpt(TERM) } {
       set will $world($w,telnet,term)
     } elseif { $optChar == $tOpt(STARTTLS) } {
       set will [expr {0 && !0 && $world($w,telnet,ssl) && $::potato::potato(hasTLS)}]
     } else {
       set will [expr { [info exists tOpt($optCharCode)] && $tOpt($optCharCode,will) }] 
     }

  if { $cmdChar == $tCmd(DO) } {
        set response [expr {$will ? $tCmd(WILL) : $tCmd(WONT)}]
     } elseif { $cmdChar == $tCmd(DONT) } {
     } elseif { $cmdChar == $tCmd(WILL) } {
       set response [expr {$will ? $tCmd(DO) : $tCmd(DONT)}]
     } elseif { $cmdChar == $tCmd(WONT) } {
     } else {
     }

  if { [info exists response] } {
       # Send response
       ::potato::sendRaw $c "$tCmd(IAC)$response$optChar" 1
       if { $response eq $tCmd(WILL) } {
            # Register the fact we're doing this
            ::potato::addProtocol $c telnet,$tOpt($optCharCode)
            if { [llength [info commands ::potato::telnet::do_$tOpt($optCharCode)]] } {
                 # Run option-specific init
                 do_$tOpt($optCharCode) $c
               }
          }
     }

  set conn($c,telnet,buffer) ""
  set conn($c,telnet,state) 0
  return [process $c $remainder];

};# ::potato::telnet::process_sub_2

#: proc ::potato::telnet::process_sub_3
#: arg c connection id
#: arg str string to parse
#: desc A telnet subnegotiation command has been partially received. Call another proc to finish parsing the SB, based on how far we've already gotten.
#: return The remainder of $str when it's been fully parsed for telnet commands
proc ::potato::telnet::process_sub_3 {c str} {
  upvar ::potato::conn conn;

  return [process_sub_3_$conn($c,telnet,subState) $c $str];

};# ::potato::telnet::process_sub_3

#: proc ::potato::telnet::process_sub_3_0
#: arg c connection id
#: arg str string to parse
#: desc We've received a telnet subnegotiation, but not yet gotten an IAC to close it. Try and find one in $str. Buffer anything before an IAC (the entirety of $str, if there is no IAC).
#: return Any remaining pieces of $str when the telnet commands have been parsed out.
proc ::potato::telnet::process_sub_3_0 {c str} {
  upvar ::potato::conn conn;
  variable tCmd;

  set iac [string first $tCmd(IAC) $str]
  if { $iac == -1 } {
       append conn($c,telnet,buffer) $str
       return;
     }

  # Buffer anything before the IAC
  append conn($c,telnet,buffer) [string range $str 0 [expr {$iac - 1}]]

  # And then advance to the next step, to process anything after it
  set conn($c,telnet,subState) 1
  return [process_sub_3_1 $c [string range $str [expr {$iac + 1}] end]];  

};# ::potato::telnet::process_sub_3_0

#: proc ::potato::telnet::process_sub_3_1
#: arg c connection id
#: arg str string to parse
#: desc We've received a telnet subnegotiation, and an IAC. Check to see what the first char of string is. If it's an IAC, we've had IAC-IAC (literal IAC), so we need to buffer one and go back to looking for an IAC. Else, proceed.
#: return Any literal text from $str after telnet processing
proc ::potato::telnet::process_sub_3_1 {c str} {
  upvar ::potato::conn conn;
  upvar ::potato::world world;
  variable tCmd;
  variable tOpt;
  variable subCmd;

  if { [string length $str] == 0 } {
       return; # wait for more input
     }

  set w $conn($c,world)

  set firstChar [string index $str 0]
  set remainder [string range $str 1 end]

  if { $firstChar eq $tCmd(IAC) } {
       # We've had IAC-IAC (literal IAC), so we need to buffer an IAC, then go back to waiting for an IAC.
       append conn($c,telnet,buffer) $tCmd(IAC)
       set conn($c,telnet,subState) 0;# wait for IAC
       return [process_sub_3_0 $c $remainder];
     }

  if { $firstChar ne $tCmd(SE) } {
       # We've gotten IAC-<char>, but <char> isn't IAC (for a literal IAC), or SE (to end the subnegotiation).
       # Which means what we have is invalid. Abort; return the rest of $str literally. This may mean some
       # telnet commands get outputted, but we can't try and parse them because they're invalid.
       # (We could just eat them, but better to risk outputting a (broken) telnet code than eating valid output).
       set conn($c,telnet,buffer) ""
       set conn($c,telnet,state) 0
       set conn($c,telnet,subState) 0
       return $remainder;
     }

  # If we get here, we have IAC-SB-*-IAC-SE. The * is buffered; let's parse it.

  set telnet $conn($c,telnet,buffer)

  # We need IAC-SB-OPT-<str>-IAC-SE to do anything, so the buffered string must be at least 2 chars long
  if { [string length $telnet] >= 2} {
       set optChar [string index $telnet 0]
       set optCharCode [scan $optChar %c]
       set subStr [unescape [string range $telnet 1 end]]
       if { $optChar eq $tOpt(TERM) } {
            if { [string index $subStr 0] eq $subCmd(,SEND) } {
                 # Identify the client, by sending IAC-SB-TERM-IS-<name>-IAC-SE
                 if { [info exists world($w,telnet,term,as)] && [string trim $world($w,telnet,term,as)] ne "" } {
                      set clientName [escape [string map [list " " "_"] $world($w,telnet,term,as)]]
                    } else {
                      set clientName [escape "Potato"]
                    }
                 ::potato::sendRaw $c "$tCmd(IAC)$tCmd(SB)$tOpt(TERM)$subCmd(,IS)$clientName$tCmd(IAC)$tCmd(SE)" 1
               }
          } elseif { $optChar eq $tOpt(CHARSET) } {
            if { [string index $subStr 0] == $subCmd(CHARSET,REQUEST) } {
                 set sep [string index $subStr 1]
                 set charsets [string range $subStr 2 end]
                 set encodings [lsort [encoding names]]
                 foreach charset [split $charsets $sep] {
                    set charsetLower [string tolower $charset]
                    if { [set charpos [lsearch $encodings $charsetLower]] >= 0 } {
                         # Got one!
                         set cs(serverName) [escape $charset]
                         set cs(clientName) [lindex $encodings $charpos]
                         break;
                       }
                 }
                 if { [info exists cs(serverName)] } {
                       # We have a match. IAC-SB-CHARSET-ACCEPTED-<charset>-IAC-SE
                       ::potato::sendRaw $c "$tCmd(IAC)$tCmd(SB)$tOpt(CHARSET)$subCmd(CHARSET,ACCEPTED)[escape $cs(serverName)]$tCmd(IAC)$tCmd(SE)" 1
                       set conn($c,id,encoding) $cs(clientName)
                       ::potato::verbose $c [::potato::T "Encoding changed to %s" $cs(clientName)]
                    } else {
                      # No match. IAC-SB-CHARSET-REJECTED-IAC-SE
                      ::potato::sendRaw $c \
                            "$tCmd(IAC)$tCmd(SB)$tOpt(CHARSET)$subCmd(CHARSET,REJECTED)$tCmd(IAC)$tCmd(SE)" 1
                    }
               } elseif { [string index $subStr 0] == $subCmd(CHARSET,TTABLE-IS) } {
                 # We don't support TTABLE. Just send a refusal. IAC-SB-CHARSET-TTABLE_REJECTED-IAC-SE
                 ::potato::sendRaw $c "$tCmd(IAC)$tCmd(SB)$tOpt(CHARSET)$subCmd(CHARSET,TTABLE-REJECTED)$tCmd(IAC)$tCmd(SE)" 1
               }
          } elseif { $optChar eq $tOpt(MSSP) } {
            # Store MSSP info
            do_MSSP $c $subStr
          } else {
            # We don't support subnegotiation for any other commands, so do nothing.
          }
     }

  # Subnegotiation complete!
  # Reset the telnet state for the connection, and parse out the rest of the string.
  set conn($c,telnet,buffer) ""
  set conn($c,telnet,state) 0
  set conn($c,telnet,subState) 0
  return [process $c $remainder];  

};# ::potato::telnet::process_sub_3_1

proc ::potato::telnet::do_MSSP {c data} {
  upvar ::potato::conn conn;
  variable subCmd;

  foreach x [split $data $subCmd(MSSP,MSSP_VAR)] { 
    if { $x eq "" } {
         continue;
       }
    foreach {var val} [split $x $subCmd(MSSP,MSSP_VAL)] {break}
    lappend conn($c,telnet,mssp) [list $var $val]
  }

};# ::potato::telnet::do_MSSP

proc ::potato::telnet::do_NAWS {c} {
  upvar ::potato::conn conn;
  upvar ::potato::world world;
  variable tCmd;
  variable tOpt;

  set w $conn($c,world)

  set width $world($w,wrap,at)

  if { $width < 1 } {
       set width 250
     }

  set bigWidth [expr {$width / 256}]
  set smallWidth [expr {$width % 256}]

  # Always report height as 24. We could check for window resize and resend NAWS every time, but
  # there's not a whole lot of point.
  set bigHeight 0
  set smallHeight 24

  set response "$tCmd(IAC)$tCmd(SB)$tOpt(NAWS)[escape [format %c%c%c%c $bigWidth $smallWidth $bigHeight $smallHeight]]$tCmd(IAC)$tCmd(SE)"
  ::potato::sendRaw $c $response 1

  return;

};# ::potato::telnet::do_NAWS

::potato::telnet::init
