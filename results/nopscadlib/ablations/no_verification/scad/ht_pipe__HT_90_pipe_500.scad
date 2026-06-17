$fn = 128;

// Parameters
nominal_size = 90; //[50:180:1]
length_mm = 500; //[250:1000:1]
pipe_od = 90; //[50:180:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_od = 98; //[80:140:0.5]
socket_length = 60; //[30:120:1]
socket_wall = 4; //[2:8:0.1]
socket_stop_thickness = 3; //[1:8:0.1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
connection_overlap = 1; //[0.5:2:0.1]

// Small epsilon for robust booleans
eps = 0.02;

// Derived radii
pipe_r  = pipe_od/2;
pipe_ir = max(0.01, pipe_r - wall_thickness);

socket_r  = socket_od/2;
socket_ir = max(0.01, pipe_r + socket_clearance);

// Lengths
socket_len = max(0.01, socket_length);
main_len   = max(0.01, length_mm - socket_len + connection_overlap);

// HT Pipe - ONE connected solid
module ht_pipe() {
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID (connected): main OD + socket OD overlapping by connection_overlap
    union() {
      cylinder(h=main_len, r=pipe_r, center=false);

      translate([0, 0, main_len - connection_overlap])
        cylinder(h=socket_len, r=socket_r, center=false);
    }

    // INNER VOID (connected): main bore + socket bore down to stop
    union() {
      // Main pipe bore (open through entire main section)
      translate([0, 0, -eps])
        cylinder(h=main_len + 2*eps, r=pipe_ir, center=false);

      // Socket bore (open from socket mouth down to stop thickness)
      translate([0, 0, main_len - connection_overlap - eps])
        cylinder(h=socket_len - socket_stop_thickness + 2*eps, r=socket_ir, center=false);
    }
  }
}

ht_pipe();