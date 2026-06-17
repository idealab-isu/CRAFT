$fn = 64;

// Target overall size (X,Y,Z)
bracket_length    = 26;
bracket_width     = 25;
bracket_thickness = 4.7;

// Corner "ears"/bumps seen in reference silhouettes
ear_r = 2.2;                 // radius of corner bump
ear_inset = ear_r * 0.55;    // how far the bump center sits inside the plate

// Mounting holes (through thickness)
hole_d = 5;
hole_r = hole_d/2;

// Hole placement (formulas from dimensions)
edge_margin_x = 6;
edge_margin_y = 6;

// Small overlap to ensure robust booleans
eps = 0.02;

module plate_with_corner_ears_2d(L, W, r, inset) {
    // Base rectangle plus 4 quarter-circle bumps at corners
    union() {
        square([L, W], center=false);

        // bottom-left
        translate([inset, inset]) circle(r=r);
        // bottom-right
        translate([L - inset, inset]) circle(r=r);
        // top-left
        translate([inset, W - inset]) circle(r=r);
        // top-right
        translate([L - inset, W - inset]) circle(r=r);
    }
}

module extrusion_bracket() {
    difference() {
        // Solid plate (one connected body)
        linear_extrude(height=bracket_thickness, center=false)
            plate_with_corner_ears_2d(bracket_length, bracket_width, ear_r, ear_inset);

        // Two through-holes (typical extrusion bracket)
        for (p = [
            [edge_margin_x, edge_margin_y],
            [bracket_length - edge_margin_x, bracket_width - edge_margin_y]
        ]) {
            translate([p[0], p[1], -eps])
                cylinder(h=bracket_thickness + 2*eps, r=hole_r, center=false);
        }
    }
}

extrusion_bracket();