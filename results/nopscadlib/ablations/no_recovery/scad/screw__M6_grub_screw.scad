// Parameters
length_mm = 12; //[6:24:1]
thread_major_d_mm = 6; //[3:12:0.5]
thread_pitch_mm = 1; //[0.5:2:0.1]
socket_af_mm = 3; //[2:5:0.5]
socket_depth_mm = 3; //[1.5:6:0.5]
tolerance_mm = 0.2; //[0.05:0.5:0.05]
point_style = 0; //[0:1:1]
cup_point_depth_mm = 0.8; //[0.3:2:0.1]
cup_point_radius_mm = 1.5; //[0.8:3:0.1]
thread_visual_depth_mm = 0.25; //[0.1:0.6:0.05]
thread_groove_count = 10; //[4:30:1]
overlap_mm = 1; //[0.5:2:0.1]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Grub screw body
    difference() {
      cylinder(r=thread_major_d_mm/2, h=length_mm, center=true);
      // Hex socket drive
      translate([0, 0, length_mm/2 - socket_depth_mm/2])
        cylinder(r=(socket_af_mm + tolerance_mm)/cos(30)/2, h=socket_depth_mm + overlap_mm, center=true);
    }
    
    // Threaded shaft with visual threads
    difference() {
      cylinder(r=thread_major_d_mm/2, h=length_mm, center=true);
      union() {
        for (i = [0:thread_groove_count-1]) {
          translate([0, 0, -length_mm/2 + (i+0.5)*(length_mm/thread_groove_count)])
            cylinder(r=thread_major_d_mm/2 - thread_visual_depth_mm, h=thread_pitch_mm/2 + overlap_mm, center=true);
        }
      }
    }
    
    // Flat or cup point tip
    if (point_style == 1) {
      translate([0, 0, -length_mm/2 + cup_point_radius_mm - cup_point_depth_mm])
        sphere(r=cup_point_radius_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();