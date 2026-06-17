// Parameters
shaft_diameter_mm = 5.0; //[2.5:10.0:0.1]
head_diameter_mm = 10.0; //[5.0:20.0:0.1]
length_mm = 10.0; //[5.0:30.0:0.5]
head_height_mm = 5.0; //[2.5:10.0:0.1]
socket_af_mm = 4.0; //[2.0:8.0:0.1]
socket_depth_mm = 3.0; //[1.5:6.0:0.1]
thread_major_diameter_mm = 5.0; //[2.5:10.0:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
thread_ridge_height_mm = 0.25; //[0.1:0.6:0.05]
thread_ridge_width_mm = 0.35; //[0.15:0.8:0.05]
thread_ridge_count = 18; //[6:60:1]
washer_outer_diameter_mm = 10.0; //[6.0:20.0:0.1]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]
washer_hole_diameter_mm = 5.5; //[3.0:12.0:0.1]
overlap_mm = 0.8; //[0.2:2.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Socket Head Cap
    difference() {
      translate([0, 0, length_mm/2 - head_height_mm/2])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=64);
      translate([0, 0, length_mm/2 - socket_depth_mm/2])
        rotate([0, 0, 0])
        cylinder(r=socket_af_mm/(2*cos(30)), h=socket_depth_mm + overlap_mm, center=true, $fn=6);
    }
    
    // Shaft with Threads
    union() {
      translate([0, 0, -(length_mm - head_height_mm)/2])
        cylinder(r=shaft_diameter_mm/2, h=length_mm - head_height_mm + overlap_mm, center=true, $fn=64);
      for (i = [0:thread_ridge_count-1]) {
        rotate([0, 0, i*360/thread_ridge_count])
          translate([thread_major_diameter_mm/2 - thread_ridge_height_mm/2, 0, -(length_mm - head_height_mm)/2])
          cube([thread_ridge_height_mm, thread_ridge_width_mm, length_mm - head_height_mm], center=true);
      }
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=64);
      translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm])
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();