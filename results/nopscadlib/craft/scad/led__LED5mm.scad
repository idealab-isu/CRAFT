// Parameters
led_diameter_mm = 5; //[2.5:10:0.1]
body_height_mm = 5.9; //[3:12:0.1]
lead_count = 2; //[2:2:1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.5; //[0.25:1:0.01]
lead_length_mm = 5; //[2.5:15:0.1]
rim_thickness_mm = 1; //[0.5:2:0.1]
rim_diameter_mm = 5.8; //[5:11.6:0.1]
right_angle = 0; //[0:10:1]
eps_mm = 0.01; //[0.001:0.1:0.001]
overlap_mm = 0.8; //[0.5:2:0.1]
lead_embed_mm = 1.2; //[0.5:3:0.1]

// Unused grill params kept for compatibility (no extra floating geometry)
grill_width_mm = 12; //[6:24:0.5]
grill_height_mm = 12; //[6:24:0.5]
grill_hole_mm = 1.5; //[0.8:3:0.1]
grill_gap_mm = 1; //[0.5:3:0.1]
grill_r_mm = 1000; //[10:2000:10]

$fn = 64;

// LED module (single connected solid)
module led() {
  // Derived geometry for a standard 5mm THT LED:
  // Total body height (excluding leads) = body_height_mm
  // Split into: flange (rim_thickness_mm) + cylindrical body + domed lens
  dome_h = min(led_diameter_mm/2, max(0.8, body_height_mm*0.35));
  cyl_h  = max(eps_mm, body_height_mm - rim_thickness_mm - dome_h);

  body_r = led_diameter_mm/2;
  rim_r  = rim_diameter_mm/2;

  // Z references (flange centered at z=0)
  rim_zc = 0;
  rim_top = rim_zc + rim_thickness_mm/2;
  rim_bot = rim_zc - rim_thickness_mm/2;

  cyl_zc = rim_top + cyl_h/2 - overlap_mm;                 // overlap into flange
  cyl_top = cyl_zc + cyl_h/2;

  dome_zc = cyl_top + dome_h/2 - overlap_mm;               // overlap into cylinder

  // Leads
  lead_total_h = lead_length_mm + lead_embed_mm;
  lead_zc = rim_bot - lead_length_mm/2 + overlap_mm;       // overlap into flange
  lead_top = lead_zc + lead_total_h/2;

  // Ensure leads actually embed into body
  // (If parameters make them too short, still keep connected via overlap)
  embed_guard = max(0, (rim_bot + lead_embed_mm) - lead_top);
  lead_zc_adj = lead_zc + embed_guard;

  union() {
    // Body (red)
    color("red")
    union() {
      // Rim / flange
      translate([0, 0, rim_zc])
        cylinder(r=rim_r, h=rim_thickness_mm, center=true);

      // Cylindrical body
      translate([0, 0, cyl_zc])
        cylinder(r=body_r, h=cyl_h, center=true);

      // Domed lens (spherical cap)
      translate([0, 0, dome_zc])
        scale([1, 1, dome_h/body_r])
          sphere(r=body_r);
    }

    // Leads (silver) - connected by embedding into flange
    color("Silver")
    union() {
      // Straight leads
      for (sx = [-1, 1]) {
        translate([sx*lead_pitch_mm/2, 0, lead_zc_adj])
          cube([lead_thickness_mm, lead_thickness_mm, lead_total_h], center=true);
      }

      // Optional right-angle bend (kept connected; replaces lower portion visually)
      if (right_angle > 0) {
        // Bend starts near bottom of flange, goes down then sideways
        bend_down_h = right_angle + lead_embed_mm;
        bend_zc = rim_bot - (bend_down_h - lead_embed_mm)/2 + overlap_mm;

        for (sx = [-1, 1]) {
          // Vertical segment for bend
          translate([sx*lead_pitch_mm/2, 0, bend_zc])
            cube([lead_thickness_mm, lead_thickness_mm, bend_down_h], center=true);

          // Horizontal segment (extends in -Y)
          horiz_yc = -right_angle/2 - lead_thickness_mm/2 + overlap_mm;
          horiz_zc = rim_bot - (bend_down_h - lead_embed_mm) + lead_thickness_mm/2 + overlap_mm;

          translate([sx*lead_pitch_mm/2, horiz_yc, horiz_zc])
            cube([lead_thickness_mm, right_angle, lead_thickness_mm], center=true);
        }
      }
    }
  }
}

led();