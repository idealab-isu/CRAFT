// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 2000; //[1000:4000:10]
pipe_od = 125; //[60:250:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
socket_length = 70; //[35:140:1]
socket_wall_extra = 1.8; //[0.8:4:0.1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
connect_overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe Body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=true);
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*connect_overlap, r=pipe_od/2 - pipe_wall, center=true);
    }
    
    // End Fitting Socket
    difference() {
      translate([0, 0, length_mm/2 + socket_length/2 - connect_overlap])
        cylinder(h=socket_length, r=pipe_od/2 + socket_clearance + socket_wall_extra, center=true);
      translate([0, 0, length_mm/2 + socket_length/2 - connect_overlap])
        cylinder(h=socket_length + 2*connect_overlap, r=pipe_od/2 + socket_clearance, center=true);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();