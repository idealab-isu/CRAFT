// Parameters
tolerance = 0.2; //[0.05:0.6:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
bezel_width = 48; //[30:96:1]
bezel_height = 29; //[18:58:1]
bezel_thickness = 3; //[1.5:6:0.5]
body_width = 45; //[28:90:1]
body_height = 26; //[16:52:1]
body_depth = 25; //[15:60:1]
cutout_width = 45.2; //[28:92:0.1]
cutout_height = 26.2; //[16:60:0.1]
display_window_width = 36; //[20:70:1]
display_window_height = 14; //[8:30:1]
display_window_depth = 2.5; //[1:6:0.5]
tab_enabled = 1; //[0:1:1]
tab_width = 6; //[3:15:0.5]
tab_height = 10; //[5:20:0.5]
tab_thickness = 2; //[1:5:0.5]
button_enabled = 1; //[0:1:1]
button_diameter = 4; //[2:8:0.5]
button_height = 1.5; //[0.8:4:0.1]
button_spacing = 8; //[5:20:0.5]
button_offset_y = 9; //[4:14:0.5]
envelope_clearance = 1.0; //[0.5:5.0:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_margin = 1.0; //[0.0:5.0:0.5]
panel_cutout_depth = 6; //[2:20:1]

// Derived Z positions (centered model)
z_bezel = 0;
z_body  = -(bezel_thickness/2 + body_depth/2 - overlap);

// Panel Meter - complete geometry
module panel_meter() {
  color("Black")
  union() {
    // Front Bezel
    translate([0, 0, z_bezel])
      cube([bezel_width, bezel_height, bezel_thickness], center=true);

    // Rear Body (overlaps bezel by 'overlap')
    translate([0, 0, z_body])
      cube([body_width, body_height, body_depth], center=true);

    // Retention Tabs (overlap into body by 'overlap')
    if (tab_enabled) {
      translate([-(body_width/2 + tab_width/2 - overlap), 0, z_body])
        cube([tab_width, tab_height, tab_thickness], center=true);
      translate([(body_width/2 + tab_width/2 - overlap), 0, z_body])
        cube([tab_width, tab_height, tab_thickness], center=true);
    }
  }
}

// Panel Meter Button/Terminals - FIXED: attached to FRONT FACE (not floating/offset)
module panel_meter_button() {
  color("Silver")
  union() {
    if (button_enabled) {

      // Attach to the bezel FRONT face (positive Z), not the top.
      // Bezel front face is at z = +bezel_thickness/2.
      // With center=true cylinder, frontmost point is z_btn + button_height/2.
      // Set cylinder to penetrate bezel by 'overlap':
      // cylinder back face = (bezel_front - overlap) => z_btn - button_height/2 = bezel_front - overlap
      // => z_btn = bezel_front - overlap + button_height/2
      z_btn = (bezel_thickness/2 - overlap + button_height/2);

      // Keep buttons within bezel height; clamp if user sets offset too large
      y_btn = min(bezel_height/2 - button_diameter/2 - tolerance,
                  max(-bezel_height/2 + button_diameter/2 + tolerance, button_offset_y));

      translate([-button_spacing/2, y_btn, z_btn])
        cylinder(d=button_diameter, h=button_height, center=true, $fn=48);

      translate([ button_spacing/2, y_btn, z_btn])
        cylinder(d=button_diameter, h=button_height, center=true, $fn=48);
    }
  }
}

// Panel Meter Cutout - complete geometry (kept separate visual/reference)
module panel_meter_cutout() {
  color("DimGray")
  union() {
    // Panel Cutout Profile
    translate([0, 0, -(bezel_thickness/2 + panel_cutout_depth/2 - overlap)])
      cube([cutout_width, cutout_height, panel_cutout_depth], center=true);

    // Rear Clearance Envelope
    translate([0, 0, z_body])
      cube([body_width + 2*envelope_clearance,
            body_height + 2*envelope_clearance,
            body_depth + 2*envelope_clearance], center=true);

    // PCB Envelope
    translate([0, 0, -(bezel_thickness/2 + body_depth - pcb_thickness/2 - overlap)])
      cube([body_width - 2*(tolerance + pcb_margin),
            body_height - 2*(tolerance + pcb_margin),
            pcb_thickness], center=true);
  }
}

// Assembly
module assembly() {
  // Single connected solid for the meter itself
  difference() {
    union() {
      panel_meter();
      panel_meter_button(); // now overlaps bezel FRONT face by 'overlap' => attached
    }

    // Display Aperture
    translate([0, 0, (bezel_thickness/2 - display_window_depth/2)])
      cube([display_window_width, display_window_height, display_window_depth + overlap*2], center=true);
  }

  // Reference cutout/envelope (not part of the solid meter body)
  panel_meter_cutout();
}

assembly();