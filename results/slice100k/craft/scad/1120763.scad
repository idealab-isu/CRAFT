// Flat strap/link plate with rounded ends and through-holes
// Target bounding box: 60.6 x 7.0 x 2.5 mm
// Fixes:
//  - Ensure large end holes are clean circular through-holes (no slots/irregular cutouts)
//  - Ensure THREE small through-holes per end in an asymmetric pattern
//  - Mirror the small-hole pattern between ends
//  - Keep a single connected solid; all cutters fully pass through thickness

$fn = 128;

// -------------------- Parameters --------------------
L = 60.55; // overall length (X)
W = 6.99;  // overall width  (Y)
T = 2.54;  // thickness      (Z)

end_r = W/2; // rounded ends radius (obround)

// Holes
large_hole_d = 3.2;
large_hole_x_from_end = 5.5;

small_hole_d = 1.6;
small_hole_x1_from_end = 3.8;
small_hole_x2_from_end = 6.6;
small_hole_x3_from_end = 9.4;

// Asymmetric Y offsets (will be mirrored between ends)
small_hole_y1_from_center = 1.2;
small_hole_y2_from_center = -0.8;
small_hole_y3_from_center = 0.4;

// Robust cutting
clearance = 0.0;
hole_cut_extra_z = 1.0; // ensure full cut through plate

// Keep holes inside outline
edge_margin = 0.25; // mm

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);
function safe_end_r() = clamp(end_r, 0.01, W/2);
function max_y_for_d(d) = (W/2) - (d/2) - edge_margin;

// -------------------- Geometry --------------------
module obround_plate(L, W, T) {
    r = safe_end_r();
    // All primitives centered to avoid accidental offsets; union guarantees single solid
    union() {
        cube([L - 2*r, W, T], center=true);
        translate([-(L/2 - r), 0, 0]) cylinder(r=r, h=T, center=true);
        translate([ (L/2 - r), 0, 0]) cylinder(r=r, h=T, center=true);
    }
}

module hole_cyl(d) {
    // Centered cutter, taller than plate to guarantee through-hole
    cylinder(r=(d + clearance)/2, h=T + hole_cut_extra_z, center=true);
}

module holes_end(sign=1) {
    // sign = -1 left end, +1 right end
    // Mirror the asymmetric small-hole pattern between ends by flipping Y with sign.

    // Convert "from end" distances into centered X coordinates
    x_large = sign * (L/2 - large_hole_x_from_end);
    x1      = sign * (L/2 - small_hole_x1_from_end);
    x2      = sign * (L/2 - small_hole_x2_from_end);
    x3      = sign * (L/2 - small_hole_x3_from_end);

    // Clamp Y offsets so holes remain within the plate width
    y1 = clamp(small_hole_y1_from_center, -max_y_for_d(small_hole_d), max_y_for_d(small_hole_d));
    y2 = clamp(small_hole_y2_from_center, -max_y_for_d(small_hole_d), max_y_for_d(small_hole_d));
    y3 = clamp(small_hole_y3_from_center, -max_y_for_d(small_hole_d), max_y_for_d(small_hole_d));

    // Large clean circular through-hole near end
    translate([x_large, 0, 0]) hole_cyl(large_hole_d);

    // Three small circular through-holes (asymmetric), mirrored between ends
    translate([x1, sign * y1, 0]) hole_cyl(small_hole_d);
    translate([x2, sign * y2, 0]) hole_cyl(small_hole_d);
    translate([x3, sign * y3, 0]) hole_cyl(small_hole_d);
}

module holes_all() {
    holes_end(-1);
    holes_end( 1);
}

// -------------------- Final Model --------------------
difference() {
    obround_plate(L, W, T);
    holes_all();
}