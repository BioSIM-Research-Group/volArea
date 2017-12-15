#!/bin/sh
# Gui.tcl \
exec tclsh "$0" ${1+"$@"}

package provide GUI 1.0
package require out 1.0


proc VolArea::GUI {} {
	variable w 0.00
    variable h 0.00
	variable d 0.00
	variable x 0.00
	variable y 0.00
	variable z 0.00


   set VolArea::VolArea ".volarea"
   toplevel $VolArea::VolArea
   wm title $VolArea::VolArea "VolArea"
   wm protocol  $VolArea::VolArea WM_DELETE_WINDOW {
	 VolArea::ResetButton h
	 wm withdraw $VolArea::VolArea
   }

   wm resizable $VolArea::VolArea 0 1


	grid columnconfigure $VolArea::VolArea 0 -weight 0; grid rowconfigure $VolArea::VolArea 0 -weight 2

	image create photo VolArea::img1 -data [VolArea::imagem]

	grid [ttk::frame $VolArea::VolArea.p -padding "0 0 0 2"] -row 0 -column 0 -sticky nsew
  	grid columnconfigure $VolArea::VolArea.p 0 -weight 1 ;grid rowconfigure $VolArea::VolArea.p 0 -weight 1
	grid [label  $VolArea::VolArea.p.logo -image VolArea::img1 -bg black -anchor e] -row 0 -column 0 -sticky wens


	grid [ttk::frame $VolArea::VolArea.btload] -column 0 -row 1 -pady 2 -padx 2 -sticky nswe
	grid columnconfigure $VolArea::VolArea.btload 1 -weight 1; grid rowconfigure $VolArea::VolArea.btload 0 -weight 1
    grid [ttk::label $VolArea::VolArea.btload.ll -text "VolArea file"] -column 0 -row 0 -sticky w -pady 2 -padx 2
    grid [ttk::entry $VolArea::VolArea.btload.en] -column 1 -row 0 -padx 2 -pady 2 -sticky we
    grid [ttk::button $VolArea::VolArea.btload.bok -text "Upload" -command VolArea::LoadButton -padding "2 0 2 0"] -column 2 -row 0 -sticky w -pady 2


        ############notebook
        grid [ttk::notebook $VolArea::VolArea.nb1 -padding "3 0 3 0"] -sticky nesw -row 2 -column 0
	grid columnconfigure $VolArea::VolArea.nb1 0 -weight 1; grid rowconfigure $VolArea::VolArea.nb1 0 -weight 1
        ###############FRAME PRINCIPAL INPUT




    grid [ttk::frame $VolArea::VolArea.nb1.fp ] -row 0 -column 0 -sticky nwes -padx 5
    grid columnconfigure $VolArea::VolArea.nb1.fp 0 -weight 2 ;grid rowconfigure $VolArea::VolArea.nb1.fp 2 -weight 2
    ######Frame principal do output
	grid [ttk::frame $VolArea::VolArea.nb1.fo ] -row 0 -column 0 -sticky nwe -padx 5
    grid columnconfigure $VolArea::VolArea.nb1.fo 0 -weight 2 ;grid rowconfigure $VolArea::VolArea.nb1.fo 1 -weight 2
    ######Frame about
	grid [ttk::frame $VolArea::VolArea.nb1.fab ] -row 0 -column 0 -sticky nwe -padx 5
	grid columnconfigure $VolArea::VolArea.nb1.fab 0 -weight 0 ;grid rowconfigure $VolArea::VolArea.nb1.fab 1 -weight 2
	############add frames to notbook
        $VolArea::VolArea.nb1 add $VolArea::VolArea.nb1.fp -text "Input" -sticky news
	$VolArea::VolArea.nb1 add $VolArea::VolArea.nb1.fo -text "Output" -sticky news
        $VolArea::VolArea.nb1 add $VolArea::VolArea.nb1.fab -text "About" -sticky news


	##########Frame INFERIOR notbook

        grid [ttk::labelframe $VolArea::VolArea.nb1.fp.f1 -text "Analysis Area" -padding "2 2 2 2"] -column 0 -row 2 -sticky nwes
        grid columnconfigure $VolArea::VolArea.nb1.fp.f1 1 -weight 2; grid rowconfigure $VolArea::VolArea.nb1.fp.f1 1 -weight 2


        #########scale width height depth
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lwi -text "width" -anchor center] -column 0 -row 0 -sticky we -padx 5 -pady 10
        scale $VolArea::VolArea.nb1.fp.f1.sw -orient horizontal -length 150 -from 0 -to 100 -showvalue 0 -variable w -resolution 0.01 -command {VolArea::drawBox b};
        grid $VolArea::VolArea.nb1.fp.f1.sw -column 1 -row 0 -sticky we -pady 10
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lw2 -textvariable w -width 6 ] -column 2 -row 0 -sticky w
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lw2a -text "A" -width 2 -anchor w] -column 2 -row 0 -sticky e


        scale $VolArea::VolArea.nb1.fp.f1.sh -orient horizontal -length 150 -from 0 -to 100 -showvalue 0 -variable h -resolution 0.01 -command {VolArea::drawBox b};
        grid $VolArea::VolArea.nb1.fp.f1.sh -column 1 -row 1 -sticky ew -pady 7
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lh1 -text "height" -anchor center] -column 0 -row 1 -sticky we -padx 5 -pady 5
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lh2 -textvariable h ] -column 2 -row 1 -sticky w
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lh2a -text "A" -width 2 -anchor w] -column 2 -row 1 -sticky e

        scale $VolArea::VolArea.nb1.fp.f1.sd -orient horizontal -length 150 -from 0 -to 100 -showvalue 0 -variable d -resolution 0.01 -command {VolArea::drawBox b};
        grid $VolArea::VolArea.nb1.fp.f1.sd -column 1 -row 2 -sticky ew -pady 7
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.ld1 -text "depth" -anchor center] -column 0 -row 2 -sticky we -padx 5 -pady 5
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.ld2 -textvariable d ] -column 2 -row 2 -sticky w
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.ld2a -text "A" -width 2 -anchor w] -column 2 -row 2 -sticky e

        ###############scale x y z

        scale $VolArea::VolArea.nb1.fp.f1.sx -orient horizontal -length 150 -from 0 -to 100 -showvalue 0 -variable x -resolution 0.01 -command {VolArea::drawBox a};
        grid $VolArea::VolArea.nb1.fp.f1.sx -column 1 -row 3 -sticky ew -pady 10
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lxi -text "x" -anchor center] -column 0 -row 3 -sticky we -padx 5 -pady 10
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lx2 -textvariable x] -column 2 -row 3 -sticky w

        scale $VolArea::VolArea.nb1.fp.f1.sy -orient horizontal -length 150 -from 0 -to 100 -showvalue 0 -variable y -resolution 0.01 -command {VolArea::drawBox a};
        grid $VolArea::VolArea.nb1.fp.f1.sy -column 1 -row 4 -sticky ew -pady 10
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lyi -text "y" -anchor center] -column 0 -row 4 -sticky we -padx 5 -pady 10
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.ly2 -textvariable y] -column 2 -row 4 -sticky w

        scale $VolArea::VolArea.nb1.fp.f1.sz -orient horizontal -length 150 -from 0 -to 100 -showvalue 0 -variable z -resolution 0.01 -command {VolArea::drawBox a};
        grid $VolArea::VolArea.nb1.fp.f1.sz -column 1 -row 5 -sticky ew -pady 10
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lzi -text "z" -anchor center] -column 0 -row 5 -sticky we -padx 5 -pady 10
        grid [ttk::label $VolArea::VolArea.nb1.fp.f1.lz2 -textvariable z] -column 2 -row 5 -sticky w


	grid [ttk::label $VolArea::VolArea.nb1.fp.f1.chsel -text "Global Selection "] -column 0 -row 6 -sticky e -padx 5
	grid [ttk::entry $VolArea::VolArea.nb1.fp.f1.ensel ] -column 1 -row 6 -padx 5 -sticky ew -pady 4
	$VolArea::VolArea.nb1.fp.f1.ensel insert 0 "all"
	grid [ttk::button $VolArea::VolArea.nb1.fp.f1.butviewl -text "View" -padding "8 2 3 2" -command VolArea::viewSel] -column 2 -row 6 -sticky e -pady 4

	grid [ttk::checkbutton $VolArea::VolArea.nb1.fp.f1.chrecenter -text "Step Re-center " -variable VolArea::RCenter -command {
		if {[$VolArea::VolArea.nb1.fp.f1.enrecenter get] == ""} {
			tk_messageBox -title "Selection" -message "Please make a valid selection" -type ok -icon info
			set VolArea::RCenter 0
		} else {
			VolArea::checkre
		}


	}] -column 0 -row 7 -sticky w -padx 5
	grid [ttk::entry $VolArea::VolArea.nb1.fp.f1.enrecenter ] -column 1 -row 7  -sticky ew -pady 4 -padx 5

	grid [ttk::button $VolArea::VolArea.nb1.fp.f1.bsel -text "Center" -padding "8 2 3 2" -command {
		set topLayer [molinfo top]
		if {[$VolArea::VolArea.nb1.fp.f1.enrecenter get] != ""} {
			if {$VolArea::RSize == 0} {
				VolArea::sel [$VolArea::VolArea.nb1.fp.f1.enrecenter get] [molinfo $topLayer get frame] 3
			} else {
				VolArea::sel [$VolArea::VolArea.nb1.fp.f1.enrecenter get] [molinfo $topLayer get frame] 2
			}
		}

	} ] -column 2 -row 7 -sticky w -pady 4

	grid [ttk::checkbutton $VolArea::VolArea.nb1.fp.f1.chresize -variable VolArea::RSize -compound bottom  -text "Dimensions of Selection"] -column 1 -row 8 -sticky w  -padx 5
	set VolArea::RSize 0

	######FRAME SUPERIOR NOTEBOOK

	#######Step Options

	if {[molinfo top] != -1} {
		set max [molinfo [molinfo top] get numframes]
	} else {
		set max 1
	}
	grid [ttk::labelframe $VolArea::VolArea.nb1.fp.fs -text "Dynamic Analysis"] -column 0 -row 1 -sticky nwe -pady 4
	grid columnconfigure $VolArea::VolArea.nb1.fp.fs 0 -weight 2; grid rowconfigure $VolArea::VolArea.nb1.fp.fs 0 -weight 2

	set frs $VolArea::VolArea.nb1.fp.fs
	grid [ttk::label $frs.lfrom -text "From"] -column 0 -row 0 -padx 5 -pady 2 -sticky e
	grid [spinbox $frs.spfrom -increment 1 -width 7 -command VolArea::spinfrom] -column 1 -row 0 -padx 2 -sticky we -pady 2
	grid [ttk::label $frs.frto -text "To"] -column 2 -row 0 -padx 5 -pady 2 -sticky e
	grid [spinbox $frs.spto -increment 1 -width 7 -command VolArea::spinfrom] -column 3 -row 0 -padx 2 -pady 2 -sticky we
	grid [ttk::label $frs.lbstep -text "Step"] -column 4 -row 0 -padx 5 -pady 2 -sticky e
	grid [spinbox $frs.spstep -increment 1 -width 7] -column 5 -row 0 -padx 2 -pady 2 -sticky e
	if {$max == 1 } {
		$frs.spfrom configure -from 0
		$frs.spfrom configure -to 1
		$frs.spto configure -from 0
		$frs.spto configure -to 1
		$frs.spstep configure -from 0
		$frs.spstep configure -to 2
		$frs.spfrom set 1
		$frs.spto set 1
		$frs.spstep set 1
	} else {
		$frs.spfrom configure -to [expr $max -1]
		$frs.spfrom configure -from 0
		$frs.spto configure -to [expr $max -1]
		$frs.spto configure -from 0
		$frs.spstep configure -to [expr $max -2]
		$frs.spstep configure -from 1
		$frs.spto set [expr $max -1]
		$frs.spstep set 1
	}

        #####Mol top label
	set molname ""
	if {[molinfo top]==-1} {
		set molname "NONE"
	} else {
		set molname [molinfo top get name]
	}
        grid [ttk::label $VolArea::VolArea.nb1.fp.lt -text "Target: $molname"] -column 0 -row 0 -sticky nwe -pady 4 -padx 5

	##############Run FRAME
	grid [ttk::labelframe $VolArea::VolArea.nb1.fp.fsa -text "Run Configuration" -padding "0 8 0 0"] -column 0 -row 3 -sticky nswe
	grid columnconfigure $VolArea::VolArea.nb1.fp.fsa 1 -weight 2; grid rowconfigure $VolArea::VolArea.nb1.fp.fsa 1 -weight 2

	set fr $VolArea::VolArea.nb1.fp.fsa
	grid [ttk::frame $fr.bvs] -column 0 -row 0 -sticky nswe


	grid [ttk::button $fr.bvs.bysa -text "Surface options" -command VolArea::view_sasa] -column 0 -row 0 -sticky w
	grid [ttk::button $fr.bvs.by -text "Volume options" -command VolArea::view_volume] -column 1 -row 0 -sticky w

	grid [ttk::checkbutton $fr.chs -text "Surface calculation : " -variable VolArea::sasa -command VolArea::checksavo] -column 0 -row 1 -sticky w -padx 5

	grid [ttk::frame $fr.sb -padding "40 0 0 0"] -column 0 -row 2 -sticky nswe
	grid columnconfigure $fr.sb 2 -weight 2; grid rowconfigure $fr.sb 1 -weight 1

	grid [ttk::label $fr.sb.lr -text "Radius(A):"] -column 0 -row 0 -sticky nswe
	grid [spinbox $fr.sb.spr -width 4 -from 0.05 -to 10 -increment 0.05 ] -column 1 -row 0 -sticky w
	$fr.sb.spr set 1.4

	grid [ttk::label $fr.sb.lrs -text "Resolution : "  -padding "7 0 0 0"] -column 2 -row 0 -sticky e
	grid [spinbox $fr.sb.sprs -width 4 -from 1 -to 5000 -increment 10] -column 3 -row 0 -sticky w
	$fr.sb.sprs set 50


	grid [ttk::frame $fr.sc -padding "40 0 0 0"] -column 0 -row 3 -sticky nswe -pady 3
	grid columnconfigure $fr.sc 2 -weight 2; grid rowconfigure $fr.sc 1 -weight 1

	grid [ttk::label $fr.sc.lss -text "Specific Selec : "] -column 0 -row 0 -sticky nswe -pady 2
	grid [ttk::entry $fr.sc.entsel] -column 1 -row 0 -sticky ew -pady 2
	$fr.sc.entsel insert 0 "all"


	grid [ttk::checkbutton $fr.chv -text "Volume calculation : " -variable VolArea::vol -command VolArea::checksavo] -column 0 -row 4 -sticky w -padx 5 -pady 4


	grid [ttk::frame $fr.vb -padding "40 0 0 0"] -column 0 -row 7 -sticky nswe
	grid columnconfigure $fr.vb 0 -weight 2; grid rowconfigure $fr.vb 0 -weight 2

	grid [ttk::label $fr.vb.lsv -text "Scale(A): "] -column 0 -row 0 -sticky nswe
	grid [spinbox $fr.vb.spsv -width 10 -from 0.7 -to 1.0 -increment 0.1] -column 1 -row 0 -sticky e

	grid [ttk::label $fr.vb.lr -text "Cavity Probe Radius(A):"] -column 0 -row 1 -sticky nswe
	grid [spinbox $fr.vb.spr -width 4 -from 0.0 -to 10.0 -increment 0.1 ] -column 1 -row 1 -sticky w
	$fr.vb.spr set 2

	grid [ttk::frame $fr.vc -padding "40 0 0 0"] -column 0 -row 6 -sticky nswe -pady 3
	grid columnconfigure $fr.sc 2 -weight 2; grid rowconfigure $fr.sc 1 -weight 1

	grid [ttk::label $fr.vc.lss -text "Specific Selec : "] -column 0 -row 0 -sticky nswe -pady 2
	grid [ttk::entry $fr.vc.vsel] -column 1 -row 0 -sticky ew -pady 2
	$fr.vc.vsel insert 0 "all"
  $fr.vb.spsv set 1.0
	grid [ttk::frame $fr.vch -padding "40 0 0 0" ] -column 0 -row 5 -sticky nwes
	grid [ttk::checkbutton $fr.vch.chva -text "Atom volume calculation" -variable VolArea::volatom] -column 0 -row 0 -sticky w
	grid forget $VolArea::VolArea.nb1.fp.fsa.vb
	grid forget $VolArea::VolArea.nb1.fp.fsa.vc
	grid forget $VolArea::VolArea.nb1.fp.fsa.sb
	grid forget $VolArea::VolArea.nb1.fp.fsa.sc
	grid [ttk::frame $VolArea::VolArea.nb1.fp.rru -padding "2 0 0 0" ] -column 0 -row 4 -sticky nwes
	grid columnconfigure $VolArea::VolArea.nb1.fp.rru 1 -weight 2; grid rowconfigure $VolArea::VolArea.nb1.fp.rru 1 -weight 2
	grid [ttk::button $VolArea::VolArea.nb1.fp.rru.b1 -text "Run" -command VolArea::RunButton] -column 1 -row 0 -sticky ew -padx 0 -pady 5
	grid [ttk::button $VolArea::VolArea.nb1.fp.rru.br -text "Reset" -command {VolArea::ResetButton r}] -column 0  -row 0 -sticky ew -padx 0 -pady 5
	grid [ttk::button $VolArea::VolArea.nb1.fp.rru.un -text "Unlock" -command VolArea::Unlock -state disable] -column 2  -row 0 -sticky ew -padx 0 -pady 5
	set num 0
	if {$VolArea::sasa == 1} {
		incr num 2
	}
	if {$VolArea::vol == 1} {
		incr num
	}
	grid [ttk::progressbar $VolArea::VolArea.nb1.fp.pg -mode determinate -variable VolArea::pb] -column 0 -row 5 -sticky news -pady 2


	#############Output contents

	set fro $VolArea::VolArea.nb1.fo.f1
	grid [ttk::frame $VolArea::VolArea.nb1.fo.f1] -column 0 -row 0 -sticky nswe -pady 10 -padx 5
	grid columnconfigure $VolArea::VolArea.nb1.fo.f1 1 -weight 2; grid rowconfigure $VolArea::VolArea.nb1.fo.f1 1 -weight 1

	#######Load file fild
	set lo $VolArea::VolArea.nb1.fo.f1


	grid [ttk::label $lo.lbfr -text "Frame :"] -column 0 -row 1 -sticky w -padx 2 -pady 2
	grid [spinbox $lo.spfra -width 7 -state disable -command VolArea::Load] -column 1 -row 1 -sticky w -padx 2 -pady 2



	##################Tablelist

	grid [ttk::labelframe $VolArea::VolArea.nb1.fo.f2 -text "Surface Table"] -column 0 -row 1 -sticky nswe -pady 0 -padx 5
	grid columnconfigure $VolArea::VolArea.nb1.fo.f2 0 -weight 2; grid rowconfigure $VolArea::VolArea.nb1.fo.f2 0 -weight 1

	set fro2 $VolArea::VolArea.nb1.fo.f2
	option add *Tablelist.activeStyle       frame
	option add *Tablelist.background        gray98
	option add *Tablelist.stripeBackground  #e0e8f0
	#option add *Tablelist.setGrid           yes
	option add *Tablelist.movableColumns    yes
	option add *Tablelist.labelCommand      tablelist::sortByColumn


    	tablelist::tablelist $fro2.tb \
		-columns {	0 "Resname"	 left
				0 "Resid"	 right
				0 "Chain" 	 right
				0 "Surface(A²)"     right
				0 "Mean(A²)"	 right
				0 "STDV" right} \
                -yscrollcommand [list $fro2.scr1 set] -xscrollcommand [list $fro2.scr2 set] \
                -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
                -foreground black -background white -state disable -selectmode single -stretch "3 4 5"


	$fro2.tb columnconfigure 0 -sortmode dictionary -name "Resname"
        $fro2.tb columnconfigure 1 -sortmode real -name "Resid"
	$fro2.tb columnconfigure 2 -sortmode dictionary -name "Chain"
	$fro2.tb columnconfigure 3 -sortmode real -name "Surface(A²)"
	$fro2.tb columnconfigure 4 -sortmode real -name "Mean(A²)"
	$fro2.tb columnconfigure 5 -sortmode real -name "STDV"

	grid $fro2.tb -row 0 -column 0 -sticky news
	grid columnconfigure $fro2.tb 0 -weight 2; grid rowconfigure $fro2.tb 1 -weight 1

	##Scrool_BAr V
	scrollbar $fro2.scr1 -orient vertical -command [list $fro2.tb  yview]
      	grid $fro2.scr1 -row 0 -column 1  -sticky ens


	## Scrool_Bar H
      	scrollbar $fro2.scr2 -orient horizontal -command [list $fro2.tb xview]
      	grid $fro2.scr2 -row 1 -column 0 -sticky swe

	##################Frame output representation
	grid [ttk::frame $fro2.rep] -column 0 -row 2 -sticky nwes -padx 2
	grid columnconfigure $fro2.rep 2 -weight 2; grid rowconfigure $fro2.rep 2 -weight 2
	set fro2 $fro2.rep
	grid [ttk::label $fro2.lrep -text "Representation : " -padding "5 0 0 0"] -column 0 -row 0 -sticky w

	grid [ttk::frame $fro2.pr -padding "5 0 0 0"] -column 0 -row 1 -sticky nwes
	grid columnconfigure $fro2.pr 1 -weight 1; grid rowconfigure $fro2.pr 1 -weight 1
	set fro2 $fro2.pr
	grid [ttk::label $fro2.lrept -text "Type : "] -column 0 -row 2 -sticky w -pady 2
	set rep "Off VDW Surface"

	grid [ttk::combobox $fro2.cb1 -values $rep -width 8 -state readonly] -row 2 -column 1 -sticky e
	$fro2.cb1  set [lindex $rep 2]

	 bind $fro2.cb1 <<ComboboxSelected>> {
		$VolArea::VolArea.nb1.fo.f2.rep.pr.cb1 selection clear
	}

	grid [ttk::label $fro2.lbSel -text "Colored by : " -padding "8 0 0 0" ]  -row 2 -column 2

	set repN "Name ResName ResType Index Pos Beta"
	grid [ttk::combobox $fro2.cb2 -values $repN -width 8 -state readonly] -row 2 -column 3 -sticky e
	$fro2.cb2  set [lindex $repN 0]

	bind $fro2.cb2 <<ComboboxSelected>> {
		$VolArea::VolArea.nb1.fo.f2.rep.pr.cb2 selection clear
	}
	grid [ttk::button $fro2.bt -text "Update" -command VolArea::Load -width 6 -padding "2 0 0 0" -state disable] -column 4 -row 2 -column 4 -padx 4
	#####Tableliste volume
	set fro2 $VolArea::VolArea.nb1.fo
	grid [ttk::frame $fro2.fbu] -column 0 -row 3 -sticky nwes -pady 2
	grid columnconfigure $fro2.fbu 0 -weight 2 ;grid rowconfigure $fro2.fbu 0 -weight 2
	grid [ttk::button $fro2.fbu.b -text "Graph" -command VolArea::edgraph -state disable] -column 1 -row 2 -sticky e -pady 2 -padx 2
	grid [ttk::button $fro2.fbu.ba -text "Add Series" -command {VolArea::addseries sasa ""} -state disable] -column 2 -row 2 -sticky e -pady 2 -padx 2
	grid [ttk::button $fro2.fbu.exp -text "Export data" -command VolArea::export -state disable] -column 0 -row 2 -sticky e -pady 2 -padx 2
	grid [ttk::labelframe $fro2.v -text "Volume Table"] -column 0 -row 2 -padx 2 -pady 2 -sticky nwes
	grid columnconfigure $fro2.v 0 -weight 2 ;grid rowconfigure $fro2.v 0 -weight 2


	grid [ttk::frame $fro2.v.vol] -column 0 -row 0 -padx 2 -pady 2 -sticky nwe
	grid columnconfigure $fro2.v.vol 0 -weight 2; grid rowconfigure $fro2.v.vol 2 -weight 2

	set sframe $VolArea::VolArea.nb1.fo.v.vol


	option add *Tablelist.activeStyle       frame
	option add *Tablelist.background        gray98
	option add *Tablelist.stripeBackground  #e0e8f0
	#option add *Tablelist.setGrid           yes
	option add *Tablelist.movableColumns    yes
	option add *Tablelist.labelCommand      tablelist::sortByColumn


    	tablelist::tablelist $sframe.tbt \
		-columns {	0 "Type"	 left
				0 "Volume(A³)"	 right
				0 "Mean(A³)"	 right
				0 "STDV"	 right} \
                -yscrollcommand [list $sframe.scr1 set] -xscrollcommand [list $sframe.scr2 set] \
                -showseparators 0 -labelrelief groove  -labelbd 1 -selectbackground blue -selectforeground white\
                -foreground black -background white -selectmode extended -state disable -stretch "1 2 3" -height 5


	$sframe.tbt columnconfigure 0 -sortmode dictionary -name "Type"
	$sframe.tbt columnconfigure 1 -sortmode real -name "Volume(A³)"
       	$sframe.tbt columnconfigure 1 -sortmode real -name "Mean(A³)"
	$sframe.tbt columnconfigure 1 -sortmode real -name "STDV"
	grid $sframe.tbt -row 0 -column 0 -sticky news
	grid columnconfigure $sframe.tbt 0 -weight 2; grid rowconfigure $sframe.tbt 2 -weight 2

	##Scrool_BAr V
	scrollbar $sframe.scr1 -orient vertical -command [list $sframe.tbt  yview]
      	grid $sframe.scr1 -row 0 -column 1  -sticky ens


	## Scrool_Bar H
      	scrollbar $sframe.scr2 -orient horizontal -command [list $sframe.tbt xview]
      	grid $sframe.scr2 -row 1 -column 0 -sticky swe



	grid [ttk::frame $VolArea::VolArea.nb1.fo.v.rep] -column 0 -row 1 -sticky nwes -padx 2 -pady 2
	set grid $VolArea::VolArea.nb1.fo.v.rep
	grid columnconfigure $grid 1 -weight 2; grid rowconfigure $grid 1 -weight 1

	grid [ttk::label $grid.lrep -text "Representation : " -padding "5 2 0 0"] -column 0 -row 0 -sticky w

	grid [ttk::frame $grid.pr -padding "5 0 0 0"] -column 0 -row 1 -sticky nwes
	grid columnconfigure $grid.pr 1 -weight 2; grid rowconfigure $grid.pr 1 -weight 2
	set fro2 $grid.pr
	grid [ttk::label $fro2.lrept -text "Type : "] -column 0 -row 0 -sticky w -pady 2
	set rep "Off VDW CPK IsoSurface"

	grid [ttk::combobox $fro2.cb1 -values $rep -width 10 -state readonly] -row 0 -column 1 -sticky w
	$fro2.cb1  set [lindex $rep 2]
	bind $VolArea::VolArea.nb1.fo.v.rep.pr.cb1 <<ComboboxSelected>> {
		$VolArea::VolArea.nb1.fo.v.rep.pr.cb1 selection clear
	}
	 $fro2.cb1  set IsoSurface
	grid [ttk::label $fro2.lbSel -text "Colored by : " -padding "8 0 0 0"]  -row 0 -column 2 -sticky w

	set repN "{ColorID 0} {ColorID 1} {ColorID 2} {ColorID 3} {ColorID 4} {ColorID 5} {ColorID 6} {ColorID 7} {ColorID 8} {ColorID 9} {ColorID 10}"
	grid [ttk::combobox $fro2.cb2 -values $repN -width 10 -state readonly] -row 0 -column 3 -sticky w
	$fro2.cb2  set [lindex $repN 0]

	bind $VolArea::VolArea.nb1.fo.v.rep.pr.cb2 <<ComboboxSelected>> {
		$VolArea::VolArea.nb1.fo.v.rep.pr.cb2 selection clear
	}

	grid [ttk::button $fro2.bt -text "Update" -command VolArea::Load -width 6 -padding "2 0 0 0" -state disable] -row 0 -column 4 -padx 4

	#####About###########################################

	image create photo VolArea::img2 -data [VolArea::imagem2]
	grid [ttk::label $VolArea::VolArea.nb1.fab.im -image VolArea::img2 -background #4a4a4c] -row 0 -column 0 -sticky nesw

	set tex {VolArea is a user friendly vmd plug-in that calculates the exposed surface area and volume of molecular systems. Surface values are calculate in a per residue basis (as defined in vmd) . The volume tool can be used to calculate the volume occupied by atoms or the volume that corresponds to cavities within molecules.
This tool can be applied to a wide range of different structures, either whole molecules of molecular fragments defined by the user, using the vmd nomenclature.
The results are stored in a sqlite database chosen by user, and the surface area/volumes can be represented in vmd. Time-dependent values are also represented graphically.
This plug-in was developed by the group of computational biochemistry of the Faculty of Sciences of Porto, Portugal

e-mail: joao.ribeiro@fc.up.pt}
	grid [ttk::frame $VolArea::VolArea.nb1.fab.la] -column 0 -row 1 -sticky nwes
	grid columnconfigure $VolArea::VolArea.nb1.fab.la 0 -weight 2; grid rowconfigure $VolArea::VolArea.nb1.fab.la 0 -weight 2
	grid [text $VolArea::VolArea.nb1.fab.la.te -background white -yscrollcommand [list $VolArea::VolArea.nb1.fab.la.scr1 set] -width 25 -height 15 -wrap word] -row 0 -column 0 -sticky news
	grid columnconfigure $VolArea::VolArea.nb1.fab.la.te 0 -weight 2; grid rowconfigure $VolArea::VolArea.nb1.fab.la.te 0 -weight 1
	$VolArea::VolArea.nb1.fab.la.te insert end $tex
	$VolArea::VolArea.nb1.fab.la.te configure -state disable
	##Scrool_BAr V
	scrollbar $VolArea::VolArea.nb1.fab.la.scr1 -orient vertical -command [list  $VolArea::VolArea.nb1.fab.la.te  yview]
	grid $VolArea::VolArea.nb1.fab.la.scr1 -row 0 -column 1  -sticky ens

	grid [ttk::frame $VolArea::VolArea.nb1.fab.symb] -row 2 -column 0 -sticky news
	grid columnconfigure $VolArea::VolArea.nb1.fab.symb 1 -weight 3; grid rowconfigure $VolArea::VolArea.nb1.fab.symb 1 -weight 1


	image create photo VolArea::imageFCUP -data [VolArea::imageFCUPproc]
	grid [ttk::label $VolArea::VolArea.nb1.fab.symb.imFC -image VolArea::imageFCUP] -row 0 -column 0 -sticky nesw

	image create photo VolArea::imageLicense -data [VolArea::imageLicenseproc]
	grid [ttk::label $VolArea::VolArea.nb1.fab.symb.imLI -image VolArea::imageLicense] -row 0 -column 1 -sticky ns

	image create photo VolArea::imageREQUIMTE -data [VolArea::imageREQUIMTEproc]
	grid [ttk::label $VolArea::VolArea.nb1.fab.symb.imRE -image VolArea::imageREQUIMTE] -row 0 -column 2 -sticky nesw



}
proc VolArea::view_volume {} {
	if {$VolArea::hide_volume ==1} {
		grid forget $VolArea::VolArea.nb1.fp.fsa.vb
		grid forget $VolArea::VolArea.nb1.fp.fsa.vc
		set VolArea::hide_volume 0
	} elseif {$VolArea::hide_volume ==0} {
		grid conf $VolArea::VolArea.nb1.fp.fsa.vb -sticky news -row 7
		grid conf $VolArea::VolArea.nb1.fp.fsa.vc -sticky news  -row 6
		set VolArea::hide_volume 1
	}
}
proc VolArea::view_sasa {} {
	if {$VolArea::hide_sasa ==1} {
		grid forget $VolArea::VolArea.nb1.fp.fsa.sb
		grid forget $VolArea::VolArea.nb1.fp.fsa.sc
		set VolArea::hide_sasa 0
	} elseif {$VolArea::hide_sasa ==0} {
		grid conf $VolArea::VolArea.nb1.fp.fsa.sb -sticky news -row 2
		grid conf $VolArea::VolArea.nb1.fp.fsa.sc -sticky news -row 3
		set VolArea::hide_sasa 1
	}
}
