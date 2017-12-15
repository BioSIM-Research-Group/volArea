
#!/bin/sh
# 90.tcl \
exec tclsh "$0" ${1+"$@"}
package provide graph 1.0

proc VolArea::makegraph {color} {
	if {[winfo exists $VolArea::VolArea.c]} {
		destroy $VolArea::VolArea.c
	}
	toplevel $VolArea::VolArea.c

	wm title $VolArea::VolArea.c "Plot window "
	grid columnconfigure $VolArea::VolArea.c 0 -weight 2 ;grid rowconfigure $VolArea::VolArea.c 0 -weight 1

	grid [ttk::frame $VolArea::VolArea.c.fg] -column 0 -row 0 -sticky news
	grid columnconfigure $VolArea::VolArea.c.fg 2 -weight 2 ;grid rowconfigure $VolArea::VolArea.c.fg 1 -weight 2

	grid [ttk::labelframe $VolArea::VolArea.c.ftb -text "Selected Series"] -column 1 -row 0 -sticky nwes
	grid columnconfigure $VolArea::VolArea.c.ftb 1 -weight 0 ;grid rowconfigure $VolArea::VolArea.c.ftb 1 -weight 0

	grid [tk::listbox $VolArea::VolArea.c.ftb.tbr -yscrollcommand [list $VolArea::VolArea.c.ftb.scrtbr1 set] -xscrollcommand [list $VolArea::VolArea.c.ftb.scrtbr2 set] -selectmode single] -column 0 -row 4 -sticky news
	grid columnconfigure $VolArea::VolArea.c.ftb.tbr 1 -weight 2 ;grid rowconfigure $VolArea::VolArea.c.ftb.tbr 1 -weight 2

	##Binding made in plotpriv.tcl in proc ::Plotchart::DrawData

	scrollbar $VolArea::VolArea.c.ftb.scrtbr1 -orient vertical -command [list $VolArea::VolArea.c.ftb.tbr yview]
      	grid $VolArea::VolArea.c.ftb.scrtbr1 -column 1 -row 4 -sticky sne

	scrollbar $VolArea::VolArea.c.ftb.scrtbr2 -orient horizontal -command [list $VolArea::VolArea.c.ftb.tbr xview]
      	grid $VolArea::VolArea.c.ftb.scrtbr2 -column 0 -row 5 -sticky ews
	if {$VolArea::sasa==1} {
		set xyp [xyplot $VolArea::VolArea.c.fg.xyp -xformat "%5.0f" -yformat "%5.2f" -xtext "Frame Nº" -ytext "Area(A²)" -title "[molinfo top get name] Surface Graph " -background $color]
        	pack $xyp -fill both -expand true


        	grid [tk::listbox $VolArea::VolArea.c.ftb.tb  -yscrollcommand [list $VolArea::VolArea.c.ftb.scr1 set] -xscrollcommand [list $VolArea::VolArea.c.ftb.scr2 set] -selectmode single] -column 0 -row 0 -sticky news
        	grid columnconfigure $VolArea::VolArea.c.ftb.tb 2 -weight 2 ;grid rowconfigure $VolArea::VolArea.c.ftb.tb 1 -weight 2


        	scrollbar $VolArea::VolArea.c.ftb.scr1 -orient vertical -command [list $VolArea::VolArea.c.ftb.tb yview]
              	grid $VolArea::VolArea.c.ftb.scr1 -row 0 -column 1  -sticky sne

        	scrollbar $VolArea::VolArea.c.ftb.scr2 -orient horizontal -command [list $VolArea::VolArea.c.ftb.tb xview]
              	grid $VolArea::VolArea.c.ftb.scr2 -row 1 -column 0  -sticky ews

		grid [ttk::frame $VolArea::VolArea.c.ftb.b] -column 0 -row 2 -sticky nswe
		grid columnconfigure $VolArea::VolArea.c.ftb.b 2 -weight 2 ;grid rowconfigure $VolArea::VolArea.c.ftb.b 1 -weight 2

		grid [ttk::button $VolArea::VolArea.c.ftb.b.bdel -text "Delete" -command VolArea::delseries] -column 1 -row 0 -sticky e -pady 2
            	set fr $VolArea::VolArea.c.ftb.b

            	grid [ttk::button $fr.mean -text "Add mean series" -command VolArea::mean] -column 0 -row 0 -stick w

            	$VolArea::VolArea.nb1.fo.fbu.ba configure -state normal
            	$VolArea::VolArea.nb1.fo.f2.tb selection clear 0 end
		$VolArea::VolArea.nb1.fo.f2.tb selection set 0
	}

}
proc VolArea::mean {} {
	if {[$VolArea::VolArea.c.ftb.tb curselection] != ""} {
		set item [$VolArea::VolArea.c.ftb.tb get [$VolArea::VolArea.c.ftb.tb curselection]]
              	if {[string range $item [expr [string length $item] -4] [string length $item]] != "mean"} {
        		  VolArea::addseries "SasaMean" red
                } else {
        		VolArea::delseries
                }
	}
}

proc VolArea::addseriesvol {bcolor color} {
	sqlite $VolArea::namedb $VolArea::path
	set xyp [xyplot $VolArea::VolArea.c.fg.xyp2 -xformat "%5.0f" -yformat "%5.2f" -xtext "Nº Frame" -ytext "Volume(A³)" -title "[molinfo top get name] Volume Graph " -background $bcolor]
	pack $xyp -fill both -expand true
	set resdata ""
	set name "volume"
	for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} {incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
		set sum [$VolArea::namedb eval "SELECT sasa  FROM frame_$i WHERE resname= :name"]
		set sum [string trim $sum "{"]
		set sum [string trim $sum "}"]
		set sum [string trim $sum " "]
		lappend resdata $i $sum
	}
	 if {[lsearch [$VolArea::VolArea.c.fg.xyp2 cget series] volume] == -1} {
		 if {$color == ""} {
			 set color [format #%06x [expr {int(rand() * 0xFFFFFF)}]]
		 }
		set s3 [$VolArea::VolArea.c.fg.xyp2 add_data volume $resdata -legend volume -color $color ]
	}

	set name "volume"
	set resdata ""
	for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} {incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
		set sum [$VolArea::namedb eval "SELECT SasaMean  FROM frame_$i WHERE resname= :name"]
		set sum [string trim $sum "{"]
		set sum [string trim $sum "}"]
		set sum [string trim $sum " "]
		lappend resdata $i $sum
	}
	 if {[lsearch [$VolArea::VolArea.c.fg.xyp2 cget series] volumeMean] == -1} {
		set s3 [$VolArea::VolArea.c.fg.xyp2 add_data volumeMean $resdata -legend volumeMean -color red ]
	}
	if {$VolArea::volatom ==1} {
        	set resdata ""
        	set name "volatom"
        	for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} {incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
        		set sum [$VolArea::namedb eval "SELECT sasa  FROM frame_$i WHERE resname= :name"]
        		set sum [string trim $sum "{"]
        		set sum [string trim $sum "}"]
        		set sum [string trim $sum " "]
        		lappend resdata $i $sum
        	}
        	 if {[lsearch [$VolArea::VolArea.c.fg.xyp2 cget series] volatom] == -1} {
        		 if {$color == ""} {
        			 set color [format #%06x [expr {int(rand() * 0xFFFFFF)}]]
        		 }
        		set s3 [$VolArea::VolArea.c.fg.xyp2 add_data volatom $resdata -legend volatom -color #0033ff ]
        	}

        	set name "volatom"
        	set resdata ""
        	for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} {incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
        		set sum [$VolArea::namedb eval "SELECT SasaMean  FROM frame_$i WHERE resname= :name"]
        		set sum [string trim $sum "{"]
        		set sum [string trim $sum "}"]
        		set sum [string trim $sum " "]
			set sum [format %7.3f $sum]
        		lappend resdata $i $sum
        	}
        	 if {[lsearch [$VolArea::VolArea.c.fg.xyp2 cget series] volatomMean] == -1} {
        		set s3 [$VolArea::VolArea.c.fg.xyp2 add_data volatomMean $resdata -legend volatomMean -color red ]
        	}
	}
}
proc VolArea::addseries {val color} {
	sqlite $VolArea::namedb $VolArea::path
	$VolArea::VolArea.c.ftb.b.mean configure -state normal
	set tbsel [$VolArea::VolArea.nb1.fo.f2.tb get [$VolArea::VolArea.nb1.fo.f2.tb curselection]]
	if {$val != "sasa"} {
		set tbsel [$VolArea::VolArea.c.ftb.tb get [$VolArea::VolArea.c.ftb.tb curselection]]
		set staux ""
		set staux [lappend staux [string range $tbsel 0 2]]
		if {[string range $tbsel [expr [string length $tbsel] -4] [string length $tbsel]] == "mean"} {
			set staux [lappend staux [string range $tbsel 3 [expr [string length $tbsel] -5]]]
		} else {
			set staux [lappend staux [string range $tbsel 3 [string length $tbsel]]]
		}
		set tbsel $staux
	}
	if {[string trim [lindex $tbsel 0]] != "" } {
		set id [string trim [lindex $tbsel 1] " "]
		set name [string trim [lindex $tbsel 0] " "]
		set chain [string trim [lindex $tbsel 2] " "]
		set resdata ""
		for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} {incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
			set sum ""
			if {$chain != ""} {
				set sum [$VolArea::namedb eval "SELECT $val FROM frame_$i WHERE id= :id AND resname= :name AND chain = :chain"]
			} else {
				set sum [$VolArea::namedb eval "SELECT $val FROM frame_$i WHERE id= :id AND resname= :name"]
			}


			set sum [string trimleft $sum "{"]
			set sum [string trimright $sum "}"]
			set sum [string trim $sum " "]
			if {$sum != ""} {
				set sum [format %7.3f $sum]
				lappend resdata $i $sum
			}

		}
		$VolArea::VolArea.c.ftb.tb selection clear end
		if {$val == "SasaMean"} {
			if {[lsearch [$VolArea::VolArea.c.fg.xyp cget series] [lindex $tbsel 0][lindex $tbsel 1]mean] == -1} {
				 if {$color == ""} {
			 		set color [format #%06x [expr {int(rand() * 0xFFFFFF)}]]
		 		}
				set s3 [$VolArea::VolArea.c.fg.xyp add_data [lindex $tbsel 0][lindex $tbsel 1]mean $resdata -legend "[string trim  [lindex $tbsel 0][lindex $tbsel 1]]mean" -color $color ]
				$VolArea::VolArea.c.ftb.tb insert end [lindex $tbsel 0][lindex $tbsel 1]mean

			}
		} elseif {[lsearch [$VolArea::VolArea.c.fg.xyp cget series] [lindex $tbsel 0][lindex $tbsel 1]] == -1} {
			if {$color == ""} {
	 			set color [format #%06x [expr {int(rand() * 0xFFFFFF)}]]
		 	}
			set s3 [$VolArea::VolArea.c.fg.xyp add_data [lindex $tbsel 0][lindex $tbsel 1] $resdata -legend "[string trim  [lindex $tbsel 0][lindex $tbsel 1]]" -color $color ]
			$VolArea::VolArea.c.ftb.tb insert end [lindex $tbsel 0][lindex $tbsel 1]

		}

	}
}

proc VolArea::delseries {} {
	if {[$VolArea::VolArea.c.ftb.tb curselection] != ""} {
		set item [$VolArea::VolArea.c.ftb.tb get [$VolArea::VolArea.c.ftb.tb curselection]]
		$VolArea::VolArea.c.fg.xyp remove_data $item
		$VolArea::VolArea.c.ftb.tb delete [$VolArea::VolArea.c.ftb.tb curselection]
		$VolArea::VolArea.c.ftb.tb selection set end
		if {[$VolArea::VolArea.c.ftb.tb get 0] == ""} {
			$VolArea::VolArea.c.ftb.b.mean configure -state disable

		}
	}

}