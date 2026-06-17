// A extrusion bracket overall size: [38, 31, 8.5] (L, W, T)

// Parameters
bracket_L = 38;   // X
bracket_W = 31;   // Y
bracket_T = 8.5;  // Z

// Feature parameters (kept proportional; do not change overall size)
corner_r = min(3, min(bracket_L, bracket_W)/6);
hole_d   = 5.2;                 // typical clearance
hole_off = 7;                   // offset from edges
csk_d    = 9.5;                 // countersink/counterbore diameter
csk_h    = min(2.2, bracket_T*0.35);

$fn = 64;

module rounded_plate(L, W, T, r) {
    // 2D rounded rectangle extruded to thickness T
    linear_extrude(height=T, center=true)
        offset(r=r)
            square([L-2*r, W-2*r], center=true);
}

module extrusion_bracket() {
    difference() {
        // Main connected solid body (not a flat 2D shape)
        rounded_plate(bracket_L, bracket_W, bracket_T, corner_r);

        // 4 through holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(bracket_L/2 - hole_off), sy*(bracket_W/2 - hole_off), 0])
                cylinder(h=bracket_T + 0.6, d=hole_d, center=true);

            // shallow counterbore on top face (still one connected solid after subtraction)
            translate([sx*(bracket_L/2 - hole_off), sy*(bracket_W/2 - hole_off),
                       bracket_T/2 - csk_h/2 + 0.01])
                cylinder(h=csk_h + 0.02, d=csk_d, center=true);
        }
    }
}

color("Silver") extrusion_bracket();