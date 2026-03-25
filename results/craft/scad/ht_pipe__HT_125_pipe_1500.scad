// Parameters
outer_diameter_mm = 125; //[80:250:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
length_mm = 1500; //[750:3000:1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    difference() {
      // Outer pipe
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=false);
      // Inner bore
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();