// Parameters
pipe_standard = 0; //[0:0:1]
nominal_size = 50; //[25:110:1]
length_mm = 250; //[125:500:1]
center = 0; //[0:1:1]
ht50_outer_diameter = 50; //[40:80:0.5]
ht50_wall_thickness = 1.8; //[1:4:0.1]
bore_clearance = 0.2; //[0:0.6:0.05]
bore_extra_length = 1; //[0.5:3:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe segment
      translate([0, 0, 0])
        cylinder(h=length_mm, r=ht50_outer_diameter/2, center=false, $fn=64);
      
      // Inner hollow bore
      translate([0, 0, -bore_extra_length])
        cylinder(h=length_mm + 2*bore_extra_length, 
                 r=ht50_outer_diameter/2 - ht50_wall_thickness + bore_clearance, 
                 center=false, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();