// SMD body target overall size: [8.70, 3.90, 1.25] (X, Y, Z)

$fn = 48;

// Exact target dimensions
body_length = 8.70;
body_width  = 3.90;
body_height = 1.25;

// Simple, robust details (kept subtle; no extra corner markers)
chamfer = 0.25;                 // visual edge break (kept small)
top_mark_length = 4.80;
top_mark_width  = 1.20;
top_mark_depth  = 0.08;

// Terminals (kept within overall length so the model stays exactly 8.70 long)
terminal_length = 1.20;         // per side, inside the body footprint
terminal_thickness = 0.18;
terminal_width_margin = 0.25;

// Small overlap to guarantee manifold unions/differences
eps = 0.02;

// --- Helpers ---
module rounded_box(size=[1,1,1], r=0.2) {
    // Minkowski rounding; r is clamped to avoid invalid geometry
    rr = min(r, min(size[0], min(size[1], size[2]))/2 - eps);
    if (rr <= 0)
        cube(size, center=true);
    else
        minkowski() {
            cube([size[0]-2*rr, size[1]-2*rr, size[2]-2*rr], center=true);
            sphere(r=rr);
        }
}

// --- Main body with subtle chamfer/rounding and a shallow top marking recess ---
module body() {
    difference() {
        rounded_box([body_length, body_width, body_height], r=chamfer);

        // Top marking recess (subtracted), stays within top face
        translate([0, 0, body_height/2 - top_mark_depth/2 + eps])
            cube([top_mark_length, top_mark_width, top_mark_depth + 2*eps], center=true);
    }
}

// Terminals are added as shallow pads on the bottom, but kept INSIDE the body length
// so overall dimensions remain exactly [8.70, 3.90, 1.25].
module terminals() {
    pad_w = body_width - 2*terminal_width_margin;
    pad_l = terminal_length;
    pad_h = terminal_thickness;

    // Place pads so their outer edges align with body ends (no protrusion beyond 8.70)
    x_center = body_length/2 - pad_l/2;

    for (sx = [-1, 1]) {
        translate([sx * x_center, 0, -body_height/2 + pad_h/2 - eps])
            cube([pad_l, pad_w, pad_h], center=true);
    }
}

// --- Final connected solid ---
union() {
    body();
    terminals();
}