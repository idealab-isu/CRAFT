// Flat strap/link plate with rounded ends and through-holes
// Bounding box target: 60.6 x 7.0 x 2.5 mm

$fn = 96;

// Parameters
L = 60.55;                 // overall length (X)
W = 6.99;                  // overall width  (Y)
T = 2.54;                  // thickness      (Z)
end_radius = W/2;          // rounded end radius (matches width/2)

large_hole_d = 3.2;
large_hole_offset_from_end = 5.0;

small_hole_d = 1.6;
small_hole_x1_from_end = 3.5;
small_hole_x2_from_end = 6.5;
small_hole_x3_from_end = 9.5;

// Asymmetric Y offsets for the three small holes (end A pattern)
small_hole_y1_from_center = 1.2;
small_hole_y2_from_center = -0.8;
small_hole_y3_from_center = 0.4;

hole_cut_extra = 0.8;      // ensures clean through-cuts

// --- Geometry helpers ---
module strap_outline_2d() {
    // 2D capsule: rectangle + two semicircular ends
    hull() {
        translate([-(L/2 - end_radius), 0]) circle(r=end_radius);
        translate([ (L/2 - end_radius), 0]) circle(r=end_radius);
    }
}

module holes_2d() {
    // Large holes (one near each end, centered in Y)
    translate([-(L/2 - large_hole_offset_from_end), 0]) circle(d=large_hole_d);
    translate([ (L/2 - large_hole_offset_from_end), 0]) circle(d=large_hole_d);

    // Small holes near end A (left)
    translate([-(L/2 - small_hole_x1_from_end), small_hole_y1_from_center]) circle(d=small_hole_d);
    translate([-(L/2 - small_hole_x2_from_end), small_hole_y2_from_center]) circle(d=small_hole_d);
    translate([-(L/2 - small_hole_x3_from_end), small_hole_y3_from_center]) circle(d=small_hole_d);

    // Small holes near end B (right) mirrored in Y (pattern mirrored between ends)
    translate([ (L/2 - small_hole_x1_from_end), -small_hole_y1_from_center]) circle(d=small_hole_d);
    translate([ (L/2 - small_hole_x2_from_end), -small_hole_y2_from_center]) circle(d=small_hole_d);
    translate([ (L/2 - small_hole_x3_from_end), -small_hole_y3_from_center]) circle(d=small_hole_d);
}

// --- Final solid (one connected body) ---
difference() {
    linear_extrude(height=T, center=true, convexity=10)
        strap_outline_2d();

    linear_extrude(height=T + hole_cut_extra, center=true, convexity=10)
        holes_2d();
}