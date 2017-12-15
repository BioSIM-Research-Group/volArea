package provide vol 1.0


proc VolArea::startVol {nfr frmtot} {
array unset ::VolArea::matrix
	array set ::VolArea::matrix ""
	 array unset VolArea::matrix
	 array set VolArea::matrix ""
	set scale [$VolArea::VolArea.nb1.fp.fsa.vb.spsv get]
	set grid $VolArea::VolArea.nb1.fp.f1
	set center "[$grid.sx get] [$grid.sy get] [$grid.sz get]"
	set w [$grid.sw get]
	set h [$grid.sh get]
	set d [$grid.sd get]
	set w [expr round ([expr $w + [expr $scale -[expr {fmod( $w,$scale)}]]])]
	set h [expr round ([expr $h + [expr $scale -[expr {fmod( $h,$scale)}]]])]
	set d [expr round ([expr $d + [expr $scale -[expr {fmod( $d,$scale)}]]])]
	set topLayer [molinfo top]
	set selection ""
	set xmax [expr [lindex $center 0] + [expr [$grid.sw get]/2]]
	set xmin [expr [lindex $center 0] - [expr [$grid.sw get]/2]]
	set ymax [expr [lindex $center 1] + [expr [$grid.sh get]/2]]
	set ymin [expr [lindex $center 1] - [expr [$grid.sh get]/2]]
	set zmax [expr [lindex $center 2] + [expr [$grid.sd get]/2]]
	set zmin [expr [lindex $center 2] - [expr [$grid.sd get]/2]]
	set selection [atomselect $topLayer "[$VolArea::VolArea.nb1.fp.f1.ensel get] and [$VolArea::VolArea.nb1.fp.fsa.vc.vsel get] and x >= [expr $xmin - 4] and x <= [expr $xmax + 4] and y >= [expr $ymin - 4] and y <= [expr $ymax + 4] and z >= [expr $zmin - 4] and z <= [expr $zmax + 4]" frame $nfr]
	$selection update
	set x_origin [expr $xmin + $scale/2]
	set y_origin [expr $ymin + $scale/2]
	set z_origin [expr $zmin + $scale/2]
	set list [$selection get {x y z}]
	set i 0
	set xl ""
	set yl ""
	set zl ""
	set xyz_2 ""
	set il ""
	set vdw [$selection get radius]
	 set frm [expr [expr [$VolArea::VolArea.nb1.fp.fs.spto get] - [$VolArea::VolArea.nb1.fp.fs.spfrom get]] / [$VolArea::VolArea.nb1.fp.fs.spstep get]]
	while {[lindex $list $i] != ""} {
		set xyz [lindex $list $i]
		set x [expr round ([expr [expr [lindex $xyz 0] - $x_origin] / $scale])]
		set y [expr round ([expr [expr [lindex $xyz 1] - $y_origin]/ $scale])]
		set z [expr round ([expr [expr [lindex $xyz 2] - $z_origin]/ $scale])]
		set rad [lindex $vdw $i]
		if {[lsearch $xyz_2 $x$y$z] == -1} {
			set xyzr [lappend xyzr [list $x $y $z $rad]]
		}
		set xyz_2 [lappend $xyz_2 $x$y$z]
		incr i
	}
	set i 0
	set xyzr [lsort -integer -increasing -index 2 $xyzr]
	set vdw ""
	while { $i < [llength $xyzr]} {
		set lis [lindex $xyzr $i]
		set xl [lappend xl [lindex $lis 0]]
		set yl [lappend yl [lindex $lis 1]]
		set zl [lappend zl [lindex $lis 2]]
		set vdw [lappend vdw [lindex $lis 3]]
		incr i
	}

	set a_xmin [expr round ([expr [expr  $x_origin - $x_origin] / $scale])]
	set a_ymin [expr round ([expr [expr  $y_origin - $y_origin] / $scale])]
	set a_zmin [expr round ([expr [expr  $z_origin - $z_origin] / $scale])]
	set a_xmax [expr round ([expr [expr  $xmax - $x_origin] / $scale])]
	set a_ymax [expr round ([expr [expr  $ymax - $y_origin] / $scale])]
	set a_zmax [expr round ([expr [expr  $zmax - $z_origin] / $scale])]


   array unset VolArea::matrix ""
   array set VolArea::matrix ""
   set fld "Routines/Lib"
   if {[string index $::VolAreaPath end] != "/"} {
	 set ::VolAreaPath "$::VolAreaPath/"
   }
   set infile [file dirname $VolArea::path]
   set xl_file [open $infile/xl.cor w+]
   puts $xl_file $xl
   close $xl_file
   set yl_file [open $infile/yl.cor w+]
   puts $yl_file $yl
   close $yl_file
   set zl_file [open $infile/zl.cor w+]
   puts $zl_file $zl
   close $zl_file
   set vdw_file [open $infile/vdw.cor w+]
   puts $vdw_file $vdw
   close $vdw_file

	set scale [$VolArea::VolArea.nb1.fp.fsa.vb.spsv get]
	set grid $VolArea::VolArea.nb1.fp.f1
	set w [$grid.sw get]
	set h [$grid.sh get]
	set d [$grid.sd get]
	set w [expr round ([expr $w + [expr $scale -[expr {fmod( $w,$scale)}]]])]
	set h [expr round ([expr $h + [expr $scale -[expr {fmod( $h,$scale)}]]])]
	set dist_empt [$VolArea::VolArea.nb1.fp.fsa.vb.spr get]
  if {$::tcl_platform(os) == "Darwin" } {
    catch {eval exec tclsh8.4 $::VolAreaPath$fld/Vdw.tcl $scale $a_xmin $a_ymin $a_zmin $a_xmax $a_ymax $a_zmax $::VolAreaPath $nfr $frmtot $dist_empt $::VolAreaPath $VolArea::namedb $VolArea::path $x_origin $y_origin $z_origin} value
	} elseif {$::tcl_platform(os) == "Linux"} {
		catch {eval exec tclsh8.5 $::VolAreaPath$fld/Vdw.tcl $scale $a_xmin $a_ymin $a_zmin $a_xmax $a_ymax $a_zmax $::VolAreaPath $nfr $frmtot $dist_empt $::VolAreaPath $VolArea::namedb $VolArea::path $x_origin $y_origin $z_origin} value
	} elseif {[string first "Windows" $::tcl_platform(os)] != -1} {
    eval exec tclsh84 $::VolAreaPath$fld/Vdw.tcl $scale $a_xmin $a_ymin $a_zmin $a_xmax $a_ymax $a_zmax $::VolAreaPath $nfr $frmtot $dist_empt $::VolAreaPath $VolArea::namedb $VolArea::path $x_origin $y_origin $z_origin
	}
	unset upproc_var_$selection
	foreach v [info vars] {unset $v}
  unset v

	return

}




proc VolArea::showVol {nfr a} {
   set nfr [$VolArea::VolArea.nb1.fo.f1.spfra get]
   sqlite $VolArea::namedb $VolArea::path
   set topLayer [molinfo top]
   set name "volume"
   $VolArea::namedb busy
   set list [$VolArea::namedb eval "SELECT xyz FROM frame_$nfr WHERE resname=:name"]
	 if {$list!= "{}"} {
		set lis ""
		set scale [$VolArea::namedb eval "SELECT volScale FROM inputfile"]
		set i 0
		set nameLayer ""
		foreach nameL [molinfo list] {
			 set nameLayer [lappend nameLayer [molinfo $nameL get name]]
		}
		if {[lsearch $nameLayer "Volume"] !=-1} {
			set volLayer [molinfo index [lsearch $nameLayer "Volume"]]
			if {$a!=0} {
			 VolArea::save_viewpoint 1
			}
			mol delete $volLayer
		}
		foreach point [lindex $list $i] {
			set lis [lappend lis "$scale H H A A $point 0"]
			incr i
		}
		if {[llength $point] > 0} {
		 set mol [mol new atoms $i]
			 mol rename top "Volume"
			 animate dup $mol
			 set sel [atomselect $mol all]
			 $sel set {radius element name resname chain x y z beta} $lis
			if {[$VolArea::VolArea.nb1.fo.v.rep.pr.cb1 get] != "IsoSurface"} {
			 mol addrep $mol
			 set repr [$VolArea::VolArea.nb1.fo.v.rep.pr.cb1 get]
			 mol modstyle 0 $mol $repr
			 mol modcolor 0 $mol [$VolArea::VolArea.nb1.fo.v.rep.pr.cb2 get]



			 set repr [$VolArea::VolArea.nb1.fo.v.rep.pr.cb1 get]

			 mol modstyle 0 $mol $repr
			 mol modcolor 0 $mol [$VolArea::VolArea.nb1.fo.v.rep.pr.cb2 get]

			 if {$a==0} {
				 ::TopoTools::adddefaultrep [molinfo top]
			 } else {
				 VolArea::restore_viewpoint 1
			 }
			 unset upproc_var_$sel
			 mol delrep 1 $mol
			} else {
					set sel [atomselect $mol "all"]
					set scl [$VolArea::VolArea.nb1.fp.fsa.vb.spsv get]
					if {$scl == 1} {
					eval "volmap occupancy $sel -res $scl -mol $mol -combine avg -points"
					mol rep Isosurface 0.4 0 0 0 1
					} else {
					eval "volmap occupancy $sel -res 0.7 -mol $mol -combine avg -points"
					mol rep Isosurface 0.7 0 0 0 1
					}

					mol selection all
					mol material Opaque
					mol addrep $mol
					mol modcolor 0 $mol [$VolArea::VolArea.nb1.fo.v.rep.pr.cb2 get]

			}
		}
	 }
	 unset list
	 $VolArea::VolArea.nb1.fo.v.vol.tbt configure -state normal
	 $VolArea::VolArea.nb1.fo.v.vol.tbt delete 0 end
	 mol top $topLayer
	 set name "volume"
	 $VolArea::namedb busy
	 set val [$VolArea::namedb eval "SELECT sasa FROM frame_$nfr WHERE resname=:name"]
	 set mean [$VolArea::namedb eval "SELECT SasaMean FROM frame_$nfr WHERE resname=:name"]
	 set stdv [$VolArea::namedb eval "SELECT STDV FROM frame_$nfr WHERE resname=:name"]
	 set val [string trim $val "{"]
	 set val [string trim $val "}"]
	 set mean [string trim $mean "{"]
	 set mean [string trim $mean "}"]
	 set stdv [string trim $stdv "{"]
	 set stdv [string trim $stdv "}"]
	 $VolArea::VolArea.nb1.fo.v.vol.tbt insert end "Cavity $val $mean $stdv"
	 if {$VolArea::volatom == 1} {
	    set name "volatom"
	    $VolArea::namedb busy
	    set val [$VolArea::namedb eval "SELECT sasa FROM frame_$nfr WHERE resname=:name"]
	    set mean [$VolArea::namedb eval "SELECT SasaMean FROM frame_$nfr WHERE resname=:name"]
	    set stdv [$VolArea::namedb eval "SELECT STDV FROM frame_$nfr WHERE resname=:name"]
	    set val [string trim $val "{"]
	    set val [string trim $val "}"]
	    set mean [string trim $mean "{"]
	    set mean [string trim $mean "}"]
	    set stdv [string trim $stdv "{"]
	    set stdv [string trim $stdv "}"]
	    $VolArea::VolArea.nb1.fo.v.vol.tbt insert end "Volatom $val $mean $stdv"
	 }

}

proc VolArea::calcall {} {
	set name "volume"
	set sum 0
	set lista ""
	$VolArea::VolArea.nb1.fo.v.vol.tbt delete 0 end
	$VolArea::VolArea.nb1.fo.v.vol.tbt configure -state normal
	for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} { incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
    		$VolArea::namedb busy
		incr VolArea::pb
		set val [$VolArea::namedb eval "SELECT sasa FROM frame_$i WHERE resname=:name"]
		set sum [expr $sum + $val]
		set lista [lappend lista [format %7.3f $val]]
        }
	set volmean  [format %7.3f [math::statistics::mean $lista]]
	if {[llength $lista] == 1} {
		set volstdv 0.000
	} else {
		set volstdv [expr [math::statistics::stdev $lista] / [expr sqrt([molinfo [molinfo top] get numframes])]]
		set volstdv [format %7.3f $volstdv]
	}

	for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} { incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
	 	$VolArea::namedb busy
		set val [$VolArea::namedb eval "SELECT sasa FROM frame_$i WHERE resname=:name"]
		$VolArea::namedb eval "UPDATE frame_$i SET SasaMean=:volmean WHERE resname=:name"
    $VolArea::namedb eval "UPDATE frame_$i SET STDV=:volstdv WHERE resname=:name"
	}

	for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} { incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
	 	$VolArea::namedb busy
		set val [$VolArea::namedb eval "SELECT sasa FROM frame_$i WHERE resname=:name"]
		$VolArea::namedb eval "UPDATE frame_$i SET SasaMean=:volmean WHERE resname=:name"
    $VolArea::namedb eval "UPDATE frame_$i SET STDV=:volstdv WHERE resname=:name"
	}
	if {$VolArea::volatom == 1} {
		set name "volatom"
		set sum 0
		set lista ""
		for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} { incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
					set val [$VolArea::namedb eval "SELECT sasa FROM frame_$i WHERE resname=:name"]
			set sum [expr $sum + $val]
			set lista [lappend lista [format %7.3f $val]]
					}
		set volmean  [format %7.3f [math::statistics::mean $lista]]
		if {[llength $lista] == 1} {
			set volstdv 0.000
		} else {
			set volstdv [expr [math::statistics::stdev $lista] / [expr sqrt([molinfo [molinfo top] get numframes])]]
			set volstdv [format %7.3f $volstdv]
		}
		for {set i [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$i <= [$VolArea::VolArea.nb1.fp.fs.spto get]} { incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
			set val [$VolArea::namedb eval "SELECT sasa FROM frame_$i WHERE resname=:name"]
			$VolArea::namedb eval "UPDATE frame_$i SET SasaMean=:volmean WHERE resname=:name"
			$VolArea::namedb eval "UPDATE frame_$i SET STDV=:volstdv WHERE resname=:name"
		}
	}
}
