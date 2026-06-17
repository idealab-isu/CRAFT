// Parameters
led_diameter_mm = 8; //[4:16:0.1]
body_height_mm = 9.2; //[4.6:18.4:0.1]
rim_thickness_mm = 1; //[0.5:2:0.1]
rim_diameter_mm = 9; //[6:18:0.1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.5; //[0.3:1:0.01]
lead_length_mm = 5; //[2.5:15:0.1]
eps_mm = 0.8; //[0.5:2:0.1]
lens_tip_radius_mm = 4; //[2:8:0.1]
lens_tip_overlap_mm = 1.2; //[0.5:3:0.1]
grill_hole_mm = 1.2; //[0.6:3:0.1]
grill_r_mm = 1000; //[50:2000:10]

// LED Module
module led() {
  color("red") {
    // LED Body
    union() {
      translate([0, 0, rim_thickness_mm + body_height_mm/2 - eps_mm])
        cylinder(r=led_diameter_mm/2, h=body_height_mm, center=true);
      translate([0, 0, rim_thickness_mm + body_height_mm - lens_tip_radius_mm + lens_tip_overlap_mm])
        sphere(r=lens_tip_radius_mm, center=true);
    }
    // Base Rim Flange
    translate([0, 0, rim_thickness_mm/2])
      cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true);
    // Leads
    union() {
      translate([-lead_pitch_mm/2, 0, -(lead_length_mm + rim_thickness_mm + eps_mm)/2 + rim_thickness_mm/2])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + rim_thickness_mm + eps_mm], center=true);
      translate([lead_pitch_mm/2, 0, -(lead_length_mm + rim_thickness_mm + eps_mm)/2 + rim_thickness_mm/2])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + rim_thickness_mm + eps_mm], center=true);
    }
  }
}

// Grill Hole Positions Module
module grill_hole_positions() {
  color("Silver") {
    for (i = [-1, 0, 1])
      for (j = [-1, 0, 1])
        if (i != 0 || j != 0) {
          translate([i * grill_hole_mm * 2, j * grill_hole_mm * 2, rim_thickness_mm/2])
            cylinder(r=grill_hole_mm/2, h=rim_thickness_mm, center=true);
        }
  }
}

// Assembly Module
module assembly() {
  led();
  grill_hole_positions();
}

assembly();