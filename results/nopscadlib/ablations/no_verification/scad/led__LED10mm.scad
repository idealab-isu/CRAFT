// Parameters
led_diameter_mm = 10; //[5:20:0.1]
body_height_mm = 11; //[5.5:22:0.1]
through_hole = 1; //[0:1:1]
lead_count = 2; //[2:2:1]
lead_length_mm = 25; //[10:60:1]
lead_pitch_mm = 2.54; //[1.27:7.62:0.01]
lead_thickness_mm = 0.6; //[0.3:1.2:0.05]
rim_thickness_mm = 1.2; //[0.6:2.4:0.05]
rim_diameter_mm = 11.2; //[10.2:22.4:0.1]
lens_round_radius_mm = 5; //[2.5:10:0.1]
lead_overlap_mm = 1; //[0.5:2:0.1]
grill_width_mm = 20; //[10:40:1]
grill_height_mm = 20; //[10:40:1]
grill_hole_mm = 3; //[1.5:6:0.1]
grill_gap_mm = 2; //[1:6:0.1]
grill_r_mm = 1000; //[20:2000:1]
grill_post_height_mm = 1.5; //[0.8:4:0.1]
grill_attach_overlap_mm = 1; //[0.5:2:0.1]

// LED Module
module led() {
  color("red") {
    // LED Body
    union() {
      translate([0, 0, (body_height_mm - lens_round_radius_mm) / 2])
        cylinder(r=led_diameter_mm/2, h=body_height_mm - lens_round_radius_mm, center=true);
      translate([0, 0, body_height_mm - led_diameter_mm/2])
        sphere(r=led_diameter_mm/2, center=true);
    }
    // Rim Flange
    translate([0, 0, rim_thickness_mm/2])
      cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true);
    // Leads
    union() {
      translate([-lead_pitch_mm/2, 0, -lead_length_mm/2 + lead_overlap_mm])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
      translate([lead_pitch_mm/2, 0, -lead_length_mm/2 + lead_overlap_mm])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
    }
  }
}

// Grill Hole Positions Module
module grill_hole_positions() {
  color("gray") {
    union() {
      translate([0, 0, rim_thickness_mm/2 + grill_post_height_mm/2 - grill_attach_overlap_mm])
        cylinder(r=grill_hole_mm/2, h=grill_post_height_mm, center=true);
      translate([min(grill_width_mm/4, rim_diameter_mm/4), 0, rim_thickness_mm/2 + grill_post_height_mm/2 - grill_attach_overlap_mm])
        cylinder(r=grill_hole_mm/2, h=grill_post_height_mm, center=true);
      translate([-min(grill_width_mm/4, rim_diameter_mm/4), 0, rim_thickness_mm/2 + grill_post_height_mm/2 - grill_attach_overlap_mm])
        cylinder(r=grill_hole_mm/2, h=grill_post_height_mm, center=true);
      translate([0, min(grill_height_mm/4, rim_diameter_mm/4), rim_thickness_mm/2 + grill_post_height_mm/2 - grill_attach_overlap_mm])
        cylinder(r=grill_hole_mm/2, h=grill_post_height_mm, center=true);
      translate([0, -min(grill_height_mm/4, rim_diameter_mm/4), rim_thickness_mm/2 + grill_post_height_mm/2 - grill_attach_overlap_mm])
        cylinder(r=grill_hole_mm/2, h=grill_post_height_mm, center=true);
    }
  }
}

// Assembly Module
module assembly() {
  led();
  grill_hole_positions();
}

// Final Assembly Call
assembly();