#!/bin/sh
# sqlite_man.tcl \
exec tclsh "$0" ${1+"$@"}
package provide SQL 1.0


 proc VolArea::savefile {} {
	 set types {
                {{ŜurfVol}       {.srfv}        }
            }

    	set VolArea::path [tk_getSaveFile -defaultextension ".srfv" -filetypes $types]
    	set pointdb [lindex [split $VolArea::path "/"] end]
	set VolArea::namedb [string trim [lindex [split $pointdb "."] 0] " "]
     }

proc VolArea::saveinputfile {} {
	VolArea::spinsasa
	VolArea::spincav
	set grid $VolArea::VolArea.nb1.fp
	set radius [format %2.2f [$grid.fsa.sb.spr get]]

	set resolution [$grid.fsa.sb.sprs get]
	set width [$grid.f1.sw get]
	set heigth [$grid.f1.sh get]
	set depth [$grid.f1.sd get]
	set x [$grid.f1.sx get]
	set y [$grid.f1.sy get]
	set z [$grid.f1.sz get]
	set froms [$VolArea::VolArea.nb1.fp.fs.spfrom get]
	set tos [$VolArea::VolArea.nb1.fp.fs.spto get]
	set step [$VolArea::VolArea.nb1.fp.fs.spstep get]
	set molname [molinfo top get name]
	set volScale [format %2.1f [$grid.fsa.vb.spsv get]]
	set sasaSel $VolArea::sasa
	set txtsasaSel [$grid.fsa.sc.entsel get]
	set volSel $VolArea::vol
	set txtvolSel [$grid.fsa.vc.vsel get]
	set volAt $VolArea::volatom
	set volcleanmin [format %2.1f [$grid.fsa.vb.spr get]]
	set sel [$grid.f1.ensel get]
	set recenter [$grid.f1.enrecenter get]
	set checkre $VolArea::RCenter
	set checksize $VolArea::RSize
	sqlite $VolArea::namedb $VolArea::path
	set lis [$VolArea::namedb eval "SELECT name FROM sqlite_master"]
	set i 0
	while {[lindex $lis $i] != ""} {
		set name [lindex $lis $i]
		$VolArea::namedb eval "DROP TABLE if exists $name"
		incr i
	}
	$VolArea::namedb eval "CREATE TABLE if not exists inputfile(molname TEXT, radius double, resolution INTEGER, sel Text,checkre INTEGER, checksize INTEGER , recenter Text, volScale float, volcleanmin float, volcleanmax float, sasaSel INTEGER, txtsasaSel Text, volSel INTEGER, txtvolSel Text, volAt INTEGER, width float, heigth float, depth float, x float, y float, z float, froms INTEGER, tos INTEGER, step INTEGER)"

	$VolArea::namedb eval "INSERT INTO inputfile (molname, radius, resolution, sel,checkre, checksize, recenter, volScale, volcleanmin, volcleanmax, sasaSel , txtsasaSel, volSel, txtvolSel, volAt, width, heigth, depth, x, y, z, froms, tos, step) VAlUES(:molname, :radius, :resolution ,:sel,:checkre , :checksize,:recenter, :volScale,:volcleanmin, :volcleanmax, :sasaSel, :txtsasaSel,  :volSel, :txtvolSel , :volAt,  :width, :heigth, :depth, :x, :y, :z, :froms, :tos, :step)"


}
