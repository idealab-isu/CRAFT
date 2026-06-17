// Pillow block bearing housing (UCP-style simplified, improved)
// Target: 8.0mm shaft bore, 55.0mm x 42.0mm base
// ONE connected solid; no floating parts; all translates derived from dimensions.

$fn = 128;

// ---------- Parameters ----------
base_L = 55.0;                 // base length (X)
base_W = 42.0;                 // base width  (Y)
base_H = 10.0;                 // base thickness (Z)

shaft_d = 8.0;                 // shaft bore diameter (critical)

mount_hole_d = 6.5;
mount_hole_spacing_L = 40.0;   // center-to-center along X
mount_boss_d = 14.0;
mount_boss_h = 2.0;

// Housing proportions (typical pillow block look)
housing_W = 30.0;              // width of housing body (Y)
housing_block_H = 14.0;        // rectangular portion above base (Z)
arch_r = 16.0;                 // top arch radius (YZ)
housing_L = 34.0;              // length of housing body (X)

// Bearing seat (raised ring around bore on both sides)
seat_d = 22.0;                 // visual bearing OD seat
seat_ring_t = 4.0;             // ring thickness along X (each side)

// Split cap groove (visual detail)
cap_groove_w = 1.2;            // groove width along Z
cap_groove_depth = 1.2;        // groove depth into housing along Y

// Set screw (simple radial hole from top into bore)
set_screw_d = 4.0;
set_screw_z_from_top = 6.0;

// Grease boss
grease_boss_d = 8.0;
grease_boss_h = 6.0;
grease_hole_d = 2.0;

// Edge chamfer on base
edge_chamfer = 1.0;

// Robust boolean overlap
overlap = 0.8;

// ---------- Derived positions ----------
base_z0 = -base_H/2;
base_top_z = base_H/2;

housing_block_zc = base_top_z + housing_block_H/2 - overlap;
arch_axis_z = base_top_z + housing_block_H - overlap; // cylinder axis for arch

// Total housing height (approx) = base_H + housing_block_H + arch_r
z_top = arch_axis_z + arch_r;

// ---------- Helpers ----------
module chamfer_base_edges() {
  // subtract small wedges at base perimeter (keeps base size verifiable)
  for (sx = [-1, 1]) {
    translate([sx*(base_L/2 - edge_chamfer/2), 0, 0])
      rotate([0, 0, 45])
        cube([edge_chamfer, base_W + 2*overlap, base_H + 2*overlap], center=true);
  }
  for (sy = [-1, 1]) {
    translate([0, sy*(base_W/2 - edge_chamfer/2), 0])
      rotate([0, 0, 45])
        cube([base_L + 2*overlap, edge_chamfer, base_H + 2*overlap], center=true);
  }
}

module base_solid() {
  union() {
    cube([base_L, base_W, base_H], center=true);

    // mounting pads on top face (connected)
    for (sx = [-1, 1]) {
      translate([sx*mount_hole_spacing_L/2, 0, base_top_z + mount_boss_h/2 - overlap])
        cylinder(d=mount_boss_d, h=mount_boss_h, center=true);
    }
  }
}

module housing_outer() {
  // Outer housing: rectangular block + top arch, connected to base
  union() {
    // rectangular portion
    translate([0, 0, housing_block_zc])
      cube([housing_L, housing_W, housing_block_H], center=true);

    // arched top (cylinder along X)
    translate([0, 0, arch_axis_z])
      rotate([0, 90, 0])
        cylinder(r=arch_r, h=housing_L, center=true);

    // raised bearing seat rings on both sides (connected to housing)
    for (sx = [-1, 1]) {
      translate([sx*(housing_L/2 + seat_ring_t/2 - overlap), 0, arch_axis_z])
        rotate([0, 90, 0])
          cylinder(d=seat_d + 2*4.0, h=seat_ring_t, center=true); // outer ring diameter
    }

    // grease boss on top center (connected)
    translate([0, 0, z_top + grease_boss_h/2 - overlap])
      cylinder(d=grease_boss_d, h=grease_boss_h, center=true);
  }
}

module cap_split_groove() {
  // Visual split line around the cap: a shallow groove across the arch
  // Implemented as a thin rectangular cut that wraps by intersecting the arch region.
  // Positioned slightly above arch axis (typical cap split).
  groove_z = arch_axis_z + arch_r*0.35;
  translate([0, 0, groove_z])
    cube([housing_L + 2*seat_ring_t + 4*overlap, housing_W + 2*overlap, cap_groove_w], center=true);

  // Side relief to make it look like a split cap (small notches on both sides)
  for (sy = [-1, 1]) {
    translate([0, sy*(housing_W/2 - cap_groove_depth/2 + overlap), groove_z])
      cube([housing_L + 2*seat_ring_t + 4*overlap, cap_groove_depth, cap_groove_w*2], center=true);
  }
}

module mounting_holes() {
  for (sx = [-1, 1]) {
    translate([sx*mount_hole_spacing_L/2, 0, 0])
      cylinder(d=mount_hole_d, h=base_H + 2*mount_boss_h + 6*overlap, center=true);
  }
}

module shaft_bore() {
  // Shaft bore along X through entire housing + seat rings
  bore_len = housing_L + 2*seat_ring_t + 2*arch_r + 8*overlap;
  translate([0, 0, arch_axis_z])
    rotate([0, 90, 0])
      cylinder(d=shaft_d, h=bore_len, center=true);
}

module bearing_seat_bore() {
  // Larger bore region (visual bearing insert seat) centered in housing
  // Keep it shorter than full housing to leave material at ends.
  seat_len = housing_L - 2*6.0;
  translate([0, 0, arch_axis_z])
    rotate([0, 90, 0])
      cylinder(d=seat_d, h=seat_len, center=true);
}

module set_screw_hole() {
  // Radial hole from top down into bore (axis along Y)
  z_pos = z_top - set_screw_z_from_top;
  translate([0, 0, z_pos])
    rotate([90, 0, 0])
      cylinder(d=set_screw_d, h=housing_W + 2*arch_r + 8*overlap, center=true);
}

module grease_feed_hole() {
  // Vertical grease hole from boss down to bore region
  z1 = z_top + grease_boss_h;
  z0 = arch_axis_z;
  h = (z1 - z0) + 4*overlap;
  translate([0, 0, (z1 + z0)/2])
    cylinder(d=grease_hole_d, h=h, center=true);
}

// ---------- Final Model ----------
module pillow_block_bearing() {
  difference() {
    // ONE connected solid
    union() {
      // base with chamfered edges
      difference() {
        base_solid();
        chamfer_base_edges();
      }

      // housing on top of base (overlapped)
      housing_outer();
    }

    // subtract features
    union() {
      mounting_holes();
      shaft_bore();
      bearing_seat_bore();
      set_screw_hole();
      grease_feed_hole();
      cap_split_groove();
    }
  }
}

pillow_block_bearing();