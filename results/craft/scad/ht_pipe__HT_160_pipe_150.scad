// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 160; //[80:320:1]
length_mm = 150; //[75:300:1]
center = 0; //[0:1:1]
ht160_outer_diameter = 160; //[120:200:1]
ht160_wall_thickness = 4.9; //[2.5:10:0.1]
overlap_mm = 1; //[0.5:2:0.1]
bore_radius = 75.1; //[50:95:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe segment
      cylinder(r=ht160_outer_diameter/2, h=length_mm, center=false);
      
      // Inner hollow bore
      translate([0, 0, -overlap_mm])
        cylinder(r=bore_radius, h=length_mm + 2*overlap_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();