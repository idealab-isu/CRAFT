// Parameters
nominal_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 6; //[3:24:1]
thread_length_mm = 6; //[3:24:1]
socket_af_mm = 1.5; //[0.8:3:0.1]
socket_depth_mm = 1.5; //[0.8:4:0.1]
thread_major_diameter_mm = 3; //[1.5:6:0.1]
thread_minor_diameter_mm = 2.6; //[1.2:5.2:0.1]
thread_crest_height_mm = 0.2; //[0.1:0.5:0.05]
thread_pitch_mm = 0.5; //[0.35:1:0.05]
thread_ridge_count = 12; //[6:60:1]
tip_style_cup = 0; //[0:1:1]
cup_dimple_radius_mm = 1.2; //[0.6:2.4:0.1]
cup_dimple_depth_mm = 0.4; //[0.2:1.2:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw - complete geometry
module screw() {
  color("DimGray") {
    // Grub screw body
    cylinder(r=thread_major_diameter_mm/2, h=length_mm, center=true);

    // Threaded shaft
    translate([0, 0, -(length_mm/2) + (thread_length_mm/2)])
      cylinder(r=thread_minor_diameter_mm/2, h=thread_length_mm, center=true);

    // Thread ridges
    for (i = [0:thread_ridge_count-1]) {
      translate([0, 0, -(length_mm/2) + (thread_pitch_mm*i) + overlap_mm])
        scale([1, 1, thread_pitch_mm/thread_crest_height_mm])
          rotate_extrude($fn=32)
            translate([thread_minor_diameter_mm/2 + thread_crest_height_mm/2, 0, 0])
              circle(r=thread_crest_height_mm/2);
    }

    // Hex socket recess
    difference() {
      translate([0, 0, (length_mm/2) - (socket_depth_mm/2)])
        cylinder(r=socket_af_mm/(2*cos(30)), h=socket_depth_mm + overlap_mm, center=true);
    }

    // End point tip
    if (tip_style_cup == 1) {
      translate([0, 0, -(length_mm/2) + cup_dimple_radius_mm - cup_dimple_depth_mm])
        sphere(r=cup_dimple_radius_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();