// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 160; //[80:320:1]
length_mm = 250; //[125:500:1]
pipe_od = 160; //[80:320:1]
wall_thickness = 4.7; //[2.35:9.4:0.1]
include_end_fitting = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]
socket_length = 45; //[25:90:1]
socket_wall_extra = 3; //[1.5:6:0.1]
socket_id_clearance = 0.8; //[0.2:2:0.1]
stop_ring_length = 6; //[3:15:0.5]
stop_ring_radial = 2; //[1:5:0.1]
chamfer_length = 4; //[2:10:0.5]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Hollow tube body
    difference() {
      cylinder(r=pipe_od/2, h=length_mm, center=false);
      translate([0, 0, -overlap])
        cylinder(r=pipe_od/2 - wall_thickness, h=length_mm + 2*overlap, center=false);
    }
    
    // End fitting (socket)
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - overlap])
          cylinder(r=pipe_od/2 + socket_wall_extra, h=socket_length, center=false);
        translate([0, 0, length_mm - 2*overlap])
          cylinder(r=pipe_od/2 + socket_id_clearance, h=socket_length + 2*overlap, center=false);
        translate([0, 0, length_mm - overlap + (socket_length - stop_ring_length) - overlap])
          cylinder(r=pipe_od/2 + socket_id_clearance - stop_ring_radial, h=stop_ring_length + 2*overlap, center=false);
        translate([0, 0, length_mm - 2*overlap])
          cylinder(r1=pipe_od/2 + socket_id_clearance, r2=pipe_od/2 + socket_id_clearance + chamfer_length, h=chamfer_length + overlap, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();