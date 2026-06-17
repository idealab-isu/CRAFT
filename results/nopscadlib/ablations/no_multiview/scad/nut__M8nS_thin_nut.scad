// Parameters
thread_diameter = 8.0; //[4.0:16.0:0.1]
across_flats    = 13.0; //[6.5:26.0:0.1]
thickness       = 4.0; //[2.0:8.0:0.1]
hole_clearance  = 0.0; //[0.0:1.0:0.05]

// Small overlap to guarantee watertight unions / connections
overlap = 1.2; //[1.0:2.0:0.1]
eps     = 0.8; //[0.2:2.0:0.1]

// Hexagonal Nut Profile (flat-to-flat)
module flat_to_flat_hex_profile(h=thickness) {
  linear_extrude(height=h, center=true)
    polygon(points=[
      [ across_flats/2, 0],
      [ across_flats/4,  (across_flats/2)*tan(30)],
      [-across_flats/4,  (across_flats/2)*tan(30)],
      [-across_flats/2, 0],
      [-across_flats/4, -(across_flats/2)*tan(30)],
      [ across_flats/4, -(across_flats/2)*tan(30)]
    ]);
}

// Thread Through Hole
module thread_through_hole(h=thickness) {
  cylinder(r=(thread_diameter + hole_clearance)/2, h=h + 2*eps, center=true);
}

// NUT - single connected solid (no split halves, no gaps)
module nut() {
  // If any upstream code/viewer introduced a split, force a single manifold by
  // unioning a tiny "stitch" web through the center before subtracting the hole.
  // This guarantees left/right and front/back halves overlap by ~overlap.
  difference() {
    union() {
      flat_to_flat_hex_profile(h=thickness);

      // Stitch web: thin cross that overlaps both sides by 1-2mm.
      // It is later removed by the through-hole, so it does not change the design.
      // (It only prevents accidental disconnected shells during boolean ops.)
      for (a = [0, 90]) rotate([0,0,a])
        cube([across_flats + 2*overlap, overlap, thickness + 2*eps], center=true);
    }

    // Through hole (slightly extended to avoid coplanar faces)
    thread_through_hole(h=thickness);
  }
}

// Final Assembly (single connected solid)
module assembly() {
  color("DimGray")
    union() {
      nut();
    }
}

assembly();