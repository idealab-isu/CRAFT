// Parameters
led_diameter_mm = 10; //[5:20:0.1]
body_height_mm = 11; //[5.5:22:0.1]
rim_diameter_mm = 12; //[8:24:0.1]
rim_thickness_mm = 1.2; //[0.6:2.4:0.1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.6; //[0.3:1.2:0.05]
lead_length_mm = 25; //[10:50:0.5]
overlap_mm = 1; //[0.5:2:0.1]
lens_round_radius_mm = 5; //[2.5:10:0.1]
grill_width_mm = 20; //[10:40:0.5]
grill_height_mm = 20; //[10:40:0.5]
grill_hole_mm = 3; //[1.5:6:0.1]
grill_gap_mm = 2; //[1:6:0.1]
grill_marker_height_mm = 0.8; //[0.4:2:0.1]

// LED - complete geometry (single connected solid)
module led() {

  // Derived Z references (keep everything formula-based and connected)
  rim_zc   = rim_thickness_mm/2;                         // rim center Z
  rim_top  = rim_thickness_mm;                           // rim top Z
  body_zc  = rim_top + body_height_mm/2 - overlap_mm;     // body center Z (overlaps rim)
  body_top = body_zc + body_height_mm/2;                 // body top Z

  // Side tabs/clips (must intersect the LED body, not just the rim)
  // Fix: make tabs span the rim+lower body region and push them radially inward
  // so they overlap the LED body cylinder by ~1-2mm.
  tab_radial_overlap = 1.5; // mm overlap into LED body (guaranteed connection)
  tab_len = 3.0;            // outward length
  tab_w   = 2.2;            // tangential width

  // Z: center tabs so they intersect both rim and the lower body (no vertical gap)
  tab_h  = rim_thickness_mm + 2*overlap_mm;              // ensure Z overlap
  tab_zc = rim_zc + overlap_mm;                          // slightly above rim center

  // R: place tabs so their inner face intrudes into the LED body radius
  body_r = led_diameter_mm/2;
  tab_center_r = body_r + tab_len/2 - tab_radial_overlap;

  module side_tabs() {
    color("Silver")
      union() {
        for (a = [45, 135, 225, 315]) {
          rotate([0,0,a])
            translate([tab_center_r, 0, tab_zc])
              cube([tab_len, tab_w, tab_h], center=true);
        }
      }
  }

  // Entire LED as one union so all parts are physically connected
  union() {

    // Red LED body + rim + leads (kept as one connected solid)
    color("red")
      union() {
        // Rim/Flange
        translate([0, 0, rim_zc])
          cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true);

        // LED Body (overlaps rim by overlap_mm)
        translate([0, 0, body_zc])
          cylinder(r=led_diameter_mm/2, h=body_height_mm, center=true);

        // Lens dome (overlaps body)
        translate([0, 0, body_top - lens_round_radius_mm - overlap_mm])
          sphere(r=lens_round_radius_mm);

        // Leads (overlap into rim by overlap_mm)
        translate([-lead_pitch_mm/2, 0, -lead_length_mm/2 + overlap_mm])
          cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
        translate([ lead_pitch_mm/2, 0, -lead_length_mm/2 + overlap_mm])
          cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
      }

    // Gray side tabs/clips (now physically attached via overlap into LED body + rim)
    side_tabs();
  }
}

// Grill Hole Positions - complete geometry (kept as separate markers)
module grill_hole_positions() {
  color("Silver") {
    union() {
      translate([-grill_width_mm/4, -grill_height_mm/4, rim_thickness_mm/2])
        cylinder(r=grill_hole_mm/2, h=grill_marker_height_mm, center=true);
      translate([grill_width_mm/4, -grill_height_mm/4, rim_thickness_mm/2])
        cylinder(r=grill_hole_mm/2, h=grill_marker_height_mm, center=true);
      translate([-grill_width_mm/4, grill_height_mm/4, rim_thickness_mm/2])
        cylinder(r=grill_hole_mm/2, h=grill_marker_height_mm, center=true);
      translate([grill_width_mm/4, grill_height_mm/4, rim_thickness_mm/2])
        cylinder(r=grill_hole_mm/2, h=grill_marker_height_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  union() {
    led();
    grill_hole_positions();
  }
}

assembly();