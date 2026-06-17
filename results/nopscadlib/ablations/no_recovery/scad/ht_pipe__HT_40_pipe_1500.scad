// Parameters
length_mm = 1500; //[750:3000:10]
ht40_outer_diameter_mm = 40; //[30:80:1]
ht40_wall_thickness_mm = 1.8; //[1:4:0.1]
bore_clearance_mm = 0.2; //[0:1:0.05]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe segment
      cylinder(h=length_mm, r=ht40_outer_diameter_mm/2, center=true, $fn=64);
      
      // Inner hollow bore
      cylinder(h=length_mm + 2*bore_clearance_mm, 
               r=ht40_outer_diameter_mm/2 - ht40_wall_thickness_mm + bore_clearance_mm, 
               center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();