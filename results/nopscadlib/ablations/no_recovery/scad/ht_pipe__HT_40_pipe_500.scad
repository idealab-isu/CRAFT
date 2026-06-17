// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 40; //[20:80:1]
length_mm = 500; //[250:1000:1]
include_end_fitting = 1; //[0:1:1]
ht40_outer_diameter = 40; //[30:60:0.5]
pipe_wall_thickness = 1.8; //[1.0:3.6:0.1]
fit_overlap = 1; //[0.5:2:0.1]
socket_length = 35; //[20:70:1]
socket_wall_extra = 2.2; //[1.0:5.0:0.1]
socket_clearance = 0.6; //[0.2:1.2:0.1]
stop_ring_thickness = 2; //[1:5:0.1]
stop_ring_radial = 1.2; //[0.5:3:0.1]
chamfer_length = 3; //[1:8:0.5]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      translate([0, 0, 0])
        cylinder(h=length_mm, r=ht40_outer_diameter/2, center=false);
      translate([0, 0, -fit_overlap])
        cylinder(h=length_mm + fit_overlap, r=ht40_outer_diameter/2 - pipe_wall_thickness, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        // Socket shell
        translate([0, 0, length_mm - fit_overlap])
          cylinder(h=socket_length, r=ht40_outer_diameter/2 + socket_wall_extra, center=false);
        
        // Socket inner void
        translate([0, 0, length_mm - fit_overlap])
          cylinder(h=socket_length + fit_overlap, r=ht40_outer_diameter/2 + socket_clearance, center=false);
        
        // Stop ring void
        translate([0, 0, length_mm - fit_overlap + socket_length - stop_ring_thickness])
          cylinder(h=stop_ring_thickness + fit_overlap, r=ht40_outer_diameter/2 + socket_clearance - stop_ring_radial, center=false);
        
        // Mouth chamfer void
        translate([0, 0, length_mm - fit_overlap + socket_length - chamfer_length])
          cylinder(h=chamfer_length, r1=ht40_outer_diameter/2 + socket_clearance, r2=ht40_outer_diameter/2 + socket_clearance + chamfer_length, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();