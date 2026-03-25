// Parameters
nominal_size_ht110 = 1; //[1:1:1]
length_mm = 500; //[250:1000:1]
center = 0; //[0:1:1]
ht110_outer_diameter = 110; //[90:160:0.1]
ht110_wall_thickness = 3.2; //[2:6:0.1]
epsilon_overlap = 1; //[0.5:2:0.1]
inner_diameter = ht110_outer_diameter - 2 * ht110_wall_thickness; //[80:155:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Outer cylinder
    difference() {
      cylinder(h=length_mm, r=ht110_outer_diameter/2, center=false);
      // Inner cylinder
      translate([0, 0, -epsilon_overlap])
        cylinder(h=length_mm + 2 * epsilon_overlap, r=inner_diameter/2, center=false);
    }
    // End faces
    union() {
      // Start disk
      translate([0, 0, 0])
        cylinder(h=epsilon_overlap, r=ht110_outer_diameter/2, center=false);
      // End disk
      translate([0, 0, length_mm - epsilon_overlap])
        cylinder(h=epsilon_overlap, r=ht110_outer_diameter/2, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();