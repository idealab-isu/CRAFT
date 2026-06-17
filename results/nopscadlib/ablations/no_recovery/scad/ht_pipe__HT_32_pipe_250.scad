// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 32; //[16:64:1]
length_mm = 250; //[125:500:1]
wall_thickness_mm = 2.4; //[1.2:4.8:0.1]
socket_length_mm = 25; //[12.5:50:0.5]
socket_wall_extra_mm = 1.6; //[0.8:3.2:0.1]
socket_clearance_mm = 0.4; //[0.2:1.0:0.05]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        translate([0, 0, 0])
          cylinder(h=length_mm, r=nominal_diameter_mm/2, $fn=64);
        translate([0, 0, -overlap_mm/2])
          cylinder(h=length_mm + overlap_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, $fn=64);
      }
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=socket_length_mm + overlap_mm, r=nominal_diameter_mm/2 + socket_wall_extra_mm, $fn=64);
        translate([0, 0, length_mm - overlap_mm*2])
          cylinder(h=socket_length_mm + overlap_mm*2, r=nominal_diameter_mm/2 - wall_thickness_mm + socket_clearance_mm, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();