#!/bin/sh \
exec tclsh8.4 "$0" ${1+"$@"}
package provide vdw 1.0

proc VolArea::vdwfun {rad scale x y z xm ym zm x_max y_max z_max index} {
  set tcl_precision 17
  set rad [expr $rad / $scale]
   set st ""
   set dist_intra [expr round([expr double ($rad * 0.5)])]
   set dist_find $dist_intra
   set a "a"

	for {set k [expr round ($z - [expr $rad  + $dist_find])] } {$k <= [expr round ($z + [expr $rad  + $dist_find])] } {incr k} {
	 for {set j [expr round ($y - [expr $rad  + $dist_find])] } {$j <=  [expr round ($y + [expr $rad  + $dist_find])] } {incr j} {
		 for {set i  [expr round ($x - [expr $rad  + $dist_find])] } {$i <= [expr round ($x + [expr $rad  + $dist_find])] } {incr i} {

      if {[info exists VolArea::matrix($i,$j,$k)] != 1} {
        set VolArea::matrix($i,$j,$k) "a"
      }

			if {$VolArea::matrix($i,$j,$k) != -1} {
        set distx [expr  $i -  $x]
        set disty [expr  $j -  $y]
        set distz [expr  $k - $z]
        set dist1 [expr sqrt([expr [expr $distx * $distx] + [expr $disty * $disty] + [expr $distz * $distz]]) ]
				if {[expr $dist1] <= $rad} {
					set VolArea::matrix($i,$j,$k) -1
				} elseif {[expr $dist1] >= $rad && [expr $dist1] <= [expr $rad + $dist_intra]} {
          if {$VolArea::matrix($i,$j,$k) == "a"} {
            set VolArea::matrix($i,$j,$k) $index
          } elseif {$VolArea::matrix($i,$j,$k) != $index && $VolArea::matrix($i,$j,$k) != -1 && $VolArea::matrix($i,$j,$k) != "a" } {
						set VolArea::matrix($i,$j,$k) -1
					}
				}
			}
		 }
	 }
  }
}


proc VolArea::intra {rad scale x y z xm ym zm x_max y_max z_max dist_empt index} {
  set tcl_precision 17
   set rad [expr $rad / $scale]
   set dist_empt [expr round($dist_empt/$scale)]
   set st ""
   set dist_find $dist_empt

   set a "b"
  set var "$index$a"
	for {set k [expr round ($z - [expr $rad  + $dist_find])] } {$k <= [expr round ($z + [expr $rad  + $dist_find])] } {incr k} {
	 for {set j [expr round ($y - [expr $rad  + $dist_find])] } {$j <=  [expr round ($y + [expr $rad  + $dist_find])] } {incr j} {
		 for {set i  [expr round ($x - [expr $rad  + $dist_find])] } {$i <= [expr round ($x + [expr $rad  + $dist_find])] } {incr i} {
      if {[info exists VolArea::matrix($i,$j,$k)] != 1} {
        set VolArea::matrix($i,$j,$k) "b"
      } elseif {$VolArea::matrix($i,$j,$k) == "a"} {
        set VolArea::matrix($i,$j,$k) "b"
      }
			if {$VolArea::matrix($i,$j,$k) != -1 && $VolArea::matrix($i,$j,$k) != -2} {
        set distx [expr  $i -  $x]
        set disty [expr  $j -  $y]
        set distz [expr  $k - $z]
        set dist1 [expr sqrt([expr [expr $distx * $distx] + [expr $disty * $disty] + [expr $distz * $distz]]) ]
        if {[expr $dist1] > $rad && [expr $dist1] <= [expr $rad + $dist_empt]} {
          if {$VolArea::matrix($i,$j,$k) == "b"} {
            set VolArea::matrix($i,$j,$k) $var
          } elseif {$var !=  $VolArea::matrix($i,$j,$k) && $VolArea::matrix($i,$j,$k) != -1 && $VolArea::matrix($i,$j,$k) != "b" && $VolArea::matrix($i,$j,$k) != "a" && [string index $VolArea::matrix($i,$j,$k) end] == "b"} {
            
						set count 0
						set countfor 0
						for {set h [expr $k -[expr round (1 / $scale)]]} {$h <= [expr $k +[expr round (1 / $scale)]]} {incr h} {
							for {set l [expr $j -[expr round (1 / $scale)]]} {$l <= [expr $j +[expr round (1 / $scale)]]} {incr l} {
								for {set m [expr $i -[expr round (1 / $scale)]]} {$m <= [expr $i +[expr round (1 / $scale)]]} {incr m} {
									if {[info exists VolArea::matrix($m,$l,$h)] == 1} {
										if {$VolArea::matrix($m,$l,$h) == -1 || $VolArea::matrix($m,$l,$h) == "a" ||  [string index $VolArea::matrix($i,$j,$k) end] != "b"} {
											incr count
										}
										incr countfor
									}
								}
							}
						}
						if {$count <= [expr 5 * $scale *[expr $scale * $scale]] && $countfor > 0} {
							set VolArea::matrix($i,$j,$k) -2
						}
          }
        }
			}
		 }
	 }
  }
}