$fn = 64;

// Leadscrew nut housing: 8.0mm x 12.75mm x 19.0mm block (X x Y x Z)
module leadscrew_nut_housing() {
    // Overall block dimensions
    L = 8.0;     // X
    W = 12.75;   // Y
    H = 19.0;    // Z

    // Features (kept conservative so the part remains a single connected solid)
    bore_r = 2.5;          // through bore radius
    nut_x = 6.0;           // nut cavity size in X
    nut_y = 8.0;           // nut cavity size in Y
    nut_h = 10.0;          // nut cavity height in Z (blind pocket)
    nut_floor = 2.0;       // material left at bottom

    hole_r = 1.2;          // mounting hole radius
    hole_edge = 2.0;       // edge margin from X/Y faces

    difference() {
        // Main body centered at origin
        cube([L, W, H], center=true);

        // Through bore along Z, centered
        cylinder(h=H + 0.4, r=bore_r, center=true);

        // Blind nut cavity from top face downward
        translate([0, 0, H/2 - nut_h/2])
            cube([nut_x, nut_y, nut_h + 0.2], center=true);

        // 4 mounting holes through Z, positioned by formulas from dimensions
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx*(L/2 - hole_edge), sy*(W/2 - hole_edge), 0])
                    cylinder(h=H + 0.4, r=hole_r, center=true);
    }
}

leadscrew_nut_housing();