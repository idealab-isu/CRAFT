$fn = 64;

// Display Module v3.0
// Overall size: 84.5mm x 54.5mm

module display_module_v3(
    L = 84.5,   // length (X)
    W = 54.5,   // width  (Y)
    T = 1.6,    // PCB thickness
    corner_r = 2.5,

    // Mounting holes (typical)
    hole_d = 3.2,
    hole_edge_x = 3.5,
    hole_edge_y = 3.5,

    // Display window / cutout (typical)
    window_L = 70.0,
    window_W = 40.0,
    window_z = 0.8,      // depth into PCB (engrave)
    window_offset_y = 2.0, // shift window slightly upward

    // Header footprint (typical)
    header_pins = 16,
    header_pitch = 2.54,
    header_row_y = -W/2 + 7.0,
    header_pin_d = 1.0,

    // Silkscreen-like raised border around window
    bezel_h = 0.6,
    bezel_t = 1.2
) {
    module rounded_plate(x, y, z, r) {
        linear_extrude(height = z)
            offset(r = r)
                square([x - 2*r, y - 2*r], center = true);
    }

    difference() {
        // PCB body
        color([0.05, 0.35, 0.12])
            rounded_plate(L, W, T, corner_r);

        // Mounting holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(L/2 - hole_edge_x), sy*(W/2 - hole_edge_y), -0.1])
                cylinder(d = hole_d, h = T + 0.2);
        }

        // Display window engraving (shallow recess)
        translate([0, window_offset_y, T - window_z])
            linear_extrude(height = window_z + 0.01)
                square([window_L, window_W], center = true);

        // Header pin holes (single row)
        for (i = [0 : header_pins - 1]) {
            x = (i - (header_pins - 1)/2) * header_pitch;
            translate([x, header_row_y, -0.1])
                cylinder(d = header_pin_d, h = T + 0.2);
        }
    }

    // Raised bezel around window (silkscreen-like)
    color([0.9, 0.9, 0.9])
    translate([0, window_offset_y, T])
    difference() {
        linear_extrude(height = bezel_h)
            square([window_L + 2*bezel_t, window_W + 2*bezel_t], center = true);
        translate([0, 0, -0.01])
            linear_extrude(height = bezel_h + 0.02)
                square([window_L, window_W], center = true);
    }

    // Simple header body (for visualization)
    header_body_L = (header_pins - 1) * header_pitch + 5.0;
    header_body_W = 5.0;
    header_body_H = 4.0;

    color([0.1, 0.1, 0.1])
    translate([0, header_row_y, T])
        translate([0, 0, header_body_H/2])
            cube([header_body_L, header_body_W, header_body_H], center = true);

    // Pins
    color([0.8, 0.7, 0.2])
    for (i = [0 : header_pins - 1]) {
        x = (i - (header_pins - 1)/2) * header_pitch;
        translate([x, header_row_y, T])
            cylinder(d = 0.8, h = 6.0);
    }
}

display_module_v3();