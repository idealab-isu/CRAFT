// HT 40 pipe 250 mm (single connected solid)

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 40; //[20:80:1]
length_mm = 250; //[125:500:1]
od_mm = 40; //[20:80:0.5]
wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
fitting_length_mm = 45; //[25:90:1]
fitting_wall_extra_mm = 1.5; //[0.5:4:0.1]
socket_clearance_mm = 0.4; //[0.1:1.2:0.05]
socket_stop_thickness_mm = 3; //[1.5:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
  // Radii
  od_r = od_mm/2;
  id_r = max(0.01, od_r - wall_thickness_mm);

  socket_od_r = od_r + fitting_wall_extra_mm;
  socket_id_r = od_r + socket_clearance_mm;

  // Ensure valid stop thickness
  stop_t = min(socket_stop_thickness_mm, max(0.01, fitting_length_mm - 0.01));

  // Z layout (pipe total length includes socket)
  z0 = 0;
  z_socket0 = z0;
  z_socket1 = z_socket0 + fitting_length_mm;

  // Main pipe overlaps into socket to guarantee connectivity
  z_pipe0 = z_socket1 - overlap_mm;
  z_pipe1 = z0 + length_mm;

  // Small epsilon to avoid coplanar subtraction artifacts
  eps = 0.02;

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER: connected union
    union() {
      translate([0,0,z_socket0])
        cylinder(h=fitting_length_mm, r=socket_od_r, center=false);

      translate([0,0,z_pipe0])
        cylinder(h=(z_pipe1 - z_pipe0), r=od_r, center=false);
    }

    // INNER: connected union (slightly extended to ensure clean openings)
    union() {
      // Socket bore (open end), stops before far end by stop_t
      translate([0,0,z_socket0 - eps])
        cylinder(h=(fitting_length_mm - stop_t) + eps, r=socket_id_r, center=false);

      // Pipe bore (through pipe length, including overlap region)
      translate([0,0,z_pipe0 - eps])
        cylinder(h=(z_pipe1 - z_pipe0) + 2*eps, r=id_r, center=false);
    }
  }
}

ht_pipe();