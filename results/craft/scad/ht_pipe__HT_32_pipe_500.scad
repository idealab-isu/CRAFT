// Parameters
nominal_size_mm = 32; //[16:64:1]
length_mm = 500; //[250:1000:1]
ht32_outer_diameter = 32; //[24:48:0.5]
ht32_wall_thickness = 1.8; //[1.0:3.6:0.1]
interface_ring_length = 12; //[6:24:1]
interface_ring_radial_thickness = 1.5; //[0.5:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe
    difference() {
      cylinder(h=length_mm, r=ht32_outer_diameter/2, center=false);
      // Inner void
      translate([0, 0, 0])
        cylinder(h=length_mm, r=ht32_outer_diameter/2 - ht32_wall_thickness, center=false);
    }
    
    // End fitting interface
    translate([0, 0, length_mm - interface_ring_length]) {
      difference() {
        cylinder(h=interface_ring_length, r=ht32_outer_diameter/2 + interface_ring_radial_thickness, center=false);
        // Inner void for interface
        translate([0, 0, 0])
          cylinder(h=interface_ring_length + overlap_mm, r=ht32_outer_diameter/2 - ht32_wall_thickness, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();