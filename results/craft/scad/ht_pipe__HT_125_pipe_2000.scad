// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 2000; //[500:4000:10]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
socket_length_mm = 60; //[30:120:1]
socket_wall_extra_mm = 2.5; //[1:6:0.1]
socket_overlap_mm = 1; //[0.5:2:0.1]
inner_clearance_mm = 0.5; //[0.2:1.5:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=nominal_diameter_mm/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting socket
    difference() {
      translate([0, 0, length_mm - socket_overlap_mm])
        cylinder(h=socket_length_mm, r=nominal_diameter_mm/2 + socket_wall_extra_mm, center=false);
      translate([0, 0, length_mm - socket_overlap_mm])
        cylinder(h=socket_length_mm, r=nominal_diameter_mm/2 + inner_clearance_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();