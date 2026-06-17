// Parameters
nominal_diameter = 90; //[45:180:1]
pipe_outer_diameter = 90; //[45:180:0.1]
socket_depth = 50; //[25:100:1]
wall_thickness = 3; //[1.5:6:0.1]
cap_end_thickness = 4; //[2:8:0.1]
lead_in_chamfer_angle = 30; //[10:60:1]
clearance = 0.2; //[0:0.6:0.05]
overlap = 1; //[0.5:2:0.1]
cap_outer_diameter = 96; //[48:192:0.1]
cap_total_length = 54; //[27:108:0.1]
socket_inner_diameter = 90.4; //[45:181:0.1]
chamfer_axial_length = 2.5; //[1:6:0.1]
ht_pipe_length = 70; //[35:140:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.0, 0.4, 0.2]) { // Green for PVC
    cylinder(h=ht_pipe_length, r=pipe_outer_diameter/2, center=true, $fn=64);
  }
}

// Cap assembly
module cap_with_pipe() {
  difference() {
    // Cap body
    color([0.85, 0.85, 0.8]) { // Off-white for PVC
      translate([0, 0, 0])
        cylinder(h=cap_total_length, r=cap_outer_diameter/2, center=true, $fn=64);
    }
    // Inner bore
    translate([0, 0, -cap_total_length/2 + socket_depth/2])
      cylinder(h=socket_depth + overlap, r=socket_inner_diameter/2, center=true, $fn=64);
    // Lead-in chamfer
    translate([0, 0, -cap_total_length/2 + chamfer_axial_length/2])
      cylinder(h=chamfer_axial_length + overlap, r1=socket_inner_diameter/2 + chamfer_axial_length*tan(lead_in_chamfer_angle), r2=socket_inner_diameter/2, center=true, $fn=64);
  }
  // HT Pipe
  translate([0, 0, -cap_total_length/2 + socket_depth/2 - overlap])
    ht_pipe();
}

// Final assembly
module assembly() {
  cap_with_pipe();
}

assembly();