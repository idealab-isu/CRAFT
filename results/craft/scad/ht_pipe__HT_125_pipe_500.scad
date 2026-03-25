// Parameters
length_mm = 500; //[250:1000:1]
center = 0; //[0:1:1]
include_fitting_end = 1; //[0:1:1]
ht125_outer_diameter = 125; //[62.5:250:0.1]
ht125_wall_thickness = 3.2; //[1.6:6.4:0.1]
end_face_thickness = 1.5; //[0.5:3:0.1]
fit_overlap = 1; //[0.5:2:0.1]
fitting_height = 35; //[15:70:1]
fitting_radial_thickness = 4; //[2:8:0.1]
fitting_clearance = 0.6; //[0.2:1.2:0.1]
z0_offset = 0; //[-500:500:1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main pipe body
    difference() {
      translate([0, 0, z0_offset])
        cylinder(h=length_mm, r=ht125_outer_diameter/2, center=false, $fn=64);
      translate([0, 0, z0_offset])
        cylinder(h=length_mm, r=ht125_outer_diameter/2 - ht125_wall_thickness, center=false, $fn=64);
    }
    
    // End faces
    union() {
      // Bottom end face
      difference() {
        translate([0, 0, z0_offset])
          cylinder(h=end_face_thickness, r=ht125_outer_diameter/2, center=false, $fn=64);
        translate([0, 0, z0_offset])
          cylinder(h=end_face_thickness, r=ht125_outer_diameter/2 - ht125_wall_thickness, center=false, $fn=64);
      }
      // Top end face
      difference() {
        translate([0, 0, z0_offset + length_mm - end_face_thickness])
          cylinder(h=end_face_thickness, r=ht125_outer_diameter/2, center=false, $fn=64);
        translate([0, 0, z0_offset + length_mm - end_face_thickness])
          cylinder(h=end_face_thickness, r=ht125_outer_diameter/2 - ht125_wall_thickness, center=false, $fn=64);
      }
    }
    
    // Optional fitting socket
    if (include_fitting_end) {
      difference() {
        translate([0, 0, z0_offset + length_mm - fit_overlap])
          cylinder(h=fitting_height, r=ht125_outer_diameter/2 + fitting_radial_thickness, center=false, $fn=64);
        translate([0, 0, z0_offset + length_mm - fit_overlap])
          cylinder(h=fitting_height, r=ht125_outer_diameter/2 + fitting_clearance, center=false, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();