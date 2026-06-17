// Parameters
shank_diameter_mm = 5; //[2.5:10:0.1]
length_under_head_mm = 10; //[5:20:0.5]
head_diameter_mm = 10; //[6:20:0.5]
head_height_mm = 5; //[2.5:10:0.25]
socket_across_flats_mm = 4; //[2:8:0.1]
socket_depth_mm = 3; //[1.5:6:0.1]
thread_length_mm = 10; //[5:20:0.5]
thread_major_diameter_mm = 5.2; //[4.8:6.5:0.05]
washer_enabled = 1; //[0:1:1]
washer_outer_diameter_mm = 10; //[6:20:0.5]
washer_thickness_mm = 1; //[0.5:3:0.1]
clearance_mm = 0.2; //[0.05:0.5:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw and Washer - Complete detailed geometry
module screw_and_washer() {
  color("DimGray") {
    // Cap Head
    translate([0, 0, 0])
      cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=64);

    // Screw Body
    translate([0, 0, -head_height_mm/2 - length_under_head_mm/2 + overlap_mm])
      cylinder(r=shank_diameter_mm/2, h=length_under_head_mm, center=true, $fn=64);

    // Threaded Shank
    translate([0, 0, -head_height_mm/2 - thread_length_mm/2 + overlap_mm])
      cylinder(r=thread_major_diameter_mm/2, h=thread_length_mm, center=true, $fn=64);

    // Washer
    if (washer_enabled) {
      difference() {
        translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + overlap_mm])
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=64);
        translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + overlap_mm])
          cylinder(r=shank_diameter_mm/2 + clearance_mm, h=washer_thickness_mm + overlap_mm*2, center=true, $fn=64);
      }
    }

    // Hex Socket
    difference() {
      translate([0, 0, head_height_mm/2 - (socket_depth_mm + overlap_mm)/2])
        cylinder(r=(socket_across_flats_mm + clearance_mm)/cos(30)/2, h=socket_depth_mm + overlap_mm, center=true, $fn=6);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();