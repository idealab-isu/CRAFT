// Parameters
nominal_diameter_mm = 75; //[40:150:1]
pipe_outer_diameter_mm = 75; //[40:150:0.1]
cap_wall_thickness_mm = 3; //[1.5:8:0.1]
insertion_depth_mm = 30; //[10:80:1]
end_thickness_mm = 4; //[2:12:0.1]
clearance_mm = 0.3; //[0:1.5:0.05]
chamfer_mm = 1; //[0:4:0.1]
pipe_wall_thickness_mm = 2.5; //[1:6:0.1]
pipe_length_mm = 60; //[30:200:1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.0, 0.4, 0.2]) { // Green for PVC pipe
    difference() {
      // Outer pipe
      cylinder(h=pipe_length_mm, r=pipe_outer_diameter_mm/2, center=true, $fn=64);
      // Inner cavity
      translate([0, 0, -pipe_length_mm/2])
        cylinder(h=pipe_length_mm, r=pipe_outer_diameter_mm/2 - pipe_wall_thickness_mm, center=false, $fn=64);
    }
  }
}

// Cap Body
module cap_body() {
  difference() {
    // Outer cap body
    cylinder(h=insertion_depth_mm + end_thickness_mm, r=(pipe_outer_diameter_mm/2 + clearance_mm) + cap_wall_thickness_mm, center=true, $fn=64);
    // Inner socket cavity
    translate([0, 0, (end_thickness_mm/2) - (overlap_mm/2)])
      cylinder(h=insertion_depth_mm + overlap_mm, r=(pipe_outer_diameter_mm/2 + clearance_mm), center=true, $fn=64);
    // Lead-in chamfer
    translate([0, 0, -((insertion_depth_mm + end_thickness_mm)/2) + (chamfer_mm + overlap_mm)/2])
      cylinder(h=chamfer_mm + overlap_mm, r1=(pipe_outer_diameter_mm/2 + clearance_mm) + chamfer_mm, r2=(pipe_outer_diameter_mm/2 + clearance_mm), center=true, $fn=64);
  }
}

// End Face
module end_face() {
  cylinder(h=end_thickness_mm, r=(pipe_outer_diameter_mm/2 + clearance_mm) + cap_wall_thickness_mm, center=true, $fn=64);
}

// Assembly
module assembly() {
  union() {
    // Cap with end face
    translate([0, 0, insertion_depth_mm/2]) {
      cap_body();
      end_face();
    }
    // HT Pipe
    translate([0, 0, -((insertion_depth_mm + end_thickness_mm)/2) + (pipe_length_mm/2) - overlap_mm])
      ht_pipe();
  }
}

assembly();