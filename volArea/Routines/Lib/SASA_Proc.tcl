#!/bin/sh
# SASA_Proc.tcl \
exec tclsh "$0" ${1+"$@"}
package provide SASA_Proc 1.0

proc VolArea::ShowSasa {} {
	set topLayer [molinfo top]
	set selection ""
	set safeArea 0
	set nameLayer ""
	foreach x [molinfo list] {
        	set nameLayer [lappend nameLayer end [molinfo $x get name]]
    }
    if {[lsearch $nameLayer "SASA"] !=-1} {
        	set sasaLayer [molinfo index [lsearch $nameLayer "SASA"]]
            mol delete $sasaLayer
		set conf [lsearch $nameLayer "SASA"]
	}
	$VolArea::VolArea.nb1.fp.f1.sw configure -state normal
	$VolArea::VolArea.nb1.fp.f1.sh configure -state normal
	$VolArea::VolArea.nb1.fp.f1.sd configure -state normal
	$VolArea::VolArea.nb1.fp.f1.sx configure -state normal
	$VolArea::VolArea.nb1.fp.f1.sy configure -state normal
	$VolArea::VolArea.nb1.fp.f1.sz configure -state normal
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
	$VolArea::VolArea.nb1.fp.f1.sw configure -state disable
	$VolArea::VolArea.nb1.fp.f1.sh configure -state disable
	$VolArea::VolArea.nb1.fp.f1.sd configure -state disable
	$VolArea::VolArea.nb1.fp.f1.sx configure -state disable
	$VolArea::VolArea.nb1.fp.f1.sy configure -state disable
	$VolArea::VolArea.nb1.fp.f1.sz configure -state disable
    for {set nfr [$VolArea::VolArea.nb1.fp.fs.spfrom get]} { $nfr <= [$VolArea::VolArea.nb1.fp.fs.spto get]} {incr nfr  [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
		    	incr VolArea::pb
				if {$VolArea::RCenter==1} {
					$VolArea::VolArea.nb1.fp.f1.sw configure -state normal
					$VolArea::VolArea.nb1.fp.f1.sh configure -state normal
					$VolArea::VolArea.nb1.fp.f1.sd configure -state normal
					$VolArea::VolArea.nb1.fp.f1.sx configure -state normal
					$VolArea::VolArea.nb1.fp.f1.sy configure -state normal
					$VolArea::VolArea.nb1.fp.f1.sz configure -state normal
					if {$VolArea::RSize == 0} {
						VolArea::sel [$VolArea::VolArea.nb1.fp.f1.enrecenter get] $nfr 3
					} else {
						VolArea::sel [$VolArea::VolArea.nb1.fp.f1.enrecenter get] $nfr 2
					}
					$VolArea::VolArea.nb1.fp.f1.sw configure -state disable
					$VolArea::VolArea.nb1.fp.f1.sh configure -state disable
					$VolArea::VolArea.nb1.fp.f1.sd configure -state disable
					$VolArea::VolArea.nb1.fp.f1.sx configure -state disable
					$VolArea::VolArea.nb1.fp.f1.sy configure -state disable
					$VolArea::VolArea.nb1.fp.f1.sz configure -state disable
				}

				set ibsel [$VolArea::VolArea.nb1.fp.f1.ensel get]

				set allsel [atomselect $topLayer "$ibsel and x >= [expr $xmin -4] and x <= [expr $xmax +4] and y >= [expr $ymin -4] and y <= [expr $ymax +4] and z >= [expr $zmin -4] and z <= [expr $zmax +4]" frame $nfr]

				$allsel frame $nfr
				$allsel update
				set select ""
				set idd -1
				set sel ""
				set un "_"
				$VolArea::namedb eval "CREATE TABLE if not exists frame_$nfr (resname TEXT,id INTEGER, chain TEXT, xyz TEXT , sasa TEXT, SasaMean TEXT, STDV TEXT)"
				foreach  index [$allsel get resid] name [$allsel get resname] chain [$allsel get chain] {
					if {$idd != "$index$un$name$chain"} {

							set list ""
							set pointsMem ""

			    			set sasa ""
						if {$chain != ""} {
							set sel [atomselect $topLayer "[$VolArea::VolArea.nb1.fp.fsa.sc.entsel get] and (resid $index and resname $name and chain $chain) and x >= $xmin and x <= $xmax and y >= $ymin and y <= $ymax and z >= $zmin and z <= $zmax"  frame $nfr]

						} else {
							set sel [atomselect $topLayer "[$VolArea::VolArea.nb1.fp.fsa.sc.entsel get] and (resid $index and resname $name) and x >= $xmin and x <= $xmax and y >= $ymin and y <= $ymax and z >= $zmin and z <= $zmax"  frame $nfr]
 						}

			    	$sel frame $nfr
						$sel update

	          set sasa [measure sasa [$VolArea::VolArea.nb1.fp.fsa.sb.spr get] $allsel -restrict $sel -points pts -samples [$VolArea::VolArea.nb1.fp.fsa.sb.sprs get]]
			    			if {$sasa>=0 && [lsearch $select $index$un$name$chain] == -1} {
									set un "_"
					    				set select "$select $index$un$name$chain"
					    				foreach pt $pts {
					    					if {([lindex $pt 0] >= $xmin && [lindex $pt 0] <= $xmax) && \
					    					    ([lindex $pt 1] >= $ymin && [lindex $pt 1] <= $ymax) && \
					    					    ([lindex $pt 2] >= $zmin && [lindex $pt 2] <= $zmax) } {
					        					set pointsMem  [lappend pointsMem $pt]
										        set sasa [format %7.3f $sasa]
					    					}

					    				}
									set pts ""
									if {$pointsMem!=""} {
							    			$VolArea::namedb busy
										if {$chain != ""} {

											$VolArea::namedb eval "INSERT INTO frame_$nfr (resname, id, chain, xyz , sasa) VALUES(:name,:index, :chain, :pointsMem ,:sasa)"
										} else {
											set chain " "
											$VolArea::namedb eval "INSERT INTO frame_$nfr (resname, id, chain, xyz , sasa) VALUES(:name,:index,:chain, :pointsMem ,:sasa)"
										}
									}
									set idd "$index$un$name$chain"
									set sasa ""
									set name ""
									set index ""
									set pointsMem ""
									set chain ""
			    			}
            unset upproc_var_$sel
					}
					set idd "$index$un$name$chain"

					update
		    }

			unset upproc_var_$allsel
			#wm deiconify $VolArea::VolArea
			update
    }

}
