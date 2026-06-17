$fn = 128;

// HT pipe parameters (approximate for HT 110)
outer_d = 110;        // mm
wall_thickness = 3.2; // mm (typical for HT 110; adjust if needed)
length = 2000;        // mm

inner_d = outer_d - 2 * wall_thickness;

difference() {
    cylinder(h = length, d = outer_d, center = false);
    translate([0, 0, -0.5])
        cylinder(h = length + 1, d = inner_d, center = false);
}