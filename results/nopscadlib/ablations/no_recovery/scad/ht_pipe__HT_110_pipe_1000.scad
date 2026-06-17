// Parameters
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]
od_mm = 110; //[90:160:1]
wall_thickness_mm = 3.2; //[2:6.5:0.1]
socket_length_mm = 60; //[30:120:1]
socket_wall_extra_mm = 2.0; //[0.5:6.0:0.1]
socket_od_extra_mm = 6.0; //[2.0:16.0:0.5]
socket_stop_thickness_mm = 4.0; //[2.0:10.0:0.5]
socket_stop_length_mm = 8.0; //[4.0:20.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=od_mm/2 - wall_thickness_mm, center=false);
    }
    
    if (include_end_fitting) {
      // Socket fitting
      union() {
        // Socket shell
        difference() {
          translate([0, 0, length_mm - overlap_mm])
            cylinder(h=socket_length_mm, r=(od_mm + socket_od_extra_mm)/2, center=false);
          translate([0, 0, length_mm - overlap_mm - overlap_mm/2])
            cylinder(h=socket_length_mm + overlap_mm, r=od_mm/2 + socket_wall_extra_mm, center=false);
        }
        
        // Socket stop ring
        difference() {
          translate([0, 0, length_mm - overlap_mm + socket_length_mm - socket_stop_length_mm - overlap_mm])
            cylinder(h=socket_stop_length_mm, r=od_mm/2 + socket_wall_extra_mm, center=false);
          translate([0, 0, length_mm - overlap_mm + socket_length_mm - socket_stop_length_mm - overlap_mm - overlap_mm/2])
            cylinder(h=socket_stop_length_mm + overlap_mm, r=od_mm/2 - wall_thickness_mm, center=false);
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