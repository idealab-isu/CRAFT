// Parameters
length_mm = 12; //[6:24:1]
thread_size_nominal_d_mm = 6; //[3:12:1]
thread_pitch_mm = 1; //[0.5:2:0.1]
show_threads = 1; //[0:1:1]
hex_socket_af_mm = 3; //[2:5:0.5]
hex_socket_depth_mm = 3; //[1.5:6:0.5]
hob_point_mm = 0; //[0:4:0.5]
tip_cone_length_mm = 1.5; //[0.5:4:0.5]
thread_root_reduction_mm = 0.4; //[0.2:1:0.1]
thread_ridge_height_mm = 0.25; //[0.1:0.6:0.05]
thread_ridge_width_mm = 0.6; //[0.3:1.2:0.1]
thread_ridge_count = 10; //[4:30:1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Grub screw body
    cylinder(r=thread_size_nominal_d_mm/2, h=length_mm, center=true);

    // Hex socket drive
    difference() {
      translate([0, 0, length_mm/2 - (hex_socket_depth_mm + overlap_mm)/2])
        cylinder(r=hex_socket_af_mm/(2*cos(30)), h=hex_socket_depth_mm + overlap_mm, center=true);
    }

    // Threaded shaft with optional threads
    if (show_threads) {
      union() {
        // Threaded shaft root
        translate([0, 0, -hex_socket_depth_mm/2])
          cylinder(r=thread_size_nominal_d_mm/2 - thread_root_reduction_mm, h=length_mm - hex_socket_depth_mm, center=true);

        // Thread ridges
        for (i = [0:thread_ridge_count-1]) {
          translate([0, 0, -length_mm/2 + thread_ridge_width_mm/2 + i*thread_pitch_mm])
            cylinder(r=thread_size_nominal_d_mm/2 - thread_root_reduction_mm + thread_ridge_height_mm, h=thread_ridge_width_mm, center=true);
        }
      }
    } else {
      // Smooth shaft
      translate([0, 0, -hex_socket_depth_mm/2])
        cylinder(r=thread_size_nominal_d_mm/2 - thread_root_reduction_mm, h=length_mm - hex_socket_depth_mm, center=true);
    }

    // Tip cone
    translate([0, 0, -length_mm/2 + tip_cone_length_mm/2])
      cylinder(r1=thread_size_nominal_d_mm/2, r2=0, h=tip_cone_length_mm, center=true);

    // Optional hobbed point
    if (hob_point_mm > 0) {
      translate([0, 0, -length_mm/2 + tip_cone_length_mm - overlap_mm + hob_point_mm/2])
        cylinder(r=thread_size_nominal_d_mm/2 - thread_root_reduction_mm, h=hob_point_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();