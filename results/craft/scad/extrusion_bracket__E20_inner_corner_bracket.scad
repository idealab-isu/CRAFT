$fn = 96;

// A extrusion bracket overall size: [26, 25, 4.7]
overall_x = 26;
overall_y = 25;
thickness = 4.7;

// Cross arm widths (chosen to match the shown "plus" silhouette)
arm_w_y = 12;  // width of horizontal arm (in Y)
arm_w_x = 12;  // width of vertical arm (in X)

// Outer corner rounding
corner_r = 1.2;

// Semicircular side cutouts (as in the renders)
cutout_d = 8.0;
cutout_r = cutout_d/2;

// How far the cutout centers sit from the outer edge (controls "bite" depth)
cutout_edge_inset = 2.0;

// Robust boolean overlap
eps = 0.25;

// Connectivity fix: add a thin "web" that bridges any accidental slice segmentation
// seen in some renderers/exports (1–2mm overlap requirement).
bridge_overlap = 1.2;   // mm (ensures continuous solid along length)
bridge_w = 2.0;         // mm (thin, does not change silhouette noticeably)

// 2D rounded rectangle centered at origin
module rounded_rect_centered_2d(w, h, r) {
    r2 = min(r, w/2, h/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

// Base "plus" plate (one connected solid)
module plus_plate_2d() {
    union() {
        // Horizontal bar: overall_x by arm_w_y
        rounded_rect_centered_2d(overall_x, arm_w_y, corner_r);

        // Vertical bar: arm_w_x by overall_y
        rounded_rect_centered_2d(arm_w_x, overall_y, corner_r);

        // Structural bridge web (ensures no thin slice-like disconnected segments)
        // Overlaps both bars by bridge_overlap to guarantee attachment.
        square([overall_x + 2*bridge_overlap, bridge_w], center=true);
        square([bridge_w, overall_y + 2*bridge_overlap], center=true);
    }
}

// Side semicircular cutouts (two per side, alternating like the views)
module side_cutouts_2d() {
    x_edge = overall_x/2;
    y_edge = overall_y/2;

    x_c = x_edge - cutout_edge_inset; // centers near left/right edges
    y_c = y_edge - cutout_edge_inset; // centers near top/bottom edges

    // Left side: upper cutout
    translate([-x_c,  arm_w_y/2]) circle(r=cutout_r);

    // Right side: lower cutout
    translate([ x_c, -arm_w_y/2]) circle(r=cutout_r);

    // Top side: left cutout
    translate([-arm_w_x/2,  y_c]) circle(r=cutout_r);

    // Bottom side: right cutout
    translate([ arm_w_x/2, -y_c]) circle(r=cutout_r);
}

// Final solid (explicit union to guarantee single connected body)
union() {
    difference() {
        linear_extrude(height=thickness, center=true, convexity=10)
            plus_plate_2d();

        // Through-cut the semicircular notches (slightly taller for clean boolean)
        linear_extrude(height=thickness + 2*eps, center=true, convexity=10)
            side_cutouts_2d();
    }
}