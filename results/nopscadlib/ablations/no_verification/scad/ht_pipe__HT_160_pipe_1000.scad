// HT 160 pipe 1000 mm (single connected solid) - FIXED

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 160; //[80:320:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]

od_mm = 160; //[80:320:1]
wall_thickness_mm = 4.7; //[2.35:9.4:0.1]

socket_length_mm = 70; //[35:140:1]
socket_wall_extra_mm = 3.0; //[1.5:6.0:0.1]
socket_clearance_mm = 1.0; //[0.5:2.0:0.1]

stop_ring_thickness_mm = 3.0; //[1.5:6.0:0.1]
stop_ring_depth_mm = 6.0; //[3.0:12.0:0.1]

overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 128;

module ht_pipe() {
  od_r = od_mm/2;
  id_r = od_r - wall_thickness_mm;

  // Guards to prevent invalid/empty geometry
  eps = 0.01;
  ov  = max(overlap_mm, eps);

  id_r_safe = max(eps, id_r);

  socket_id_r = max(id_r_safe + eps, od_r + socket_clearance_mm);
  socket_od_r = max(od_r + eps, od_r + socket_wall_extra_mm);

  // Ensure socket fits within length
  sock_len = min(socket_length_mm, length_mm);
  socket_z0 = length_mm - sock_len;

  // Stop ring: keep a short section at socket start with smaller ID (id_r_safe)
  ring_t = min(stop_ring_thickness_mm, sock_len);
  ring_cut_r = max(id_r_safe, socket_id_r - stop_ring_depth_mm);

  color([0.85, 0.85, 0.8])
  difference() {
    // Outer solid (ONE connected union)
    union() {
      cylinder(h=length_mm, r=od_r, center=false);

      if (include_end_fitting && sock_len > 0) {
        // Overlap into main pipe by ov to guarantee connectivity
        translate([0, 0, socket_z0 - ov])
          cylinder(h=sock_len + ov, r=socket_od_r, center=false);
      }
    }

    // Inner void through entire pipe (extend slightly for clean subtraction)
    translate([0, 0, -ov])
      cylinder(h=length_mm + 2*ov, r=id_r_safe, center=false);

    if (include_end_fitting && sock_len > 0) {
      // Enlarge inner diameter inside socket region (clearance)
      // Start slightly AFTER socket start so the stop-ring section remains at id_r_safe
      translate([0, 0, socket_z0 + ring_t - ov])
        cylinder(h=(sock_len - ring_t) + 2*ov, r=socket_id_r, center=false);

      // Create the internal shoulder by cutting a smaller radius only in the ring zone
      // This removes material between ring_cut_r and socket_id_r in the first ring_t mm.
      translate([0, 0, socket_z0 - ov])
        cylinder(h=ring_t + 2*ov, r=ring_cut_r, center=false);
    }
  }
}

ht_pipe();