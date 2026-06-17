// Parameters
pulley_type = 0; //[0:1:1]
teeth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:0.5]
belt_pitch_mm = 2; //[1:5:0.1]
width_mm = 10; //[5:30:0.5]
bore_diameter_mm = 5; //[2:12:0.1]
hub_diameter_mm = 12; //[6:24:0.5]
hub_length_mm = 8; //[0:24:0.5]
hub_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[10:40:0.5]
flange_thickness_mm = 1; //[0:5:0.1]
flanges_enabled = 1; //[0:1:1]
set_screw_count = 0; //[0:4:1]
set_screw_diameter_mm = 3; //[1:6:0.1]
set_screw_z_offset_mm = 0; //[-10:10:0.5]
overlap_mm = 1; //[0.5:2:0.1]
tooth_height_mm = 1; //[0.5:3:0.1]
tooth_width_factor = 0.6; //[0.3:0.9:0.05]
set_screw_length_mm = 30; //[10:80:1]

$fn = 96;

module pulley() {
  ov = max(0.05, overlap_mm);

  // Base body
  body_r = max(0.1, outer_diameter_mm/2);
  body_h = max(0.1, width_mm);

  // Hub (make sure it is not smaller than body so union stays one solid)
  hub_on = (hub_enabled != 0) && (hub_length_mm > 0) && (hub_diameter_mm > 0);
  hub_r  = max(body_r, hub_diameter_mm/2);
  hub_h  = max(0.1, hub_length_mm);

  // Flanges
  flange_on = (flanges_enabled != 0) && (flange_thickness_mm > 0) && (flange_diameter_mm > 0);
  flange_r  = max(body_r, flange_diameter_mm/2);
  flange_h  = max(0.1, flange_thickness_mm);

  // Teeth
  tooth_on  = (pulley_type == 1) && (teeth_count > 0) && (tooth_height_mm > 0) && (belt_pitch_mm > 0);
  tooth_len = max(0.1, tooth_height_mm + ov);                 // radial length
  tooth_w   = max(0.1, belt_pitch_mm * tooth_width_factor);
  tooth_h   = body_h;

  // Z placement (all formula-based, with overlap to guarantee connectivity)
  hub_z        = body_h/2 + hub_h/2 - ov;
  top_flange_z = body_h/2 + flange_h/2 - ov;
  bot_flange_z = -(body_h/2 + flange_h/2 - ov);

  // Bore through entire assembled height (computed, not arbitrary)
  total_h = body_h
          + (hub_on ? (hub_h - ov) : 0)
          + (flange_on ? 2*(flange_h - ov) : 0);

  bore_r = max(0.1, bore_diameter_mm/2);
  bore_h = total_h + 4*ov;

  difference() {
    union() {
      // Main body
      cylinder(r=body_r, h=body_h, center=true);

      // Hub (connected)
      if (hub_on)
        translate([0, 0, hub_z])
          cylinder(r=hub_r, h=hub_h, center=true);

      // Flanges (connected)
      if (flange_on) {
        translate([0, 0, top_flange_z])
          cylinder(r=flange_r, h=flange_h, center=true);
        translate([0, 0, bot_flange_z])
          cylinder(r=flange_r, h=flange_h, center=true);
      }

      // Teeth (protrude outward, overlap into body)
      if (tooth_on)
        for (i = [0:teeth_count-1])
          rotate([0, 0, i*360/teeth_count])
            translate([body_r + tooth_len/2 - ov, 0, 0])
              cube([tooth_len, tooth_w, tooth_h], center=true);
    }

    // Center bore
    cylinder(r=bore_r, h=bore_h, center=true);

    // Set screw holes (radial, only if hub exists)
    if (hub_on && set_screw_count > 0 && set_screw_diameter_mm > 0) {
      screw_r = max(0.1, set_screw_diameter_mm/2);

      // Clamp screw Z so it always intersects the hub (prevents "no visible geometry" from odd offsets)
      screw_z_raw = hub_z + set_screw_z_offset_mm;
      screw_z_min = hub_z - hub_h/2 + screw_r + ov;
      screw_z_max = hub_z + hub_h/2 - screw_r - ov;
      screw_z = (screw_z_min <= screw_z_max)
              ? min(max(screw_z_raw, screw_z_min), screw_z_max)
              : hub_z;

      // Axis near hub OD, with overlap so it definitely cuts
      screw_axis_x = hub_r - ov;

      for (i = [0:set_screw_count-1])
        rotate([0, 0, i*360/set_screw_count])
          translate([screw_axis_x, 0, screw_z])
            rotate([0, 90, 0])
              cylinder(r=screw_r, h=max(0.1, set_screw_length_mm), center=true);
    }
  }
}

pulley();