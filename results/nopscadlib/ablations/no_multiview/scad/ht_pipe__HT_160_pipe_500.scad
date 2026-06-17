// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 160; //[80:320:1]
length_mm = 500; //[250:1000:1]
pipe_od = 160; //[80:320:1]
pipe_wall = 4.9; //[2.5:10:0.1]
socket_length = 70; //[35:140:1]
socket_wall_extra = 3; //[1:8:0.5]
socket_bore_clearance = 1; //[0.2:3:0.1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=pipe_od/2, center=false);
        translate([0, 0, -overlap])
          cylinder(h=length_mm + overlap*2, r=pipe_od/2 - pipe_wall, center=false);
      }
      // End fitting (socket)
      difference() {
        translate([0, 0, length_mm - overlap])
          cylinder(h=socket_length, r=pipe_od/2 + socket_wall_extra, center=false);
        translate([0, 0, length_mm - overlap - overlap])
          cylinder(h=socket_length + overlap*2, r=pipe_od/2 + socket_bore_clearance, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();