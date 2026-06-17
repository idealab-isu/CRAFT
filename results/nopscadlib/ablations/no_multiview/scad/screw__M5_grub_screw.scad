// Parameters
length_mm = 10; //[5:30:1]
tolerance_mm = 0.2; //[0.05:0.5:0.05]
thread_major_d_mm = 5; //[4:6:0.1]
thread_pitch_mm = 0.8; //[0.5:1.2:0.05]
thread_depth_mm = 0.35; //[0.2:0.6:0.05]
hex_af_mm = 2.5; //[2:3:0.1]
socket_depth_mm = 2.5; //[1.5:4:0.1]
cup_depth_mm = 0.6; //[0.2:1.5:0.05]
cup_radius_mm = 1.2; //[0.6:2.2:0.05]
tip_style_cup = 1; //[0:1:1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Grub screw body
    cylinder(r=thread_major_d_mm/2, h=length_mm, center=true);

    // Simplified threaded shaft
    scale([(thread_major_d_mm/2 - thread_depth_mm)/(thread_major_d_mm/2),
           (thread_major_d_mm/2 - thread_depth_mm)/(thread_major_d_mm/2), 1])
      cylinder(r=thread_major_d_mm/2, h=length_mm, center=true);

    // Hex socket drive
    difference() {
      cylinder(r=thread_major_d_mm/2, h=length_mm, center=true);
      translate([0, 0, length_mm/2 - socket_depth_mm/2])
        cylinder(r=(hex_af_mm + tolerance_mm)/cos(30)/2, h=socket_depth_mm + overlap_mm, center=true);
    }

    // Tip profile (cup or flat)
    if (tip_style_cup == 1) {
      translate([0, 0, -length_mm/2 + cup_radius_mm - cup_depth_mm])
        sphere(r=cup_radius_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();