$fn = 64;

// Aluminium tooling plate (sheet) with subtle corner chamfers and mounting holes
length = 200;
width  = 150;
thickness = 6;

chamfer = 2;          // small edge chamfer to distinguish from a plain cube
hole_d = 8;           // typical mounting hole diameter
edge_margin = 15;     // distance from edges to hole centers

module chamfered_plate(l, w, t, c) {
    // 2D rectangle with 45° corner chamfers, then extruded
    linear_extrude(height=t, center=true)
        polygon(points=[
            [-l/2 + c, -w/2],
            [ l/2 - c, -w/2],
            [ l/2,     -w/2 + c],
            [ l/2,      w/2 - c],
            [ l/2 - c,  w/2],
            [-l/2 + c,  w/2],
            [-l/2,      w/2 - c],
            [-l/2,     -w/2 + c]
        ]);
}

module tooling_plate(l, w, t, c, hd, m) {
    color([0.75, 0.78, 0.82])
    difference() {
        chamfered_plate(l, w, t, c);

        // 4 corner mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - m), sy*(w/2 - m), 0])
                cylinder(h=t + 0.2, d=hd, center=true);
    }
}

tooling_plate(length, width, thickness, chamfer, hole_d, edge_margin);