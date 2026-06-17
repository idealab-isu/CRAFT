// Parameters
shaft_diameter_mm = 2.0; //[1.0:4.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 3.8; //[2.0:7.6:0.1]
head_height_mm = 2.0; //[1.0:4.0:0.1]
socket_across_flats_mm = 1.5; //[0.8:3.0:0.05]
socket_depth_mm = 1.2; //[0.6:2.4:0.05]
threaded_length_mm = 10.0; //[5.0:20.0:0.5]
thread_pitch_mm = 0.4; //[0.2:0.8:0.05]
washer_outer_diameter_mm = 5.0; //[3.0:10.0:0.1]
washer_thickness_mm = 0.6; //[0.3:1.2:0.05]
clearance_mm = 0.1; //[0.0:0.3:0.01]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Screw and Washer - Complete Geometry
module screw_and_washer() {
  color("DimGray") {
    // Cap Head
    difference() {
      translate([0, 0, head_height_mm/2])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=32);
      translate([0, 0, head_height_mm - socket_depth_mm/2])
        rotate([0, 0, 0])
        cylinder(r=(socket_across_flats_mm + clearance_mm)/sqrt(3), h=socket_depth_mm + overlap_mm, center=true, $fn=6);
    }
    
    // Threaded Shaft
    translate([0, 0, -length_mm/2])
      cylinder(r=shaft_diameter_mm/2, h=length_mm, center=true, $fn=32);
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, head_height_mm - overlap_mm + washer_thickness_mm/2])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=32);
      translate([0, 0, head_height_mm - overlap_mm + washer_thickness_mm/2])
        cylinder(r=shaft_diameter_mm/2 + clearance_mm, h=washer_thickness_mm + overlap_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();