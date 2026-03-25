$fn = 128;

// Requested dimensions (LM16UU)
bore_diameter_mm  = 16.0;   // ID
outer_diameter_mm = 28.0;   // OD
length_mm         = 37.0;   // overall length

// Detail parameters (kept subtle; do not change overall OD/ID/Length)
seal_ring_thickness_mm = 2.0;
groove_depth_mm        = 0.8;
groove_width_mm        = 2.2;
groove_spacing_mm      = 26.0;
overlap_mm             = 0.2;

module linear_bearing_16_28_37() {
  difference() {
    // Outer body (exact OD and length)
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

    // Inner bore (exact ID, through)
    cylinder(h=length_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);

    // External grooves (subtractive; do not add protrusions)
    for (z = [ -groove_spacing_mm/2, groove_spacing_mm/2 ]) {
      translate([0, 0, z])
        difference() {
          cylinder(h=groove_width_mm, r=outer_diameter_mm/2 + overlap_mm, center=true);
          cylinder(h=groove_width_mm + 2*overlap_mm,
                   r=outer_diameter_mm/2 - groove_depth_mm, center=true);
        }
    }

    // Slight end recess to suggest seals (subtractive; keeps overall length)
    for (z = [ -1, 1 ]) {
      translate([0, 0, z*(length_mm/2 - seal_ring_thickness_mm/2)])
        cylinder(h=seal_ring_thickness_mm + overlap_mm,
                 r=outer_diameter_mm/2 - 0.6, center=true);
    }
  }
}

linear_bearing_16_28_37();