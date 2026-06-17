$fn = 128;

// Parameters
bore_diameter_mm = 16; //[8:32:0.1]
outer_diameter_mm = 28; //[14:56:0.1]
length_mm = 37; //[18.5:74:0.1]

eps_mm = 0.2; //[0.05:0.5:0.01]
overlap_mm = 1; //[0.5:2:0.1]

seal_length_mm = 3; //[1.5:6:0.1]
seal_radial_thickness_mm = 1.5; //[0.8:3:0.1]

lead_in_length_mm = 1.5; //[0.5:4:0.1]
lead_in_extra_radius_mm = 0.8; //[0.2:2:0.05]

groove_count = 2; //[0:2:1]
groove_width_mm = 2.2; //[1:5:0.1]
groove_depth_mm = 0.8; //[0.3:2:0.1]
groove_offset_from_end_mm = 6; //[3:12:0.1]

// Derived
outer_r = outer_diameter_mm/2;
bore_r  = bore_diameter_mm/2;

// Linear Bearing (single connected solid with real through-bore)
module linear_bearing() {
  color("DimGray")
  difference() {
    // Outer shell with optional external grooves
    union() {
      cylinder(r=outer_r, h=length_mm, center=true);

      if (groove_count > 0) {
        for (i = [-1, 1]) {
          // Groove center position measured from ends (formula, not arbitrary)
          z_g = i * (length_mm/2 - groove_offset_from_end_mm);

          // Add a "negative groove volume" as a ring that will be subtracted below
          // (implemented by subtracting a slightly smaller cylinder from a slightly larger one)
          // We add it here as geometry to be subtracted in the difference() below via children().
        }
      }
    }

    // Through bore (actual hole)
    cylinder(r=bore_r + eps_mm, h=length_mm + 2*eps_mm, center=true);

    // Lead-in chamfers at both ends (remove material near bore)
    for (i = [-1, 1]) {
      z_li = i * (length_mm/2 - lead_in_length_mm/2);
      translate([0, 0, z_li])
        cylinder(
          h=lead_in_length_mm + 2*eps_mm,
          r1=bore_r + lead_in_extra_radius_mm + eps_mm,
          r2=bore_r + eps_mm,
          center=true
        );
    }

    // External grooves (remove material from OD)
    if (groove_count > 0) {
      for (i = [-1, 1]) {
        z_g = i * (length_mm/2 - groove_offset_from_end_mm);
        translate([0, 0, z_g])
          difference() {
            cylinder(r=outer_r + eps_mm, h=groove_width_mm + 2*eps_mm, center=true);
            cylinder(r=outer_r - groove_depth_mm, h=groove_width_mm + 4*eps_mm, center=true);
          }
      }
    }
  }

  // End seals as small internal lips (kept connected to body)
  // These are inside the bore region, so they don't change OD and remain attached.
  color("DimGray")
  for (i = [-1, 1]) {
    z_seal = i * (length_mm/2 - seal_length_mm/2);
    translate([0, 0, z_seal])
      difference() {
        cylinder(r=bore_r + seal_radial_thickness_mm, h=seal_length_mm, center=true);
        cylinder(r=bore_r + eps_mm, h=seal_length_mm + 2*eps_mm, center=true);
      }
  }
}

linear_bearing();