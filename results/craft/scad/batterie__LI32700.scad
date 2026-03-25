$fn = 128;

// Target overall size
height_mm   = 70.2;
diameter_mm = 32.4;
radius_mm   = diameter_mm/2;

// Terminals
positive_terminal_diameter_mm = 10;
positive_terminal_height_mm   = 1.5;

negative_terminal_diameter_mm = 12;
negative_terminal_height_mm   = 0.2;

// Edge rounding + connectivity
edge_fillet_radius_mm = 0.5;
connect_overlap_mm    = 0.8;

// Derived: make total height match exactly (body + terminals - overlaps)
body_height_mm = height_mm - positive_terminal_height_mm - negative_terminal_height_mm + 2*connect_overlap_mm;

// Rounded cylinder body (single solid)
module battery_cell_body() {
    minkowski() {
        cylinder(
            r = max(0.01, radius_mm - edge_fillet_radius_mm),
            h = max(0.01, body_height_mm - 2*edge_fillet_radius_mm),
            center = true
        );
        sphere(r = edge_fillet_radius_mm);
    }
}

module positive_terminal_bump() {
    translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - connect_overlap_mm])
        cylinder(r = positive_terminal_diameter_mm/2, h = positive_terminal_height_mm, center = true);
}

module negative_terminal_flat() {
    translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + connect_overlap_mm])
        cylinder(r = negative_terminal_diameter_mm/2, h = negative_terminal_height_mm, center = true);
}

union() {
    battery_cell_body();
    positive_terminal_bump();
    negative_terminal_flat();
}