$fn = 96;

module leadscrew_nut_housing() {
    // Overall target size (X x Y x Z)
    L = 30.0;
    W = 34.0;
    H = 30.0;

    // Features
    bore_r = 8.0;          // through bore radius
    bore_h = H + 2;        // ensure full cut-through

    hole_r = 2.0;          // mounting hole radius
    hole_h = H + 2;        // ensure full cut-through

    // Place holes safely inside the block with margins
    hole_margin_x = 6.0;
    hole_margin_y = 6.0;
    hole_x = L/2 - hole_margin_x;
    hole_y = W/2 - hole_margin_y;

    // Shallow top pocket (retention counterbore)
    pocket_r = 10.0;
    pocket_depth = 2.0;

    difference() {
        // Main body block
        cube([L, W, H], center=true);

        // Central through bore (leadscrew/nut clearance)
        cylinder(h=bore_h, r=bore_r, center=true);

        // 4x mounting holes through
        for (x = [-hole_x, hole_x])
            for (y = [-hole_y, hole_y])
                translate([x, y, 0])
                    cylinder(h=hole_h, r=hole_r, center=true);

        // Top retention pocket (shallow)
        translate([0, 0, H/2 - pocket_depth/2])
            cylinder(h=pocket_depth + 0.2, r=pocket_r, center=true);
    }
}

leadscrew_nut_housing();