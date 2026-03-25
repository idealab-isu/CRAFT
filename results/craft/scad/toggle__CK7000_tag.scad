// Toggle switch (connected solid), body Ø0.76mm, overall height 4.7mm
// Improved silhouette: rectangular switch body + threaded bushing + hex nut + tilted lever + knob
// All translate() values are derived from dimensions; one connected solid.

$fn = 96;

// Requested key dimensions
body_diameter_mm  = 0.76;  // used as the main body width (across X)
overall_height_mm = 4.7;   // total Z height from bottom of body to top of knob

// Shape controls (kept small to match micro scale)
connection_overlap_mm = 0.05; //[0.02:0.2:0.01]

// Switch body (rectangular to be recognizable in ortho views)
body_w_mm = body_diameter_mm;     // X width matches requested "body diameter"
body_d_mm = body_diameter_mm*0.72; // Y depth (slightly thinner than width)
body_h_mm = 2.10;                 // Z height of main body

// Top bushing (threaded collar look)
bushing_d_mm = body_diameter_mm*0.62;
bushing_h_mm = 0.55;

// Hex nut (gives recognizable toggle hardware)
nut_flat_d_mm = body_diameter_mm*0.95; // across flats
nut_h_mm      = 0.28;

// Lever + knob
lever_d_mm  = body_diameter_mm*0.22;
lever_h_mm  = 1.35;
lever_tilt_deg = 18;

knob_d_mm = body_diameter_mm*0.55;
knob_h_mm = 0.42;

// Derived: ensure exact overall height by adjusting body height if needed
stack_top_mm = bushing_h_mm + nut_h_mm + lever_h_mm + knob_h_mm;
body_h_mm_adj = max(0.6, overall_height_mm - stack_top_mm);

// Helpers
module hex_prism(flat_d, h, center=true) {
  // Regular hex: across flats = 2*apothem => R = flat_d / sqrt(3)
  R = flat_d / sqrt(3);
  cylinder(h=h, r=R, $fn=6, center=center);
}

module toggle() {
  overlap = connection_overlap_mm;

  // Z references (bottom of body at z=0)
  z_body_top    = body_h_mm_adj;
  z_bush_top    = z_body_top + bushing_h_mm;
  z_nut_top     = z_bush_top + nut_h_mm;
  z_lever_base  = z_nut_top - overlap; // lever starts slightly into nut for connectivity

  union() {
    // Main switch body (rectangular with slight rounding)
    // Use hull of two thin cylinders to round edges while keeping rectangular silhouette.
    hull() {
      translate([ body_w_mm/2 - body_d_mm/2, 0, body_h_mm_adj/2])
        cylinder(d=body_d_mm, h=body_h_mm_adj, center=true);
      translate([-body_w_mm/2 + body_d_mm/2, 0, body_h_mm_adj/2])
        cylinder(d=body_d_mm, h=body_h_mm_adj, center=true);
    }

    // Top bushing (cylindrical collar) connected to body
    translate([0, 0, z_body_top + bushing_h_mm/2 - overlap])
      cylinder(d=bushing_d_mm, h=bushing_h_mm, center=true);

    // Hex nut connected to bushing
    translate([0, 0, z_bush_top + nut_h_mm/2 - 2*overlap])
      hex_prism(nut_flat_d_mm, nut_h_mm, center=true);

    // Lever (tilted) connected into nut
    // Place lever so its base intersects the nut by overlap.
    translate([0, 0, z_lever_base])
      rotate([0, lever_tilt_deg, 0])
        translate([0, 0, lever_h_mm/2])
          cylinder(d=lever_d_mm, h=lever_h_mm, center=true);

    // Knob at lever tip (also tilted with lever), connected by overlap
    translate([0, 0, z_lever_base])
      rotate([0, lever_tilt_deg, 0])
        translate([0, 0, lever_h_mm - overlap + knob_h_mm/2])
          cylinder(d=knob_d_mm, h=knob_h_mm, center=true);
  }
}

toggle();