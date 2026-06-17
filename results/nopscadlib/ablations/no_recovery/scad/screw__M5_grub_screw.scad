// Parameters
length_mm = 10; //[5:30:1]
threaded_length_mm = 10; //[5:30:1]
thread_major_d_mm = 5; //[3:10:0.1]
thread_pitch_mm = 0.8; //[0.5:1.5:0.05]
socket_af_mm = 2.5; //[1.5:4:0.1]
socket_depth_mm = 3; //[1.5:6:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]
clearance_mm = 0.15; //[0.05:0.4:0.05]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Grub screw body with internal hex socket
    difference() {
      cylinder(r=thread_major_d_mm/2, h=length_mm, center=true);
      translate([0, 0, length_mm/2 - socket_depth_mm/2])
        cylinder(r=(socket_af_mm + clearance_mm) / cos(30) / 2, h=socket_depth_mm + 2 * overlap_mm, center=true);
    }
    // Threaded shaft (cylindrical approximation)
    translate([0, 0, -length_mm/2])
      cylinder(r=thread_major_d_mm/2, h=threaded_length_mm, center=true);
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();