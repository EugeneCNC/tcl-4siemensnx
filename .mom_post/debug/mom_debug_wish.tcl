###############################################################################
#
# DESCRIPTION
#
# This file contains the wish commands that are part of our simple debugger.
#
# REVISIONS
#
#    09may1997    fdm       Initial
#    20may1998    MKG       better debugger.
#    04dec1998    naveen    Modified the path of wish script
#    15Jun1999    whb       Update with v15 - includes scroll bars
#                           remove puts to stdout (NO stdout on NT)
#    21Jul1999    MKG       adopt to the installed wish(my_wish).
#$HISTORY$
################################################################################
set line_num 0
set events 1
set vars 1
set addresses 1
set eventnum 0
set range 0
set from 1
set to 1
set option menu

proc step {} {
    global debug_resp_file
    set mom_debug_resp_file [open $debug_resp_file w ] 
    puts $mom_debug_resp_file 1
    close $mom_debug_resp_file
    exit
}

proc go {} {
    global debug_resp_file
    set mom_debug_resp_file [open $debug_resp_file w ] 
    puts $mom_debug_resp_file 0
    close $mom_debug_resp_file
    exit
}
 
proc addnextline { fptr } {
   global line_num
   if { [gets $fptr line] == -1 } {
      return 0
   } else {
      .lst insert end "$line"
      return 1
   }
}
   
proc OK {} {
    global events
    global vars
    global addresses
    global eventnum
    global range
    global from
    global to
    global debug_resp_file
    set mom_debug_resp_file [open $debug_resp_file w ] 
    puts $mom_debug_resp_file "$events $vars $addresses $eventnum $range $from $to"
    close $mom_debug_resp_file
    exit
}

proc CANCEL {} {
    global debug_resp_file
    set mom_debug_resp_file [open $debug_resp_file w ] 
    puts $mom_debug_resp_file "0 0 0 0 0 0 0"
    close $mom_debug_resp_file
    exit
}


for {set idx 0} {$idx < $argc} {incr idx} {if {[string last "wish.tcl" [lindex $argv $idx]] == -1} {break}}
set option [lindex $argv $idx]
set debug_resp_file [lindex $argv [expr $idx + 1]]

if { $option == "menu" } {

   frame .from
   frame .to

   button .ok -text "Ok" -command OK
   button .cancel -text "Cancel" -command CANCEL
   
   checkbutton .events -text "Events" -relief raised -variable events \
               -anchor w
   checkbutton .vars -text "Variables" -relief raised -variable vars \
               -anchor w
   checkbutton .address -text "Addresses" -relief raised -variable addresses \
               -anchor w
   checkbutton .eventnum -text "Display event numbers" -relief raised \
               -variable eventnum -anchor w
   checkbutton .range -text "Debug in range" -relief raised -variable range \
               -anchor w
   
   label .label1 -text "From Event number:" -anchor w
   label .label2 -text "  To Event number:"   -anchor w
   label .blank -text ""
   
   entry .entry1 -width 8 -relief sunken -bd 2 -textvariable from
   entry .entry2 -width 8 -relief sunken -bd 2 -textvariable to
   
   pack .events .vars .address -side top -anchor w -fill x
   pack .blank -side top -pady 1m
   pack .eventnum -side top -anchor w -fill x
   pack .range -side top -anchor w -fill x
   pack .from -side top -anchor w
   pack .to -side top -anchor w
   pack .label1 .entry1 -in .from -side left -padx 1m -pady 2m -anchor w
   pack .label2 .entry2 -in .to -side left -padx 1m -pady 2m -anchor w
   pack .ok .cancel -side left -expand 1 -fill x

} else {
   
   set fname [lindex $argv [expr $idx + 2]]
   set fp [open $fname r]
   listbox .lst -height 25 -width 80 -yscrollcommand ".scry set"
   while { [addnextline $fp] == 1 } { }
   scrollbar .scry -command ".lst yview"
   button .step -text "Step" -command step
   button .go -text "Go" -command go
   pack .scry -side right -fill y
   pack .lst -side left
   pack .step .go -side bottom
}
