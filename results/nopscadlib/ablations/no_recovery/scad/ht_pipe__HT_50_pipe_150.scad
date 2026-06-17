// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 50; //[25:100:1]
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
od_mm = 50; //[25:100:0.5]
wall_mm = 1.8; //[0.9:3.6:0.1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_len_mm = 30; //[15:60:1]
fitting_od_extra_mm = 6; //[3:12:0.5]
socket_wall_extra_mm = 1.2; //[0.6:2.4:0.1]
socket_depth_mm = 22; //[11:44:1]
chamfer_len_mm = 2; //[1:5:0.5]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe segment
      difference() {
        cylinder(h=length_mm, r=od_mm/2, center=false);
        translate([0, 0, wall_mm])
          cylinder(h=length_mm, r=od_mm/2 - wall_mm, center=false);
      }
      
      // Integrated end fitting
      if (include_end_fitting) {
        difference() {
          translate([0, 0, length_mm - overlap_mm])
            cylinder(h=fitting_len_mm, r=od_mm/2 + fitting_od_extra_mm/2, center=false);
          
          // Bore void
          translate([0, 0, length_mm - overlap_mm])
            cylinder(h=fitting_len_mm, r=od_mm/2 - wall_mm - socket_wall_extra_mm, center=false);
          
          // Socket void
          translate([0, 0, length_mm - overlap_mm + (fitting_len_mm - socket_depth_mm)])
            cylinder(h=socket_depth_mm, r=od_mm/2 - wall_mm, center=false);
          
          // Chamfer void
          translate([0, 0, length_mm - overlap_mm + (fitting_len_mm - socket_depth_mm) - chamfer_len_mm])
            cylinder(h=chamfer_len_mm, r1=od_mm/2 - wall_mm, r2=od_mm/2 - wall_mm - socket_wall_extra_mm, center=false);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();