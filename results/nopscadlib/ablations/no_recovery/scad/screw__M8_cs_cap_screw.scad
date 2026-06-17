// Parameters
shank_diameter_mm = 8; //[4:16:0.1]
head_diameter_mm = 16; //[8:32:0.1]
length_mm = 10; //[5:20:0.5]
head_height_mm = 8; //[4:16:0.1]
socket_af_mm = 6; //[3:12:0.1]
socket_depth_mm = 5; //[2.5:10:0.1]
thread_length_mm = 8; //[4:20:0.5]
thread_diameter_mm = 7.6; //[3.8:15.2:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Hex socket calculation
hex_radius = socket_af_mm / (2 * cos(30));

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Cap Head
    translate([0, 0, head_height_mm / 2])
      cylinder(r=head_diameter_mm / 2, h=head_height_mm, center=true, $fn=64);

    // Shank
    translate([0, 0, -length_mm / 2])
      cylinder(r=shank_diameter_mm / 2, h=length_mm, center=true, $fn=64);

    // Thread Region (Simplified)
    translate([0, 0, -length_mm + thread_length_mm / 2])
      cylinder(r=thread_diameter_mm / 2, h=thread_length_mm, center=true, $fn=64);

    // Hex Socket
    translate([0, 0, head_height_mm - socket_depth_mm / 2])
      rotate([0, 0, 0])
      difference() {
        cylinder(r=hex_radius, h=socket_depth_mm, center=true, $fn=6);
        cylinder(r=hex_radius - overlap_mm, h=socket_depth_mm + overlap_mm, center=true, $fn=6);
      }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();