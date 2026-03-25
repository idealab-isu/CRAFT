// HT 50 pipe 2000 mm (single connected solid)

// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 50; //[25:100:1]
length_mm = 2000; //[1000:4000:10]
pipe_od_mm = 50; //[25:100:1]
wall_thickness_mm = 2.4; //[1.2:4.8:0.1]
fitting_length_mm = 45; //[20:90:1]
fitting_od_extra_mm = 6; //[2:12:0.5]
fitting_wall_extra_mm = 1.2; //[0.5:3:0.1]
socket_depth_mm = 35; //[15:70:1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - complete geometry
module ht_pipe() {
  // Derived dimensions (guarded)
  od = pipe_od_mm;
  r_outer = od/2;
  r_inner = max(0.01, r_outer - wall_thickness_mm);

  r_socket_outer = r_outer + fitting_od_extra_mm/2;
  r_socket_inner = max(0.01, r_socket_outer - (wall_thickness_mm + fitting_wall_extra_mm));

  L = length_mm;
  Lsock = fitting_length_mm;
  Lbody = max(0.01, L - Lsock);                 // straight section length
  sock_depth = min(socket_depth_mm, Lsock);     // keep within socket length
  eps = overlap_mm;

  // Center the whole pipe on Z so it is visible in all orthographic views
  translate([0, 0, -L/2])
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER: union of straight pipe + socket (connected with overlap)
    union() {
      // Straight pipe outer
      cylinder(r=r_outer, h=Lbody + eps, center=false);

      // Socket outer (starts slightly inside straight section to guarantee union)
      translate([0, 0, Lbody - eps])
        cylinder(r=r_socket_outer, h=Lsock + eps, center=false);
    }

    // INNER: through-bore + socket counterbore (single connected void)
    union() {
      // Through-bore for entire length (slightly extended for clean subtraction)
      translate([0, 0, -eps])
        cylinder(r=r_inner, h=L + 2*eps, center=false);

      // Socket counterbore (wider inner diameter) from socket start
      translate([0, 0, Lbody - eps])
        cylinder(r=r_socket_inner, h=sock_depth + 2*eps, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();