// Parameters
led_type = 5; //[3:10:1]
lead = 5; //[2.5:10:0.5]
right_angle = 0; //[0:12:1]
eps = 0.8; //[0.5:2:0.1]
body_d = 5; //[3:10:1]
body_h = 8.5; //[4.25:17:0.5]
rim_t = 1.2; //[0.6:2.4:0.1]
rim_d = 6; //[3:12:0.5]
lead_t = 0.6; //[0.3:1.2:0.05]
lead_pitch = 2.54; //[1.27:5.08:0.01]
solder_len = 1.2; //[0.6:3:0.1]
bend_radius = 0.9; //[0.45:1.8:0.05]

$fn = 64;

module led() {
  // Robust overlap to guarantee manifold connectivity
  overlap = max(0.25, eps);

  // Z references (computed)
  z_rim_bottom = 0;
  z_rim_top    = rim_t;

  z_body_bottom = z_rim_top - overlap;
  z_body_top    = z_body_bottom + body_h;

  // Dome: use hemisphere on top of body (prevents "floating sphere" look)
  dome_r = body_d/2;
  z_dome_center = z_body_top - dome_r + overlap; // overlaps into body

  // Leads: start slightly inside rim to ensure union
  z_lead_top    = z_rim_bottom + overlap;
  z_lead_bottom = z_lead_top - lead;

  // Solder: extend from lead bottom further down, overlapping into lead
  z_solder_top    = z_lead_bottom + overlap;
  z_solder_bottom = z_solder_top - solder_len;

  color("red")
  union() {
    // Rim flange
    translate([0, 0, (z_rim_bottom + z_rim_top)/2])
      cylinder(r=rim_d/2, h=rim_t, center=true);

    // Body cylinder
    translate([0, 0, (z_body_bottom + z_body_top)/2])
      cylinder(r=body_d/2, h=body_h, center=true);

    // Dome (hemisphere) connected to body
    translate([0, 0, z_dome_center])
      intersection() {
        sphere(r=dome_r);
        // keep upper half only
        translate([0, 0, dome_r/2])
          cube([2*dome_r + 2, 2*dome_r + 2, dome_r + 2], center=true);
      }

    // Leads (vertical)
    for (sx = [-1, 1]) {
      x = sx * lead_pitch/2;

      // Main lead
      translate([x, 0, (z_lead_top + z_lead_bottom)/2])
        cube([lead_t, lead_t, (z_lead_top - z_lead_bottom)], center=true);

      // Solder extension (overlaps into lead)
      translate([x, 0, (z_solder_top + z_solder_bottom)/2])
        cube([lead_t, lead_t, (z_solder_top - z_solder_bottom)], center=true);
    }

    // Optional right-angle bend (kept connected)
    if (right_angle > 0) {
      // Horizontal segment starts at lead bottom and extends in -Y
      y_h_center = -(right_angle/2 - overlap);
      z_h_center = z_lead_bottom + lead_t/2 - overlap;

      for (sx = [-1, 1]) {
        x = sx * lead_pitch/2;

        // Horizontal segment
        translate([x, y_h_center, z_h_center])
          cube([lead_t, right_angle, lead_t], center=true);

        // Corner fillet (quarter torus) positioned to overlap both segments
        // Place torus center at the inside corner of the L
        translate([x, -lead_t/2 + overlap, z_lead_bottom + lead_t/2 - overlap])
          rotate([90, 0, 0])
            rotate_extrude(angle=90)
              translate([bend_radius, 0, 0])
                circle(r=lead_t/2);
      }
    }
  }
}

led();