// Parameters
nominal_size_label = 50; //[50:50:1]
length_mm = 150; //[75:300:1]
ht50_outer_diameter = 50; //[45:60:0.1]
ht50_wall_thickness = 1.8; //[1:4:0.1]
connect_overlap = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    // Outer cylinder
    difference() {
      cylinder(r=ht50_outer_diameter/2, h=length_mm, center=true, $fn=64);
      // Inner cylinder to create hollow tube
      translate([0, 0, 0])
        cylinder(r=ht50_outer_diameter/2 - ht50_wall_thickness, h=length_mm, center=true, $fn=64);
    }
    
    // End faces
    for (z = [-length_mm/2, length_mm/2]) {
      translate([0, 0, z]) {
        difference() {
          // Outer reference
          cylinder(r=ht50_outer_diameter/2, h=connect_overlap, center=true, $fn=64);
          // Inner reference
          cylinder(r=ht50_outer_diameter/2 - ht50_wall_thickness, h=connect_overlap, center=true, $fn=64);
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