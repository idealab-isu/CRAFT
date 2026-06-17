// Parameters
outer_diameter_mm = 10; //[5:20:0.1]
height_mm = 2; //[1:4:0.1]
inner_diameter_mm = 0; //[0:10:0.1]
edge_round_radius_mm = 0.2; //[0:1:0.05]
tolerance_mm = 0.1; //[0:0.5:0.01]

$fn = 128;

// Magnet - single connected solid (rounded disk, optional bore)
module magnet() {
  outer_r = outer_diameter_mm/2;
  inner_r = (inner_diameter_mm + 2*tolerance_mm)/2;

  // Keep fillet valid for thin parts and avoid degenerate Minkowski
  fillet_r = min(edge_round_radius_mm, outer_r*0.45, height_mm*0.45);

  // If fillet is effectively zero, skip Minkowski for robustness
  use_fillet = (fillet_r > 0.0001);

  core_r = max(0.01, outer_r - fillet_r);
  core_h = max(0.01, height_mm - 2*fillet_r);

  color([0.72, 0.45, 0.2])
  difference() {
    if (use_fillet) {
      minkowski() {
        cylinder(r=core_r, h=core_h, center=true);
        sphere(r=fillet_r);
      }
    } else {
      cylinder(r=outer_r, h=height_mm, center=true);
    }

    // Central bore (only if it fits)
    if (inner_diameter_mm > 0 && inner_r < outer_r - 0.05) {
      cylinder(r=inner_r, h=height_mm + 2*fillet_r + 0.2, center=true);
    }
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();