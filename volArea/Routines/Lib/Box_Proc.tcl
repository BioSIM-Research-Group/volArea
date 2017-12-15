#!/bin/sh
# Box_Proc.tcl \
exec tclsh "$0" ${1+"$@"}
package provide Box_Proc 1.0

proc VolArea::sel {text numframe opt} {
	set topLayer [molinfo top]
	set selection [atomselect $topLayer $text frame $numframe]
	$selection update
	set grid $VolArea::VolArea.nb1.fp.f1

	if {[$selection get name] != ""} {
		if  {$opt == 3} {
			set w [$grid.sw get]
			set h [$grid.sh get]
			set d [$grid.sd get]
			set VolArea::sizemol [VolArea::box_molecule_size [$VolArea::VolArea.nb1.fp.f1.enrecenter get] $numframe]
			$grid.sw set [expr ((([lindex  [lindex $VolArea::sizemol 1] 0]- [lindex  [lindex $VolArea::sizemol 0] 0])))]
			$grid.sh set [expr ((([lindex  [lindex $VolArea::sizemol 1] 1]- [lindex  [lindex $VolArea::sizemol 0] 1])))]
		       $grid.sd set [expr ((([lindex  [lindex $VolArea::sizemol 1] 2]- [lindex  [lindex $VolArea::sizemol 0] 2])))]
			VolArea::box_update_center
			VolArea::drawBox a 0
    			$grid.sw set $w
    			$grid.sh set $h
    			$grid.sd set $d
			set VolArea::sizemol [VolArea::box_molecule_size "all" $numframe]
			VolArea::box_update_center
			VolArea::drawBox a 0
		} elseif {$opt==2} {
			set VolArea::sizemol [VolArea::box_molecule_size [$VolArea::VolArea.nb1.fp.f1.enrecenter get] $numframe]
			$grid.sw set [expr ((([lindex  [lindex $VolArea::sizemol 1] 0]- [lindex  [lindex $VolArea::sizemol 0] 0])))]
			$grid.sh set [expr ((([lindex  [lindex $VolArea::sizemol 1] 1]- [lindex  [lindex $VolArea::sizemol 0] 1])))]
		    	$grid.sd set [expr ((([lindex  [lindex $VolArea::sizemol 1] 2]- [lindex  [lindex $VolArea::sizemol 0] 2])))]
			VolArea::box_update_center
			VolArea::drawBox a 0
			set VolArea::sizemol [VolArea::box_molecule_size "all" $numframe]
			VolArea::box_update_center
			VolArea::drawBox a 0
		}  else {
			set VolArea::sizemol [VolArea::box_molecule_size [$VolArea::VolArea.nb1.fp.f1.enrecenter get] $numframe]
			VolArea::box_update_dimension
			VolArea::box_update_center
			VolArea::drawBox a 0
		}
		unset upproc_var_$selection
	} else {
		tk_messageBox -title "Warning" -message "Please choose a valide selection" -type ok -icon info
	}
}
proc VolArea::box_molecule_size {text numfra} {
	set topLayer [molinfo top]
	set selection [atomselect $topLayer $text frame $numfra]
	$selection update
	set sx [$selection get x]; set sy [$selection get y]; set sz [$selection get z]
	set minx [lindex $sx 0]; set miny [lindex $sy 0]; set minz [lindex $sz 0]
	set maxx $minx; set maxy $miny; set maxz $minz


	foreach x $sx y $sy z $sz {
		if {$x < $minx} {set minx [format %4.1f $x]} else {if {$x > $maxx} {set maxx [format %4.1f $x]}}
		if {$y < $miny} {set miny [format %4.1f $y]} else {if {$y > $maxy} {set maxy [format %4.1f $y]}}
		if {$z < $minz} {set minz [format %4.1f $z]} else {if {$z > $maxz} {set maxz [format %4.1f $z]}}
	}
	## increase the radius by 5 angstroms to see all asa
	set val 2
	return [list [list [expr $minx-$val] [expr $miny-$val] [expr $minz-$val]] [list [expr $maxx+$val] [expr $maxy +$val] [expr $maxz+$val]]]
	unset upproc_var_$selection
}

proc VolArea::box_update_dimension {} {
    	set grid $VolArea::VolArea.nb1.fp.f1

    	# Update the values of the box dimension
    	$grid.sw configure  -from 0
    	$grid.sw configure  -to   [expr ((([lindex  [lindex $VolArea::sizemol 1] 0]- [lindex  [lindex $VolArea::sizemol 0] 0])))]
	$grid.sh configure  -from 0
    	$grid.sh configure  -to   [expr ((([lindex  [lindex $VolArea::sizemol 1] 1]- [lindex  [lindex $VolArea::sizemol 0] 1])))]
	$grid.sd configure  -from 0
    	$grid.sd configure  -to   [expr ((([lindex  [lindex $VolArea::sizemol 1] 2]- [lindex  [lindex $VolArea::sizemol 0] 2])))]

	$grid.sw set [expr ((([lindex  [lindex $VolArea::sizemol 1] 0]- [lindex  [lindex $VolArea::sizemol 0] 0])))]
	$grid.sh set [expr ((([lindex  [lindex $VolArea::sizemol 1] 1]- [lindex  [lindex $VolArea::sizemol 0] 1])))]
	$grid.sd set [expr ((([lindex  [lindex $VolArea::sizemol 1] 2]- [lindex  [lindex $VolArea::sizemol 0] 2])))]



}
proc VolArea::box_update_center {} {
    	set grid $VolArea::VolArea.nb1.fp.f1

    	# Update the values of the box center
	set maxx [expr [lindex  [lindex $VolArea::sizemol 1] 0] - [$grid.sw get]/2]
	set minx [expr [lindex  [lindex $VolArea::sizemol 0] 0] + [$grid.sw get]/2]
	set maxy [expr [lindex  [lindex $VolArea::sizemol 1] 1] - [$grid.sh get]/2]
	set miny [expr [lindex  [lindex $VolArea::sizemol 0] 1] + [$grid.sh get]/2]
	set maxz [expr [lindex  [lindex $VolArea::sizemol 1] 2] - [$grid.sd get]/2]
	set minz [expr [lindex  [lindex $VolArea::sizemol 0] 2] + [$grid.sd get]/2]

	$grid.sx configure  -from $minx
    	$grid.sx configure  -to   $maxx
    	$grid.sy configure  -from $miny
    	$grid.sy configure  -to   $maxy
    	$grid.sz configure  -from $minz
    	$grid.sz configure  -to   $maxz

}

proc VolArea::drawBox {conf lixo} {
	variable topLayer
	set grid  $VolArea::VolArea.nb1.fp.f1
	global boxLayer

	if {[molinfo top]!=-1} {
		set topLayer [molinfo top]

		set boxVariance 1; set nameLayer ""
		foreach x [molinfo list] {set nameLayer [linsert $nameLayer end [molinfo $x get name]]}


        	if {[lsearch $nameLayer "Box"]==-1} {
        		# save orientation and zoom parameters
         		   set viewpoints [molinfo $topLayer get {center_matrix rotate_matrix scale_matrix global_matrix}]

        		# Creates a new layer for the drawing
        		mol load graphics "Box"; set boxLayer [molinfo top]

        		# restore orientation and zoom of the new layer
        			molinfo $boxLayer set {center_matrix rotate_matrix scale_matrix global_matrix} $viewpoints
        	} else {set boxLayer [molinfo index [lsearch $nameLayer "Box"]]}
		graphics $boxLayer delete all


        	set width 2

        	set center "[$grid.sx get] [$grid.sy get] [$grid.sz get]"

        	set boxW [expr [$grid.sw get]* $boxVariance /2]
        	set boxH [expr [$grid.sh get]* $boxVariance /2]
        	set boxD [expr [$grid.sd get]* $boxVariance /2]

        	graphics $boxLayer color yellow
        		graphics $boxLayer line "[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]+($boxD)]" \
        				     	"[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]+($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]+($boxD)]" \
        				     	"[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]+($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]-($boxD)]" \
        				     	"[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]+($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]-($boxD)]" \
        				     	"[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]+($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]-($boxD)]" \
        				     	"[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]-($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]+($boxD)]" \
        				     	"[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]+($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]+($boxD)]" \
        				     	"[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]-($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]+($boxD)]" \
        				     	"[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]-($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]-($boxD)]" \
        				     	"[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]-($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]+($boxD)]" \
        				     	"[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]+($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]+($boxH)] [expr [lindex $center 2]-($boxD)]" \
        				     	"[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]-($boxD)]" width $width
        		graphics $boxLayer line "[expr [lindex $center 0]-($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]-($boxD)]" \
        				     	"[expr [lindex $center 0]+($boxW)] [expr [lindex $center 1]-($boxH)] [expr [lindex $center 2]-($boxD)]" width $width
            if {[string compare $conf "b"]==0} {
            	if {$lixo == 5} {
            		set VolArea::sizemol [VolArea::box_molecule_size all now]
            	}
            	box_update_center
            }
    }

}
