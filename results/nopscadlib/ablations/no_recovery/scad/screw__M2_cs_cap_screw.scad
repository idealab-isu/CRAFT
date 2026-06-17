// Parameters
nominal_diameter_mm = 2.0; //[1.0:4.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 3.8; //[2.0:7.6:0.1]
head_height_mm = 2.0; //[1.0:4.0:0.1]
socket_hex_af_mm = 1.5; //[0.8:3.0:0.05]
socket_depth_mm = 1.2; //[0.6:2.4:0.05]
threaded_length_mm = 10.0; //[0.0:20.0:0.5]
thread_pitch_mm = 0.4; //[0.2:0.8:0.05]
thread_major_diameter_mm = 2.0; //[1.0:4.0:0.1]
thread_minor_diameter_mm = 1.6; //[0.8:3.2:0.1]
head_to_shank_chamfer_h_mm = 0.4; //[0.2:0.8:0.05]
shaft_end_chamfer_h_mm = 0.4; //[0.2:1.0:0.05]
washer_outer_diameter_mm = 5.0; //[2.5:10.0:0.1]
washer_thickness_mm = 0.5; //[0.25:1.5:0.05]
washer_hole_diameter_mm = 2.2; //[1.2:4.4:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shaft
    translate([0, 0, -length_mm/2])
      cylinder(h=length_mm, r=nominal_diameter_mm/2, center=true);

    // Cap Head
    translate([0, 0, head_height_mm/2])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);

    // Head to Shank Chamfer
    translate([0, 0, -head_to_shank_chamfer_h_mm/2 + overlap_mm/2])
      cylinder(h=head_to_shank_chamfer_h_mm, r1=head_diameter_mm/2, r2=nominal_diameter_mm/2, center=true);

    // Shaft End Chamfer
    translate([0, 0, -length_mm + shaft_end_chamfer_h_mm/2 - overlap_mm/2])
      cylinder(h=shaft_end_chamfer_h_mm, r1=nominal_diameter_mm/2, r2=nominal_diameter_mm/2 - shaft_end_chamfer_h_mm, center=true);

    // Thread Representation
    for (i = [0:2]) {
      translate([0, 0, -length_mm + threaded_length_mm*(i+1)/3])
        cylinder(h=thread_pitch_mm/3, r=thread_major_diameter_mm/2, center=true);
    }

    // Hex Socket
    translate([0, 0, head_height_mm - socket_depth_mm/2 + overlap_mm/2])
      rotate([0, 0, 0])
      cylinder(h=socket_depth_mm + overlap_mm, r=socket_hex_af_mm/(2*cos(30)), center=true);
  }

  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, washer_thickness_mm/2 + overlap_mm/2])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      translate([0, 0, washer_thickness_mm/2 + overlap_mm/2])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=washer_hole_diameter_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
}

assembly();