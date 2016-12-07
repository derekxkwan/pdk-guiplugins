# META pdkcalc/TK prompt plugin
# META DESCRIPTION adds a calculator to the pd window (code mostly lifted from tclprompt by IOhannes zmoelnig and Hans-Christoph Steiner)
# META AUTHOR Derek Kwan
# META VERSION 0.1

package require pdwindow 0.1
namespace eval ::pdkcalc:: {
    
	variable pdkcalcentry {}
	variable pdkcalcentry_history {}
	variable history_position 0
	variable show 1
}



    proc ::pdkcalc::eval_pdkcalcentry {} {
	variable pdkcalcentry
	variable pdkcalcentry_history
	variable history_position 0
	if {$pdkcalcentry eq ""} {return} ;# no need to do anything if empty
	if {[catch {expr $pdkcalcentry} errorname]} {
	    global errorInfo
            ::pdwindow::error "pdkcalc: improper input!"
	} else {
            ::pdwindow::post [expr $pdkcalcentry]
            ::pdwindow::post "\n"
        }
	lappend pdkcalcentry_history $pdkcalcentry
	set pdkcalcentry {}
    }


    proc ::pdkcalc::get_history {direction} {
	variable pdkcalcentry_history
	variable history_position

	incr history_position $direction
	if {$history_position < 0} {set history_position 0}
	if {$history_position > [llength $pdkcalcentry_history]} {
	    set history_position [llength $pdkcalcentry_history]
	}
	.pdwindow.pdkcalc.entry delete 0 end
	.pdwindow.pdkcalc.entry insert 0 \
	    [lindex $pdkcalcentry_history end-[expr $history_position - 1]]
    }



    #--create pdkcalc entry-----------------------------------------------------------#

    proc ::pdkcalc::create {} {
	# pdkcalc entry box frame
	frame .pdwindow.pdkcalc -borderwidth 0
	pack .pdwindow.pdkcalc -side bottom -fill x -before .pdwindow.text
	label .pdwindow.pdkcalc.label -text [_ "Calc:"] -anchor e
	pack .pdwindow.pdkcalc.label -side left
	entry .pdwindow.pdkcalc.entry -width 200 \
	    -exportselection 1 -insertwidth 2 -insertbackground blue \
	    -textvariable ::pdkcalc::pdkcalcentry -font {$::font_family -12}
	pack .pdwindow.pdkcalc.entry -side left -fill x

	# bindings for the pdkcalc entry widget
	bind .pdwindow.pdkcalc.entry <$::modifier-Key-a> "%W selection range 0 end; break"
	bind .pdwindow.pdkcalc.entry <Return> "::pdkcalc::eval_pdkcalcentry"
	bind .pdwindow.pdkcalc.entry <Up>     "::pdkcalc::get_history 1"
	bind .pdwindow.pdkcalc.entry <Down>   "::pdkcalc::get_history -1"
	#bind .pdwindow.pdkcalc.entry <KeyRelease> +"::pdkcalc::validate_pdkcalc"

	bind .pdwindow.text <Key-Tab> "focus .pdwindow.pdkcalc.entry; break"
	#    pack .pdwindow.pdkcalc
    }

    proc ::pdkcalc::destroy {} {
	::destroy .pdwindow.pdkcalc
    }

    set mymenu .menubar.help
    $mymenu add separator
    $mymenu add check -label [_ "pdkcalc prompt"] -variable ::pdkcalc::show \
        -command {::pdkcalc::toggle $::pdkcalc::show}

# bind all <$::modifier-Key-s> {::deken::open_helpbrowser .helpbrowser2}

    ::pdkcalc::create


} else {
    puts "built-in pdkcalc"

    proc ::pdkcalc::create {} {}
    proc ::pdkcalc::destroy {} {
	# actually we *can* destroy it, but we cannot re-create it
	::pdwindow::error "cannot destroy built-in pdkcalc"
    }
}

proc ::pdkcalc::toggle {state} {
    if { $state } { ::pdkcalc::create } { ::pdkcalc::destroy }
}
proc ::pdkcalc::test {} {
    after 1000 ::pdkcalc::create
    ::pdkcalc::destroy
}
pdtk_post "loaded pdkcalc-plugin\n"
