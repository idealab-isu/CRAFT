// Parameters
length_mm = 150; //[75:300:1]
ht32_od = 32; //[16:64:0.5]
wall_thickness = 1.8; //[0.9:3.6:0.1]
socket_length = 25; //[12.5:50:0.5]
socket_wall = 2.4; //[1.2:4.8:0.1]
socket_clearance = 0.4; //[0.1:1.0:0.05]
socket_stop_thickness = 2.0; //[1.0:4.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

$fn = 128;

// Module for the HT Pipe (one connected solid)
module ht_pipe() {
  od_r = ht32_od/2;
  id_r = max(0.01, od_r - wall_thickness);

  sock_od_r = od_r + socket_wall;
  sock_id_r = max(0.01, od_r + socket_clearance);

  // Socket is at the pipe end, overlapping into the pipe to guarantee connectivity
  sock_h  = socket_length;
  sock_z0 = length_mm - overlap;

  // Inner socket bore: starts at socket mouth and stops short to form a stop ring
  bore_h = max(0.01, socket_length - socket_stop_thickness);

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER solid (pipe + socket) as one connected union
    union() {
      cylinder(h=length_mm, r=od_r, center=false);
      translate([0, 0, sock_z0])
        cylinder(h=sock_h, r=sock_od_r, center=false);
    }

    // INNER voids removed in one pass to avoid coplanar/empty artifacts
    union() {
      // Main pipe bore (through entire pipe)
      translate([0, 0, -overlap])
        cylinder(h=length_mm + 2*overlap, r=id_r, center=false);

      // Socket bore (from socket mouth down to stop ring)
      translate([0, 0, sock_z0 - overlap])
        cylinder(h=bore_h + 2*overlap, r=sock_id_r, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();