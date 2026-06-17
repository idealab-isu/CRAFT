// Parameters
nominal_diameter_mm = 32; //[16:64:1]
pipe_outer_diameter_mm = 32; //[20:50:0.1]
cap_outer_diameter_mm = 40; //[28:80:0.1]
wall_thickness_mm = 2.5; //[1.2:6:0.1]
insertion_depth_mm = 25; //[12:60:1]
end_thickness_mm = 3; //[1.5:8:0.1]
clearance_mm = 0.3; //[0.1:1:0.05]
chamfer_mm = 1; //[0:3:0.1]
stop_shoulder_thickness_mm = 2; //[1:5:0.1]
grip_rim_radial_mm = 2; //[0:6:0.1]
grip_rim_height_mm = 6; //[2:15:0.5]
pipe_wall_mm = 2.0; //[1.0:4.0:0.1]
pipe_stub_length_mm = 60; //[30:150:1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(h=pipe_stub_length_mm, r=pipe_outer_diameter_mm/2, center=true);
      // Inner cavity
      translate([0, 0, -overlap_mm/2])
        cylinder(h=pipe_stub_length_mm + overlap_mm, r=pipe_outer_diameter_mm/2 - pipe_wall_mm, center=true);
    }
  }
}

// Cap assembly
module cap_assembly() {
  color([0.85, 0.85, 0.8]) {
    // Cap body
    difference() {
      cylinder(h=end_thickness_mm + insertion_depth_mm, r=cap_outer_diameter_mm/2, center=true);
      // Socket cavity
      translate([0, 0, (end_thickness_mm + insertion_depth_mm)/2 - (insertion_depth_mm + overlap_mm)/2])
        cylinder(h=insertion_depth_mm + overlap_mm, r=pipe_outer_diameter_mm/2 + clearance_mm, center=true);
      // Stop shoulder
      translate([0, 0, -(end_thickness_mm + insertion_depth_mm)/2 + end_thickness_mm + insertion_depth_mm - stop_shoulder_thickness_mm/2])
        cylinder(h=stop_shoulder_thickness_mm, r=pipe_outer_diameter_mm/2 + clearance_mm, center=true);
      // Chamfer cutter
      translate([0, 0, (end_thickness_mm + insertion_depth_mm)/2 - chamfer_mm/2])
        rotate([180, 0, 0])
        cylinder(h=chamfer_mm, r1=pipe_outer_diameter_mm/2 + clearance_mm + chamfer_mm, r2=0, center=true);
    }
    // Outer grip rim
    translate([0, 0, (end_thickness_mm + insertion_depth_mm)/2 - grip_rim_height_mm/2])
      cylinder(h=grip_rim_height_mm, r=cap_outer_diameter_mm/2 + grip_rim_radial_mm, center=true);
    // End face
    translate([0, 0, -(end_thickness_mm + insertion_depth_mm)/2 + end_thickness_mm/2])
      cylinder(h=end_thickness_mm, r=cap_outer_diameter_mm/2, center=true);
  }
}

// Final assembly
module assembly() {
  cap_assembly();
  translate([0, 0, (end_thickness_mm + insertion_depth_mm)/2 - insertion_depth_mm/2 - overlap_mm])
    ht_pipe();
}

assembly();