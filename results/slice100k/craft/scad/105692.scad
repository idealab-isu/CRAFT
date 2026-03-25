$fn = 96;

// Parameters (mm)
bbox_X = 29.78;
bbox_Y = 30.86;
bbox_Z = 6.0;

body_thickness = bbox_Z;

outer_flat_to_flat_X = bbox_X;
outer_flat_to_flat_Y = bbox_Y;

bore_d = 18.0;

// Keyway/notch parameters (rectangular cutouts interrupting the bore)
keyway_w = 3.0;                 // tangential width (Y)
keyway_depth_radial = 2.0;      // radial intrusion into ring from bore wall (X)
keyway_length_axial = bbox_Z;   // through

// Pins/tabs
pin_d = 2.0;
pin_h = 1.2;
pin_edge_offset = 2.0;          // from outer edge inward (Y)
pin_spacing = 6.0;              // center-to-center along X

// Overlaps / robustness
cut_overlap = 1.0;              // extra length for cutters so they fully cut
attach_overlap = 1.0;           // overlap between pins and body for solid union

// Helpers
function oct_points(w, h) =
    let(
        a = w/2,
        b = h/2,
        c = min(w, h) * 0.22
    )
    [
        [ a - c,  b],
        [ a,      b - c],
        [ a,     -b + c],
        [ a - c, -b],
        [-a + c, -b],
        [-a,     -b + c],
        [-a,      b - c],
        [-a + c,  b]
    ];

module outer_octagon_prism() {
    linear_extrude(height=body_thickness, center=true)
        polygon(points=oct_points(outer_flat_to_flat_X, outer_flat_to_flat_Y));
}

module bore_and_keyways_cutter() {
    // This is a CUTTER (to be subtracted): bore + two opposing rectangular notches
    union() {
        // main through-bore
        cylinder(d=bore_d, h=body_thickness + 2*cut_overlap, center=true);

        // two opposing rectangular keyways/notches intruding into bore
        // Place each notch so it overlaps the bore wall and clearly interrupts the circle.
        // Center is slightly OUTSIDE the bore radius so the notch cuts into the ring.
        for (sx = [-1, 1]) {
            translate([sx*(bore_d/2 + keyway_depth_radial/2), 0, 0])
                cube([keyway_depth_radial, keyway_w, body_thickness + 2*cut_overlap], center=true);
        }
    }
}

module outer_ring_body() {
    difference() {
        outer_octagon_prism();
        bore_and_keyways_cutter();
    }
}

module pins() {
    // Pins protrude from +Z face, near +Y edge, spaced along X.
    // Ensure they intersect the body by attach_overlap.
    zc = body_thickness/2 + pin_h/2 - attach_overlap;
    yc = outer_flat_to_flat_Y/2 - pin_edge_offset - pin_d/2;

    for (x = [-pin_spacing/2, pin_spacing/2]) {
        translate([x, yc, zc])
            cylinder(d=pin_d, h=pin_h, center=true);
    }
}

union() {
    outer_ring_body();
    pins();
}