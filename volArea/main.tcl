#!/bin/sh \
exec tclsh "$0" ${1+"$@"}

package provide VolArea 1.0

namespace eval ::VolArea:: {


   package require vdw 1.0
	set tcl_precision 17
	variable namedb ""
	variable path ""
	array set sum ""
	array set avg ""
	array set stdv ""
	array set resname ""
	array set listpoint ""
	array set list ""
	set BSel(0) ""
	set BSel(1) ""
	variable avgt 0
	variable stdvt 0
	variable step 0
	variable sizemol "{0 0 0 } {0 0 0}"
	variable pre 0
	variable sasa 1
	variable vol 1
	variable volatom 0
	variable result ""
	variable pb 0
	variable VolArea ""
	variable RCenter 0
	variable hide_volume 0
	variable hide_sasa 0
	variable RSize 0
	variable imageFCUP ""
	variable imageLicense ""
	variable imageREQUIMTE ""
	array set polar ""
	upvar 0 array set matrix ""
     namespace export vdwfun
}

proc VolArea::VolArea {} {

   package require Tk
	package require GUI 1.0
	package require  Box_Proc 1.0
	package require SQL 1.0
     	#package require vdw 1.0
	package require out 1.0
	package require SASA_Proc 1.0
	package require image 1.0
	package require graph 1.0
	package require vol 1.0
	package require tablelist
	package require math
	package require math::statistics 0.6
	package require xyplot 1.0.0
	package require Plotchart 1.8
    if {[molinfo top]==-1} {
            tk_messageBox -message "Please load a molecule" -title "No molecule"
    }
    if {[winfo exists $VolArea::VolArea]} {
            VolArea::ResetButton
            wm deiconify $VolArea::VolArea
    } else {
                    VolArea::GUI
                    set topLayer [molinfo top]
            if {[molinfo top] != -1} {
                    if {[molinfo $topLayer get numframes]>1} {
                            molinfo $topLayer set frame 0
                    }
                    set VolArea::sizemol [VolArea::box_molecule_size [$VolArea::VolArea.nb1.fp.f1.ensel get] now]
                    VolArea::box_update_dimension
                    VolArea::box_update_center
                    VolArea::drawBox a 12
            } else {
                    set VolArea::sizemol 1

            }
            if {[molinfo top] != -1} {
                    mol top $topLayer
            }
            wm deiconify $VolArea::VolArea
            update
            return $VolArea::VolArea
    }

}

proc VolArea::ResetButton {opt} {

	destroy $VolArea::VolArea
	variable namedb ""
	variable path ""
	variable avgt 0
	array set sum ""
	array set avg ""
	array set stdv ""
	array set resname ""
	array set listpoint ""
	array set list ""
	variable stdvt 0
	variable step 0
	variable sizemol "{0 0 0 } {0 0 0}"
	variable pre 0
	variable sasa 1
	variable vol 1
	variable volatom 0
	variable result ""
	variable RCenter 0
	variable RSize 0
	variable pb 0
	variable matrix
	set VolArea::VolArea ""
	set nameLayer ""
	array set polar ""
	array set matrix ""
	variable hide_volume 0
	variable hide_sasa 0
	set x 0
	foreach x [molinfo list] {
		set nameLayer [lappend nameLayer [molinfo $x get name]]
	}
	set i 0
	while {$i <= $x} {
		if {[lsearch $nameLayer "SASA"] !=-1 || [lsearch $nameLayer "Volume"] !=-1 || [lsearch $nameLayer "Box"] !=-1 || [lsearch $nameLayer "Selection"] !=-1  || [lsearch $nameLayer "No Molecule"] !=-1} {
			set sasaLayer [molinfo index [lsearch $nameLayer "SASA"]]
			mol delete $sasaLayer

			set sasaLayer [molinfo index [lsearch $nameLayer "Volume"]]
			mol delete $sasaLayer


		   set sasaLayer [molinfo index [lsearch $nameLayer "Box"]]
			mol delete $sasaLayer

			set sasaLayer [molinfo index [lsearch $nameLayer "Selection"]]
			mol delete $sasaLayer

			set sasaLayer [molinfo index [lsearch $nameLayer "No Molecule"]]
			mol delete $sasaLayer
			set nameLayer ""
			foreach x [molinfo list] {
				set nameLayer [lappend nameLayer [molinfo $x get name]]
			}
			set i -1
		}
		incr i
	}

	set topLayer [molinfo top]
	VolArea::GUI
	if {[molinfo $topLayer get numframes]>	1} {
		molinfo $topLayer set frame 0
	}

	set VolArea::sizemol [VolArea::box_molecule_size [$VolArea::VolArea.nb1.fp.f1.ensel get] now]
	VolArea::box_update_dimension
	VolArea::box_update_center
	wm deiconify $VolArea::VolArea
	update
	mol top $topLayer
	if {$VolArea::BSel(0) != ""} {
		mol delrep  $VolArea::BSel(0) $topLayer
		set VolArea::BSel(0) ""
		if {$VolArea::BSel(1) != ""} {
			set VolArea::BSel(1) [expr $VolArea::BSel(1) -1]
		}
	}
	if {$VolArea::BSel(1) != ""} {
		mol delrep  $VolArea::BSel(1) $topLayer
		set VolArea::BSel(1) ""
	}

}


proc VolArea::RunButton {} {
 	set do 0
    	set v 0
    	set s 0
	## put computer to think
   	set topLayer [molinfo top]
	foreach x [molinfo list] {
			set nameLayer [lappend nameLayer [molinfo $x get name]]
	}
	set i 0
	while {$i <= $x} {
		if {[lsearch $nameLayer "SASA"] !=-1} {
			set sasaLayer [molinfo index [lsearch $nameLayer "SASA"]]
			mol delete $sasaLayer
		} elseif { [lsearch $nameLayer "Volume"] !=-1} {
			set sasaLayer [molinfo index [lsearch $nameLayer "Volume"]]
			mol delete $sasaLayer
		}
		incr i
	}
    	$VolArea::VolArea configure -cursor watch; update
    	set grid $VolArea::VolArea.nb1.fp.f1
    	set center "[$grid.sx get] [$grid.sy get] [$grid.sz get]"
	set w [$grid.sw get]
    	set h [$grid.sh get]
    	set d [$grid.sd get]
	set xmax [expr [lindex $center 0] + [expr $w/2]]
	set xmin [expr [lindex $center 0] - [expr $w/2]]
    	set ymax [expr [lindex $center 1] + [expr $h/2]]
    	set ymin [expr [lindex $center 1] - [expr $h/2]]
       	set zmax [expr [lindex $center 2] + [expr $d/2]]
       	set zmin [expr [lindex $center 2] - [expr $d/2]]

    	set allselv [atomselect $topLayer "[$VolArea::VolArea.nb1.fp.f1.ensel get] and [$VolArea::VolArea.nb1.fp.fsa.vc.vsel get] and x > $xmin and x < $xmax and y > $ymin and y < $ymax and z > $zmin and z < $zmax"]
	set allsels [atomselect $topLayer "[$VolArea::VolArea.nb1.fp.f1.ensel get] and [$VolArea::VolArea.nb1.fp.fsa.sc.entsel get] and x > $xmin and x < $xmax and y > $ymin and y < $ymax and z > $zmin and z < $zmax"]
	$allselv update
         $allsels update
    	if {[$allselv get name] != "" || [$allsels get name] != ""} {

		set num 0
	if {$VolArea::sasa == 1} {
		incr num 2
	}
	if {$VolArea::vol == 1} {
		incr num 2
	}

	$VolArea::VolArea.nb1.fp.pg configure -maximum [expr round([expr [expr [expr [$VolArea::VolArea.nb1.fp.fs.spto get] - [$VolArea::VolArea.nb1.fp.fs.spfrom get]] / [$VolArea::VolArea.nb1.fp.fs.spstep get]] * $num] )]
    	if {$VolArea::sasa == 1} {
            VolArea::savefile
            if {$VolArea::path != ""} {
                    sqlite $VolArea::namedb $VolArea::path
                    VolArea::saveinputfile
                    VolArea::setvalues
                    VolArea::ShowSasa
            $VolArea::VolArea.nb1.fo.f2.tb configure -state normal
            $VolArea::VolArea.nb1.fo.f2.tb delete 0 end
            $VolArea::VolArea.nb1.fo.f2.tb configure -state disable
            for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} { incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
               update
               VolArea::maketablecurrent $i [$VolArea::VolArea.nb1.fp.fs.spfrom get]
               incr VolArea::pb
            }
            set s 1
            $VolArea::namedb close
            }
            $VolArea::VolArea.nb1.fp.f1.sw configure -state disable
            $VolArea::VolArea.nb1.fp.f1.sh configure -state disable
            $VolArea::VolArea.nb1.fp.f1.sd configure -state disable
            $VolArea::VolArea.nb1.fp.f1.sx configure -state disable
            $VolArea::VolArea.nb1.fp.f1.sy configure -state disable
            $VolArea::VolArea.nb1.fp.f1.sz configure -state disable
    	}
    	if {$VolArea::vol == 1} {
            if {$VolArea::sasa == 0} {
                    VolArea::savefile
                    if {$VolArea::path != ""} {
                           sqlite $VolArea::namedb $VolArea::path
                           VolArea::saveinputfile
                           VolArea::setvalues
                           $VolArea::namedb close
                    }
            }
            if {$VolArea::path != ""} {
            sqlite $VolArea::namedb $VolArea::path
             for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} { incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
               update
               if {$VolArea::RCenter==1} {
                  $VolArea::VolArea.nb1.fp.f1.sw configure -state normal
                  $VolArea::VolArea.nb1.fp.f1.sh configure -state normal
                  $VolArea::VolArea.nb1.fp.f1.sd configure -state normal
                  $VolArea::VolArea.nb1.fp.f1.sx configure -state normal
                  $VolArea::VolArea.nb1.fp.f1.sy configure -state normal
                  $VolArea::VolArea.nb1.fp.f1.sz configure -state normal
                  if {$VolArea::RSize == 0} {
                     VolArea::sel [$VolArea::VolArea.nb1.fp.f1.enrecenter get] $i 3
                  } else {
                    VolArea::sel [$VolArea::VolArea.nb1.fp.f1.enrecenter get] $i 2
                  }
                  $VolArea::VolArea.nb1.fp.f1.sw configure -state disable
                  $VolArea::VolArea.nb1.fp.f1.sh configure -state disable
                  $VolArea::VolArea.nb1.fp.f1.sd configure -state disable
                  $VolArea::VolArea.nb1.fp.f1.sx configure -state disable
                  $VolArea::VolArea.nb1.fp.f1.sy configure -state disable
                  $VolArea::VolArea.nb1.fp.f1.sz configure -state disable
               }
               VolArea::startVol $i [$VolArea::VolArea.nb1.fp.fs.spto get]
               incr VolArea::pb
            }
            set v 1
            VolArea::calcall
            array unset VolArea::matrix
            $VolArea::namedb close

            }
    	}
	  if {$VolArea::vol == 1 && $v==1} {
	       sqlite $VolArea::namedb $VolArea::path
	       $VolArea::VolArea.nb1.fo.v.rep.pr.cb1 set "IsoSurface"
		VolArea::showVol [$VolArea::VolArea.nb1.fp.fs.spfrom get] 0
		$VolArea::namedb close
	  }
	  if {$VolArea::sasa == 1 && $s==1} {
    		  sqlite $VolArea::namedb $VolArea::path
    		  VolArea::LoadFile 2
    		  $VolArea::namedb close
	  }
	if {[molinfo [molinfo top] get numframes] > 1} {
		$VolArea::VolArea.nb1.fo.fbu.b configure -state normal
	}

        	$VolArea::VolArea.nb1.fo.fbu.exp configure -state normal
	} else {
	tk_messageBox -message "Please choose a valide box conformation" -title "Box Error" -type ok
	}
      unset upproc_var_$allselv
      unset upproc_var_$allsels
	mol top $topLayer
        wm deiconify $VolArea::VolArea
	$VolArea::VolArea configure -cursor {}; update
        return

}

proc VolArea::Load {} {
    ## put computer to think
    $VolArea::VolArea configure -cursor watch; update
        sqlite $VolArea::namedb $VolArea::path
    if {[expr $VolArea::pre + [$VolArea::VolArea.nb1.fp.fs.spstep get] ] > [$VolArea::VolArea.nb1.fp.fs.spto get]} {
                $VolArea::VolArea.nb1.fo.f1.spfra set $VolArea::pre
                $VolArea::VolArea.nb1.fo.f1.spfra set [$VolArea::VolArea.nb1.fp.fs.spfrom get]
                set VolArea::pre [$VolArea::VolArea.nb1.fo.f1.spfra get]
                } else {
                        set VolArea::pre [$VolArea::VolArea.nb1.fo.f1.spfra get]
                }
                    set topLayer [molinfo top]
            molinfo $topLayer  set frame [$VolArea::VolArea.nb1.fo.f1.spfra get]
        if {$VolArea::RCenter==1} {
                $VolArea::VolArea.nb1.fp.f1.sw configure -state normal
                $VolArea::VolArea.nb1.fp.f1.sh configure -state normal
                $VolArea::VolArea.nb1.fp.f1.sd configure -state normal
                $VolArea::VolArea.nb1.fp.f1.sx configure -state normal
                $VolArea::VolArea.nb1.fp.f1.sy configure -state normal
                $VolArea::VolArea.nb1.fp.f1.sz configure -state normal
                if {$VolArea::RSize == 0} {
                            VolArea::sel [$VolArea::VolArea.nb1.fp.f1.enrecenter get] [$VolArea::VolArea.nb1.fo.f1.spfra get] 3
                    } else {
                            VolArea::sel [$VolArea::VolArea.nb1.fp.f1.enrecenter get] [$VolArea::VolArea.nb1.fo.f1.spfra get] 2
                    }
                $VolArea::VolArea.nb1.fp.f1.sw configure -state disable
                $VolArea::VolArea.nb1.fp.f1.sh configure -state disable
                $VolArea::VolArea.nb1.fp.f1.sd configure -state disable
                $VolArea::VolArea.nb1.fp.f1.sx configure -state disable
                $VolArea::VolArea.nb1.fp.f1.sy configure -state disable
                $VolArea::VolArea.nb1.fp.f1.sz configure -state disable
        }
        if {$VolArea::sasa==1} {
                VolArea::LoadFile 0
        }
        if {$VolArea::vol==1} {

                VolArea::showVol [$VolArea::VolArea.nb1.fo.f1.spfra get] 1
        }

        $VolArea::namedb close
        $VolArea::VolArea configure -cursor {}; update
}

proc VolArea::LoadButton {} {
    set topLayer [molinfo top]
    ## put computer to think
    $VolArea::VolArea configure -cursor watch; update

    set types {
            {{VolArea}       {.srfv}        }
    }
    set VolArea::path ""
    set VolArea::path [tk_getOpenFile -filetypes $types]
    set nameLayer ""
    set x 0
    foreach x [molinfo list] {
            set nameLayer [lappend nameLayer [molinfo $x get name]]
    }
    if {[lsearch $nameLayer "SASA"] !=-1 || [lsearch $nameLayer "Volume"] !=-1 || [lsearch $nameLayer "Box"] !=-1 || [lsearch $nameLayer "Selection"] !=-1} {
            set sasaLayer [molinfo index [lsearch $nameLayer "SASA"]]
            mol delete $sasaLayer

                    set sasaLayer [molinfo index [lsearch $nameLayer "SASA"]]
            mol delete $sasaLayer

            set sasaLayer [molinfo index [lsearch $nameLayer "Volume"]]
            mol delete $sasaLayer


                    set sasaLayer [molinfo index [lsearch $nameLayer "Box"]]
            mol delete $sasaLayer

            set sasaLayer [molinfo index [lsearch $nameLayer "Selection"]]
            mol delete $sasaLayer
            }
    set name "volume"
    set lis ""
     set i 0

    if {$VolArea::path != ""} {
            sqlite $VolArea::namedb $VolArea::path
            $VolArea::VolArea.btload.en configure -state normal
            $VolArea::VolArea.btload.en delete 0 end
            VolArea::setvalues
            molinfo $topLayer set frame [$VolArea::VolArea.nb1.fo.f1.spfra get]
            set molname [$VolArea::namedb eval "SELECT molname FROM inputfile"]
            if {$molname != [molinfo $topLayer get name]} {
                    tk_messageBox -title "Warning" -message "The database file doesn't correspond to the choosen molecule" -type ok -icon info
            } else {
                    set VolArea::sasa [$VolArea::namedb eval "SELECT sasaSel FROM inputfile"]
                    set VolArea::vol [$VolArea::namedb eval "SELECT volSel FROM inputfile"]
                    set VolArea::volatom [$VolArea::namedb eval "SELECT volAt FROM inputfile"]
                    if {$VolArea::sasa ==1} {
                            VolArea::LoadFile 1
                    }
                    if {$VolArea::vol==1} {
                            if {$VolArea::sasa ==0} {
                                    $VolArea::VolArea.nb1.fo.f2.tb delete 0 end
                                    $VolArea::VolArea.nb1.fo.f2.tb configure -state disable
                            }
														$VolArea::VolArea.nb1.fo.v.rep.pr.cb1 set "IsoSurface"
                            VolArea::showVol [$VolArea::VolArea.nb1.fo.f1.spfra get] 0


                    } else {
                            $VolArea::VolArea.nb1.fo.v.vol.tbt delete 0 end
                            $VolArea::VolArea.nb1.fo.v.vol.tbt configure -state disable

                    }
            }

            if {[molinfo $topLayer get numframes] > 1} {
                            $VolArea::VolArea.nb1.fo.fbu.b configure -state normal
            }
            $VolArea::VolArea.nb1.fo.fbu.exp configure -state normal
            $VolArea::namedb close
    }
    $VolArea::VolArea configure -cursor {}; update
    mol top $topLayer

}

proc VolArea::edgraph {} {
    if {$VolArea::vol==1} {
    	VolArea::makegraph #ffffcc
       	VolArea::addseriesvol  #ffffcc black

    }
    if {$VolArea::sasa==1} {
    	if {$VolArea::vol==0} {
    		VolArea::makegraph #ffffcc
    	}
        	VolArea::addseries sasa black

    }
    $VolArea::namedb close
}

proc VolArea::checksavo {} {
    set topLayer [molinfo top]
    set grid $VolArea::VolArea.nb1.fp.fsa
    if {$VolArea::sasa==1} {
            $grid.sb.spr configure -state normal
            $grid.sb.sprs configure -state normal
            $grid.sc.entsel configure -state normal
    } else {
            $grid.sb.spr configure -state disable
            $grid.sb.sprs configure -state disable
            $grid.sc.entsel configure -state disable
            if {[info exists VolArea::BSel(0)]} {
                    if {$VolArea::BSel(0) != ""} {
                            mol delrep  $VolArea::BSel(0) $topLayer
                            set VolArea::BSel(0) ""
                            if {$VolArea::BSel(1) != ""} {
                                    set VolArea::BSel(1) [expr $VolArea::BSel(1) - 1]
                            }
                    }
            }


    }
    if {$VolArea::vol==1} {
               $grid.vb.spsv configure -state normal
               $grid.vch.chva configure -state normal
               $grid.vc.vsel configure -state normal
    } else {
               $grid.vb.spsv configure -state disable
               $grid.vch.chva configure -state disable
               $grid.vc.vsel configure -state disable
               if {$VolArea::BSel(1) != ""} {
                       mol delrep  $VolArea::BSel(1) $topLayer
                       set VolArea::BSel(1) ""
               }

    }
}

proc VolArea::viewSel {} {
    set grid $VolArea::VolArea.nb1.fp.f1
    set center "[$grid.sx get] [$grid.sy get] [$grid.sz get]"
    set w [$grid.sw get]
    set h [$grid.sh get]
    set d [$grid.sd get]
    set xmax [expr [lindex $center 0] + [expr $w/2]]
    set xmin [expr [lindex $center 0] - [expr $w/2]]
    set ymax [expr [lindex $center 1] + [expr $h/2]]
    set ymin [expr [lindex $center 1] - [expr $h/2]]
    set zmax [expr [lindex $center 2] + [expr $d/2]]
    set zmin [expr [lindex $center 2] - [expr $d/2]]

    set topLayer [molinfo top]
    if {$VolArea::BSel(0) == "" && $VolArea::BSel(1) == ""} {
            if {$VolArea::sasa==1} {
                    set repr "Surf"

                    mol selection ""
                    mol selection "[$VolArea::VolArea.nb1.fp.f1.ensel get] and [$VolArea::VolArea.nb1.fp.fsa.sc.entsel get] and x > $xmin and x < $xmax and y > $ymin and y < $ymax and z > $zmin and z < $zmax"
                    mol representation $repr
                    mol color "ColorID 1"
                    mol addrep $topLayer
                    set ind [molinfo $topLayer get numreps]
                    mol modrep $ind $topLayer
                    set VolArea::BSel(0) [expr $ind -1]
            }
            if {$VolArea::vol==1} {
                    set repr "Surf"

                    mol selection ""
                    mol selection "[$VolArea::VolArea.nb1.fp.f1.ensel get] and [$VolArea::VolArea.nb1.fp.fsa.vc.vsel get] and x > $xmin and x < $xmax and y > $ymin and y < $ymax and z > $zmin and z < $zmax"
                    mol representation $repr
                    mol color "ColorID 0"
                    mol addrep $topLayer
                    set ind [molinfo $topLayer get numreps]
                    mol modrep $ind $topLayer
                    set VolArea::BSel(1) [expr $ind -1]
            }
    } else  {
            if {$VolArea::sasa==1} {
                    if {$VolArea::BSel(0) != ""} {
                            mol delrep  $VolArea::BSel(0) $topLayer
                            set VolArea::BSel(0) ""
                    }

            }
            if {$VolArea::vol==1} {
                    if {$VolArea::sasa==1} {
                            set VolArea::BSel(1) [expr $VolArea::BSel(1) - 1]
                    }
                    if {$VolArea::BSel(1) != ""} {
                            mol delrep  $VolArea::BSel(1) $topLayer
                            set VolArea::BSel(1) ""
                    }

            }
    }


}

proc VolArea::export {} {
    set types {
            {{Data}       {.txt}        }
    }
    set file [tk_getSaveFile -defaultextension ".txt" -filetypes $types]
    if {$file != ""} {
            sqlite $VolArea::namedb $VolArea::path
            set fil [open $file w]
            for {set nfr [$VolArea::VolArea.nb1.fp.fs.spfrom get]} { $nfr <= [$VolArea::VolArea.nb1.fp.fs.spto get]} {incr nfr  [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
                    set stid [$VolArea::namedb eval "SELECT resname,id,chain,sasa,SasaMean,STDV FROM frame_$nfr ORDER BY id asc"]
                    puts $fil "-----------------------	--------------	--------------	--------------	--------------"
                    puts $fil "frame $nfr"
                    set i 0
                    while {[lindex $stid $i] != ""} {
                            set lis [lrange $stid $i [expr $i +5]]
                            set li [lindex $lis 1]
                            set name [lindex $lis 0]

                            set chain [lindex $lis 2]
                            if {$chain == " "} {
                                set chain "?"
                            }
                            if {$name == "ALL"} {
                                     puts $fil "Sasa_Data"
                            } elseif {$name == "volume"} {
                                    puts $fil "Cavity_Volume_Data"
                            } elseif {$name == "volatom"} {
                                    puts $fil "Atom_Volume_Data"
                            }

                            set val [lindex $lis 3]
                            set val [string trim $val "{"]
                            set val [string trim $val "}"]
                            set valmean [lindex $lis 4]
                            set valmean [string trim $valmean "{"]
                            set valmean [string trim $valmean "}"]
                            set valstdv [lindex $lis 5]
                            set valstdv [string trim $valstdv "{"]
                            set valstdv [string trim $valstdv "}"]
                            set un "_"
                            puts $fil "$name$li$un$chain\t$val\t$valmean\t$valstdv"
                            incr i 6

                    }
            }
             close $fil

            set h 0
            set fil [open $file r+]
            set path [split $file "/"]
            set filname [file rootname [lindex $path end]]
            set path [file dirname $file]
                    set und "_"
            array set sasa ""
            array set vol ""
            set res ""
            set res_vol ""
            if {$VolArea::sasa==1} {
                    set str "SASA"
                    set out_sasa [open "$path/$filname$und$str.txt" w+]
            }
            if {$VolArea::vol==1} {
                    set str "vol"
                    set out_vol [open "$path/$filname$und$str.txt" w+]
            }
            set h 0
            while {[eof $fil]!= 1} {
                    set linha [gets $fil]
                    set linha [split $linha "\t"]
                    if {$VolArea::sasa==1} {
                            if {[lindex $linha 0] == "Sasa_Data"} {
                                    set linha [gets $fil]
                                    set linha [split $linha "\t"]
                                    while {[lindex $linha 0] != "-----------------------" && [eof $fil] != 1} {
                                                if { [lsearch $res [lindex $linha 0] ] == -1} {
                                                        set res [append res "[lindex $linha 0]\t" ]

                                                }
                                                set sasa([lindex $linha 0],$h) [lindex $linha 1]
                                                set linha [gets $fil]
                                                set linha [split $linha "\t"]
                                        }
                                        if {[lindex $linha 0] == "-----------------------"} {
                                                incr h
                                        }
                                    }
                    }
                    if {$VolArea::vol==1} {
                            if {[lindex $linha 0] == "Cavity_Volume_Data" || [lindex $linha 0] == "Atom_Volume_Data"} {
                                set linha [gets $fil]
                                set linha [split $linha "\t"]
                                    if { [lsearch $res_vol [lindex $linha 0] ] == -1} {
                                            set res_vol [lappend res_vol [lindex $linha 0] ]

                                    }
                                    set vol([lindex $linha 0],$h) [lindex $linha 1]

                        }
                            if {[lindex $linha 0] == "-----------------------"} {
                                incr h
                            }
                    }
            }
            close $fil
            if {$VolArea::sasa==1} {
                    puts $out_sasa $res
                    for {set i 0} {$i<= $h} {incr i} {
                                set j 0
                                set srt ""
                                while {$j<=[expr [llength $res]-1]} {
                                        set resname [lindex $res $j]
                                        if {[info exists sasa($resname,$i)] == 0} {
                                                set srt [append srt "\t"]
                                        } else {
                                                set srt [append srt "$sasa($resname,$i)\t"]

                                        }
                                        incr j
                                }
                            if {$srt != ""} {
                                    puts $out_sasa $srt
                            }
                    }
                    close $out_sasa
            }
            if {$VolArea::vol==1} {
                    puts $out_vol "ATOM CAVITY"
                      for {set i 0} {$i<= $h} {incr i} {
                                  set j 0
                                  set srt ""
                                  while {$j<=[expr [llength $res_vol]-1]} {
                                          set resname [lindex $res_vol $j]
                                          if {[info exists vol($resname,$i)] == 0} {
                                                  set srt [append srt "\t"]
                                          } else {
                                                  set srt [append srt "$vol($resname,$i)\t"]

                                          }
                                          incr j
                                  }
                              if {$srt != ""} {
                                      puts $out_vol $srt
                              }

                      }
                      close $out_vol
            }

    }

}
proc VolArea::spinfrom {} {
    if {[expr [$VolArea::VolArea.nb1.fp.fs.spto get] - [$VolArea::VolArea.nb1.fp.fs.spfrom get]] > 0} {
        $VolArea::VolArea.nb1.fp.fs.spstep configure -to [expr [$VolArea::VolArea.nb1.fp.fs.spto get] - [$VolArea::VolArea.nb1.fp.fs.spfrom get]]

    }
    if {[expr [$VolArea::VolArea.nb1.fp.fs.spto get] - [$VolArea::VolArea.nb1.fp.fs.spfrom get]]<0} {
            $VolArea::VolArea.nb1.fp.fs.spto set [$VolArea::VolArea.nb1.fp.fs.spfrom get]
    }
}
proc VolArea::spinsasa {} {
    if {[$VolArea::VolArea.nb1.fp.fsa.sb.spr get] > 10} {
            $VolArea::VolArea.nb1.fp.fsa.sb.spr set 10
    }
    if {[$VolArea::VolArea.nb1.fp.fsa.sb.spr get] < 0.05} {
     $VolArea::VolArea.nb1.fp.fsa.sb.spr set 0.05
    }

    if {[$VolArea::VolArea.nb1.fp.fsa.sb.sprs get] > 5000} {
            $VolArea::VolArea.nb1.fp.fsa.sb.sprs set 5000
    }

    if {[$VolArea::VolArea.nb1.fp.fsa.sb.sprs get] < 1} {
                            $VolArea::VolArea.nb1.fp.fsa.sb.sprs set 1
    }

}

proc VolArea::spincav {} {
    if {[$VolArea::VolArea.nb1.fp.fsa.vb.spr get] > 10} {
            $VolArea::VolArea.nb1.fp.fsa.sb.spr set 10
    }
    if {[$VolArea::VolArea.nb1.fp.fsa.sb.spr get] < 0} {
     $VolArea::VolArea.nb1.fp.fsa.sb.spr set 0.00
    }

}
proc VolArea::checkre {} {

    set topLayer [molinfo top]
    set selection [atomselect $topLayer [$VolArea::VolArea.nb1.fp.f1.enrecenter get]]
    if {[$selection get name]==""} {
            tk_messageBox -title "Warning" -message "Please choose a valide selection" -type ok -icon info
    }
}


proc VolArea::Unlock {} {
    set grid $VolArea::VolArea.nb1.fp
    $grid.fsa.sb.spr configure -state normal
    $grid.fsa.sb.sprs configure -state normal
    $grid.fsa.chs configure -state normal
    $grid.fsa.chv configure -state normal
    $grid.fsa.vb.spsv configure -state normal
    $grid.fsa.vb.spr configure -state normal
    $grid.fs.spfrom configure -state normal
    $grid.fs.spto configure -state normal
    $grid.fs.spstep configure -state normal
    $grid.fsa.vch.chva configure -state normal
    $grid.rru.b1 configure -state normal
    $grid.f1.sw configure -state normal
    $grid.f1.sh configure -state normal
    $grid.f1.sd configure -state normal
    $grid.f1.sx configure -state normal
    $grid.f1.sy configure -state normal
    $grid.f1.sz configure -state normal
    $grid.fsa.vc.vsel configure -state normal
    $grid.f1.enrecenter configure -state normal
    $grid.f1.ensel configure -state normal
    $grid.fsa.sc.entsel configure -state normal
    $grid.f1.chrecenter configure -state normal
    $grid.f1.chresize configure -state normal
    variable pb 0
    variable stdvt 0
    array unset ::VolArea::sum
    array set ::VolArea::sum ""
    array unset ::VolArea::avg
    array set ::VolArea::avg ""
    array unset ::VolArea::stdv
    array set ::VolArea::stdv ""
    array unset ::VolArea::resname
    array set ::VolArea::resname ""
    array unset ::VolArea::list
    array set ::VolArea::list ""
    array unset ::VolArea::listpoint
    array set ::VolArea::listpoint ""
}
