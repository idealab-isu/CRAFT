// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 40; //[20:80:1]
length_mm = 150; //[75:300:1]
ht40_outer_diameter = 40; //[35:50:0.5]
wall_thickness = 1.8; //[1:3.6:0.1]
fit_socket_length = 35; //[20:70:1]
fit_socket_od_extra = 6; //[2:12:0.5]
fit_socket_wall_extra = 1.2; //[0.5:3:0.1]
fit_stop_ring_length = 4; //[2:10:0.5]
fit_stop_ring_radial = 1.2; //[0.5:3:0.1]
overlap = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
  od = ht40_outer_diameter;
  r_outer = od/2;
  r_inner = r_outer - wall_thickness;

  socket_od = od + fit_socket_od_extra;
  r_socket_outer = socket_od/2;

  r_socket_inner = r_socket_outer - (wall_thickness + fit_socket_wall_extra);

  // Safety clamps
  r_outer_ok = max(0.01, r_outer);
  r_inner_ok = max(0.01, min(r_inner, r_outer_ok - 0.01));
  r_socket_outer_ok = max(0.01, r_socket_outer);
  r_socket_inner_ok = max(0.01, min(r_socket_inner, r_socket_outer_ok - 0.01));

  // Place socket so its inner end overlaps into the main pipe by 'overlap'
  // Main pipe spans [-L/2, +L/2]
  // Socket spans [z - Ls/2, z + Ls/2]
  // Set socket bottom = +L/2 - overlap  => z = +L/2 - overlap + Ls/2
  z_socket_c = length_mm/2 - overlap + fit_socket_length/2;

  // Stop ring location: near the outer mouth of the socket (top end)
  z_ring_c_local = fit_socket_length/2 - fit_stop_ring_length/2;

  color([0.85, 0.85, 0.8])
  union() {
    // Main pipe tube
    difference() {
      cylinder(h=length_mm, r=r_outer_ok, center=true);
      cylinder(h=length_mm + 2*overlap, r=r_inner_ok, center=true);
    }

    // Bell/socket end (connected via overlap)
    translate([0, 0, z_socket_c])
    difference() {
      cylinder(h=fit_socket_length, r=r_socket_outer_ok, center=true);

      // Socket bore
      cylinder(h=fit_socket_length + 2*overlap, r=r_socket_inner_ok, center=true);

      // Internal stop ring: locally reduce bore near the mouth
      translate([0, 0, z_ring_c_local])
        cylinder(
          h=fit_stop_ring_length + 2*overlap,
          r=max(0.01, r_socket_inner_ok - fit_stop_ring_radial),
          center=true
        );
    }
  }
}

ht_pipe();