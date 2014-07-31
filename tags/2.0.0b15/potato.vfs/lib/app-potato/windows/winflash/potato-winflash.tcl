
if { ![package vsatisfies [package require Tk] 8.6-] } {
     if { [catch {load [file join [file dirname [info script]] flash85.dll] flash} err errdict] } {
          ::potato::errorLog "Unable to load flash85.dll: $err" error [::potato::errorTrace $errdict]
          return;
        }
   } elseif { [catch {load [file join [file dirname [info script]] "Winflash_[::potato::checkbits]bit.dll"] flash} err errdict] } {
     ::potato::errorLog "Unable to load winflash dll: $err" error [::potato::errorTrace $errdict]
     return;
   }

package provide potato-winflash 1.1
