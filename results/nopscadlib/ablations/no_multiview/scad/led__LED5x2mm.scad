// Parameters
led_type = 5; //[3:10:1]
lead = 5; //[2.5:15:0.5]
right_angle = 0; //[0:10:1]
eps = 0.8; //[0.5:2:0.1]
body_d = 5; //[2.5:10:0.5]
body_h = 8; //[4:16:0.5]
rim_t = 1.2; //[0.6:2.4:0.1]
rim_d = 6; //[3:12:0.5]
lead_t = 0.6; //[0.3:1.2:0.05]
lead_pitch = 2.54; //[1.5:5:0.01]
solder_r = 0.9; //[0.5:2:0.1]
solder_h = 1.2; //[0.6:3:0.1]

// Connectivity overlap (1-2mm) to guarantee solid unions
overlap = 1.2;

// LED Body (base sits on z=0, extends upward)
module led_body() {
  color("red")
    union() {
      // Main cylindrical body: bottom at z=0, top at z=body_h
      translate([0, 0, body_h/2])
        cylinder(r=body_d/2, h=body_h, center=true);

      // Dome: overlaps slightly into the cylinder
      translate([0, 0, body_h - overlap])
        sphere(r=body_d/2);
    }
}

// Rim Flange (centered around z=0, overlaps into body)
module rim_flange() {
  color("red")
    translate([0, 0, rim_t/2 - overlap/2])
      cylinder(r=rim_d/2, h=rim_t + overlap, center=true);
}

// LED Leads (pins) - top of pins overlaps into rim/body (no gap)
module led_leads() {
  // Pin length includes overlap into the LED base
  pin_len = lead + overlap;

  // Place pins so their TOP is at z=overlap (i.e., they extend into the body by 'overlap')
  // For a centered cube: center_z + pin_len/2 = overlap  => center_z = overlap - pin_len/2
  pin_center_z = overlap - pin_len/2;

  color("Silver")
    union() {
      translate([-lead_pitch/2, 0, pin_center_z])
        cube([lead_t, lead_t, pin_len], center=true);

      translate([ lead_pitch/2, 0, pin_center_z])
        cube([lead_t, lead_t, pin_len], center=true);

      if (right_angle > 0) {
        // Keep right-angle feature attached to the vertical pins with overlap
        // Horizontal segment sits near the bottom of the vertical pin
        translate([-lead_pitch/2, -right_angle/2 - lead_t/2 + overlap/2, -lead + lead_t/2])
          cube([lead_t, right_angle + overlap, lead_t], center=true);

        translate([ lead_pitch/2, -right_angle/2 - lead_t/2 + overlap/2, -lead + lead_t/2])
          cube([lead_t, right_angle + overlap, lead_t], center=true);
      }
    }
}

// Solder Ends - overlap into the bottom of the pins (no separation)
module solder_ends() {
  // Put solder so its TOP overlaps into the pin bottom by 'overlap'
  // Pin bottom is at z = overlap - pin_len = overlap - (lead+overlap) = -lead
  // So pin bottom is exactly at z=-lead. Make solder top at z=-lead + overlap.
  // For centered cylinder: center_z + (solder_h+overlap)/2 = -lead + overlap
  solder_len = solder_h + overlap;
  solder_center_z = (-lead + overlap) - solder_len/2;

  color("Silver")
    union() {
      translate([-lead_pitch/2, 0, solder_center_z])
        cylinder(r=solder_r, h=solder_len, center=true);

      translate([ lead_pitch/2, 0, solder_center_z])
        cylinder(r=solder_r, h=solder_len, center=true);
    }
}

// Complete LED Assembly (single connected solid via union)
module led() {
  union() {
    rim_flange();
    led_body();
    led_leads();
    solder_ends();
  }
}

// Final Assembly
module assembly() {
  led();
}

assembly();