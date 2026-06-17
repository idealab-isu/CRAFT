// Parameters
pipe_outer_diameter_mm = 50; //[25:100:0.1]
cap_outer_diameter_mm = 56; //[28:112:0.1]
wall_thickness_mm = 3; //[1.5:6:0.1]
socket_inner_diameter_mm = 50.5; //[25.25:101:0.1]
insertion_depth_mm = 35; //[17.5:70:0.5]
end_thickness_mm = 4; //[2:8:0.1]
chamfer_mm = 1; //[0:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
pipe_length_mm = 60; //[30:120:1]
pipe_wall_thickness_mm = 2; //[1:4:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color("DimGray") {
    // Outer pipe
    cylinder(r=pipe_outer_diameter_mm/2, h=pipe_length_mm, center=true);
    // Inner cavity
    translate([0, 0, -overlap_mm/2])
      cylinder(r=(pipe_outer_diameter_mm/2) - pipe_wall_thickness_mm, h=pipe_length_mm + overlap_mm, center=true);
  }
}

// Cap assembly
module cap_assembly() {
  color("Silver") {
    // Cap body
    difference() {
      cylinder(r=cap_outer_diameter_mm/2, h=insertion_depth_mm + end_thickness_mm, center=true);
      // Inner socket cavity
      translate([0, 0, (insertion_depth_mm + overlap_mm)/2 - (insertion_depth_mm + end_thickness_mm)/2])
        cylinder(r=socket_inner_diameter_mm/2, h=insertion_depth_mm + overlap_mm, center=true);
      // Socket chamfer cavity
      translate([0, 0, -(insertion_depth_mm + end_thickness_mm)/2 + chamfer_mm/2])
        cylinder(r1=(socket_inner_diameter_mm/2) + chamfer_mm, r2=socket_inner_diameter_mm/2, h=chamfer_mm, center=true);
    }
    // End face
    translate([0, 0, (insertion_depth_mm + end_thickness_mm)/2 - end_thickness_mm/2])
      cylinder(r=cap_outer_diameter_mm/2, h=end_thickness_mm, center=true);
  }
}

// Assembly
module assembly() {
  cap_assembly();
  translate([0, 0, -(insertion_depth_mm + end_thickness_mm)/2 - pipe_length_mm/2 + overlap_mm])
    ht_pipe();
}

assembly();