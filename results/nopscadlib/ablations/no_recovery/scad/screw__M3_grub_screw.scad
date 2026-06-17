// Parameters
length_mm = 6; //[3:12:1]
threaded_length_mm = 6; //[3:12:1]
thread_pitch_mm = 0.5; //[0.25:1:0.05]
major_diameter_mm = 3; //[2.5:4:0.1]
minor_diameter_mm = 2.4; //[2:3.2:0.1]
socket_af_mm = 1.5; //[1:2.5:0.1]
socket_depth_mm = 2; //[1:4:0.1]
point_type_flat = 1; //[0:1:1]
cup_depth_mm = 0.6; //[0:1.5:0.1]
cup_radius_mm = 1.1; //[0.6:1.6:0.1]
runout_length_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 0.8; //[0.2:2:0.1]
thread_ridge_radial_mm = 0.15; //[0.05:0.3:0.01]
thread_ridge_width_mm = 0.25; //[0.1:0.5:0.01]
thread_teeth_count = 18; //[8:40:1]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Grub screw body
    cylinder(r=major_diameter_mm/2, h=length_mm, center=true);

    // Threaded shaft core
    translate([0, 0, (-length_mm/2) + (threaded_length_mm/2)])
      cylinder(r=minor_diameter_mm/2, h=threaded_length_mm, center=true);

    // Thread runout
    translate([0, 0, (length_mm/2) - (socket_depth_mm) - (runout_length_mm/2) + overlap_mm/2])
      cylinder(r=minor_diameter_mm/2, h=runout_length_mm, center=true);

    // Thread ridge teeth
    for (i = [0:thread_teeth_count-1]) {
      rotate([0, 0, i*360/thread_teeth_count])
        translate([(minor_diameter_mm/2) + thread_ridge_radial_mm - overlap_mm/2, 0, (-length_mm/2) + ((threaded_length_mm - runout_length_mm)/2)])
          cube([thread_ridge_radial_mm*2, thread_ridge_width_mm, threaded_length_mm - runout_length_mm], center=true);
    }

    // Hex socket drive
    translate([0, 0, (length_mm/2) - (socket_depth_mm/2)])
      cylinder(r=socket_af_mm/(2*cos(30)), h=socket_depth_mm + overlap_mm, center=true);

    // Flat or cup point tip
    if (point_type_flat == 0) {
      translate([0, 0, (-length_mm/2) + cup_radius_mm - cup_depth_mm])
        sphere(r=cup_radius_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();