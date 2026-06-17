// Parameters
nominal_diameter_mm = 90; //[50:180:1]
length_mm = 1500; //[750:3000:10]
include_end_fitting = 1; //[0:1:1]
center = 0; //[0:1:1]

pipe_od_mm = 90; //[50:180:1]
pipe_wall_mm = 2.7; //[1.5:5.4:0.1]

socket_length_mm = 55; //[30:110:1]
socket_wall_extra_mm = 2.5; //[1:6:0.1]
socket_bore_clearance_mm = 1.0; //[0.2:2.5:0.1]
socket_stop_thickness_mm = 4; //[2:10:0.5]
socket_stop_length_mm = 10; //[5:25:1]

overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
  pipe_r_o = pipe_od_mm/2;
  pipe_r_i = max(0.01, pipe_r_o - pipe_wall_mm);

  socket_r_o = pipe_r_o + socket_wall_extra_mm;
  socket_r_i = pipe_r_o + socket_bore_clearance_mm;

  // Stop ring reduces bore near socket end
  stop_r_i = max(0.01, socket_r_i - socket_stop_thickness_mm);

  // Z placement
  z0 = center ? -length_mm/2 : 0;
  z_pipe0 = z0;
  z_pipe1 = z0 + length_mm;

  // Socket overlaps into pipe so it is connected
  z_sock0 = z_pipe1 - overlap_mm;
  z_sock1 = z_sock0 + socket_length_mm;

  z_stop0 = z_sock1 - socket_stop_length_mm;

  // Small epsilon to avoid coplanar/zero-thickness artifacts
  eps = 0.05;

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID (one connected solid)
    union() {
      translate([0, 0, z_pipe0])
        cylinder(h=length_mm, r=pipe_r_o, center=false);

      if (include_end_fitting) {
        translate([0, 0, z_sock0])
          cylinder(h=socket_length_mm, r=socket_r_o, center=false);
      }
    }

    // INNER VOID (continuous bore)
    union() {
      // Main pipe bore (extend slightly to ensure clean subtraction)
      translate([0, 0, z_pipe0 - eps])
        cylinder(h=length_mm + 2*eps, r=pipe_r_i, center=false);

      if (include_end_fitting) {
        // Socket bore (slightly larger than pipe bore)
        translate([0, 0, z_sock0 - eps])
          cylinder(h=socket_length_mm + 2*eps, r=socket_r_i, center=false);

        // Stop ring restriction (smaller bore near socket end)
        translate([0, 0, z_stop0 - eps])
          cylinder(h=socket_stop_length_mm + 2*eps, r=stop_r_i, center=false);
      }
    }
  }
}

ht_pipe();