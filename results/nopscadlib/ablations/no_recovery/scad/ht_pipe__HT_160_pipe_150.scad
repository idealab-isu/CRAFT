// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 160; //[80:320:1]
length_mm = 150; //[75:300:1]
center = 0; //[0:1:1]
ht160_outer_diameter = 160; //[120:200:1]
ht160_wall_thickness = 4.9; //[2.5:9.8:0.1]
socket_length = 55; //[30:110:1]
socket_wall_extra = 2.5; //[1:6:0.1]
socket_inner_clearance = 1.0; //[0.2:2.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe outer
    difference() {
      cylinder(h=length_mm, r=ht160_outer_diameter/2, center=false);
      // Pipe inner void
      translate([0, 0, ht160_wall_thickness])
        cylinder(h=length_mm, r=ht160_outer_diameter/2 - ht160_wall_thickness, center=false);
    }
    
    // Socket end fitting
    translate([0, 0, length_mm - socket_length - overlap]) {
      difference() {
        cylinder(h=socket_length, r=ht160_outer_diameter/2 + socket_wall_extra, center=false);
        // Socket inner void
        cylinder(h=socket_length, r=ht160_outer_diameter/2 + socket_inner_clearance, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();