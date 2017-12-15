#!/bin/sh
# output.tcl \
exec tclsh "$0" ${1+"$@"}
package provide out 1.0
package require view_points 1.0

proc VolArea::setvalues {} {
	set grid $VolArea::VolArea.nb1.fp
	$grid.fsa.sb.spr configure -state normal
	$grid.fsa.sb.sprs configure -state normal
	$grid.fsa.chs configure -state normal
	$grid.fsa.chv configure -state normal
	$grid.fsa.vb.spsv configure -state normal
	$grid.f1.sw configure -state normal
	$grid.f1.sh configure -state normal
	$grid.f1.sd configure -state normal
	$grid.f1.sx configure -state normal
	$grid.f1.sy configure -state normal
	$grid.f1.sz configure -state normal
	$grid.f1.enrecenter configure -state normal
	$grid.f1.ensel configure -state normal
	$grid.fs.spfrom configure -state disable
	$grid.fs.spto configure -state disable
	$grid.fs.spstep configure -state disable
	$grid.f1.chrecenter configure -state normal
	$grid.f1.chresize configure -state normal
	set pointdb [lindex [split $VolArea::path "/"] end]
	set VolArea::namedb [string trim [lindex [split $pointdb "."] 0] " "]
	$VolArea::VolArea.btload.en delete 0 end
	$VolArea::VolArea.btload.en insert 0 $VolArea::path
	sqlite $VolArea::namedb $VolArea::path
	$VolArea::namedb busy
	$grid.fsa.sb.spr set [format %2.2f [$VolArea::namedb eval "SELECT radius FROM inputfile"]]
	$grid.fsa.sb.sprs set [$VolArea::namedb eval "SELECT resolution FROM inputfile"]
	$grid.fsa.vb.spsv set  [format %2.2f [$VolArea::namedb eval "SELECT volScale FROM inputfile"]]
	$grid.fsa.vb.spr set [format %2.2f [$VolArea::namedb eval "SELECT volcleanmin FROM inputfile"]]
	$grid.fsa.sc.entsel delete 0 end
	set txtsasa [$VolArea::namedb eval "SELECT txtsasaSel FROM inputfile"]
	$grid.fsa.sc.entsel insert 0  [string trim [string trim  $txtsasa "{"] "}"]
	$grid.fsa.vc.vsel delete 0 end
	set txtvol  [$VolArea::namedb eval "SELECT txtvolSel FROM inputfile"]
	$grid.fsa.vc.vsel insert 0 [string trim [string trim $txtvol "{"] "}"]
	$grid.f1.sw set [$VolArea::namedb eval "SELECT width FROM inputfile"]
	$grid.f1.sh set [$VolArea::namedb eval "SELECT heigth FROM inputfile"]
	$grid.f1.sd set [$VolArea::namedb eval "SELECT depth FROM inputfile"]
	$grid.f1.ensel delete 0 end
	set txtsel [$VolArea::namedb eval "SELECT sel FROM inputfile"]
	$grid.f1.ensel insert 0 [string trim [string trim $txtsel "{"] "}"]
	$grid.f1.enrecenter delete 0 end
	set txtcen [$VolArea::namedb eval "SELECT recenter FROM inputfile"]
	set VolArea::RCenter [$VolArea::namedb eval "SELECT checkre FROM inputfile"]
	set VolArea::RSize [$VolArea::namedb eval "SELECT checksize FROM inputfile"]
	$grid.f1.enrecenter insert 0  [string trim [string trim $txtcen "{"] "}"]
	set VolArea::RCenter [$VolArea::namedb eval "SELECT checkre FROM inputfile"]
	VolArea::drawBox b lixo
	$grid.f1.sx set [$VolArea::namedb eval "SELECT x FROM inputfile"]
	$grid.f1.sy set [$VolArea::namedb eval "SELECT y FROM inputfile"]
	$grid.f1.sz set [$VolArea::namedb eval "SELECT z FROM inputfile"]
	$grid.fs.spfrom set [$VolArea::namedb eval "SELECT froms FROM inputfile"]
	$grid.fs.spto set [$VolArea::namedb eval "SELECT tos FROM inputfile"]
	$grid.fs.spstep set [$VolArea::namedb eval "SELECT step FROM inputfile"]
	VolArea::drawBox  a lixo
	$grid.fsa.sb.spr configure -state disable
	$grid.fsa.sb.sprs configure -state disable
	$grid.fsa.chs configure -state disable
	$grid.fsa.chv configure -state disable
	$grid.fsa.vb.spsv configure -state disable
	$grid.fs.spfrom configure -state disable
	$grid.fs.spto configure -state disable
	$grid.fs.spstep configure -state disable
	$grid.fsa.vch.chva configure -state disable
	$grid.rru.b1 configure -state disable
	$grid.rru.un configure -state normal
	$VolArea::VolArea.nb1.fo.v.rep.pr.bt configure -state normal
	$VolArea::VolArea.nb1.fo.f2.rep.pr.bt configure -state normal
	$VolArea::VolArea.nb1.fo.f1.spfra configure -state normal
	$VolArea::VolArea.nb1.fo.f1.spfra configure -to [ $VolArea::VolArea.nb1.fp.fs.spto get]
	$VolArea::VolArea.nb1.fo.f1.spfra configure -from [ $VolArea::VolArea.nb1.fp.fs.spfrom get]
	$VolArea::VolArea.nb1.fo.f1.spfra configure -increment [ $VolArea::VolArea.nb1.fp.fs.spstep get]
	$VolArea::VolArea.nb1.fo.f1.spfra set [ $VolArea::VolArea.nb1.fp.fs.spfrom get]
	$grid.f1.enrecenter configure -state disable
	$grid.f1.ensel configure -state disable
	$grid.f1.sw configure -state disable
	$grid.f1.sh configure -state disable
	$grid.f1.sd configure -state disable
	$grid.f1.sx configure -state disable
	$grid.f1.sy configure -state disable
	$grid.f1.sz configure -state disable
	$grid.fsa.sc.entsel configure -state disable
	$grid.fsa.vc.vsel configure -state disable
	$grid.f1.chrecenter configure -state disable
	$grid.f1.chresize configure -state disable
	$grid.fsa.vb.spr configure -state disable
	wm deiconify $VolArea::VolArea
	update
}

proc VolArea::maketablecurrent {nfr ini} {
	set topLayer [molinfo top]
	set grid .nb1.fp.f1
	set nameLayer ""
	set safeArea 0
	set und "_"
        set num 0;
	$VolArea::VolArea.nb1.fo.f2.tb configure -state normal
	if {[$VolArea::VolArea.nb1.fo.f2.tb get 0]== ""} {
		VolArea::calmean
	}
	$VolArea::VolArea.nb1.fo.f2.tb delete 0 end

	set namel ""
	set sqlsasa ""
	set sqlst ""
	#$VolArea::namedb busy
	set listva [$VolArea::namedb eval "SELECT * FROM frame_[$VolArea::VolArea.nb1.fo.f1.spfra get]"]


	while {$num < [expr [llength $listva] -7]} {
    		set name [lindex $listva $num]
    		set namel [lappend namel $name[lindex $listva $num+1]]
		set chainL [lindex $listva [expr $num +2] ]
    		if {[string trim [lindex $listva $num+4]] != ""} {
    			set sasa [string trim [lindex $listva $num+4] " "]
    		}
    		#set i 0
    		#set listxyz [lindex [lindex $listva $num+2] $i]

		set lista "$name [lindex $listva $num+1] $chainL [format %7.3f $sasa] $VolArea::avg($name$und[lindex $listva $num+1]$und$chainL) $VolArea::stdv($name$und[lindex $listva $num+1]$und$chainL)"
		$VolArea::VolArea.nb1.fo.f2.tb insert end $lista
		incr num 7
    	}
	$VolArea::namedb busy
	set liname [$VolArea::namedb eval "SELECT (resname) FROM frame_[$VolArea::VolArea.nb1.fo.f1.spfra get]"]
	set lid [$VolArea::namedb eval "SELECT (id) FROM frame_[$VolArea::VolArea.nb1.fo.f1.spfra get]"]
	set lchain [$VolArea::namedb eval "SELECT (chain) FROM frame_[$VolArea::VolArea.nb1.fo.f1.spfra get]"]
	set i 0
	set rname ""
	foreach a $liname {
		if {[lindex $lid $i]=="-1"} {
			break
		} else {
			set rname [lappend rname "[lindex $liname $i][lindex $lid $i][lindex $lchain $i]"]
		}
		incr i
	}
	set i 0
	$VolArea::namedb busy
	set nameid [$VolArea::namedb eval "SELECT (xyz) FROM frame_[$VolArea::VolArea.nb1.fo.f1.spfra get] WHERE id = -1"]
	set nameid [lindex $nameid 0]
	while {[lindex $nameid $i]!= ""} {
		set namaux [split  [lindex $nameid $i] "	"]
		if {[lsearch $rname [lindex $nameid $i]] == -1 } {
			$VolArea::VolArea.nb1.fo.f2.tb insert end "[lindex $namaux 0] [lindex $namaux 1] 0.00 $VolArea::avg([lindex $nameid $i]) $VolArea::stdv([lindex $nameid $i])"

			#$VolArea::VolArea.nb1.fo.f2.tb insert end "[string range [lindex $nameid $i] 0 2] [string range [lindex $nameid $i] 3 [string length [lindex $nameid $i]]] 0.00 $VolArea::avg([lindex $nameid $i]) $VolArea::stdv([lindex $nameid $i])"
		}
		incr i
	}
	$VolArea::VolArea.nb1.fo.f2.tb sortbycolumn 1

  	set topLayer [molinfo top]

}

proc VolArea::LoadFile {bt} {
	set topLayer [molinfo top]
	set nameLayer ""
	array set  VolArea::listpoint ""
	array set  VolArea::list ""
	set sa ""
	set lista ""
	set und "_"
	set spc " "
	if {$bt == 2} {
		for {set nfr [$VolArea::VolArea.nb1.fp.fs.spfrom get]} {$nfr <= [$VolArea::VolArea.nb1.fp.fs.spto get]} {incr nfr [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
    	$VolArea::namedb busy
			set liname [$VolArea::namedb eval "SELECT (resname) FROM frame_$nfr"]
      set lchain [$VolArea::namedb eval "SELECT (chain) FROM frame_$nfr"]
    	set lid [$VolArea::namedb eval "SELECT (id) FROM frame_$nfr"]
    	set i 0
    	set rname ""
    	foreach a $liname {
        if {[lindex $lid $i]=="-1"} {
    			break
				} else {
					if {[lindex $lchain $i] != " "} {
						set rname [lappend rname "[lindex $liname $i]$und[lindex $lid $i]$und[lindex $lchain $i]"]
					} else {
						set rname [lappend rname "[lindex $liname $i]$und[lindex $lid $i]$und$spc"]
					}
				}
				incr i
			}
    	set i 0
			$VolArea::namedb busy
			set nameid [$VolArea::namedb eval "SELECT (xyz) FROM frame_$nfr WHERE id = -1"]
			set nameid [lindex $nameid 0]
			while {[lindex $nameid $i]!= ""} {
    	if {[lsearch $rname [lindex $nameid $i]] == -1 } {
				set name [split [lindex $nameid $i] $und]
				set resname [lindex $name 0]
				set id [lindex $name 1]
				set chain [lindex $name 2]
				set xyz " "
				set sasa 0.00
				set SasaMean $VolArea::avg([lindex $nameid $i])
				set STDV $VolArea::stdv([lindex $nameid $i])
				$VolArea::namedb eval "INSERT INTO frame_$nfr VALUES (:resname, :id,:chain, :xyz, :sasa, :SasaMean, :STDV)"
			}
			incr i
			}
		}
		$VolArea::VolArea.nb1.fo.f2.tb configure -state normal
    		set i 0
    		set lis ""
    		set lispoint ""
		set name "volume"
		set name2 "volatom"
		$VolArea::namedb busy
    		set lista [$VolArea::namedb eval "SELECT * FROM frame_[$VolArea::VolArea.nb1.fp.fs.spfrom get] WHERE id != -1 AND resname!= :name AND resname != :name2"]
    		$VolArea::VolArea.nb1.fo.f2.tb delete 0 end
    		set all [$VolArea::namedb eval "SELECT * FROM frame_[$VolArea::VolArea.nb1.fp.fs.spfrom get] WHERE id= -1"]
    		$VolArea::VolArea.nb1.fo.f2.tb insert end "[lrange $all 0 2] [lrange $all 4 [llength $all]]"
    		set i 0
		set VolArea::list([$VolArea::VolArea.nb1.fo.f1.spfra get]) ""
		set VolArea::listpoint([$VolArea::VolArea.nb1.fo.f1.spfra get]) ""
    		while {$i < [llength $lista]} {
    			set listxyz [lindex $lista [expr $i + 3] ]
    			set j 0
    			while {[lindex $listxyz $j]!= ""} {
    				set xyz [lindex $listxyz $j]
    	    			set VolArea::list([$VolArea::VolArea.nb1.fp.fs.spfrom get]) [lappend VolArea::list([$VolArea::VolArea.nb1.fp.fs.spfrom get]) " 1 H H [lindex $lista $i] A [format %7.3f [lindex $xyz 0]] [format %7.3f [lindex $xyz 1]] [format %7.3f [lindex $xyz 2]] [lindex $lista $i+4]"]
    	  			set VolArea::listpoint([$VolArea::VolArea.nb1.fp.fs.spfrom get]) [lappend VolArea::listpoint([$VolArea::VolArea.nb1.fp.fs.spfrom get]) $listxyz]
    				incr j
    			}
       			set sa [string trim [lindex $lista [expr $i +5]] "{"]
			set sa [string trim $sa "}"]
			set st [string trim [lindex $lista [expr $i +6]] "{"]
			set st [string trim $st "}"]
       			$VolArea::VolArea.nb1.fo.f2.tb insert end "[lrange $lista $i [expr $i + 1]] [lrange $lista [expr $i + 2] [expr $i + 2]] [lindex $lista [expr $i+4]] $sa $st"
        			incr i 7
    		}

		$VolArea::VolArea.nb1.fo.f2.tb sortbycolumn 1
        		set nameLayer ""
        		set x 0
        		foreach x [molinfo list] {
        			set nameLayer [lappend nameLayer [molinfo $x get name]]
        		}
		set id -1
    		if {[lsearch $nameLayer "SASA"] !=-1} {
        			set sasaLayer [molinfo index [lsearch $nameLayer "SASA"]]
			VolArea::save_viewpoint $id
        			mol delete $sasaLayer
    		}

    		set mol [mol new atoms [llength $VolArea::listpoint([$VolArea::VolArea.nb1.fo.f1.spfra get])]]
    		mol rename top "SASA"
    		animate dup $mol
    		set sel [atomselect $mol all]
    		$sel set {radius element name resname chain x y z beta} $VolArea::list([$VolArea::VolArea.nb1.fo.f1.spfra get])


            	## Load the data in layer

		mol addrep $mol

    		set repr "Surf"

    		if {[$VolArea::VolArea.nb1.fo.f2.rep.pr.cb1 get]=="VDW"} {set repr "VDW"}
    		if {[$VolArea::VolArea.nb1.fo.f2.rep.pr.cb1 get]=="Surface"} {set repr "Surf"}
    		if {[$VolArea::VolArea.nb1.fo.f2.rep.pr.cb1 get]=="Off"} {set repr "Off"}
		mol modstyle 0 $mol $repr
    		mol modcolor 0 $mol [$VolArea::VolArea.nb1.fo.f2.rep.pr.cb2 get]
    		mol delrep -1 $mol
		::TopoTools::adddefaultrep [molinfo top]
    		mol top $topLayer
		unset upproc_var_$sel
	} else {
		$VolArea::VolArea.nb1.fo.f2.tb configure -state normal
        		set i 0
        		set lis ""
    		set lispoint ""
		set name "volume"
		set name2 "volatom"
		$VolArea::namedb busy
    		set lista [$VolArea::namedb eval "SELECT * FROM frame_[$VolArea::VolArea.nb1.fo.f1.spfra get] WHERE id != -1 AND resname!= :name AND resname != :name2"]
		$VolArea::VolArea.nb1.fo.f2.tb delete 0 end
	    	set all [$VolArea::namedb eval "SELECT * FROM frame_[$VolArea::VolArea.nb1.fo.f1.spfra get] WHERE id= -1"]
		$VolArea::VolArea.nb1.fo.f2.tb insert end "[lrange $all 0 2] [lrange $all 4 [llength $all]]"
    		set i 0
		set VolArea::list([$VolArea::VolArea.nb1.fo.f1.spfra get]) ""
		set VolArea::listpoint([$VolArea::VolArea.nb1.fo.f1.spfra get]) ""
    		while {$i < [llength $lista]} {
    			set listxyz [lindex $lista $i+3]
    			set j 0
    			while {[lindex $listxyz $j]!= ""} {
    				set xyz [lindex $listxyz $j]
	    			set VolArea::list([$VolArea::VolArea.nb1.fo.f1.spfra get]) [lappend VolArea::list([$VolArea::VolArea.nb1.fo.f1.spfra get]) " 1 H H [lindex $lista $i] A [format %7.3f [lindex $xyz 0]] [format %7.3f [lindex $xyz 1]] [format %7.3f [lindex $xyz 2]] [lindex $lista $i+4]"]
    	  			set VolArea::listpoint([$VolArea::VolArea.nb1.fo.f1.spfra get]) [lappend VolArea::listpoint([$VolArea::VolArea.nb1.fo.f1.spfra get]) $listxyz]
    				incr j
    			}
			set sa [string trim [lindex $lista [expr $i +5]] "{"]
			set sa [string trim $sa "}"]
			set st [string trim [lindex $lista [expr $i +6]] "{"]
			set st [string trim $st "}"]
       			$VolArea::VolArea.nb1.fo.f2.tb insert end "[lrange $lista $i [expr $i + 1]] [lrange $lista [expr $i + 2] [expr $i + 2]] [lindex $lista [expr $i+4]] $sa $st"
	        		incr i 7
    		}
		$VolArea::VolArea.nb1.fo.f2.tb sortbycolumn 1
    		set nameLayer ""
		 set x 0
            	foreach x [molinfo list] {
        			set nameLayer [lappend nameLayer [molinfo $x get name]]
            	}
		set id -1
            	if {[lsearch $nameLayer "SASA"] !=-1} {
        	    	set sasaLayer [molinfo index [lsearch $nameLayer "SASA"]]
        			if {$bt!=1} {
        				VolArea::save_viewpoint 1
        			}
        			mol delete $sasaLayer
            	}
            	set mol [mol new atoms [llength $VolArea::listpoint([$VolArea::VolArea.nb1.fo.f1.spfra get])]]
    		mol rename top "SASA"
    		animate dup $mol
    		set sel [atomselect $mol all]
    		$sel set {radius element name resname chain x y z beta } $VolArea::list([$VolArea::VolArea.nb1.fo.f1.spfra get])


                    	## Load the data in layer

		mol addrep $mol

    		set repr "Surf"

            	if {[$VolArea::VolArea.nb1.fo.f2.rep.pr.cb1 get]=="VDW"} {set repr "VDW"}
            	if {[$VolArea::VolArea.nb1.fo.f2.rep.pr.cb1 get]=="Surface"} {set repr "Surf"}
		if {[$VolArea::VolArea.nb1.fo.f2.rep.pr.cb1 get]=="Off"} {set repr "Off"}
            	mol modstyle 0 $mol $repr
            	mol modcolor 0 $mol [$VolArea::VolArea.nb1.fo.f2.rep.pr.cb2 get]
            	mol delrep -1 $mol
		if {$bt==1} {
			::TopoTools::adddefaultrep [molinfo top]
		}  else {
			VolArea::restore_viewpoint 1

		}
		unset upproc_var_$sel
    		mol top $topLayer
	}
	mol top $topLayer

}

proc VolArea::calmean {} {
	set nameid ""
	set from [$VolArea::VolArea.nb1.fp.fs.spfrom get]
	set to [$VolArea::VolArea.nb1.fp.fs.spto get]
	set und "_"
	set tb ""
	set count 0
	set sumi 0
	set nameidaux ""
	for {set fr $from} {$fr <= $to} {incr fr [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
		$VolArea::namedb busy
		set lisfr [$VolArea::namedb eval "SELECT resname,id,chain,sasa FROM frame_$fr ORDER BY id asc" ]
		set i 0
		while {$i != [llength $lisfr]} {
			set nameidaux "[lindex $lisfr $i]$und[lindex $lisfr [expr $i+1]]$und[lindex $lisfr [expr $i+2]]"
			if {[lsearch $nameid $nameidaux] == -1} {
				set nameid [lappend nameid $nameidaux]
				set VolArea::resname($nameidaux) ""
			}
			set VolArea::resname($nameidaux) [lappend VolArea::resname($nameidaux) [lindex $lisfr [expr $i+3]]]
			set sumi [expr $sumi + [lindex $lisfr [expr $i+3]]]
			incr i 4
		}
		set VolArea::sum($fr) $sumi
		set sumi 0
		incr count
	}
	set lis ""
	for {set i $from} {$i <= $to} {incr i [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
		set lis [lappend lis $VolArea::sum($i)]
	}
	if {[llength $lis] !=1 } {
    set VolArea::avgt [format %7.3f [math::statistics::mean $lis]]
		set VolArea::stdvt [expr [math::statistics::stdev $lis] / [expr sqrt([molinfo [molinfo top] get numframes])] ]
    set VolArea::stdvt [format %7.3f $VolArea::stdvt]
	} else {
		set VolArea::avgt $lis
		set VolArea::stdvt 0.000
	}
	set i 0
	while {[lindex $nameid $i] != ""} {
		if {[llength $VolArea::resname([lindex $nameid $i])] != $count} {
			while {[llength $VolArea::resname([lindex $nameid $i])] <= $count} {
				set VolArea::resname([lindex $nameid $i]) [lappend VolArea::resname([lindex $nameid $i]) 0]
			}
		}
		incr i
	}
	for {set i 0} {$i < [llength $nameid]} {incr i} {
		if {[llength $lis] !=1} {
			set VolArea::avg([lindex $nameid $i]) [format %7.3f [math::statistics::mean $VolArea::resname([lindex $nameid $i])]]
			set VolArea::stdv([lindex $nameid $i]) [math::statistics::stdev $VolArea::resname([lindex $nameid $i])]
			set VolArea::stdv([lindex $nameid $i]) [format %7.3f [expr $VolArea::stdv([lindex $nameid $i]) / [expr sqrt([molinfo [molinfo top] get numframes])]]]

		} else {
			set VolArea::avg([lindex $nameid $i]) 0.000
			set VolArea::avg([lindex $nameid $i]) $VolArea::resname([lindex $nameid $i])
			set VolArea::stdv([lindex $nameid $i]) 0.000
			set VolArea::stdv([lindex $nameid $i]) 0.000
		}

	}

	for {set nfr $from} {$nfr <= $to} {incr nfr [$VolArea::VolArea.nb1.fp.fs.spstep get]} {
		set name "ALL"
		set id -1
		set soma [format %7.3f $VolArea::sum($nfr)]
		set av [format %7.3f $VolArea::avgt]
		set st [format %7.3f $VolArea::stdvt]
		set chain " "
		$VolArea::namedb busy
		$VolArea::VolArea.nb1.fo.f2.tb insert end "$name $id $chain $nameid [format %7.3f $VolArea::sum([$VolArea::VolArea.nb1.fo.f1.spfra get])] [format %7.3f $VolArea::avgt] [format %7.3f $VolArea::stdvt]"
		$VolArea::namedb eval "INSERT INTO frame_$nfr (resname, id,chain, xyz , sasa, SasaMean, STDV) VALUES(:name, :id, :chain, :nameid, :soma, :av, :st)"
		for {set i 0} {$i < [llength $nameid]} {incr i} {
    	$VolArea::namedb busy
			set sqlsasa $VolArea::avg([lindex $nameid $i])
			set sqlst $VolArea::stdv([lindex $nameid $i])
			set name [split [lindex $nameid $i] $und]
			set resname [lindex $name 0]
			set id [lindex $name 1]
			set chain [lindex $name 2]

			$VolArea::namedb eval "UPDATE frame_$nfr SET SasaMean=:sqlsasa WHERE id=:id AND resname=:resname AND chain=:chain"
			$VolArea::namedb eval "UPDATE frame_$nfr SET STDV=:sqlst WHERE id=:id AND resname=:resname AND chain=:chain"
		}

	}

}
