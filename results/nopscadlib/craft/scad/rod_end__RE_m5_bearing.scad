// Parameters
thread_d_major_mm = 5; //[2.5:10:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
thread_length_mm = 12; //[6:24:0.5]
shank_length_mm = 35; //[18:70:1]
shank_diameter_mm = 5; //[2.5:10:0.1]
shoulder_diameter_mm = 6; //[3:12:0.1]
shoulder_length_mm = 2; //[1:6:0.1]
eye_outer_diameter_mm = 14; //[7:28:0.5]
eye_width_mm = 7; //[3.5:14:0.25]
ball_outer_diameter_mm = 10; //[5:20:0.5]
bore_diameter_mm = 5.2; //[2.6:10.4:0.1]
eye_rim_thickness_mm = 1; //[0.5:2:0.1]
ball_slot_width_mm = 4; //[2:8:0.25]
chamfer_mm = 0.5; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Rod End Bearing - complete geometry
module rod_end_bearing() {
  // Eye body with cavity and slot
  color("DimGray") {
    union() {
      difference() {
        cylinder(r=eye_outer_diameter_mm/2, h=eye_width_mm, center=true);
        sphere(r=ball_outer_diameter_mm/2 + eps_mm);
        cube([eye_outer_diameter_mm + 2*eps_mm, ball_slot_width_mm, eye_width_mm + 2*eps_mm], center=true);
      }

      // Eye side rims
      translate([0, 0, -eye_width_mm/2 + eye_rim_thickness_mm/2])
        cylinder(r=eye_outer_diameter_mm/2, h=eye_rim_thickness_mm, center=true);
      translate([0, 0,  eye_width_mm/2 - eye_rim_thickness_mm/2])
        cylinder(r=eye_outer_diameter_mm/2, h=eye_rim_thickness_mm, center=true);

      // Ball retention lips
      translate([0, 0, -eye_width_mm/2 + eye_rim_thickness_mm/2 + overlap_mm/2])
        cylinder(r=ball_outer_diameter_mm/2 - chamfer_mm, h=eye_rim_thickness_mm, center=true);
      translate([0, 0,  eye_width_mm/2 - eye_rim_thickness_mm/2 - overlap_mm/2])
        cylinder(r=ball_outer_diameter_mm/2 - chamfer_mm, h=eye_rim_thickness_mm, center=true);
    }
  }

  // Spherical ball with through bore
  color("Silver") {
    difference() {
      sphere(r=ball_outer_diameter_mm/2);
      rotate([0, 90, 0])
        cylinder(r=bore_diameter_mm/2, h=eye_outer_diameter_mm + 2*eps_mm, center=true);
    }
  }
}

// Rod - complete geometry (built so its LEFT END is at x=0, extending +X)
module rod() {
  color("Black") {
    union() {
      // Shoulder (adjacent to eye)
      translate([shoulder_length_mm/2, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=shoulder_diameter_mm/2, h=shoulder_length_mm, center=true);

      // Unthreaded shank (after shoulder)
      translate([shoulder_length_mm + (shank_length_mm - thread_length_mm)/2, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=shank_diameter_mm/2, h=shank_length_mm - thread_length_mm, center=true);

      // Threaded portion at the far end
      translate([shoulder_length_mm + (shank_length_mm - thread_length_mm) + thread_length_mm/2, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=thread_d_major_mm/2, h=thread_length_mm, center=true);
    }
  }
}

// Assembly (single connected solid; rod overlaps eye by overlap_mm)
module assembly() {
  union() {
    rod_end_bearing();

    // Attach rod to the RIGHT side of the eye:
    // Eye extends to +eye_outer_diameter_mm/2 in X.
    // Place rod so its left end is inside the eye by overlap_mm.
    translate([eye_outer_diameter_mm/2 - overlap_mm, 0, 0])
      rod();
  }
}

assembly();