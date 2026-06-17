// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 50; //[25:100:1]
length_mm = 150; //[75:300:1]
pipe_od = 50; //[25:100:1]
wall_thickness = 1.8; //[0.9:3.6:0.1]
socket_length = 25; //[12.5:50:0.5]
socket_wall_extra = 1.2; //[0.6:2.4:0.1]
overlap = 1; //[0.5:2:0.1]

// Module for the HT pipe segment
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Hollow tube body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=pipe_od/2 - wall_thickness, center=false);
    }
    
    // End fitting geometry
    difference() {
      translate([0, 0, length_mm - overlap])
        cylinder(h=socket_length, r=pipe_od/2 + socket_wall_extra, center=false);
      translate([0, 0, length_mm - overlap])
        cylinder(h=socket_length + overlap, r=pipe_od/2 - wall_thickness, center=false);
    }
  }
}

// Assembly module
module assembly() {
  ht_pipe();
}

// Call the assembly
assembly();