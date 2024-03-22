#!/usr/local/bin/wish
##############################################################################
# REVISIONS
#   Date       Who              Reason
#   2/11/98    mjz              Created
#   2/11/98    mjz              Added a counter for the Event to assist in file
#                               seeks.
#   3/25/98    HW (UG-Colonge)  add  proc_data file
#   6/10/98    Naveen (Cypress) changed debug_data file to review_data file
#   6/12/98    Naveen (Cypress) add debug_data file
#   8/04/98    Naveen (Cypress) Fixed some problems
# 10-Jun-1999   whb     remove puts to stdout (NO stdout on NT)
# 15-Jun-1999   whb     use "delete file" not "exec rm"
# 13-Jul-1999   whb     correctly delete files using MOM_remove_file.
# 07/21/1999   MKG      adopt to the installed wish(my_wish).
# 13-apr-2000  satya    added lsort to sort the variables of the events in an
#                       alphabetical order
# 07/22/2009   gsl  PR6165649  Remove review_data & proc_data here instead of mom_review.tcl
# 01/24/2011   gsl      Display data output directory in the title of review tool dialog
#                       It's set in mom_review.tcl.
# 04/21/2011   gsl      Changed UG to NX
#
# 12/12/12     gsl  (nx900) Showing active directory in error messages
# 12/19/12     gsl          Also display data file name in dialog's title
# 02/12/13     gsl          Submitted to nx9 ip8
#
#$HISTORY$
##############################################################################
#
# Set this first line if wish is not in your path
###############################################################################
#
#  Daten fuer BOX 1 ermitteln und ausgeben
#  Determine and output data for BOX 1
#
###############################################################################

proc show_box1 {} \
{
  # global box1 box2 LIST_EVENT STR_LG VAR_SEARCH
  global box1
  global box2
  global LIST_EVENT
  global STR_LG
  global VAR_SEARCH

  global LIST_VARIABLE
  global box2_flag 
  # global TEMP_LIST_EVENT TEMP_LIST_OUT TEMP_LIST_VAR
  global TEMP_LIST_EVENT
  global TEMP_LIST_OUT
  global TEMP_LIST_VAR

  global range
  global ok_flag

  set VAR_FLAG 0
  set index 0

  set event_index  [ $::box2 curselection ]

  if { [ string length $event_index  ] == 0 } \
  {
      set ::VAR_SEARCH  " "
      set VAR_FLAG 2
  } else \
  {
      set event_string [ $::box2 get $event_index ]

      if { [string index $event_string 0] == "V" } \
      {
          set POS  [expr [string first "=" $event_string ] -2 ]
          set ::VAR_SEARCH [string range $event_string 2 $POS]
          set ::box2_flag 1
          set VAR_FLAG 1
      }
  }

  if { $VAR_FLAG == 1 } \
  {
     # Daten in Box1 loeschen
     # Delete data in Box1
     # -----------------------
     $::box1 delete 0 end
   
     # Label in Box1 setzen
     # Set label in Box1
     # -----------------------
     set TEXT "  Var: "
     set POS [ expr $::STR_LG -10 ]
     # .box1.text config -text "[ format %-${POS}s $TEXT ]proc in Post  = $::VAR_SEARCH"
     .box1.text config -text "$TEXT  =  $::VAR_SEARCH"
     update idletasks
         
     # Daten in Box1 ausgeben
     # Output data in Box1
     # -----------------------
     if {$::ok_flag == 0 } \
     {
        foreach LINE_ENV  $::LIST_EVENT \
        {
           set EVENT [lindex $LINE_ENV 0]
           set POS [expr [string length $EVENT ] -2]
           set EVENT_OUT [string range $EVENT 0 [ expr $POS -1] ]
           set VAR_OUT [string range $EVENT $POS end]
           set VAR_LIST [lindex $::LIST_VARIABLE $index]
            foreach LINE_VAR  $VAR_LIST \
            {
                # nach variablen suchen
                set POS  [expr [string first "=" $LINE_VAR ] -2 ]
                set LINE [string range $LINE_VAR 2 $POS]
                if { [string compare "$::VAR_SEARCH" "$LINE"] == 0 } \
                {
                   set VAR_OUT "$VAR_OUT [string range $LINE_VAR [expr $POS + 2 ] end ]"
                }
            }

            $::box1 insert end "[ format %-${STR_LG}s $EVENT_OUT ] $VAR_OUT "
            # $::box1 insert end "$EVENT_OUT $VAR_OUT" 
            incr index
         }
    } elseif {$ok_flag == 1} \
    {
       foreach LINE_ENV  $TEMP_LIST_EVENT \
       {
          set EVENT [lindex $LINE_ENV 0]
          set POS [expr [string length $EVENT ] -2]
          set EVENT_OUT [string range $EVENT 0 [ expr $POS -1] ]
          set VAR_OUT [string range $EVENT $POS end]
          set VAR_LIST [lindex $TEMP_LIST_VAR $index]
           foreach LINE_VAR  $VAR_LIST \
           {
               # nach variablen suchen
               set POS  [expr [string first "=" $LINE_VAR ] -2 ]
               set LINE [string range $LINE_VAR 2 $POS]
               if { [string compare "$::VAR_SEARCH" "$LINE"] == 0 } \
               {
                  set VAR_OUT "$VAR_OUT [string range $LINE_VAR [expr $POS + 2 ] end ]"
               }
           }

           $::box1 insert end "[ format %-${STR_LG}s $EVENT_OUT ] $VAR_OUT "
           #  $::box1 insert end "$EVENT_OUT $VAR_OUT" 
           incr index
        }
    }
  } elseif { $VAR_FLAG == 2} \
  {
     # Daten in Box1 loeschen
     # -----------------------
     $::box1 delete 0 end
   
     # Label in Box1 setzen
     # -----------------------
     set TEXT "  Var: "
     set POS [ expr $::STR_LG -10 ]
     # .box1.text config -text "[ format %-${POS}s $TEXT ]proc in Post  = $::VAR_SEARCH"
     .box1.text config -text "$TEXT  =  $::VAR_SEARCH"
     update idletasks

      if {$ok_flag == 0 } \
      {
         foreach LINE_ENV  $::LIST_EVENT \
         {
            set EVENT [lindex $LINE_ENV 0]
            set POS [expr [string length $EVENT ] -2]
            set EVENT_OUT [string range $EVENT 0 [ expr $POS -1] ]
            set VAR_OUT [string range $EVENT $POS end]
            $::box1 insert end "[ format %-${STR_LG}s $EVENT_OUT ] $VAR_OUT"
         }
      } elseif {$ok_flag == 1} \
      {
         foreach LINE_ENV  $TEMP_LIST_EVENT \
         {
            set EVENT [lindex $LINE_ENV 0]
            set POS [expr [string length $EVENT ] -2]
            set EVENT_OUT [string range $EVENT 0 [ expr $POS -1] ]
            set VAR_OUT [string range $EVENT $POS end]
            $::box1 insert end "[ format %-${STR_LG}s $EVENT_OUT ] $VAR_OUT"
         }
      
      }
  } 
}
###############################################################################
#
#  Daten fuer BOX 2 ermitteln und ausgeben
#  Determine and output data for BOX 2
#
###############################################################################
proc show_box2 {}\
{
  global box1 box2 box3 LIST_EVENT LIST_VARIABLE VAR_SEARCH LIST_OUT
  global box3_flag box2_flag index
  global range
  global TEMP_LIST_OUT TEMP_LIST_EVENT TEMP_LIST_VAR
  global MASTER_LINO TEMP_LINO
  global ok_flag
  set start_hig 0
  set end_hig 0

  if {$box3_flag == 1} \
  {
      set event_index $::index
      $::box1 yview $::index
  } else \
  {
      set event_index  [ $box1 curselection ]
  }

  set event_string [ $box1 get $event_index ]
  # evt.variable aus event_string weglesen
  # --------------------------------------
  set TEST [ expr [ string first "=" $event_string  ] -1 ]
  if { $TEST > 0 } \
  { set event_string [ string  range $event_string 0 $TEST ] }
  
  # evt. "NOT in POST" an  event_string anhaengen
  # ---------------------------------------------
  set POS  [ expr [ string length $event_string ] - 3 ]
  set TEST [ string range $event_string  $POS [expr $POS + 1 ] ]
  set DUM  "[ string range $event_string 0 [expr $POS - 1 ]]"

  if { [ string compare "$TEST"  "NO" ] == 0  } \
  { set event_string $DUM }
  

  # Daten in Box2 loeschen
  # -----------------------
  $::box2 delete 0 end

  # Label in Box2 setzen
  # -----------------------
  
  set FIN_STR [ string range $event_string 0 [expr $POS - 3 ]]
  .box2.text config -text "  Event : $FIN_STR"
  update idletasks
      
  # Daten in Box2 ausgeben
  # -----------------------
  if {$ok_flag == 0 } \
  {
     set VAR [ lindex $::LIST_VARIABLE $event_index ]
     set EVENT [ lindex $::LIST_EVENT $event_index ]
  } elseif {$ok_flag == 1} \
  {

     set VAR [ lindex $TEMP_LIST_VAR $event_index ]
     set EVENT [ lindex $TEMP_LIST_EVENT $event_index ]
  }

  set EVE_NAME [ lindex $EVENT 0]
  $::box2 insert end "EVENT :  $EVE_NAME"

# Sorting the variables list

  set VAR [lsort -ascii $VAR]

  foreach LINE  $VAR  \
  { 
      $::box2 insert end "$LINE"
  }
  
  if { $box3_flag != 1 } \
  {
      set event_no 0
      set start 0
      if { $ok_flag == 0 } \
      {
         set event_length [llength $MASTER_LINO]
         for {set i $event_index} {$event_no <= $event_index && \
               $i <= $event_length} {incr i} \
         {
             set event_no [lindex $MASTER_LINO $i]
             if {$event_no == $event_index && $start == 0} \
             {
                  set start_hig $i
                  set start 1
             } 
         }

         set end_hig [expr $i - 2]
                
      } elseif {$ok_flag == 1} \
      {
           set event_length [llength $TEMP_LINO]
           for {set i $event_index} {$event_no <= $event_index && \
                 $i <= $event_length} {incr i} \
           {
               set event_no [lindex $TEMP_LINO $i]
               if {$event_no == $event_index && $start == 0} \
               {
                    set start_hig $i
                    set start 1
               } 
           }
                 
                    set end_hig [expr $i - 2]
      }
        
      $::box3 selection set $start_hig $end_hig
      $::box3 yview [ expr $start_hig - 3]     
      if {$::box2_flag == 1} \
      {
             show_box1
             set box2_flag 0
      }
   }

   set box3_flag 0
}  

###############################################################################
#
#  Daten fuer BOX 3 ermitteln und ausgeben
#  Determine and output data for BOX 3
#
###############################################################################
proc show_box3 {}\
{
  global box1 box2 box3 
  global box3_flag index
  global MASTER_LINO TEMP_LINO
  global range
  global ok_flag

  set event_index  [ $::box3 curselection ]
  set event_string [ $::box3 get $event_index ]
  
  if {$ok_flag == 0 } \
  {
     set index [lindex $MASTER_LINO $event_index]
  } elseif {$ok_flag == 1} \
  {
     set index [lindex $TEMP_LINO $event_index]
  }

   .box3.text config -text "       Post Output"
   set box3_flag 1
   show_box2

}  

###############################################################################
#
# proc user_exit
#
###############################################################################
proc user_exit {} \
{
   exit
}

#############################################################################
#
# proc make_list
#
############################################################################
proc make_list {} \
 {
   global LIST_EVENT STR_LG LIST_OUT LIST_VARIABLE
   global TEMP_LIST_EVENT TEMP_LIST_OUT TEMP_LIST_VAR
   global LIST_PROC TEMP_LINO
   global box3 box2
   global range
   global from
   global to
   global debug_data
   global ok_flag
   global total_no_events
   set start_list 0
   set TEMP_LIST_OUT ""
   set TEMP_LIST_EVENT ""
   set TEMP_LIST_VAR ""
   set event_no 0

# Debugdaten auf Listen einlesen
# ------------------------------
 
     $::box2 delete 0 end
     $::box3 delete 0 end

   if {$ok_flag == 1} \
   {
     if { [ info exists TEMP_LIST_EVENT ] == 1} \
      {
         set TEMP_LIST_EVENT ""
      }
     if { [ info exists TEMP_LIST_OUT ] == 1} \
      {
         set TEMP_LIST_OUT ""
      }
     if { [ info exists TEMP_LIST_VAR ] == 1} \
      {
         set TEMP_LIST_VAR ""
      }
     if { [info exists TEMP_LINO ] == 1} \
      {
         set TEMP_LINO ""
      }

      if {$to > $total_no_events} {
        set to $total_no_events
      }

     for {set i $from} {$i <= $to} {incr i} \
     {
        set TEMP_STR [ lindex $::LIST_EVENT $i ]
        lappend TEMP_LIST_EVENT $TEMP_STR 
        set TEMP_OUT [ lindex $LIST_OUT $i ]
        foreach LINE $TEMP_OUT \
        {
           lappend TEMP_LINO $event_no
        }
        lappend TEMP_LIST_OUT $TEMP_OUT
        set TEMP_VAR [ lindex $::LIST_VARIABLE $i ]
        lappend TEMP_LIST_VAR $TEMP_VAR
        incr event_no
     }
  
  }

  
   set TEST [ show_box1 ]

  if {$ok_flag == 1} \
  {

     foreach OUTPUT $TEMP_LIST_OUT \
     {
       foreach NAME $OUTPUT \
       {
          set TEST [ expr [ string first "=" $NAME ] +2 ]
          if { $TEST > 0 } \
           { set NAME [ string  range $NAME $TEST end]
           }
                $::box3 insert end $NAME
       }
     }
  } elseif {$ok_flag == 0 } {
     foreach OUTPUT $LIST_OUT \
     {
       foreach NAME $OUTPUT \
       {
          set TEST [ expr [ string first "=" $NAME ] +2 ]
          if { $TEST > 0 } \
           { set NAME [ string  range $NAME $TEST end]
           }
                $::box3 insert end $NAME
       }
     }
  }
 
}
##############################################################################
#
#  proc range_proc
#
##############################################################################
proc range_proc {} \
{
  global range
  global from
  global to
  global prev_from
  global prev_to
  global ok_flag
  global total_no_events

  if {$range == 1 } \
  {
         set ok_flag 1
     if {$prev_from != $from || $prev_to != $to} \
     {

        if {$from < 0 || $from > $total_no_events || $to < $from} {
             error " Invalid range specified "
             return
        }
         make_list
         set prev_from $from
         set prev_to $to
     }
  } elseif {$range == 0} \
  {
      set ok_flag 0
      make_list
      set from 0
      set to 0
      set prev_from $from
      set prev_to $to
      set range -1
  }

}

###############################################################################
#
#                           H A U P T P R O G R A M M 
#                           M A I N  P R O G R A M 
#
###############################################################################
# 
# this sets the output file variable
# IT MUST BE SET THE SAME IN THE debug_listbox.tcl SCRIPT
#

for { set idx 0 } { $idx < $argc } { incr idx } \
{
   if { [string last "wish.tcl" [lindex $argv $idx]] == -1 } {
      break
   }
}

set debug_data [lindex $argv $idx]
set proc_data [lindex $argv [expr $idx + 1]]
set box3_flag 0
set box2_flag 0
set index 0
set range -1
set from 0
set to 0
set prev_from 0
set prev_to 0
set TEMP_LIST_EVENT ""
set TEMP_LIST_VAR ""
set TEMP_LINO ""
set TEMP_LIST_OUT ""
set FIRST_EVENT 0
set event_no 0
set before_motion_flag 0
set ok_flag 0
set total_no_events 0

#  Start create window
#----------------------
#<01-24-11 gsl>
wm title . "NX/Post Review Tool - [pwd]/$debug_data"

frame .box1
menubutton .box1.text -text "List of event's:"
scrollbar .box1.y -orient vertical -command [list .box1.pick yview]
scrollbar .box1.x -orient horizontal -command [list .box1.pick xview]
set box1 [listbox .box1.pick -width 30 -height 30 -borderwidth 5 -bg white \
         -fg black -relief sunken -setgrid true \
         -selectmode single\
         -yscrollcommand [list .box1.y set]\
         -xscrollcommand [list .box1.x set] ]

frame .box2
menubutton .box2.text -text "please pick one event in the left window"
scrollbar .box2.y -orient vertical -command [list .box2.pick yview]
scrollbar .box2.x -orient horizontal -command [list .box2.pick xview]
set box2 [listbox .box2.pick -width 30 -height 30 -borderwidth 5 -bg white \
         -fg black -relief sunken -setgrid true \
         -selectmode single\
         -yscrollcommand [list .box2.y set]\
         -xscrollcommand [list .box2.x set] ]

frame .box3
menubutton .box3.text -text "        Post Output "
scrollbar .box3.y -orient vertical -command [list .box3.pick yview]
scrollbar .box3.x -orient horizontal -command [list .box3.pick xview]
set box3 [listbox .box3.pick -width 30 -height 30 -borderwidth 5 -bg white \
         -fg black -relief sunken -setgrid true \
         -selectmode single\
         -yscrollcommand [list .box3.y set]\
         -xscrollcommand [list .box3.x set] ]

frame .buttons 
checkbutton .buttons.range -text "  Range Of Events  " -variable range -anchor w
label .buttons.from -text "  From  "
entry .buttons.frentry -width 5 -relief sunken -bd 2 -textvariable from
label .buttons.to -text "  To  "
entry .buttons.toentry -width 5 -relief sunken -bd 2 -textvariable to
button .buttons.ok -text "  OK  " -command range_proc
button .buttons.quit -text "  Exit  " -command user_exit
pack .buttons.range .buttons.from .buttons.frentry .buttons.to \
     .buttons.toentry .buttons.ok -side left -fill both
pack .buttons.quit -side right -fill both      ;#-fill both 
pack .buttons -side bottom             ;#-fill both 


pack .box1.text  -in .box1  -side top -anchor nw 
pack .box1.x -side bottom  -fill both
pack .box1.pick  -side left -expand 1 -fill both 
pack .box1.y -side right  -fill both

pack .box2.text -in .box2  -side top -anchor nw 
pack .box2.x -side bottom -fill both 
pack .box2.pick  -side left -expand 1 -fill both 
pack .box2.y -side right  -fill both 

pack .box3.text -in .box3  -side top -anchor nw 
pack .box3.x -side bottom  -fill both 
pack .box3.pick  -side left -expand 1 -fill both 
pack .box3.y -side right  -fill both 

pack .box1 .box2 .box3 -side left -expand 1 -fill both 
# pack .box1 .box2 .box3 -side left

bind $::box1 <ButtonRelease-1> show_box2
bind $::box2 <ButtonRelease-1> show_box1
bind $::box3 <ButtonRelease-1> show_box3

# Procdaten auf Listen einlesen
# -------------------------
  if [catch {open $proc_data r} FP1] \
  { 
    tk_messageBox -type ok -icon error\
                  -message "Can't open data file \"[pwd]\" $proc_data"

    catch { MOM_remove_file $proc_data }

exit

  } else \
  { 
    while { [eof $FP1] != 1 } \
    {
      gets $FP1 procline
      lappend LIST_PROC  "$procline"
    }
    close $FP1

    catch { MOM_remove_file $proc_data }
  }


# Debugdaten auf Listen einlesen
# ------------------------------
  if [catch {open $debug_data r} FP2] \
  {
    tk_messageBox -type ok -icon error\
                  -message "Can't open data file \"[pwd]\" $debug_data \n$errorInfo"

    catch { MOM_remove_file $debug_data }

exit

  } else \
  {
    set STR_LG 0
    set output_flag 0
    while { [eof $FP2] != 1 } \
    {
      gets $FP2 dataline
      if { [string index $dataline 0] == "E" } \
      {
        set STR_L [ string length $dataline ]
        if { $STR_L > $::STR_LG } { set STR_LG $STR_L }

        # test ob proc in post
        #---------------------
        if { $output_flag != 0 } \
        {
          if { [ info exists EVENT_OUT ] == 0 } \
          {
            lappend EVENT_OUT " No Output From Event "
            lappend MASTER_LINO [ expr $event_no - 1 ]
          }
          if {$before_motion_flag == 0} \
          {
            lappend LIST_OUT "$EVENT_OUT"
          }
          unset EVENT_OUT
        }

        set TEST_STRING [ string trimleft $dataline  "E " ]
        set POS  [expr [string first " " $TEST_STRING ] -1 ]
        set TEST_STRING [ string range $TEST_STRING 0 $POS ]
        set TEST_PROC [ lsearch $LIST_PROC $TEST_STRING ]
        if { $TEST_PROC >= 0 } { set TEST_PROC "+ " } { set TEST_PROC "NO" }

        set STRING [ string trimleft $dataline  "E " ]
        set fin_dataline "$STRING $TEST_PROC"
        if { [ info exists LIST_ENV ] == 0 && $FIRST_EVENT != 0} \
        {
          lappend LIST_ENV  " Variables Are Not Available"
        }

        if { [ info exists LIST_ENV ] == 1 } \
        {
          if { $before_motion_flag == 0 } \
          {
            lappend LIST_VARIABLE $LIST_ENV
          }
          unset LIST_ENV                         ;# alles Loeschen
        }
        if { $TEST_STRING != "MOM_before_motion" } \
        {
          lappend LIST_EVENT  "[ list $fin_dataline ]"
          set before_motion_flag 0
          incr event_no
        } else {
          set before_motion_flag 1
        }
        set output_flag 1
        set FIRST_EVENT 1

      } else \
      {
        # variablen einlesen
        if { [string index $dataline 0] == "V" } \
        {
          set TEST_STRING [ string trimleft $dataline  "V" ]
          lappend LIST_ENV  "V: $TEST_STRING"
        } elseif { [string index $dataline 0] == "A" } \
        {
          set TEST_STRING [ string trimleft $dataline  "A" ]
          lappend LIST_ENV  "Address:  $TEST_STRING"
        } elseif { [string index $dataline 0] == "O" } \
        {
          lappend EVENT_OUT "$dataline"
          lappend MASTER_LINO [ expr $event_no - 1 ]
        }
      }
    }

    if { [ info exists EVENT_OUT ] == 0 } \
    {
      lappend EVENT_OUT " No Output From Event"
    }
    lappend LIST_OUT "$EVENT_OUT"
    lappend MASTER_LINO [ expr $event_no - 1 ]
    unset EVENT_OUT

    if { [ info exists LIST_ENV ] == 0 && $FIRST_EVENT != 0 } \
    {
      lappend LIST_ENV  " Variables Are Not Available"
    }

    lappend LIST_VARIABLE $LIST_ENV
    unset LIST_ENV                         ;# alles Loeschen

    close $FP2
    global LIST_EVENT LIST_VARIABLE STR_LG LIST_OUT
    global MASTER_LINO
    set total_no_events [expr $event_no - 1]

    catch { MOM_remove_file $debug_data }
  }

  # Erster Aufruf Box1
  #--------------------
  set TEST [ show_box1 ]

  foreach OUTPUT $LIST_OUT \
  {
    foreach NAME $OUTPUT \
    {
      set TEST [ expr [ string first "=" $NAME ] +2 ]
      if { $TEST > 0 } \
      {
        set NAME [ string range $NAME $TEST end ]
      }
      $::box3 insert end $NAME
    }
  }


