$fn = 180;

// Linear bearing nominal envelope (LM16UU style)
bore_d = 16.0;
od_d   = 28.0;
len    = 37.0;

// Feature parameters (kept within OD/length; all placements derived from dimensions)
eps = 0.02;

seal_w = 1.2;                 // end seal width
seal_lip = 0.6;               // small OD relief at ends
mid_groove_w = 2.0;           // center groove width
mid_groove_depth = 0.5;       // groove depth into OD

track_count = 6;              // visible ball-track scallops
track_r = 1.1;                // scallop radius
track_depth = 0.9;            // how far scallops cut into wall
track_z_margin = seal_w + 1.0; // keep tracks away from seals

module linear_bearing_16_28_37() {
  difference() {
    // Outer body with subtle end reliefs and a center groove
    union() {
      // Main OD
      cylinder(d = od_d, h = len, center = false);

      // End reliefs (slightly smaller OD) to suggest seal landings
      translate([0, 0, 0])
        cylinder(d = od_d - 2*seal_lip, h = seal_w, center = false);

      translate([0, 0, len - seal_w])
        cylinder(d = od_d - 2*seal_lip, h = seal_w, center = false);

      // Center groove (slightly smaller OD band)
      translate([0, 0, len/2 - mid_groove_w/2])
        cylinder(d = od_d - 2*mid_groove_depth, h = mid_groove_w, center = false);
    }

    // Bore
    translate([0, 0, -eps])
      cylinder(d = bore_d, h = len + 2*eps, center = false);

    // Ball-track scallops (external cuts), evenly spaced around OD
    // Positioned at radius so they cut into the wall by track_depth.
    track_center_r = od_d/2 - track_depth + track_r;
    track_h = len - 2*track_z_margin;

    for (i = [0:track_count-1]) {
      rotate([0, 0, i * 360/track_count])
        translate([track_center_r, 0, track_z_margin])
          cylinder(r = track_r, h = track_h, center = false);
    }
  }
}

linear_bearing_16_28_37();