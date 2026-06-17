// Parameters
length_mm = 10; //[5:20:1]
major_diameter_mm = 4; //[3:6:0.1]
pitch_mm = 0.7; //[0.5:1:0.05]
thread_depth_mm = 0.35; //[0.2:0.6:0.05]
hex_af_mm = 2; //[1.5:3:0.1]
socket_depth_mm = 2; //[1:4:0.1]
tip_cone_height_mm = 0.8; //[0.3:2:0.1]
cup_point_depth_mm = 0.4; //[0:1.2:0.1]
cup_point_radius_mm = 1.2; //[0.6:2:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Grub screw body
    cylinder(r=major_diameter_mm/2, h=length_mm, center=true, $fn=64);
    
    // Male thread (approximation)
    translate([0, 0, -length_mm/2])
      cylinder(r=major_diameter_mm/2 + thread_depth_mm, h=length_mm, center=false, $fn=64);
    
    // Hex socket drive
    difference() {
      translate([0, 0, length_mm/2 - socket_depth_mm/2])
        cylinder(r=hex_af_mm/(2*cos(30)), h=socket_depth_mm + overlap_mm, center=true, $fn=6);
    }
    
    // Tip end cone
    translate([0, 0, -length_mm/2 + tip_cone_height_mm/2])
      rotate([180, 0, 0])
      cylinder(r1=major_diameter_mm/2, r2=0, h=tip_cone_height_mm + overlap_mm, center=true, $fn=64);
    
    // Cup point cut
    if (cup_point_depth_mm > 0) {
      translate([0, 0, -length_mm/2 + cup_point_radius_mm - cup_point_depth_mm])
        sphere(r=cup_point_radius_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();