// Parameters
thread_nominal_diameter_mm = 5; //[2.5:10:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
shank_thread_length_mm = 12; //[6:24:0.5]
shank_unthreaded_length_mm = 0; //[0:10:0.5]
shank_total_length_mm = 20; //[10:40:0.5]
shank_major_diameter_mm = 5; //[2.5:10:0.1]
shank_minor_diameter_mm = 4.2; //[2:9:0.1]
shoulder_diameter_mm = 7; //[3.5:14:0.1]
shoulder_length_mm = 2; //[1:6:0.1]
eye_outer_diameter_mm = 16; //[8:32:0.5]
eye_width_mm = 8; //[4:16:0.5]
ball_outer_diameter_mm = 10; //[5:20:0.2]
ball_bore_diameter_mm = 5.1; //[2.5:12:0.1]
rim_thickness_mm = 1.5; //[0.8:3:0.1]
housing_wall_min_mm = 2; //[1:5:0.1]
edge_chamfer_mm = 0.5; //[0.2:2:0.1]
centered_model = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
eye_bore_clearance_mm = 0.2; //[0.05:0.6:0.05]
lip_radial_mm = 0.6; //[0.3:1.5:0.1]
lip_axial_mm = 0.8; //[0.4:2:0.1]

// Rod - Detailed geometry
module rod() {
  color("Silver") {
    // Shank
    translate([-(eye_width_mm/2 + shank_total_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=shank_major_diameter_mm/2, h=shank_total_length_mm, center=true);
    // Threaded portion
    translate([-(eye_width_mm/2 + shank_total_length_mm - shank_thread_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=shank_major_diameter_mm/2, h=shank_thread_length_mm, center=true);
    // Shoulder transition
    translate([-(eye_width_mm/2 + shoulder_length_mm/2 - overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=shoulder_diameter_mm/2, h=shoulder_length_mm, center=true);
  }
}

// Rod End Bearing - Detailed geometry
module rod_end_bearing() {
  color("DimGray") {
    // Eye housing with retention lips
    difference() {
      union() {
        // Eye outer profile
        translate([0, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=eye_outer_diameter_mm/2, h=eye_width_mm, center=true);
        // Retention lips
        translate([-(eye_width_mm/2 - lip_axial_mm/2 - overlap_mm), 0, 0])
          rotate([0, 90, 0])
          cylinder(r=ball_outer_diameter_mm/2 + eye_bore_clearance_mm - lip_radial_mm, h=lip_axial_mm, center=true);
        translate([(eye_width_mm/2 - lip_axial_mm/2 - overlap_mm), 0, 0])
          rotate([0, 90, 0])
          cylinder(r=ball_outer_diameter_mm/2 + eye_bore_clearance_mm - lip_radial_mm, h=lip_axial_mm, center=true);
      }
      // Spherical seat cavity
      translate([0, 0, 0])
        sphere(r=ball_outer_diameter_mm/2 + eye_bore_clearance_mm, center=true);
      // Side opening cut
      translate([0, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=ball_outer_diameter_mm/2 + housing_wall_min_mm, h=eye_width_mm - 2*rim_thickness_mm, center=true);
    }
    // Spherical bearing insert with bore
    difference() {
      translate([0, 0, 0])
        sphere(r=ball_outer_diameter_mm/2, center=true);
      translate([0, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=ball_bore_diameter_mm/2, h=ball_outer_diameter_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  rod();
  rod_end_bearing();
}

assembly();