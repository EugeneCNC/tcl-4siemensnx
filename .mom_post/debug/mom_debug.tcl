###############################################################################
#
# DESCRIPTION
#
# This file contains the variables and procs that enable a simple debugger.
# If this facility is desired then this file should be 'source'd into the
# desired TCL script. 
#
# This simple debugger:
#
#     1) records the setting of each variable in the TCL interpreter by a 
#        MOM_TCL (or child) object;
#     2) records the executing of each event in the TCL interpreter by a 
#        MOM_TCL (or child) object;
#     3) creates a complete listing of (1) and (2) in a file whose name is 
#        given by mom_debug_fname_all
#     4) creates a listing of (1) and (2) for only the current event in a file
#        whose name is given by mom_debug_fname_cur and then calls a wish
#        shell to put up a dialog with that information.
#     5) allows the user to 'step' while in (4) or 'go' while in (4). If the
#        user selects 'step' then (4) is repeated for each event. If the user
#        selects 'go' then (4) is not performed again.
#     6) allows the user to report Definition File Parse Errors and TCL
#        script execution errors
#
# REVISIONS
#
#      Date       Who       Reason
#    09may1997    fdm       Initial
#    29may1997    fdm       Allow for there to be no wish script
#    17dec1997    fdm       Add on_parse_error and on_event_error
#    20May1998    MKG       better debugger.
#    24Jun1998    whb       do not output before_motion
#    31Jul1998    whb       do not output catch_warning
#    04Dec1998    naveen    Modified the path of wish script
#    06Feb1999    bmp       Changed the Environment variable
# 15-Jun-1999   whb     remove puts to stdout (NO stdout on NT)
# 13-Jul-1999   whb     correctly delete files using MOM_remove_file.
# 21-Jul-1999   MKG         adopt to the installed wish(my_wish).
#$HISTORY$
################################################################################
# 
# These control where the output is written.
#
#   The complete trace
set mom_debug_fname_all "mom_debug_all.out"
#   The current event for dialog
set mom_debug_fname_cur "mom_debug_cur.out"

# This controls the name of the wish script
set mom_debug_wish_script "[MOM_ask_env_var UGII_CAM_DEBUG_DIR]mom_debug_wish.tcl"
set my_wish "[MOM_ask_env_var UGII_CAM_AUXILIARY_DIR]ugwish"

set file_all_offset1 0
set seek_flag 0
set mom_debug_init_done 0
set mom_debug_file_all ""
set mom_debug_file_current ""
set mom_debug_do_wish 0
set mom_debug_done_heading 0
set mom_debug_events 1
set mom_debug_vars   1
set mom_debug_addrs  1
set mom_debug_num_flag 0
set mom_debug_range_flag 0
set mom_debug_range_lower 0
set mom_debug_range_upper 0
set mom_debug_event_num 0

set new_date [clock seconds]
set debug_resp_file debug_resp_${new_date}_file

set DEBUG 0

if { $DEBUG } {
   set debug_err_file "mom_debug_err_file"
   set mom_debug_err_file [open "$debug_err_file" w ]
}

#This proc also exists in the main event handler to be used if debug is not
#sourced. We repeat it here so that this file is self-contained.
proc MOM__print_line_context {filename linenum context ofile} {
   set fl [open $filename r]
   set from [expr $linenum-$context]
   set to [expr $linenum+$context]
   set current 1

   if { $from < 1 } { set from 1 }

   while { $current <= $to && [gets $fl line] >= 0 } {
     if { $current >= $from && $current <= $to } {
        puts $ofile "${current}: $line"
     }
     set current [incr current]
   }

   close $fl
}

proc MOM__debug_do_heading {} {
   global mom_part_name
   global mom_logname
   global mom_date
   global mom_debug_file_all
   global mom_debug_done_heading

   if { $mom_debug_done_heading == 1 } { return }
 
   puts $mom_debug_file_all "Debug Output for TASK: $mom_part_name"
   puts $mom_debug_file_all "Created By:    $mom_logname"
   puts $mom_debug_file_all "Creation Date: $mom_date"
   set aa [info tclversion]
   puts $mom_debug_file_all "tcl version: $aa"
   puts $mom_debug_file_all "==============================================="

   set mom_debug_done_heading 1
}

proc MOM_before_each_event {} {
   global debug_resp_file
   global file_all_offset1
   global seek_flag
   global mom_debug_wish_script
   global mom_debug_file_all
   global mom_debug_file_current
   global mom_debug_fname_cur
   global mom_debug_event_name
   global mom_debug_do_wish
   global mom_debug_done_heading
   global mom_debug_events mom_debug_range_flag mom_debug_event_num 
   global mom_debug_range_lower mom_debug_range_upper mom_debug_num_flag
   global mom_debug_err_file
   global DEBUG
   global my_wish

   incr mom_debug_event_num

   if { $mom_debug_events == 0 } { return }
#MKG/WHB
   if { $mom_debug_event_name == "MOM_before_output" ||
        $mom_debug_event_name == "MOM_before_motion" ||
        $mom_debug_event_name == "MOM_catch_warning" } { return }

   if { $DEBUG } { puts $mom_debug_err_file "Entering MOM_before_each_event with Event: $mom_debug_event_name" }

   if { $mom_debug_range_flag == 1 } {
      if { $mom_debug_event_num < $mom_debug_range_lower || \
           $mom_debug_event_num > $mom_debug_range_upper } { return }
   }

   if { $mom_debug_done_heading == 0 } { MOM__debug_do_heading }

   if { $mom_debug_num_flag == 1 } {
      set num $mom_debug_event_num
   } else {
      set num ""
   }
   set file_all_offset2 [tell $mom_debug_file_all]
   seek $mom_debug_file_all $file_all_offset1 start ; # offset file ptr
   seek $mom_debug_file_current 0 start ; # set pointer to start of file
   set seek_flag 0

   puts $mom_debug_file_all ""
   puts $mom_debug_file_all "--------------------------------------------------"
   puts $mom_debug_file_all "Event ${num}: $mom_debug_event_name"
   puts $mom_debug_file_all ""

   if { $mom_debug_do_wish } {
      puts $mom_debug_file_current ""
      puts $mom_debug_file_current "Event ${num}: $mom_debug_event_name"

      flush $mom_debug_file_current

      set ier [catch \
      {exec $my_wish $mom_debug_wish_script -name debug detail $debug_resp_file $mom_debug_fname_cur}]
      if {$ier == 1} {
        set my_wish "wish"
        exec $my_wish $mom_debug_wish_script -name debug detail $debug_resp_file $mom_debug_fname_cur
      }
      set mom_debug_resp_file [open "$debug_resp_file"]
      set mom_debug_do_wish [gets $mom_debug_resp_file]
      close $mom_debug_resp_file
      
      close $mom_debug_file_current
      MOM_remove_file $mom_debug_fname_cur
      set mom_debug_file_current [open $mom_debug_fname_cur w]
   }
   seek $mom_debug_file_all $file_all_offset2 start ; # offset file ptr
}

proc MOM_before_each_add_var {} {
   global file_all_offset1
   global seek_flag
   global mom_debug_file_all
   global mom_debug_file_current
   global mom_debug_assign_var
   global mom_debug_do_wish
   global mom_debug_done_heading
   global mom_debug_vars
   global mom_debug_event_num
   global mom_debug_range_lower mom_debug_range_upper mom_debug_range_flag
   global mom_debug_err_file
   global DEBUG

   if { $DEBUG } { #puts $mom_debug_err_file "Entering MOM_before_each_add_var" }

   if { $mom_debug_vars == 0 } { return }

   if { $mom_debug_done_heading == 0 } { MOM__debug_do_heading }

   set num $mom_debug_event_num
   incr num
   if { $mom_debug_range_flag == 1 } {
      if { $num < $mom_debug_range_lower || \
           $num > $mom_debug_range_upper } { return }
   }

   if { $seek_flag == 0 } {
      set tmp_str "                                           "
      set file_all_offset1 [tell $mom_debug_file_all]
      puts $mom_debug_file_all $tmp_str
      puts $mom_debug_file_all $tmp_str
      puts $mom_debug_file_current $tmp_str
      set seek_flag 1
   }

   puts $mom_debug_file_all "Var: $mom_debug_assign_var"
   if { $mom_debug_do_wish } {
      puts $mom_debug_file_current "Var: $mom_debug_assign_var"
   }
}

proc MOM_before_load_address {} {
   global file_all_offset1
   global seek_flag
   global mom_debug_file_all
   global mom_debug_file_current
   global mom_debug_do_wish
   global mom_debug_done_heading
   global mom_debug_load_address
   global mom_debug_addrs
   global mom_debug_event_num mom_debug_range_flag
   global mom_debug_range_lower mom_debug_range_upper 
   global mom_debug_err_file
   global DEBUG

   if { $DEBUG } { #puts $mom_debug_err_file "Entering MOM_before_load_address" }

   if { $mom_debug_addrs == 0 } { return }

   if { $mom_debug_done_heading == 0 } { MOM__debug_do_heading }

   set num $mom_debug_event_num
   incr num
   if { $mom_debug_range_flag == 1 } {
      if { $num < $mom_debug_range_lower || \
           $num > $mom_debug_range_upper } { return }
   }

   if { $seek_flag == 0 } {
      set tmp_str "                                           "
      set file_all_offset1 [tell $mom_debug_file_all]
      puts $mom_debug_file_all $tmp_str
      puts $mom_debug_file_all $tmp_str
      puts $mom_debug_file_current $tmp_str
      set seek_flag 1
   }

   puts $mom_debug_file_all "Address: $mom_debug_load_address"
   if { $mom_debug_do_wish } {
      puts $mom_debug_file_current "Address: $mom_debug_load_address"
   }
}

proc MOM_init_debug {} {
   global mom_debug_init_done
   global mom_debug_file_all
   global mom_debug_file_current
   global mom_debug_fname_all
   global mom_debug_fname_cur
   global mom_debug_do_wish
   global debug_resp_file
   global mom_debug_done_heading
   global mom_debug_events mom_debug_vars mom_debug_addrs mom_debug_num_flag
   global mom_debug_range_flag mom_debug_range_lower mom_debug_range_upper
   global mom_debug_wish_script
   global mom_debug_err_file
   global DEBUG
   global resp
   global my_wish

   if { "$mom_debug_init_done" == "1" } { return }

   if { $DEBUG } { puts $mom_debug_err_file "Entering MOM_init_debug" }
   
   set mom_debug_do_wish 0
   if { [file exists $mom_debug_wish_script] } {
      set mom_debug_do_wish 1
   } else {
      if { $DEBUG } { puts $mom_debug_err_file "DID NOT FIND WISH SCRIPT" }
   }

   set mom_debug_file_all [open $mom_debug_fname_all w]

   if { $mom_debug_do_wish == 1 } {
      set ier [catch \
      {exec $my_wish $mom_debug_wish_script -name debug menu $debug_resp_file}]
      if {$ier == 1} {
        set my_wish "wish"
        exec $my_wish $mom_debug_wish_script -name debug menu $debug_resp_file
      }
      set mom_debug_resp_file [open "$debug_resp_file"]
      set resp [gets $mom_debug_resp_file]
      close $mom_debug_resp_file
      scan $resp "%d %d %d %d %d %d %d" mom_debug_events mom_debug_vars \
             mom_debug_addrs mom_debug_num_flag mom_debug_range_flag \
             mom_debug_range_lower mom_debug_range_upper
      set mom_debug_file_current [open $mom_debug_fname_cur w]
   } else {
      set mom_debug_events 1
      set mom_debug_vars 1
      set mom_debug_addrs 1
      set mom_debug_num_flag 1
   }

   set mom_debug_done_heading 0

   if { $DEBUG } {
      puts $mom_debug_err_file "mom_debug_events = $mom_debug_events"
      puts $mom_debug_err_file "mom_debug_vars =  $mom_debug_vars"
      puts $mom_debug_err_file "mom_debug_addrs = $mom_debug_addrs"
      puts $mom_debug_err_file "mom_debug_num_flag = $mom_debug_num_flag"
      puts $mom_debug_err_file "mom_debug_range_flag = $mom_debug_range_flag"
      puts $mom_debug_err_file "mom_debug_range_lower = $mom_debug_range_lower" 
      puts $mom_debug_err_file "mom_debug_range_lower = $mom_debug_range_upper"
      puts $mom_debug_err_file "mom_debug_do_wish = $mom_debug_do_wish"
   }
   set mom_debug_init_done 1
}

proc MOM_end_debug {} {
   global mom_debug_file_all
   global mom_debug_file_current
   global mom_debug_fname_cur
   global mom_debug_done_heading
   global mom_debug_err_file
   global debug_resp_file
   global DEBUG

   if { $DEBUG } { puts $mom_debug_err_file "Entering MOM_end_debug" }

   flush $mom_debug_file_all
   close $mom_debug_file_all

   catch { close $mom_debug_file_current }
   catch { MOM_remove_file $mom_debug_fname_cur }
   catch { close $mom_debug_err_file }
   catch { MOM_remove_file "$debug_resp_file" }

   set mom_debug_done_heading 0
}

proc MOM_on_parse_error {} {
   global mom_debug_fname_all
   global mom_debug_file_all
   global mom_debug_file_current
   global mom_debug_wish_script
   global mom_debug_fname_cur
   global mom_debug_do_wish
   global mom_parse_error
   global mom_parse_file_name
   global mom_parse_line_number
   global mom_parse_line
   global mom_debug_err_file
   global DEBUG
   global my_wish

   if { $DEBUG } {
      puts $mom_debug_err_file "Entering MOM_on_parse_error"
      puts $mom_debug_err_file "mom_debug_file_all: $mom_debug_file_all"
      puts $mom_debug_err_file "mom_debug_file_current: $mom_debug_file_current"
      puts $mom_debug_err_file "mom_debug_wish_script: $mom_debug_wish_script"
      puts $mom_debug_err_file "mom_debug_fname_cur: $mom_debug_fname_cur"
      puts $mom_debug_err_file "mom_debug_do_wish: $mom_debug_do_wish"
      puts $mom_debug_err_file "mom_parse_error: $mom_parse_error"
      puts $mom_debug_err_file "mom_parse_file_name: $mom_parse_file_name"
      puts $mom_debug_err_file "mom_parse_line_number: $mom_parse_line_number"
      puts $mom_debug_err_file "mom_parse_line: $mom_parse_line"
   }

   puts $mom_debug_file_all ""
   puts $mom_debug_file_all "***ERROR***: Parse Error in the Definition File"
   puts $mom_debug_file_all "--------------------------------------------------"
   puts $mom_debug_file_all "Definition file: $mom_parse_file_name"
   puts $mom_debug_file_all "In Or Near Line Number: $mom_parse_line_number"
   MOM__print_line_context $mom_parse_file_name $mom_parse_line_number 3 \
                           $mom_debug_file_all
   puts $mom_debug_file_all "Line: $mom_parse_line"
   puts $mom_debug_file_all "Parser error message: $mom_parse_error"
   puts $mom_debug_file_all ""

   if { $mom_debug_do_wish } {
      puts $mom_debug_file_current ""
      puts $mom_debug_file_current "***ERROR***: Parse Error in the Definition File"
      puts $mom_debug_file_current "-----------------------------------------------"
      puts $mom_debug_file_current "Definition file: $mom_parse_file_name"
      puts $mom_debug_file_current "In Or Near Line Number: $mom_parse_line_number"
      MOM__print_line_context $mom_parse_file_name $mom_parse_line_number 3 \
                              $mom_debug_file_current
      puts $mom_debug_file_current "Line: $mom_parse_line"
      puts $mom_debug_file_current "Parser error message: $mom_parse_error"

      flush $mom_debug_file_current

      set ier [catch \
      {exec $my_wish $mom_debug_wish_script -name debug detail $debug_resp_file $mom_debug_fname_cur}]
      if {$ier == 1} {
        set my_wish "wish"
        exec $my_wish $mom_debug_wish_script -name debug detail $debug_resp_file $mom_debug_fname_cur
      }
      set mom_debug_resp_file [open "$debug_resp_file"]
      set mom_debug_do_wish [gets $mom_debug_resp_file]
      close $mom_debug_resp_file

      close $mom_debug_file_current
      MOM_remove_file $mom_debug_fname_cur
      set mom_debug_file_current [open $mom_debug_fname_cur w]
   }

   # We need to close the file because if the application ERROR_raises after
   # a parse error then no one executes end_debug to close the file. If the
   # file isn't closed on HPUX (and probably other OS's) the data in the
   # I/O buffer is not flushed. 'flush' by itself doesn't work on HPUX.
   flush $mom_debug_file_all
   close $mom_debug_file_all
   set mom_debug_file_all [open $mom_debug_fname_all a]
   if { $DEBUG } { puts $mom_debug_err_file "Leaving MOM_on_parse_error" }
}

proc MOM_on_event_error {} {
   global mom_error_info
   global mom_error_code
   global mom_error_event
   global mom_error_event_handler_name
   global mom_debug_fname_all
   global mom_debug_file_all
   global mom_debug_file_current
   global mom_debug_wish_script
   global mom_debug_fname_cur
   global mom_debug_do_wish
   global mom_debug_err_file
   global DEBUG
   global my_wish

   if { $DEBUG } {
      puts $mom_debug_err_file "Entering MOM_on_event_error"
      puts $mom_debug_err_file "mom_debug_file_all: $mom_debug_file_all"
      puts $mom_debug_err_file "mom_debug_file_current: $mom_debug_file_current"
      puts $mom_debug_err_file "mom_debug_wish_script: $mom_debug_wish_script"
      puts $mom_debug_err_file "mom_debug_fname_cur: $mom_debug_fname_cur"
      puts $mom_debug_err_file "mom_debug_do_wish: $mom_debug_do_wish"
      puts $mom_debug_err_file "mom_error_info: $mom_error_info"
      puts $mom_debug_err_file "mom_error_code: $mom_error_code"
      puts $mom_debug_err_file "mom_error_event: $mom_error_event"
      puts $mom_debug_err_file "mom_error_event_handler_name: $mom_error_event_handler_name"
   }

   puts $mom_debug_file_all ""
   puts $mom_debug_file_all "***ERROR***: Error in the Event Handler"
   puts $mom_debug_file_all "---------------------------------------"
   puts $mom_debug_file_all "Event Handler: $mom_error_event_handler_name"
   puts $mom_debug_file_all "Event: $mom_error_event"
   puts $mom_debug_file_all "Error Info: $mom_error_info"
   puts $mom_debug_file_all "Error Code: $mom_error_code"
   puts $mom_debug_file_all ""

   if { $mom_debug_do_wish } {
      puts $mom_debug_file_current ""
      puts $mom_debug_file_current "***ERROR***: Error in the Event Handler"
      puts $mom_debug_file_current "---------------------------------------"
      puts $mom_debug_file_current \
                               "Event Handler: $mom_error_event_handler_name"
      puts $mom_debug_file_current "Event: $mom_error_event"
      puts $mom_debug_file_current "Error Info: $mom_error_info"
      puts $mom_debug_file_current "Error Code: $mom_error_code"
      puts $mom_debug_file_current ""

      flush $mom_debug_file_current

      set ier [catch \
      {exec $my_wish $mom_debug_wish_script -name debug detail $debug_resp_file $mom_debug_fname_cur}]
      if {$ier == 1} {
        set my_wish "wish"
        exec $my_wish $mom_debug_wish_script -name debug detail $debug_resp_file $mom_debug_fname_cur
      }
      set mom_debug_resp_file [open "$debug_resp_file"]
      set mom_debug_do_wish [gets $mom_debug_resp_file]
      close $mom_debug_resp_file

      close $mom_debug_file_current
      MOM_remove_file $mom_debug_fname_cur
      set mom_debug_file_current [open $mom_debug_fname_cur w]
   }

   # We need to close the file because if the application ERROR_raises after
   # a parse error then no one executes end_debug to close the file. If the
   # file isn't closed on HPUX (and probably other OS's) the data in the
   # I/O buffer is not flushed. 'flush' by itself doesn't work on HPUX.
   flush $mom_debug_file_all
   close $mom_debug_file_all
   set mom_debug_file_all [open $mom_debug_fname_all a]
   if { $DEBUG } { puts $mom_debug_err_file "Leaving MOM_on_event_error" }
}

MOM_init_debug
