

MOM_output_to_listing_device "--> initializing postprocessor's files"

# Initialization section

set cam_post_dir [MOM_ask_env_var UGII_CAM_POST_DIR]

MOM_output_to_listing_device "cam_post_dir: $cam_post_dir"

set mom_sys_this_post_dir  "[file dirname [info script]]"
MOM_output_to_listing_device "mom_sys_this_post_dir: $mom_sys_this_post_dir"

set mom_sys_this_post_name "[file rootname [file tail [info script]]]"
MOM_output_to_listing_device "mom_sys_this_post_name: $mom_sys_this_post_name"

#===============================================================================
if { ![info exists ::mom_sys_post_initialized] } {
#===============================================================================

    if {0} {
        if { ![info exists mom_sys_ugpost_base_initialized] } {
            source ${cam_post_dir}ugpost_base.tcl
            set mom_sys_ugpost_base_initialized 1
        }

        set mom_sys_debug_mode OFF

        if { ![info exists env(PB_SUPPRESS_UGPOST_DEBUG)] } {
            set env(PB_SUPPRESS_UGPOST_DEBUG) 0
        }

        if { $env(PB_SUPPRESS_UGPOST_DEBUG) } {
            set mom_sys_debug_mode OFF
        }

        if { ![string compare $mom_sys_debug_mode "OFF"] } {
            proc MOM_before_each_add_var {} {}
            proc MOM_before_each_event   {} {}
            proc MOM_before_load_address {} {}
            proc MOM_end_debug {} {}

        } else {
            set cam_debug_dir [MOM_ask_env_var UGII_CAM_DEBUG_DIR]
            source ${cam_debug_dir}mom_review.tcl
        }

        ####  Listing File variables
        set mom_sys_list_output                       "OFF"
        set mom_sys_header_output                     "OFF"
        set mom_sys_list_file_rows                    "40"
        set mom_sys_list_file_columns                 "30"
        set mom_sys_warning_output                    "OFF"
        set mom_sys_warning_output_option             "FILE"
        set mom_sys_group_output                      "OFF"
        set mom_sys_list_file_suffix                  "lpt"
        set mom_sys_output_file_suffix                "ptp"
        set mom_sys_commentary_output                 "ON"
        set mom_sys_commentary_list                   "x y z 4axis 5axis feed speed"
        set mom_sys_output_transition_path            "0"
        set mom_sys_post_output_subprogram_enabled    "0"
        set mom_sys_pb_link_var_mode                  "OFF"

        if { [string match "OFF" $mom_sys_warning_output] } {
            catch { rename MOM__util_print ugpost_MOM__util_print }
            proc MOM__util_print { args } {}
        }

        MOM_set_debug_mode $mom_sys_debug_mode

        if { [string match "OFF" $mom_sys_warning_output] } {
            catch { rename MOM__util_print "" }
            catch { rename ugpost_MOM__util_print MOM__util_print }
        }

        #=============================================================
        proc MOM_before_output { } {
        #=============================================================
        # This command is executed just before every NC block is
        # to be output to a file.
        #
        # - Never overload this command!
        # - Any customization should be done in PB_CMD_before_output!
        #

            if { [llength [info commands PB_CMD_kin_before_output]] &&\
                [llength [info commands PB_CMD_before_output]] } {

                PB_CMD_kin_before_output
            }

            # Write output buffer to the listing file with warnings
            global mom_sys_list_output
            if { [string match "ON" $mom_sys_list_output] } {
                LIST_FILE
            } else {
                global tape_bytes mom_o_buffer
                if { ![info exists tape_bytes] } {
                set tape_bytes [string length $mom_o_buffer]
                } else {
                incr tape_bytes [string length $mom_o_buffer]
                }
            }
        }

        if { [string match "OFF" [MOM_ask_env_var UGII_CAM_POST_LINK_VAR_MODE]] } {
            set mom_sys_link_var_mode "OFF"
        } else {
            set mom_sys_link_var_mode "$mom_sys_pb_link_var_mode"
        }

    }

    set ::mom_sys_control_out "("
    set ::mom_sys_control_in  ")"

    # custom block start
    set ::post_state(event_output) "essential" ;# keys: essential/advanced
    set ::cout $::mom_sys_control_out
    set ::cin $::mom_sys_control_in

    # custom block end

    set ::mom_sys_post_initialized 1

}

#===============================================================================
proc MOM__halt {} {
#===============================================================================
    MOM_output_to_listing_device "MOM__halt"
    foreach  var  [lsort [info globals mom_*]] {
        MOM_output_to_listing_device "$var"        
    }

}

#===============================================================================
proc MOM__part_attributes {} {
#===============================================================================
    MOM_output_to_listing_device "*************************************************************************"
    MOM_output_to_listing_device "*************************************************************************"
    MOM_output_to_listing_device "***MOM__part_attributes***"

}

#===============================================================================
proc MOM_start_of_program {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_start_of_program***"
    

}

#===============================================================================
proc MOM_start_of_group {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_start_of_group***"
    

}

#===============================================================================
proc MOM_machine_mode {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_machine_mode***"
    

}


#===============================================================================
proc MOM_first_turret {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_first_turret***"
    

}

#===============================================================================
proc MOM_start_of_path {} {
#===============================================================================
    MOM_output_to_listing_device "#========================================================================"
    MOM_output_to_listing_device "***MOM_start_of_path***"
    

}

#===============================================================================
proc MOM_set_csys {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_set_csys***"

    
}

#===============================================================================
proc MOM_first_tool {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_first_tool***"

    
}

#===============================================================================
proc MOM_msys {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_msys***"

    
}

#===============================================================================
proc MOM_tool_path_type_change {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_tool_path_type_change***"

    
}

#===============================================================================
proc MOM_from_move {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_from_move***"

    
}

#===============================================================================
proc MOM_initial_move {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_initial_move***"
    if {[info exists ::post_state(event_output)] && [string match -nocase "essential" $::post_state(event_output)]} {
        MOM_output_to_listing_device "..."
    } else {
        #do nothing
    }

    
}

#===============================================================================
proc MOM_first_move {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_first_move***"
    if {[info exists ::post_state(event_output)] && [string match -nocase "essential" $::post_state(event_output)]} {
        MOM_output_to_listing_device "..."
    } else {
        #do nothing
    }


    
}

#===============================================================================
proc MOM_rapid_move {} {
#===============================================================================
    if {[info exists ::post_state(event_output)] && ![string match -nocase "essential" $::post_state(event_output)]} {
        MOM_output_to_listing_device "***MOM_rapid_move***"
    } else {
        #do nothing
    }

    
}

#===============================================================================
proc MOM_linear_move {} {
#===============================================================================
    if {[info exists ::post_state(event_output)] && ![string match -nocase "essential" $::post_state(event_output)]} {
        MOM_output_to_listing_device "***MOM_linear_move***"
    } else {
        #do nothing
    }

    
}

#===============================================================================
proc MOM_circular_move {} {
#===============================================================================
    if {[info exists ::post_state(event_output)] && ![string match -nocase "essential" $::post_state(event_output)]} {
        MOM_output_to_listing_device "***MOM_circular_move***"
    } else {
        #do nothing
    }

    
}

#===============================================================================
proc MOM_drill {} {
#===============================================================================
    if {[info exists ::post_state(event_output)] && ![string match -nocase "essential" $::post_state(event_output)]} {
        MOM_output_to_listing_device "***MOM_drill***"
    } else {
        #do nothing
    }
    
}

#===============================================================================
proc MOM_drill_move {} {
#===============================================================================
    if {[info exists ::post_state(event_output)] && ![string match -nocase "essential" $::post_state(event_output)]} {
        MOM_output_to_listing_device "***MOM_drill_move***"
    } else {
        #do nothing
    }

    
}

#===============================================================================
proc MOM_cycle_off {} {
#===============================================================================
    if {[info exists ::post_state(event_output)] && ![string match -nocase "essential" $::post_state(event_output)]} {
        MOM_output_to_listing_device "***MOM_cycle_off***"
    } else {
        #do nothing
    }

    
}

#===============================================================================
proc MOM_gohome_move {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_gohome_move***"

    
}

#===============================================================================
proc MOM_end_of_path {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_end_of_path***"
    MOM_output_to_listing_device "#========================================================================"

    
}

#===============================================================================
proc MOM_end_of_group {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_end_of_group***"

    
}

#===============================================================================
proc MOM_end_of_program {} {
#===============================================================================
    MOM_output_to_listing_device "***MOM_end_of_program***"
    MOM_output_to_listing_device "*************************************************************************"
    MOM_output_to_listing_device "*************************************************************************"

    
}


