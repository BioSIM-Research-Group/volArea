package provide view_points 1.0

proc VolArea::save_viewpoint {view_num} {
   global viewpoints
   # get the current matricies
   foreach mol [molinfo list] {
      set viewpoints([molinfo $mol get name],0) [molinfo $mol get rotate_matrix]
      set viewpoints([molinfo $mol get name],1) [molinfo $mol get center_matrix]
      set viewpoints([molinfo $mol get name],2) [molinfo $mol get scale_matrix]
      set viewpoints([molinfo $mol get name],3) [molinfo $mol get global_matrix]

   }
}




proc VolArea::restore_viewpoint {view_num} {
   global viewpoints
   foreach mol [molinfo list] {
      if [info exists viewpoints([molinfo $mol get name],0)] {
         molinfo $mol set rotate_matrix   $viewpoints([molinfo $mol get name],0)
      	molinfo $mol set center_matrix   $viewpoints([molinfo $mol get name],1)
      	molinfo $mol set scale_matrix   $viewpoints([molinfo $mol get name],2)
      	molinfo $mol set global_matrix   $viewpoints([molinfo $mol get name],3)
      }
   }
}
