// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 6.0; //[3.0:12.0:0.1]
head_height_mm = 3.0; //[1.5:6.0:0.1]
hex_socket_af_mm = 2.5; //[1.5:5.0:0.1]
hex_socket_depth_mm = 1.8; //[0.8:3.5:0.1]
thread_minor_diameter_mm = 2.7; //[1.3:5.4:0.1]
threaded_shaft_smooth_fraction = 1.0; //[0.5:1.0:0.05]
washer_outer_diameter_mm = 7.0; //[4.0:14.0:0.1]
washer_thickness_mm = 0.8; //[0.4:2.0:0.1]
washer_hole_diameter_mm = 3.4; //[2.0:7.0:0.1]
overlap_mm = 0.8; //[0.2:2.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw
    difference() {
      union() {
        // Socket Head
        translate([0, 0, 0])
          cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=32);
        // Threaded Shaft
        translate([0, 0, -head_height_mm/2 - length_mm/2 + overlap_mm])
          cylinder(r=thread_diameter_mm/2, h=length_mm, center=true, $fn=32);
      }
      // Hex Socket Drive
      translate([0, 0, head_height_mm/2 - (hex_socket_depth_mm + overlap_mm)/2])
        rotate([0, 0, 0])
        cylinder(r=hex_socket_af_mm/(2*cos(30)), h=hex_socket_depth_mm + overlap_mm, center=true, $fn=6);
    }
  }
  
  color("Silver") {
    // Washer
    difference() {
      translate([0, 0, head_height_mm/2 + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=32);
      translate([0, 0, head_height_mm/2 + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();