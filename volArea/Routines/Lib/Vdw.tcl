
namespace eval ::Vdw:: {
  namespace import ::


  set IDproce 0
  array set id ""




  if {$::tcl_platform(os) == "Darwin"} {
    catch {exec sysctl -n hw.ncpu} proce
  } elseif {$::tcl_platform(os) == "Linux"} {
    catch {exec grep -c "model name" /proc/cpuinfo} proce
  } elseif {[string first "Windows" $::tcl_platform(os)] != -1} {
    catch {HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor } proce
    set proce [llength $proce]
  }
  
  
   package require Thread
  
  if {$::tcl_platform(os) == "Linux"} {
   
    if { $::tcl_platform(machine) == "i686" }   {
      set dll "/Routines/Other/sqlite/32B/"
      load [file nativename [file join "[lindex $argv 7]$dll" tclsqlite-3.6.11.so]] Sqlite3
      package require sqlite3
    }
    
    if { $::tcl_platform(machine) == "x86_64" }   {
      set dll "/Routines/Other/sqlite/64B/"
      load [file nativename [file join "[lindex $argv 7]$dll" libtclsqlite3.so]] Sqlite3
      package require sqlite3
    }
  }

  # MacOS Leopard
  if {$::tcl_platform(os) == "Darwin"} {
      set dll "/Routines/Other/sqlite/MacOs/"
      load [file nativename [file join "[lindex $argv 7]$dll" libsqlite3.6.18.dylib]] Sqlite3
      package require sqlite3
  }
  
   # Windows
   if {[string first "Windows" $::tcl_platform(os)] != -1} {
      set dll "/Routines/Other/sqlite/Windows/"
      load [file nativename [file join "[lindex $argv 7]$dll" tclsqlite3.dll]] Sqlite3
      package require sqlite3
  }

}


proc Vdw::main { scale a_xmin a_ymin a_zmin a_xmax a_ymax a_zmax path frm frmtot dist_empt VolAreaPath db pathDb x_origin y_origin z_origin} {

 
 
 
	array unset id
  array set id ""

  set fld "Routines/Lib"
	set infile [file dirname $pathDb]

  set vdw_file [open "$infile/vdw.cor" r+]
  set rad [read -nonewline $vdw_file]
  set rad [split $rad " "]
  close $vdw_file
  set xl_file [open "$infile/xl.cor" r+]
  set xl [read -nonewline $xl_file]
  set xl [split $xl " "]
  close $xl_file
  set yl_file [open "$infile/yl.cor" r+]
  set yl [read -nonewline $yl_file]
  set yl [split $yl " "]
  close $yl_file
  set zl_file [open "$infile/zl.cor" r+]
  set zl [read -nonewline $zl_file]
  set zl [split $zl " "]
  close $zl_file
  set j 0
  set i 0
  set max [expr round([expr double([llength $xl])/ $Vdw::proce])]
  set do 0
  set dist_over 2
  while {$j < $Vdw::proce} {
    set id($j) [thread::create]
        set lmin [expr $max *$j]
      set lmax [expr $max * [expr $j +1]]
      if {$j != $Vdw::proce} {
	set i 0
	set h 0
	if {[expr [expr $max * [expr $j +1]] + $i] <  [llength $zl]} {
	  set do 0
	  set pass 0
	    if {$j <  [expr $Vdw::proce -1]} {
	      while {[expr [expr [lindex $zl [expr [expr $max * [expr $j +1]] + $i]] * $scale] - [expr [lindex $zl [expr $max * [expr $j +1]]] * $scale]] <= $dist_over && $j != [expr $Vdw::proce -1] && [expr [expr $max * [expr $j +1]] + $i] < [llength $zl]} {
		incr i
	      }
	      if {$i != 0} {
		set lmax [expr [expr $max * [expr $j +1]] + $i]
	      }
	    }
	}
	if {$j > 0} {
	  if {[expr [expr $max *$j] - $h] > 0} {
	    while {[expr abs([expr [lindex $zl [expr $max *$j] ]*$scale] -  [expr [lindex $zl [expr [expr $max *$j] - $h]] * $scale]) ] <= $dist_over && [expr [expr $max *$j] - $h] > 0} {
	      incr h
	    }
	    if {$h != 0} {
	       set lmin [expr [expr $max * $j] - $h]
	    }
	  }
	}





      }

    tsv::set in 0 [lrange $xl  $lmin $lmax ]
    tsv::set in 1 [lrange $yl  $lmin  $lmax ]
    tsv::set in 2 [lrange $zl  $lmin $lmax ]
    tsv::set in 3 [lrange $rad  $lmin  $lmax ]

    tsv::set in 4 $scale
    tsv::set in 5 $a_xmin
    tsv::set in 6 $a_ymin
    tsv::set in 7 $a_zmin
    tsv::set in 8 $a_xmax
    tsv::set in 9 $a_ymax
    tsv::set in 10 $a_zmax
    tsv::set in 12 $path
    tsv::set in 15 $dist_empt
    tsv::set in 16 $Vdw::proce

    tsv::set in 14 $j
    thread::send -async $id($j) {
      set tcl_precision 17
      set xl [tsv::get in 0]
      set yl [tsv::get in 1]
      set zl [tsv::get in 2]
      set rad [tsv::get in 3]
      set scale [tsv::get in 4]
      set a_xmin [tsv::get in 5]
      set a_ymin [tsv::get in 6]
      set a_zmin [tsv::get in 7]
      set a_xmax [tsv::get in 8]
      set a_ymax [tsv::get in 9]
      set a_zmax [tsv::get in 10]
      set path [tsv::get in 12]
      set j [tsv::get in 14]
      set dist_empt [tsv::get in 15]
      set proce [tsv::get in 16]
      lappend auto_path $path
      package require VolArea 1.0
      namespace import VolArea::*
      set i 0
      set st ""
		
			array set VolArea::matrix ""
		
					while {[lindex $xl $i] != "" && [lindex $yl $i] !="" && [lindex $zl $i] != "" } {
		
			set x [lindex $xl $i]
			set y [lindex $yl $i]
			set z [lindex $zl $i]
		
			VolArea::vdwfun [lindex $rad $i] $scale $x $y $z $a_xmin $a_ymin $a_zmin $a_xmax $a_ymax $a_zmax [expr $i + [expr [llength $xl] *$j] ]
			incr i
					}


      tsv::set out $j [array get VolArea::matrix]
      return
    } Vdw::result
    incr j
  }

  set j 0
  set aux ""

  while {$j < $Vdw::proce} {
    vwait Vdw::result
    incr j
  }
	set j 0
	 while {$j < $Vdw::proce} {
    set aux [append aux "[tsv::get out $j] "]
    incr j
  }
  set j 0
  tsv::unset out
   tsv::unset in
  unset Vdw::result
  array set matrix $aux
  set lis_all [array get matrix]
  set lis_1 [lsearch -all -exact $aux -1]

  for {set i 0} {$i < [expr [llength $lis_1] -1]} {incr i} {

    if {[lindex $aux [expr [lindex $lis_1 $i] -1]] != ""} {
      if {$matrix([lindex $aux [expr [lindex $lis_1 $i] -1]]) != -1} {
	set matrix([lindex $aux [expr [lindex $lis_1 $i] -1]]) -1
      }
    }
  }

  set j 0
  array unset id
  array set id ""

  set dist_over 2

  if {$dist_empt > 0} {
    unset aux
    unset lis_all
    unset lis_1
   while {$j < $Vdw::proce} {
    set id($j) [thread::create]
      set lmin [expr $max *$j]
      set lmax [expr $max * [expr $j +1]]
      if {$j != $Vdw::proce} {
			set i 0
			set h 0
			if {[expr [expr $max * [expr $j +1]] + $i] <  [llength $zl]} {
				set do 0
				set pass 0
					if {$j <  [expr $Vdw::proce -1]} {
						while {[expr [expr [lindex $zl [expr [expr $max * [expr $j +1]] + $i]] * $scale] - [expr [lindex $zl [expr $max * [expr $j +1]]] * $scale]] <= $dist_over && $j != [expr $Vdw::proce -1] && [expr [expr $max * [expr $j +1]] + $i] < [llength $zl]} {
				incr i
						}
						if {$i != 0} {
				set lmax [expr [expr $max * [expr $j +1]] + $i]
						}
					}
			}
			if {$j > 0} {
				if {[expr [expr $max *$j] - $h] > 0} {
					while {[expr abs([expr [lindex $zl [expr $max *$j] ]*$scale] -  [expr [lindex $zl [expr [expr $max *$j] - $h]] * $scale]) ] <= $dist_over && [expr [expr $max *$j] - $h] > 0} {
						incr h
					}
					if {$h != 0} {
						 set lmin [expr [expr $max * $j] - $h]
					}
				}
			}





      }

    tsv::set in$j 0 [lrange $xl  $lmin $lmax ]
    tsv::set in$j 1 [lrange $yl  $lmin  $lmax ]
    tsv::set in$j 2 [lrange $zl  $lmin $lmax ]
    tsv::set in$j 3 [lrange $rad  $lmin  $lmax ]

      tsv::set in$j 4 $scale
      tsv::set in$j 5 $a_xmin
      tsv::set in$j 6 $a_ymin
      tsv::set in$j 7 $a_zmin
      tsv::set in$j 8 $a_xmax
      tsv::set in$j 9 $a_ymax
      tsv::set in$j 10 $a_zmax
      tsv::set in$j 13 [array get matrix]

      tsv::set in$j 12 $path
      tsv::set in$j 15 $dist_empt
      tsv::set in$j 16 $Vdw::proce
      tsv::set in 0 $j
    thread::send -async $id($j) {
      set tcl_precision 17
      set j [tsv::get in 0]
      set xl [tsv::get in$j 0]
      set yl [tsv::get in$j 1]
      set zl [tsv::get in$j 2]
      set rad [tsv::get in$j 3]
      set scale [tsv::get in$j 4]
      set a_xmin [tsv::get in$j 5]
      set a_ymin [tsv::get in$j 6]
      set a_zmin [tsv::get in$j 7]
      set a_xmax [tsv::get in$j 8]
      set a_ymax [tsv::get in$j 9]
      set a_zmax [tsv::get in$j 10]
      set path [tsv::get in$j 12]
      set dist_empt [tsv::get in$j 15]
      set proce [tsv::get in$j 16]
      lappend auto_path $path
      package require VolArea 1.0
      namespace import VolArea::*
      set fld "Routines/Lib/Vdw_func.tcl"
      set i 0
      array set st [tsv::get in$j 13]
      tsv::unset in$j
      set mt ""
      set min 0
      set max 0
      if {$j > 0} {
				set min [expr [lindex $zl 0] - [expr round([expr $dist_empt + [lindex $rad 0]]/$scale)]]
				if {$min < $a_zmin} {
					set min [lindex $zl 0]
				}
						} else {
				set min [lindex $zl 0]
						}
						if {$j < [expr $proce -1]} {
				set max [expr [lindex $zl end] + [expr round([expr $dist_empt + [lindex $rad end]]/$scale)]]
				if {$max > $a_zmax} {
					set max [lindex $zl end]
				}
						} else {
				set max [lindex $zl end]
						}
				for {set i $min} {$i <= $max} {incr i} {
					set mt [append mt "[array get st  *,*,$i] "]
				}
				array set VolArea::matrix $mt
				unset mt
				array unset st
				set i 0
				while {[lindex $xl $i] != "" && [lindex $yl $i] !="" && [lindex $zl $i] != "" } {
					set x [lindex $xl $i]
					set y [lindex $yl $i]
					set z [lindex $zl $i]
			
					VolArea::intra [lindex $rad $i] $scale $x $y $z $a_xmin $a_ymin $a_zmin $a_xmax $a_ymax $a_zmax $dist_empt [expr $i + [expr [llength $xl] *$j] ]
					incr i
				}


      tsv::set out $j [array get VolArea::matrix]
      foreach v [info vars] {unset $v}
      unset v
      return
    } Vdw::result
    incr j
    }

    set j 0
    set aux ""

			while {$j < $Vdw::proce} {
				vwait Vdw::result
				incr j
			}
			set j 0
			 while {$j < $Vdw::proce} {
				set aux [append aux "[tsv::get out $j] "]
				incr j
			}
				set j 0
				tsv::unset out
				tsv::unset in
				array set matrix_2 $aux
				set lis_all [array get matrix_2]
				set lis_1 [lsearch -all -exact $aux -2]
		
		
				for {set i 0} {$i < [expr [llength $lis_1] -1]} {incr i} {
		
			if {[lindex $aux [expr [lindex $lis_1 $i] -1]] != ""} {
				if {[info exists matrix([lindex $aux [expr [lindex $lis_1 $i] -1]])] != 1} {
					 set matrix([lindex $aux [expr [lindex $lis_1 $i] -1]]) -2
				} else {
				if {$matrix([lindex $aux [expr [lindex $lis_1 $i] -1]]) != -2 && $matrix([lindex $aux [expr [lindex $lis_1 $i] -1]]) != -1} {
					set matrix([lindex $aux [expr [lindex $lis_1 $i] -1]]) -2
				}
			}
      }
    }


  }

  unset aux
  unset lis_all
  unset lis_1
  set lis_all [array get matrix]
  array unset matrix
  update
  set vol 0
  set xyzl4 ""
  set i 0
  set volatom 0
  while {$i < [llength $lis_all]} {
    set coor [lindex $lis_all $i]
    set ix [lindex [split $coor ","] 0]
    set iy [lindex [split $coor ","] 1]
    set iz [lindex [split $coor ","] 2]
    if {$ix >= $a_xmin && $ix <= $a_xmax && $iy >= $a_ymin && $iy <= $a_ymax && $iz >= $a_zmin && $iz <= $a_zmax} {
			
      if {[lindex $lis_all [expr $i +1]] == -2} {
	  set x [expr [expr [expr $ix *$scale] + $x_origin] -$scale/2]
	  set y [expr [expr [expr $iy *$scale] + $y_origin] -$scale/2]
	  set z [expr [expr [expr $iz *$scale] + $z_origin] -$scale/2]
	  set xyzl4 [lappend xyzl4 "$x $y $z"]
	  incr vol
      } elseif {[lindex $lis_all [expr $i +1]] == -1} {
				incr volatom
      }
    }
   incr i 2
  }
  unset lis_all

  set volatom [expr $volatom * $scale *[expr $scale * $scale]]
  set vol [expr $vol * $scale *[expr $scale * $scale]]
  sqlite $db $pathDb
  $db busy
  $db eval "CREATE TABLE if not exists frame_$frm (resname TEXT,id INTEGER,chain TEXT, xyz TEXT , sasa TEXT, SasaMean TEXT, STDV TEXT)"
  set name "volume"
  set idvol -2
  set chain " "
  $db eval "INSERT INTO frame_$frm (resname,id, chain, xyz, sasa) VALUES(:name,:idvol ,:chain , :xyzl4, :vol)"
  unset xyzl4
  set name "volatom"
  set idvol -3
  $db eval "INSERT INTO frame_$frm (resname,id,chain, sasa) VALUES(:name,:idvol, :chain, :volatom)"
   $db close
  file delete $infile/xl.cor
  file delete $infile/yl.cor
  file delete $infile/zl.cor
  file delete $infile/vdw.cor


  foreach v [info vars] {unset $v}
  unset v

  array unset id
  return
}



 Vdw::main [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3] [lindex $argv 4] [lindex $argv 5]\
[lindex $argv 6] [lindex $argv 7] [lindex $argv 8] [lindex $argv 9] [lindex $argv 10] [lindex $argv 11] [lindex $argv 12] [lindex $argv 13] [lindex $argv 14] [lindex $argv 15] [lindex $argv 16]
