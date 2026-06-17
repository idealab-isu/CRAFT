// Parameters
nominal_diameter_mm = 160; //[80:320:1]
pipe_outer_diameter_mm = 160; //[80:320:1]
cap_outer_diameter_mm = 175; //[120:350:1]
wall_thickness_mm = 4.5; //[2.5:9:0.1]
socket_depth_mm = 60; //[30:120:1]
end_thickness_mm = 6; //[3:15:0.5]
clearance_mm = 0.4; //[0.1:1.2:0.05]
chamfer_mm = 2; //[0:6:0.5]
fillet_radius_mm = 1.5; //[0:5:0.5]
stop_shoulder_height_mm = 3; //[1:8:0.5]
stop_shoulder_radial_mm = 2; //[1:6:0.5]
grip_rim_radial_mm = 3; //[1:8:0.5]
grip_rim_height_mm = 8; //[3:20:1]
overlap_mm = 1; //[0.5:2:0.1]
pipe_wall_mm = 4.7; //[2.5:10:0.1]
pipe_stub_length_mm = 120; //[60:240:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(r=pipe_outer_diameter_mm/2, h=pipe_stub_length_mm, center=true);
      // Inner pipe
      translate([0, 0, -overlap_mm/2])
        cylinder(r=pipe_outer_diameter_mm/2 - pipe_wall_mm, h=pipe_stub_length_mm + overlap_mm, center=true);
    }
  }
}

// Cap assembly
module cap() {
  color([0.75, 0.75, 0.77]) {
    difference() {
      union() {
        // Cap body
        translate([0, 0, 0])
          cylinder(r=cap_outer_diameter_mm/2, h=socket_depth_mm + end_thickness_mm, center=true);
        // Outer grip rim
        translate([0, 0, -(socket_depth_mm + end_thickness_mm)/2 + grip_rim_height_mm/2 - overlap_mm])
          cylinder(r=cap_outer_diameter_mm/2 + grip_rim_radial_mm, h=grip_rim_height_mm, center=true);
        // Closed end face
        translate([0, 0, (socket_depth_mm + end_thickness_mm)/2 - end_thickness_mm/2])
          cylinder(r=(cap_outer_diameter_mm/2) - wall_thickness_mm, h=end_thickness_mm, center=true);
        // Socket stop shoulder
        translate([0, 0, (socket_depth_mm + end_thickness_mm)/2 - end_thickness_mm - stop_shoulder_height_mm/2])
          cylinder(r=((pipe_outer_diameter_mm + clearance_mm)/2) - stop_shoulder_radial_mm, h=stop_shoulder_height_mm, center=true);
      }
      // Internal socket
      translate([0, 0, (socket_depth_mm + overlap_mm)/2 - (socket_depth_mm + end_thickness_mm)/2])
        cylinder(r=(pipe_outer_diameter_mm + clearance_mm)/2, h=socket_depth_mm + overlap_mm, center=true);
      // Socket mouth chamfer
      translate([0, 0, -(socket_depth_mm + end_thickness_mm)/2 + chamfer_mm/2])
        cylinder(r1=(pipe_outer_diameter_mm + clearance_mm)/2 + chamfer_mm, r2=(pipe_outer_diameter_mm + clearance_mm)/2, h=chamfer_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  cap();
  translate([0, 0, -(socket_depth_mm + end_thickness_mm)/2 - pipe_stub_length_mm/2 + overlap_mm])
    ht_pipe();
}

assembly();