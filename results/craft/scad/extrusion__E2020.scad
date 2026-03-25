// 20x20 aluminium extrusion profile, 100mm long (single connected solid)

// Parameters
profile_width_mm  = 20.0;
profile_height_mm = 20.0;
length_mm         = 100.0;

center_part = true;

// Typical 2020-like features (simplified but recognizable)
slot_opening_mm          = 6.0;   // mouth width at outer face
slot_depth_mm            = 6.0;   // how far slot goes inward from outer face
slot_cavity_width_mm     = 10.0;  // wider undercut region
slot_cavity_depth_mm     = 3.0;   // depth of undercut region (near inner end)
center_bore_diameter_mm  = 5.0;

corner_relief_diameter_mm = 3.0;
corner_relief_offset_mm   = 5.0;
cornerHole                = 1;

overlap_mm = 0.5;

$fn = 96;

module extrusion_2020() {
  difference() {
    // Main body (square 20x20, length 100)
    cube([profile_width_mm, profile_height_mm, length_mm], center=center_part);

    // Center bore along length (Z axis)
    cylinder(d=center_bore_diameter_mm, h=length_mm + 2*overlap_mm, center=center_part);

    // T-slots on 4 sides (cut along length)
    for (a = [0, 90, 180, 270]) {
      rotate([0, 0, a]) {
        // Slot opening (narrow) from outer face inward
        translate([
          profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2,
          0,
          0
        ])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);

        // Slot cavity (wider) near inner end of slot
        translate([
          profile_width_mm/2 - slot_depth_mm + (slot_cavity_depth_mm + overlap_mm)/2,
          0,
          0
        ])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
      }
    }

    // Corner relief holes (optional), along length
    if (cornerHole) {
      for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*corner_relief_offset_mm, sy*corner_relief_offset_mm, 0])
          cylinder(d=corner_relief_diameter_mm, h=length_mm + 2*overlap_mm, center=center_part, $fn=36);
      }
    }
  }
}

extrusion_2020();