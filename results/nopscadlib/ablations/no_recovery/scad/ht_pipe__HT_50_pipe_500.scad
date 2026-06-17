// Parameters
length_mm = 500; //[250:1000:1]
ht50_outer_diameter_mm = 50; //[45:60:0.5]
wall_thickness_mm = 1.8; //[1:4:0.1]
bore_clearance_mm = 0.2; //[0:1:0.05]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe
      cylinder(h=length_mm, r=ht50_outer_diameter_mm/2, center=true, $fn=64);
      // Inner bore
      cylinder(h=length_mm + 2*bore_clearance_mm, 
               r=ht50_outer_diameter_mm/2 - wall_thickness_mm + bore_clearance_mm, 
               center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();