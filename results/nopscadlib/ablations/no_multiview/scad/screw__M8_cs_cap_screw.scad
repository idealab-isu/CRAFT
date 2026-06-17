// Parameters
shank_diameter_mm = 8; //[4:16:0.1]
head_diameter_mm = 16; //[8:32:0.1]
length_mm = 10; //[5:20:0.1]
head_height_mm = 8; //[4:16:0.1]
socket_af_mm = 6; //[3:12:0.1]
socket_depth_mm = 4; //[2:8:0.1]
thread_major_diameter_mm = 8; //[4:16:0.1]
thread_minor_diameter_mm = 6.6; //[3.3:13.2:0.1]
threaded_length_mm = 10; //[5:20:0.1]
thread_ridge_count = 8; //[4:20:1]
thread_ridge_height_mm = 0.4; //[0.2:1:0.05]
thread_ridge_width_mm = 0.8; //[0.4:2:0.05]
overlap_mm = 1; //[0.5:2:0.1]

// Screw and Washer
module screw_and_washer() {
  color("DimGray") {
    // Screw Body
    translate([0, 0, -head_height_mm/2 - length_mm/2 + overlap_mm])
      cylinder(r=shank_diameter_mm/2, h=length_mm, center=true);

    // Cylindrical Head
    translate([0, 0, 0])
      cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);

    // Hex Socket Recess
    translate([0, 0, head_height_mm/2 - socket_depth_mm/2])
      rotate([0, 0, 0])
      cylinder(r=socket_af_mm/(2*cos(30)), h=socket_depth_mm + 2*overlap_mm, center=true);

    // Thread Core
    translate([0, 0, -head_height_mm/2 - threaded_length_mm/2 + overlap_mm])
      cylinder(r=thread_minor_diameter_mm/2, h=threaded_length_mm, center=true);

    // Thread Ridges
    for (i = [0:thread_ridge_count-1]) {
      translate([0, 0, -head_height_mm/2 - threaded_length_mm + (i+0.5)*threaded_length_mm/thread_ridge_count])
        cylinder(r=thread_major_diameter_mm/2 + thread_ridge_height_mm, h=thread_ridge_width_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();