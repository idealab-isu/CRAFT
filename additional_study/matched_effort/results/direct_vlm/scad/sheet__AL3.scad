$fn = 96;

// Aluminium tooling plate (rounded corners + counterbored mounting holes)
length = 200;
width  = 150;
thickness = 6;

corner_radius = 2;

// Hole pattern (typical tooling plate feature)
edge_margin = 20;          // distance from edges to hole centers
hole_d = 6.6;              // through hole (clearance for M6)
counterbore_d = 12.0;      // counterbore diameter
counterbore_depth = 3.0;   // counterbore depth (from top face)

eps = 0.02;

module rounded_plate_3d(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    linear_extrude(height = t, center = true)
        offset(r = r2)
            square([l - 2*r2, w - 2*r2], center = true);
}

module tooling_plate(l, w, t, r){
    // Hole center positions derived from dimensions (no arbitrary offsets)
    x0 = l/2 - edge_margin;
    y0 = w/2 - edge_margin;

    difference() {
        rounded_plate_3d(l, w, t, r);

        // 4 corner counterbored holes (counterbore on top face)
        for (sx = [-1, 1], sy = [-1, 1]) {
            // Through hole
            translate([sx*x0, sy*y0, 0])
                cylinder(d = hole_d, h = t + 2*eps, center = true);

            // Counterbore (top side)
            translate([sx*x0, sy*y0, t/2 - counterbore_depth/2 + eps])
                cylinder(d = counterbore_d, h = counterbore_depth + 2*eps, center = true);
        }
    }
}

color([0.75, 0.77, 0.80])
    tooling_plate(length, width, thickness, corner_radius);