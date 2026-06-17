// Heatshrink sleeving (hollow tube) - corrected to be a single connected solid
// Fixes:
// - Ensures visible inner hole in all orthographic views (true hollow tube)
// - Removes accidental end caps / stepped solids
// - Keeps all features connected and does not block the bore

$fn = 128;

// Parameters
sleeve_L = 50; //[25:100:1]
sleeve_ID = 10; //[5:20:0.5]
wall_t = 0.6; //[0.3:1.2:0.05]
end_trim_allowance = 0; //[0:5:0.1]
shrunk_ratio = 2; //[1.2:4:0.1]
shrunk_ID = 5; //[2.5:10:0.5]
overlap = 1; //[0.5:2:0.1]
chamfer_len = 1; //[0.5:3:0.1]
chamfer_rad = 0.6; //[0.2:2:0.05]
rib_count = 18; //[0:60:1]
rib_w = 1.2; //[0.5:3:0.1]
rib_h = 0.25; //[0.1:0.8:0.05]
mark_band_w = 6; //[2:15:0.5]
mark_band_h = 0.2; //[0.05:0.6:0.05]
shrunk_L = 18; //[8:40:1]

// Derived
outer_r = sleeve_ID/2 + wall_t;
inner_r = sleeve_ID/2;

// Keep bore always valid
inner_r_safe = max(0.01, inner_r);
outer_r_safe = max(inner_r_safe + 0.01, outer_r);

// Effective length (optionally trimmed)
L_eff = max(0.01, sleeve_L - 2*end_trim_allowance);

// Helpers
module tube(h, r_out, r_in) {
  difference() {
    cylinder(h=h, r=r_out, center=true);
    cylinder(h=h + 2*overlap, r=r_in, center=true);
  }
}

// Main sleeve with simple end chamfers (outer only; bore stays open)
module sleeve_main() {
  // Outer profile with slight chamfer at both ends, then subtract bore
  difference() {
    union() {
      // Main outer cylinder shortened to make room for chamfers
      cylinder(h=max(0.01, L_eff - 2*chamfer_len), r=outer_r_safe, center=true);

      // End chamfers (outer only), connected by overlap
      translate([0,0,  (L_eff/2 - chamfer_len/2)])
        cylinder(h=chamfer_len, r1=outer_r_safe + chamfer_rad, r2=outer_r_safe, center=true);

      translate([0,0, -(L_eff/2 - chamfer_len/2)])
        cylinder(h=chamfer_len, r1=outer_r_safe + chamfer_rad, r2=outer_r_safe, center=true);
    }

    // Bore through entire part
    cylinder(h=L_eff + 2*overlap, r=inner_r_safe, center=true);
  }
}

// Marking band (outer thickening only; does not reduce bore)
module marking_band_positioned() {
  // Place near one end, fully within sleeve length
  z0 = -L_eff/2 + mark_band_w/2 + overlap;
  translate([0,0,z0])
    difference() {
      cylinder(h=mark_band_w, r=outer_r_safe + mark_band_h, center=true);
      // Clear to the sleeve outer radius so it becomes an external band only
      cylinder(h=mark_band_w + 2*overlap, r=outer_r_safe, center=true);
    }
}

// Surface ribs (external rings), evenly distributed, not blocking bore
module surface_texture_ribs() {
  if (rib_count > 0 && rib_h > 0 && rib_w > 0) {
    // Keep ribs away from chamfers and ends
    z_min = -L_eff/2 + chamfer_len + rib_w/2 + overlap;
    z_max =  L_eff/2 - chamfer_len - rib_w/2 - overlap;
    span  = max(0, z_max - z_min);

    for (i = [0 : rib_count-1]) {
      z = (rib_count == 1) ? (z_min + span/2)
                           : (z_min + i * span/(rib_count-1));
      translate([0,0,z])
        difference() {
          cylinder(h=rib_w, r=outer_r_safe + rib_h, center=true);
          cylinder(h=rib_w + 2*overlap, r=outer_r_safe, center=true);
        }
    }
  }
}

// Optional "shrunk" section as an external sleeve overlay (keeps bore open)
module shrunk_state_overlay() {
  // Clamp shrunk section length
  shr_L = min(shrunk_L, L_eff - 2*chamfer_len - 2*overlap);
  if (shr_L > 0.01) {
    // Place near the opposite end from the marking band
    zc = L_eff/2 - chamfer_len - shr_L/2 - overlap;

    // Only add material if shrunk outer radius is larger than current outer radius
    // (If smaller, it would create a step inward; skip to keep uniform sleeve)
    shr_outer_r = shrunk_ID/2 + wall_t;
    if (shr_outer_r > outer_r_safe + 0.001) {
      translate([0,0,zc])
        difference() {
          cylinder(h=shr_L, r=shr_outer_r, center=true);
          cylinder(h=shr_L + 2*overlap, r=outer_r_safe, center=true);
        }
    }
  }
}

// Final Output: one connected solid, hollow throughout
union() {
  sleeve_main();
  marking_band_positioned();
  surface_texture_ribs();
  shrunk_state_overlay();
}