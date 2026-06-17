// Parameters
nominal_diameter_mm = 3; //[1.5:6:0.1]
pitch_mm = 0.5; //[0.25:1:0.05]
length_mm = 6; //[3:24:1]
socket_across_flats_mm = 1.5; //[0.8:3:0.1]
socket_depth_mm = 1.5; //[0.8:4:0.1]
end_style_flat = 1; //[0:1:1]
show_threads = 1; //[0:1:1]
overlap_mm = 1.2; //[0.5:2:0.1]  // use 1-2mm overlap for robust connectivity
thread_major_d_mm = 3; //[1.5:6:0.1]
thread_major_r_mm = 1.5; //[0.75:3:0.05]
thread_minor_r_mm = 1.25; //[0.6:2.6:0.05]
socket_hex_radius_mm = 0.866; //[0.4:1.8:0.01]
point_length_mm = 1.2; //[0.6:3:0.1]
thread_ridge_height_mm = 0.25; //[0.1:0.6:0.05]
thread_ridge_width_mm = 0.35; //[0.15:0.8:0.05]
thread_ridge_count = 18; //[6:48:1]

// Screw - complete geometry (single connected solid)
module screw() {
  color("DimGray")
  union() {
    // Main grub screw body
    cylinder(r=thread_major_r_mm, h=length_mm, center=true);

    // External "thread ridges" (kept as in original style, but unioned)
    if (show_threads == 1) {
      for (i = [0:thread_ridge_count-1]) {
        rotate([0, 0, i*360/thread_ridge_count])
          translate([thread_major_r_mm - thread_ridge_height_mm/2 + overlap_mm/2, 0, 0])
            cube([thread_ridge_height_mm + overlap_mm, thread_ridge_width_mm, length_mm + overlap_mm],
                 center=true);
      }
    }

    // End style: flat pad or point (must ADD material, not cut it)
    if (end_style_flat == 1) {
      // Small end pad that overlaps into the body by overlap_mm
      translate([0, 0, -length_mm/2 + overlap_mm/2])
        cylinder(r=thread_major_r_mm, h=overlap_mm, center=true);
    } else {
      // Point overlaps into the body by overlap_mm
      translate([0, 0, -length_mm/2 + (point_length_mm + overlap_mm)/2])
        cylinder(r1=thread_major_r_mm, r2=0, h=point_length_mm + overlap_mm, center=true);
    }

    // NOTE: Hex socket is a recess; it must be made with difference(), not union().
    // It is implemented below by subtracting it from the unioned solid.
  }
}

// Hex socket cutter (recess)
module hex_socket_cutter() {
  // Place at the top end, overlapping slightly into the body
  translate([0, 0, length_mm/2 - socket_depth_mm/2])
    cylinder(r=socket_hex_radius_mm, h=socket_depth_mm + overlap_mm, center=true, $fn=6);
}

// Final screw with socket recess (still a single connected solid)
module screw_with_socket() {
  difference() {
    screw();
    hex_socket_cutter();
  }
}

// Assembly
module assembly() {
  union() {
    screw_with_socket();
  }
}

assembly();