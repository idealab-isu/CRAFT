// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 40; //[20:80:1]
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
od_mm = 40; //[30:60:0.5]
wall_thickness_mm = 1.8; //[1:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]
socket_length_mm = 35; //[20:70:1]
socket_wall_extra_mm = 2.2; //[1:6:0.1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
socket_stop_thickness_mm = 2; //[1:5:0.1]
socket_stop_length_mm = 6; //[3:15:1]

$fn = 128;

module ht_pipe() {
  eps = 0.01;

  // Radii
  od_r = od_mm/2;
  id_r = max(eps, od_r - wall_thickness_mm);

  socket_od_r = od_r + socket_wall_extra_mm;
  socket_id_r = od_r + socket_clearance_mm;

  stop_od_r = socket_id_r + socket_stop_thickness_mm;
  stop_id_r = socket_id_r;

  // Length guards
  sock_len = min(socket_length_mm, length_mm);
  stop_len = min(socket_stop_length_mm, sock_len);

  // Z layout: pipe centered on Z for reliable visibility in all views
  z0 = -length_mm/2;
  z1 =  length_mm/2;

  // Socket at one end (bottom)
  socket_z0 = z0;
  socket_z1 = socket_z0 + sock_len;

  // Main pipe overlaps into socket to guarantee connectivity
  main_z0 = socket_z1 - overlap_mm;
  main_z1 = z1;
  main_h  = max(eps, main_z1 - main_z0);

  // Stop ring near inner end of socket
  stop_z0 = socket_z1 - stop_len;

  color([0.85, 0.85, 0.8])
  union() {
    // Main pipe (hollow)
    difference() {
      translate([0,0,main_z0])
        cylinder(h=main_h, r=od_r, center=false);
      translate([0,0,main_z0 - eps])
        cylinder(h=main_h + 2*eps, r=id_r, center=false);
    }

    if (include_end_fitting) {
      // Socket/bell (hollow)
      difference() {
        translate([0,0,socket_z0])
          cylinder(h=sock_len, r=socket_od_r, center=false);
        translate([0,0,socket_z0 - eps])
          cylinder(h=sock_len + 2*eps, r=socket_id_r, center=false);
      }

      // Stop ring (hollow ring) inside socket
      difference() {
        translate([0,0,stop_z0])
          cylinder(h=stop_len, r=stop_od_r, center=false);
        translate([0,0,stop_z0 - eps])
          cylinder(h=stop_len + 2*eps, r=stop_id_r, center=false);
      }
    }
  }
}

ht_pipe();