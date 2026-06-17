// Parameters
led_diameter_mm = 5; //[2.5:10:0.1]
body_height_mm = 5.9; //[3:12:0.1]
lead_count = 2; //[2:2:1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.5; //[0.25:1:0.01]
lead_length_mm = 5; //[2.5:15:0.1]
rim_thickness_mm = 1; //[0.5:2:0.1]
rim_diameter_mm = 5.8; //[4:11.6:0.1]
right_angle = 0; //[0:8:1]
lead_overlap_mm = 0.8; //[0.5:2:0.1]
body_rounding_radius_mm = 2.5; //[1.25:5:0.1]
grill_width_mm = 6; //[3:20:0.1]
grill_height_mm = 6; //[3:20:0.1]
grill_hole_d_mm = 1; //[0.5:3:0.1]
grill_gap_mm = 0.6; //[0.3:3:0.1]
grill_attach_overlap_mm = 0.8; //[0.5:2:0.1]

// Quality
$fn = 96;

// LED - complete geometry (ONE connected solid)
module led() {
  // Derived dimensions / placements (all formula-based)
  led_r = led_diameter_mm/2;
  rim_r = rim_diameter_mm/2;

  // Typical 5mm LED lens: cylindrical section + domed top
  // Ensure total body height (from top of rim to top of dome) equals body_height_mm
  cyl_h = max(0.01, body_height_mm - led_r);   // dome height = led_r
  dome_r = led_r;

  // Z references
  z_rim_center = rim_thickness_mm/2;
  z_rim_top = rim_thickness_mm;
  z_body_cyl_center = z_rim_top + cyl_h/2;
  z_dome_center = z_rim_top + cyl_h;           // hemisphere center at cylinder top
  z_body_top = z_rim_top + cyl_h + dome_r;     // = rim_thickness + body_height

  // Leads: start slightly inside rim for connectivity
  lead_total_h = lead_length_mm + rim_thickness_mm + lead_overlap_mm;
  z_lead_center = z_rim_center - (lead_length_mm/2) - (lead_overlap_mm/2);

  color("red")
  union() {
    // Rim flange (connected to body and leads)
    cylinder(r=rim_r, h=rim_thickness_mm, center=true);

    // Body: cylinder + dome, both connected to rim
    union() {
      translate([0, 0, z_body_cyl_center])
        cylinder(r=led_r, h=cyl_h, center=true);

      // Dome: hemisphere (intersection of sphere with half-space)
      translate([0, 0, z_dome_center])
        intersection() {
          sphere(r=dome_r);
          // Keep upper half only (z >= 0 in local coords)
          translate([0, 0, dome_r/2])
            cube([2*dome_r + 0.2, 2*dome_r + 0.2, dome_r + 0.2], center=true);
        }
    }

    // Leads (connected through overlap into rim)
    for (sx = [-1, 1])
      translate([sx*lead_pitch_mm/2, 0, z_lead_center])
        cube([lead_thickness_mm, lead_thickness_mm, lead_total_h], center=true);
  }
}

// Grill Hole Positions - attached (unioned) to rim so model remains one connected solid
module grill_hole_positions() {
  // Place as shallow bumps that overlap into rim (not floating)
  bump_h = rim_thickness_mm; // same thickness as rim for robust connection
  z_bump_center = rim_thickness_mm/2 - grill_attach_overlap_mm/2;

  color("Silver")
  union() {
    translate([0, 0, z_bump_center])
      cylinder(r=grill_hole_d_mm/2, h=bump_h, center=true);

    translate([(grill_hole_d_mm + grill_gap_mm), 0, z_bump_center])
      cylinder(r=grill_hole_d_mm/2, h=bump_h, center=true);

    translate([(grill_hole_d_mm + grill_gap_mm)/2,
               (grill_hole_d_mm + grill_gap_mm)*0.866025403784,
               z_bump_center])
      cylinder(r=grill_hole_d_mm/2, h=bump_h, center=true);
  }
}

// Assembly (single connected solid)
module assembly() {
  union() {
    led();
    grill_hole_positions();
  }
}

assembly();