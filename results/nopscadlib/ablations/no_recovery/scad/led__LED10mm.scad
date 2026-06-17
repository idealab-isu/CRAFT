// Parameters
led_diameter_mm = 10; //[5:20:0.5]
body_height_mm = 11; //[6:22:0.5]
through_hole = 1; //[0:1:1]
lead_count = 2; //[2:2:1]
lead_length_mm = 5; //[2.5:10:0.5]
right_angle = 0; //[0:10:1]
lead_thickness_mm = 0.6; //[0.3:1.2:0.1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
rim_thickness_mm = 1.2; //[0.6:2.4:0.1]
rim_diameter_mm = 11.2; //[10.2:22.4:0.1]
lens_round_radius_mm = 5; //[2.5:10:0.5]
overlap_mm = 0.8; //[0.2:2:0.1]
grill_plate_w_mm = 18; //[9:36:0.5]
grill_plate_h_mm = 18; //[9:36:0.5]
grill_plate_t_mm = 1.6; //[0.8:3.2:0.1]
grill_hole_d_mm = 2.2; //[1:4.4:0.1]
grill_gap_mm = 1.2; //[0.6:2.4:0.1]
grill_radius_limit_mm = 1000; //[50:2000:10]

// LED Module
module led() {
  color("red") {
    // LED Body
    union() {
      translate([0, 0, (body_height_mm - lens_round_radius_mm) / 2])
        cylinder(r=led_diameter_mm/2, h=body_height_mm - lens_round_radius_mm, center=true);
      translate([0, 0, body_height_mm - lens_round_radius_mm])
        sphere(r=lens_round_radius_mm, center=true);
    }
    // Rim Flange
    translate([0, 0, rim_thickness_mm/2 - overlap_mm])
      cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true);
    // Leads
    union() {
      translate([-lead_pitch_mm/2, 0, -lead_length_mm/2 + overlap_mm])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
      translate([lead_pitch_mm/2, 0, -lead_length_mm/2 + overlap_mm])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
    }
  }
}

// Grill Hole Positions Module
module grill_hole_positions() {
  color("Silver") {
    for (x = [-1, 0, 1])
      for (y = [-1, 0, 1])
        translate([x * (grill_plate_w_mm/2 - (grill_hole_d_mm/2 + grill_gap_mm)),
                   y * (grill_plate_h_mm/2 - (grill_hole_d_mm/2 + grill_gap_mm)),
                   -lead_length_mm - grill_plate_t_mm/2 + overlap_mm])
          cylinder(r=grill_hole_d_mm/2, h=grill_plate_t_mm + 2*overlap_mm, center=true);
  }
}

// Assembly Module
module assembly() {
  led();
  if (through_hole) {
    difference() {
      translate([0, 0, -lead_length_mm - grill_plate_t_mm/2 + overlap_mm])
        cube([grill_plate_w_mm, grill_plate_h_mm, grill_plate_t_mm], center=true);
      grill_hole_positions();
    }
  }
}

assembly();