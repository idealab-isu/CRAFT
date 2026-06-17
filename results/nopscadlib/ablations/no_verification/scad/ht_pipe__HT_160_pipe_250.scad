$fn = 180;

// Parameters
length_mm = 250; //[125:500:1]
ht160_outer_diameter = 160; //[120:200:1]
wall_thickness = 4.9; //[2.5:10:0.1]
socket_length = 60; //[30:120:1]
socket_wall_extra = 3.0; //[1.0:8.0:0.1]
socket_od_extra = 8.0; //[2.0:20.0:0.5]
socket_bore_clearance = 1.0; //[0.2:3.0:0.1]
bore_overlap = 1.0; //[0.5:2.0:0.1]

eps = 0.02;

// Module for the HT Pipe (one connected solid)
module ht_pipe() {
  od = ht160_outer_diameter;
  r_out = od/2;
  r_in  = r_out - wall_thickness;

  // Socket (bell) outer radius: diameter increase + optional wall extra
  r_sock_out = r_out + socket_od_extra/2 + socket_wall_extra;

  // Socket bore radius: slightly larger than pipe OD to accept spigot
  r_sock_in = r_out + socket_bore_clearance;

  // Ensure valid radii (avoid inverted/empty differences)
  r_in_ok       = max(0.1, r_in);
  r_sock_out_ok = max(r_out + 0.2, r_sock_out);
  r_sock_in_ok  = min(r_sock_out_ok - 0.2, max(0.1, r_sock_in));

  // Place socket at the pipe end, overlapping into the pipe for connectivity
  z_sock0 = length_mm - socket_length - bore_overlap;

  color([0.85, 0.85, 0.8])
  union() {
    // Main pipe: hollow tube open at both ends
    difference() {
      cylinder(h=length_mm, r=r_out, center=false);
      translate([0, 0, -eps])
        cylinder(h=length_mm + 2*eps, r=r_in_ok, center=false);
    }

    // Socket/bell: hollow sleeve that overlaps the pipe for connectivity
    difference() {
      translate([0, 0, z_sock0])
        cylinder(h=socket_length + bore_overlap, r=r_sock_out_ok, center=false);

      translate([0, 0, z_sock0 - eps])
        cylinder(h=socket_length + bore_overlap + 2*eps, r=r_sock_in_ok, center=false);
    }
  }
}

ht_pipe();