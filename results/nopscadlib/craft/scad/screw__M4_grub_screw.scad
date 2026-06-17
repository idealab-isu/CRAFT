// M4 grub screw (set screw) - single connected solid

$fn = 96;

// Parameters
length_mm = 10; //[5:20:1]
major_diameter_mm = 4; //[3:8:0.1]
thread_pitch_mm = 0.7; //[0.5:1.4:0.05]
show_threads = 1; //[0:1:1]
hex_socket_af_mm = 2; //[1.5:3:0.1]
hex_socket_depth_mm = 2; //[1:4:0.1]
tip_flat_depth_mm = 0.6; //[0.2:1.5:0.1]
thread_ridge_height_mm = 0.25; //[0.1:0.5:0.05]
thread_ridge_width_mm = 0.35; //[0.2:0.8:0.05]
thread_ridge_count = 12; //[6:30:1]
overlap_mm = 0.8; //[0.5:2:0.1]

module screw() {
  r_major = major_diameter_mm/2;
  r_thread = r_major + thread_ridge_height_mm;

  // Ensure tip doesn't exceed body length
  tip_h = min(tip_flat_depth_mm, length_mm);

  // Hex socket geometry
  hex_r = hex_socket_af_mm/(2*cos(30)); // circumradius from across-flats
  socket_h = min(hex_socket_depth_mm, length_mm);

  // Place socket so its top is flush with screw top, and it cuts into body
  socket_center_z = length_mm/2 - socket_h/2;

  // Thread ridge spacing along length (visual approximation)
  ridge_h = thread_ridge_width_mm;
  ridge_count = max(1, thread_ridge_count);
  ridge_step = length_mm / ridge_count;

  color("DimGray")
  difference() {
    // ONE connected solid: union of body + tip + optional ridges
    union() {
      // Main cylindrical body
      cylinder(r=r_major, h=length_mm, center=true);

      // Flat point tip (slightly larger radius to guarantee overlap/connection)
      translate([0, 0, -length_mm/2 + tip_h/2])
        cylinder(r=r_major + overlap_mm, h=tip_h, center=true);

      // Thread ridges (simple rings) - connected by overlapping the body
      if (show_threads) {
        for (i = [0:ridge_count-1]) {
          z_i = -length_mm/2 + (i + 0.5) * ridge_step;
          translate([0, 0, z_i])
            cylinder(r=r_thread, h=ridge_h, center=true);
        }
      }
    }

    // Hex socket cut (must be subtracted from the union above)
    translate([0, 0, socket_center_z])
      cylinder(r=hex_r, h=socket_h + overlap_mm, center=true, $fn=6);
  }
}

screw();