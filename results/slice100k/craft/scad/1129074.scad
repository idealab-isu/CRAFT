// Elongated double-ended pointed link/connector body with central obround through-slot
// Target bounding box: ~7.8 (X) x 24.5 (Y) x 4.5 (Z) mm

$fn = 96;

// ---------------- Parameters ----------------
L = 24.5;          // overall length (Y)
W = 7.8;           // overall width  (X)
H = 4.5;           // overall height (Z)

tip_L = 4.0;       // length of each pointed end along Y
mid_L = L - 2*tip_L;

slot_L = 16.0;     // slot length along Y
slot_W = 4.2;      // slot width  along X

notch_L = 4.0;     // notch length along Y
notch_H = 1.6;     // notch height along Z
notch_depth = 0.7; // notch depth into X sides

facet_inset = 0.6; // how much to shave for faceting
cut_extra = 3.0;   // extra for cutters (robust)
overlap = 1.2;     // intentional overlap for robust connectivity/booleans

// ---------------- Helpers ----------------
module obround2d(len, wid) {
  // 2D obround centered at origin, length along Y, width along X
  r = wid/2;
  hull() {
    translate([0,  len/2 - r]) circle(r=r);
    translate([0, -len/2 + r]) circle(r=r);
  }
}

module outer_body() {
  // Connected "double-pointed" body:
  // - mid prism
  // - two tapered tips via hull to a small end cap
  tip_end_w = 1.2; // small but non-zero end width for robust hull
  tip_end_h = 1.2; // small but non-zero end height for robust hull

  union() {
    // Mid section (exactly mid_L long; tips provide the rest)
    cube([W, mid_L, H], center=true);

    // Left tip (toward -Y): base at -mid_L/2, end at -L/2
    hull() {
      translate([0, -(mid_L/2) + overlap/2, 0])
        cube([W, overlap, H], center=true);

      translate([0, -(L/2) + overlap/2, 0])
        cube([tip_end_w, tip_end_w, tip_end_h], center=true);
    }

    // Right tip (toward +Y): base at +mid_L/2, end at +L/2
    hull() {
      translate([0,  (mid_L/2) - overlap/2, 0])
        cube([W, overlap, H], center=true);

      translate([0,  (L/2) - overlap/2, 0])
        cube([tip_end_w, tip_end_w, tip_end_h], center=true);
    }
  }
}

module faceting_cuts() {
  // Four angled slabs to create a faceted/streamlined exterior (SUBTRACTED).
  // IMPORTANT: cutters must actually intersect the body; keep them centered and large.
  ang = 25;
  cutter_size = [W + 2*cut_extra, L + 2*cut_extra, H + 2*cut_extra];

  // Top facet cut
  translate([0, 0,  (H/2) - (facet_inset/2)])
    rotate([0,  ang, 0])
      cube(cutter_size, center=true);

  // Bottom facet cut
  translate([0, 0, -(H/2) + (facet_inset/2)])
    rotate([0, -ang, 0])
      cube(cutter_size, center=true);

  // Left facet cut
  translate([-(W/2) + (facet_inset/2), 0, 0])
    rotate([0, 0,  ang])
      cube(cutter_size, center=true);

  // Right facet cut
  translate([(W/2) - (facet_inset/2), 0, 0])
    rotate([0, 0, -ang])
      cube(cutter_size, center=true);
}

module central_slot_cutter() {
  // Through-slot along Y, cut through full thickness (Z)
  // FIX: extrude along Z, so the 2D obround must be in XY plane with length along Y.
  linear_extrude(height=H + 2*cut_extra, center=true)
    obround2d(slot_L, slot_W);
}

module side_notches_cutter() {
  // Shallow rectangular relief notches on mid-sides (left/right), centered in Y.
  // FIX: ensure cutters intersect the side faces by centering them slightly inside the body.
  x_center_left  = -(W/2) + (notch_depth/2) - (overlap/2);
  x_center_right =  (W/2) - (notch_depth/2) + (overlap/2);

  for (sx = [x_center_left, x_center_right]) {
    translate([sx, 0, 0])
      cube([notch_depth + overlap, notch_L, notch_H], center=true);
  }
}

// ---------------- Final Model ----------------
difference() {
  // Single connected solid body with faceting
  difference() {
    outer_body();
    faceting_cuts();
  }

  // Functional cuts
  central_slot_cutter();
  side_notches_cutter();
}