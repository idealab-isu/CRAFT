// Parameters
length_mm = 2000; //[1000:4000:10]
include_end_fitting = 1; //[0:1:1]
od_mm = 90; //[75:110:1]
wall_mm = 3.2; //[2:6:0.1]
socket_length_mm = 60; //[30:120:1]
socket_wall_extra_mm = 2.0; //[0.5:6:0.1]
socket_id_clearance_mm = 0.6; //[0.2:1.5:0.1]
stop_ring_thickness_mm = 3; //[1:8:0.5]
stop_ring_length_mm = 6; //[2:20:1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm - include_end_fitting * socket_length_mm + overlap_mm, r=od_mm/2, center=false);
        translate([0, 0, -overlap_mm])
          cylinder(h=length_mm - include_end_fitting * socket_length_mm + overlap_mm + 2 * overlap_mm, r=od_mm/2 - wall_mm, center=false);
      }
      
      // End fitting geometry
      if (include_end_fitting) {
        difference() {
          union() {
            // Socket outer
            translate([0, 0, length_mm - include_end_fitting * socket_length_mm - overlap_mm])
              cylinder(h=include_end_fitting * socket_length_mm, r=od_mm/2 + socket_wall_extra_mm, center=false);
            
            // Socket stop ring
            difference() {
              translate([0, 0, length_mm - include_end_fitting * socket_length_mm + include_end_fitting * (socket_length_mm * 0.6) - overlap_mm])
                cylinder(h=include_end_fitting * stop_ring_length_mm, r=od_mm/2 + socket_id_clearance_mm/2, center=false);
              translate([0, 0, length_mm - include_end_fitting * socket_length_mm + include_end_fitting * (socket_length_mm * 0.6) - overlap_mm - overlap_mm])
                cylinder(h=include_end_fitting * stop_ring_length_mm + 2 * overlap_mm, r=od_mm/2 + socket_id_clearance_mm/2 - stop_ring_thickness_mm, center=false);
            }
          }
          
          // Socket inner void
          translate([0, 0, length_mm - include_end_fitting * socket_length_mm - overlap_mm - overlap_mm])
            cylinder(h=include_end_fitting * socket_length_mm + 2 * overlap_mm, r=od_mm/2 + socket_id_clearance_mm/2, center=false);
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