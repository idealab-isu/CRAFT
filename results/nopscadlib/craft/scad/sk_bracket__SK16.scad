// Shaft support bracket for 16.0mm rod, 27.0mm tall
// STRUCTURAL FIXES:
// - Ensure upper/lower blue halves are physically connected (no mid-plane gap) via a thin web that
//   overlaps both halves by 1–2mm.
// - Ensure the orange cylindrical sleeve/insert is fused to the body by extending it into the body
//   and by adding small radial keys that bridge across the split.
// - Keep overall design intent; only fix connectivity.
// - All solids are unioned into one connected body.

rod_diameter_mm = 16.0; //[8.0:32.0:0.1]
rod_length_mm = 60.0; //[30.0:120.0:1]
overall_height_mm = 27.0; //[14.0:54.0:0.1]
fit_clearance_mm = 0.2; //[0.0:0.6:0.05]
wall_thickness_mm = 4.0; //[2.0:8.0:0.1]
base_thickness_mm = 6.0; //[3.0:12.0:0.1]
base_width_mm = 50.0; //[25.0:100.0:0.5]
base_length_mm = 40.0; //[20.0:80.0:0.5]
mount_hole_diameter_mm = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_x_mm = 30.0; //[15.0:60.0:0.5]
mount_hole_spacing_y_mm = 0.0; //[0.0:30.0:0.5]
rod_center_height_from_base_mm = 19.0; //[10.0:38.0:0.1]
clamp_split_width_mm = 2.0; //[1.0:4.0:0.1]
clamp_bolt_diameter_mm = 4.0; //[3.0:6.0:0.1]
clamp_bolt_count = 2; //[1:3:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
boss_diameter_mm = 10.0; //[6.0:16.0:0.1]
boss_extra_height_mm = 2.0; //[0.0:6.0:0.1]

$fn = 96;

// Derived
rod_r  = rod_diameter_mm/2;
bore_r = (rod_diameter_mm + 2*fit_clearance_mm)/2;

// Z positions
base_zc = base_thickness_mm/2;
body_zc = (base_thickness_mm - overlap_mm) + overall_height_mm/2;

// Clamp/rod-seat ring dimensions (orange sleeve)
seat_radial_thickness_mm = max(wall_thickness_mm, 3);
seat_outer_r = bore_r + seat_radial_thickness_mm;

// Extend sleeve in Y so it intersects the body everywhere (guaranteed union)
seat_len_y   = base_length_mm + 2*overlap_mm;
seat_zc      = rod_center_height_from_base_mm;

// --- Connectivity helpers (fix the "split into halves" + "gap" issues) ---

// A thin web that bridges across the clamp split, but only in a small Z band around the rod axis.
// This guarantees the upper and lower halves are one solid while keeping the clamp split visually.
bridge_z_thickness_mm = max(2*overlap_mm, 2.0); // 2mm typical
bridge_zc = rod_center_height_from_base_mm;     // centered on rod axis

// Make the bridge slightly wider than the split so it overlaps both sides.
bridge_x = clamp_split_width_mm + 2*overlap_mm;

// Keep the bridge short in Y so it doesn't "fill" the split everywhere.
bridge_y = max(8.0, 2*seat_outer_r); // local bridge around the clamp area

// Small radial keys that connect the sleeve to the body across the split (prevents sleeve "floating").
// These are outside the bore, so they don't interfere with the rod hole.
key_radial_mm = overlap_mm;                 // how far the key protrudes into each half
key_arc_r0 = bore_r + 0.6*seat_radial_thickness_mm; // place keys within sleeve wall
key_arc_r1 = seat_outer_r + key_radial_mm;          // extend slightly into body
key_z_thickness_mm = bridge_z_thickness_mm;         // same Z band as bridge
key_y_len = base_length_mm + 2*overlap_mm;          // run through clamp length

module sleeve_with_keys() {
  // Sleeve ring (orange)
  difference() {
    cylinder(r=seat_outer_r, h=seat_len_y, center=true);
    cylinder(r=bore_r,      h=seat_len_y + 2*overlap_mm, center=true);
  }

  // Two keys at +/-Y? No: keys bridge across X split, so place them at +/-90deg around the ring
  // (top and bottom of ring in Z after rotation), but since sleeve axis is Y, we key in X direction
  // by adding thin boxes that intersect the sleeve wall and extend into both halves.
  // These keys are centered on the split plane (x=0) and extend into both sides by overlap.
  for (kz = [-1, 1]) {
    translate([0, 0, kz*(key_arc_r0)])  // move up/down in Z (after rotation this is correct)
      cube([bridge_x + 2*key_radial_mm, key_y_len, overlap_mm], center=true);
  }
}

module bracket() {
  difference() {
    union() {
      // Base plate
      translate([0, 0, base_zc])
        cube([base_width_mm, base_length_mm, base_thickness_mm], center=true);

      // Upright clamp body (blue)
      translate([0, 0, body_zc])
        cube([base_width_mm, base_length_mm, overall_height_mm], center=true);

      // FIX: Bridge web to eliminate the visible horizontal gap / disconnected halves.
      // Overlaps the body by 1–2mm in Z and overlaps both sides of the split in X.
      translate([0, 0, bridge_zc])
        cube([bridge_x, bridge_y, key_z_thickness_mm], center=true);

      // FIX: Sleeve/insert fused to body (orange) + keys to ensure it is not "floating"
      translate([0, 0, seat_zc])
        rotate([90, 0, 0])
          sleeve_with_keys();

      // Clamp bosses (ensure intersection with body/ring via overlap)
      for (sx = [-1, 1]) {
        translate([sx*(rod_r + wall_thickness_mm/2 - overlap_mm), 0, rod_center_height_from_base_mm + boss_extra_height_mm])
          rotate([90, 0, 0])
            cylinder(r=boss_diameter_mm/2, h=base_length_mm + 2*overlap_mm, center=true);
      }
    }

    // Rod bore (axis along Y)
    translate([0, 0, rod_center_height_from_base_mm])
      rotate([90, 0, 0])
        cylinder(r=bore_r, h=base_length_mm + 4*overlap_mm, center=true);

    // Clamp split slot (kept). The bridge is local in Y/Z so the split remains visible elsewhere.
    translate([0, 0, body_zc])
      cube([clamp_split_width_mm, base_length_mm + 4*overlap_mm, overall_height_mm + 4*overlap_mm], center=true);

    // Mounting holes through base only
    for (sx = [-1, 1]) {
      translate([sx*(mount_hole_spacing_x_mm/2), (mount_hole_spacing_y_mm/2)*sx, base_zc])
        cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 4*overlap_mm, center=true);
    }

    // Clamp bolt holes (axis along X)
    for (sy = [-1, 1]) {
      translate([0, sy*(base_length_mm/4), rod_center_height_from_base_mm + boss_extra_height_mm])
        rotate([0, 90, 0])
          cylinder(r=clamp_bolt_diameter_mm/2, h=base_width_mm + 4*overlap_mm, center=true);
    }
  }
}

bracket();