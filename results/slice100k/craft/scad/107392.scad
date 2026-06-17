// Simple capsule-like rounded rectangular block
// Target bounding box: L x W x H = 8.04 x 2.61 x 1.11 mm (elongated along X)

L = 8.04; //[4.02:16.08:0.01]
W = 2.61; //[1.305:5.22:0.01]
H = 1.11; //[0.555:2.22:0.01]

fn = 64; //[12:128:1]

// Fillet radius (large on long edges, but limited by smallest half-dimension)
r_long = 0.45; //[0.225:0.9:0.01]

// Slight end rounding (kept subtle; also limited by geometry)
r_end  = 0.55; //[0.275:1.1:0.01]

// Small overlap for robust manifold connections (in mm)
overlap = 0.2; //[0.05:1:0.01]

// Clamp helper
function clamp(x, a, b) = min(max(x, a), b);

// Main capsule block: rounded-rectangle cross-section extruded along X,
// with rounded ends (capsule) and large fillets via Minkowski.
module capsule_block_complete() {
  // Ensure radii are feasible for the given bounding box
  r_fillet = clamp(r_long, 0, min(W, H)/2 - 0.001);
  r_cap    = clamp(r_end,  0, min(W, H)/2 - 0.001);

  // Keep overall size exactly L x W x H by shrinking the pre-shape
  // before Minkowski additions.
  coreL = max(0.001, L - 2*r_cap);
  coreW = max(0.001, W - 2*r_fillet);
  coreH = max(0.001, H - 2*r_fillet);

  union() {
    // Filleted long edges (Y/Z) + rounded ends (X) in one connected solid
    minkowski() {
      // Capsule along X made from hull of two thin slabs (gives straight-ish midsection)
      // Slight overlap ensures the hull is robust even at extreme parameter values.
      hull() {
        translate([-(coreL/2 - overlap/2), 0, 0])
          cube([overlap, coreW, coreH], center=true);
        translate([ +(coreL/2 - overlap/2), 0, 0])
          cube([overlap, coreW, coreH], center=true);
      }
      // Large fillets on long edges
      sphere(r=r_fillet, $fn=fn);
    }

    // Rounded ends (slightly radiused) by adding end caps via hull + sphere Minkowski
    // This keeps a capsule-like silhouette rather than a near-sphere.
    minkowski() {
      hull() {
        translate([-(L/2 - r_cap), 0, 0]) sphere(r=0.001, $fn=fn);
        translate([ +(L/2 - r_cap), 0, 0]) sphere(r=0.001, $fn=fn);
      }
      sphere(r=r_cap, $fn=fn);
    }
  }
}

capsule_block_complete();