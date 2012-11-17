
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

  # OPTION-NAME TELNET-CODE WILL? RFC
  foreach {x} [list \
                 [list ECHO 1 0 857] \
                 [list SGA  3 1 858] \
                 [list STATUS 5 0 859] \
                 [list TIMING-MARK 6 0 860] \
                 [list TTYPE 24 1 1091] \
                 [list EOR 25 0 885] \
                 [list NAWS 31 1 1073] \
                 [list TERMINAL-SPEED 32 0 1079] \
                 [list FLOW 33 0 1372] \
                 [list LINE 34 0 1184] \
                 [list XDISP 35 0 1096] \
                 [list ENV 36 0 1401] \
                 [list NEWENV 39 0 1572] \
                 [list CHARSET 42 1 2066] \
                 [list STARTTLS 46 0 ???] \
                 [list MSSP 70 1 ???] \
                 [list MCP 86 0 ???] \
                 [list MSP 90 0 ???] \
                 [list MXP 91 0 ???] \
               ] {
      foreach {name int will rfc} $x {break}
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

#: proc ::potato::telnet::bufferAdd
#: arg c connection id
#: arg s string to add
#: desc Add the string $str to the buffer of text ready for the MUSH for conn $c. This buffer is held until we have a complete line.
#: return nothing
proc ::potato::telnet::bufferAdd {c str} {
  upvar ::potato::conn conn;

  append conn($c,telnet,buffer,line) $str;

  return;

};# ::potato::telnet::bufferAdd

#: proc ::potato::telnet::bufferGet
#: arg c connection id
#: desc Remove and return all the complete lines of text in the buffer for conn $c - including their trailing linebreaks.
#: return Completed lines of text, if any
proc ::potato::telnet::bufferGet {c} {
  upvar ::potato::conn conn;
  upvar ::potato::world world;

  if { [set linebreak [string last $conn($c,id,lineending) $conn($c,telnet,buffer,line)]] == -1 } {
       return; # no complete lines
     } else {
       set retval [string range $conn($c,telnet,buffer,line) 0 [expr {$linebreak+$conn($c,id,lineending,length)-1}]];# includes the lineending
       set conn($c,telnet,buffer,line) [string range $conn($c,telnet,buffer,line) "$linebreak+$conn($c,id,lineending,length)" end]
       if { $retval ne "" && $conn($c,telnet,afterPrompt) } {
            set conn($c,telnet,afterPrompt) 0
            if { $world($conn($c,world),telnet,prompt,ignoreNewline) && [string first $conn($c,id,lineending) $retval] == 0 } {
                 set retval [string range $retval $conn($c,id,lineending,length) end]
               }
          }
       return $retval;
     }

};# ::potato::telnet::bufferGet

#: proc ::potato::telnet::process
#: arg c connection id
#: arg str string received
#: desc $str has been received from connection $c. Parse out and reply to any telnet commands,
#: desc and return any plain text for output. May have to buffer some of $str and wait for
#: desc more input, if an incomplete telnet code is received.
#: return whole lines of string with telnet commands parsed out
proc ::potato::telnet::process {c str} {
  upvar ::potato::conn conn;
  variable tCmd;

  if { $conn($c,telnet,state) == 0 && [string first $tCmd(IAC) $str] == -1 } {
       bufferAdd $c $str
       return [bufferGet $c]; # We're not currently in a telnet cmd, and we don't have a new one
     }

  ::potato::addProtocol $c "telnet"

  return "[process_sub_$conn($c,telnet,state) $c $str][bufferGet $c]";

};# ::potato::telnet::process

#: proc ::potato::telnet::process_sub_0
#: arg c connection id
#: arg str string received
#: desc Process $str (which contains an IAC) for connection $c, possibly buffering some to wait for a complete telnet command. We're not currently processing a telnet command.
#: return whole lines of string with telnet commands parsed out
proc ::potato::telnet::process_sub_0 {c str} {
  upvar ::potato::conn conn;
  variable tCmd;

  set iac [string first $tCmd(IAC) $str]
  set len [string length $str]
  bufferAdd $c [string range $str 0 [expr {$iac - 1}]]
  set telnet [string range $str [expr {$iac + 1}] end]

  set conn($c,telnet,state) 1

  return [process_sub_1 $c $telnet];

};# ::potato::telnet::process_sub_0

#: proc ::potato::telnet::process_sub_1
#: arg c connection id
#: arg str string received
#: desc We've received a single IAC on connection $c. Check $str; if it's empty, return. If it starts with an IAC, return an IAC and the result of re-processing the rest of the string. If it doesn't start with an IAC, process the command it contains.
#: return whole lines of string with telnet commands parsed out
proc ::potato::telnet::process_sub_1 {c str} {
  upvar ::potato::conn conn;
  upvar ::potato::world world;
  variable tCmd;

  if { [string length $str] == 0 } {
       return; # can't do anything until we have more string
     }

  set cmdChar [string index $str 0]
  set remainder [string range $str 1 end]
  if { $cmdChar eq $tCmd(IAC) } {
       # We have a literal IAC. Buffer the literal IAC, and recurse to process the rest of the string.
       set conn($c,telnet,state) 0;# reset
       bufferAdd $c $tCmd(IAC)
       return [process $c $remainder];
     }

  # See if we recognise the first character.
  scan $cmdChar %c cmdCharCode
  if { ![info exists tCmd($cmdCharCode)] } {
       # This isn't a known telnet command. We'll just ignore it.
       set conn($c,telnet,state) 0
       return [process $c $remainder];
     }

  # We have a known telnet command. But we only do something for DO, DONT, WILL, WONT, SB,
  # and maybe GA, so for any other known commands, just skip them.
  set goodCmds [list $tCmd(DO) $tCmd(DONT) $tCmd(WILL) $tCmd(WONT) $tCmd(SB)]
  if { $world($conn($c,world),telnet,prompts) } {
       lappend goodCmds $tCmd(GA)
     }
  if { [lsearch -exact $goodCmds $cmdChar] == -1 } {
       set conn($c,telnet,state) 0
       return [process $c $remainder];
     }

  if { $cmdChar eq $tCmd(SB) } {
       # We have a subnegotiation
       set conn($c,telnet,state) 3
       return [process_sub_3 $c $remainder];
     } elseif { $cmdChar eq $tCmd(GA) } {
       # Display everything since the last newline as a prompt
       set lastNewline [string last $conn($c,id,lineending) $conn($c,telnet,buffer,line)]
       if { $lastNewline == -1 } {
            # The entire thing is the prompt
            set prompt $conn($c,telnet,buffer,line)
            set conn($c,telnet,buffer,line) ""
          } else {
            # Save anything up to - and including - the last \n
            set prompt [string range $conn($c,telnet,buffer,line) $lastNewline+$conn($c,id,lineending,length) end]
            set conn($c,telnet,buffer,line) [string range $conn($c,telnet,buffer,line) 0 [expr {$lastNewline+$conn($c,id,lineending,length)-1}]]
          }
       set conn($c,telnet,afterPrompt) 1
       ::potato::setPrompt $c $prompt
       set conn($c,telnet,state) 0
       set conn($c,telnet,buffer,codes) ""
       return [process $c $remainder];
     } else {
       # We have a do/dont/will/wont
       set conn($c,telnet,state) 2
       set conn($c,telnet,buffer,codes) $cmdChar
       return [process_sub_2 $c $remainder];
     }
  return;

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

  set cmdChar $conn($c,telnet,buffer,codes)
  set optChar [string index $str 0]
  set optCharCode [scan $optChar %c]
  set remainder [string range $str 1 end]

  if { $optChar == $tOpt(CHARSET) } {
       set will $world($w,encoding,negotiate)
     } elseif { $optChar == $tOpt(NAWS) } {
       set will $world($w,telnet,naws)
     } elseif { $optChar == $tOpt(TTYPE) } {
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

  set conn($c,telnet,buffer,codes) ""
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
       append conn($c,telnet,buffer,codes) $str
       return;
     }

  # Buffer anything before the IAC
  append conn($c,telnet,buffer,codes) [string range $str 0 [expr {$iac - 1}]]

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
       append conn($c,telnet,buffer,codes) $tCmd(IAC)
       set conn($c,telnet,subState) 0;# wait for IAC
       return [process_sub_3_0 $c $remainder];
     }

  if { $firstChar ne $tCmd(SE) } {
       # We've gotten IAC-<char>, but <char> isn't IAC (for a literal IAC), or SE (to end the subnegotiation).
       # Which means what we have is invalid. Abort; buffer the rest of $str literally. This may mean some
       # telnet commands get outputted, but we can't try and parse them because they're invalid.
       # (We could just eat them, but better to risk outputting a (broken) telnet code than eating valid output).
       set conn($c,telnet,buffer,codes) ""
       set conn($c,telnet,state) 0
       set conn($c,telnet,subState) 0
       bufferAdd $c $remainder
       return;
     }

  # If we get here, we have IAC-SB-*-IAC-SE. The * is buffered; let's parse it.

  set telnet $conn($c,telnet,buffer,codes)

  # We need IAC-SB-OPT-<str>-IAC-SE to do anything, so the buffered string must be at least 2 chars long
  if { [string length $telnet] >= 2} {
       set optChar [string index $telnet 0]
       set optCharCode [scan $optChar %c]
       set subStr [unescape [string range $telnet 1 end]]
       if { $optChar eq $tOpt(TTYPE) } {
            if { [string index $subStr 0] eq $subCmd(,SEND) } {
                 # Identify the client, by sending IAC-SB-TTYPE-IS-<name>-IAC-SE
                 if { [info exists world($w,telnet,term,as)] && [string trim $world($w,telnet,term,as)] ne "" } {
                      set clientName [escape [string map [list " " "_"] $world($w,telnet,term,as)]]
                    } else {
                      set clientName [escape "Potato"]
                    }
                 ::potato::sendRaw $c "$tCmd(IAC)$tCmd(SB)$tOpt(TTYPE)$subCmd(,IS)$clientName$tCmd(IAC)$tCmd(SE)" 1
               }
          } elseif { $optChar eq $tOpt(CHARSET) } {
            if { [string index $subStr 0] == $subCmd(CHARSET,REQUEST) } {
                 set sep [string index $subStr 1]
                 set charsets [string range $subStr 2 end]
                 set encodings [lsort [encoding names]]
                 foreach charset [split $charsets $sep] {
                    set charsetLower [string tolower $charset]
                    if { [string range $charsetLower 0 3] eq "iso-" } {
                         # Pesky Tcl, not using the first -
                         set charsetISO "iso[string range $charsetLower 4 end]"
                       }
                    if { [set charpos [lsearch $encodings $charsetLower]] >= 0 || ([info exists charsetISO] && [set charpos [lsearch $encodings $charsetISO]] >= 0) } {
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
  set conn($c,telnet,buffer,codes) ""
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

  return;

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

proc ::potato::telnet::send_keepalive {c} {
  upvar ::potato::conn conn;
  variable tCmd;

  set keepalive "$tCmd(IAC)$tCmd(NOP)"

  ::potato::sendRaw $c $keepalive 1

  return;
};# ::potato::telnet::send_keepalive

::potato::telnet::init

package provide potato-telnet 1.1
