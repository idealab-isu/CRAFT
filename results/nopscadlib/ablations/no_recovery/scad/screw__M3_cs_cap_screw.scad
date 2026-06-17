// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 6.0; //[3.0:12.0:0.1]
head_height_mm = 3.0; //[1.5:6.0:0.1]
hex_socket_af_mm = 2.5; //[1.5:4.0:0.1]
hex_socket_depth_mm = 1.6; //[0.8:3.2:0.1]
washer_outer_diameter_mm = 7.0; //[4.0:14.0:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.1]
washer_hole_diameter_mm = 3.4; //[3.0:5.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Threaded Shank
    translate([0, 0, -length_mm/2])
      cylinder(r=thread_diameter_mm/2, h=length_mm, center=true);

    // Cylindrical Cap Head
    translate([0, 0, head_height_mm/2 - overlap_mm])
      cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);

    // Hex Socket Recess
    translate([0, 0, head_height_mm - hex_socket_depth_mm/2])
      difference() {
        cylinder(r=(hex_socket_af_mm/2)/cos(30), h=hex_socket_depth_mm, center=true);
        rotate([0, 0, 0]) {
          for (i = [0:5]) {
            rotate([0, 0, i*60])
              translate([hex_socket_af_mm/2, 0, 0])
              cube([hex_socket_af_mm, hex_socket_af_mm, hex_socket_depth_mm], center=true);
          }
        }
      }
  }

  color("Silver") {
    // Washer Outer
    translate([0, 0, washer_thickness_mm/2 - overlap_mm])
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        // Washer Hole
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
      }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();