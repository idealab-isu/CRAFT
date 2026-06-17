// Parameters
length_mm = 10; //[5:20:1]
major_d_mm = 4; //[3:8:1]
pitch_mm = 0.7; //[0.5:1.2:0.05]
socket_af_mm = 2; //[1.5:3:0.1]
socket_depth_mm = 2; //[1:4:0.1]
tip_style_flat = 1; //[0:1:1]
show_threads = 1; //[0:1:1]
overlap_mm = 0.8; //[0.5:2:0.1]
thread_ridge_depth_mm = 0.18; //[0.1:0.35:0.01]
thread_ridge_width_mm = 0.35; //[0.2:0.7:0.01]
thread_ridge_count = 14; //[6:40:1]
thread_runout_len_mm = 1.2; //[0.6:3:0.1]
hex_socket_clearance_mm = 0.1; //[0:0.3:0.01]

// Hex socket calculation
hex_socket_radius = (socket_af_mm + hex_socket_clearance_mm) / cos(30) / 2;

// Module for the screw
module screw() {
  color("DimGray") {
    // Screw body
    cylinder(h=length_mm, r=major_d_mm/2, center=true);

    // Threaded shaft
    if (show_threads) {
      for (i = [1:thread_ridge_count]) {
        translate([0, 0, -length_mm/2 + (length_mm - socket_depth_mm - thread_runout_len_mm)/(thread_ridge_count+1)*i])
          rotate_extrude() translate([major_d_mm/2 + thread_ridge_depth_mm, 0])
          circle(r=thread_ridge_width_mm/2);
      }
    }

    // Hex socket
    translate([0, 0, length_mm/2 - socket_depth_mm/2])
      rotate([0, 0, 0])
      cylinder(h=socket_depth_mm + 2*overlap_mm, r=hex_socket_radius, center=true);

    // End tip profile
    translate([0, 0, -length_mm/2 + overlap_mm/2])
      cylinder(h=overlap_mm, r=major_d_mm/2, center=true);

    // Thread runout
    translate([0, 0, length_mm/2 - socket_depth_mm - thread_runout_len_mm/2])
      cylinder(h=thread_runout_len_mm, r=major_d_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();