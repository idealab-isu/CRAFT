$fn = 128;

// Target dimensions (overall)
height_mm   = 70.7;
diameter_mm = 18.4;
radius_mm   = diameter_mm/2;

// Terminal features (included in overall height)
positive_terminal_height_mm   = 1.5;
positive_terminal_diameter_mm = 6;

negative_terminal_height_mm   = 0.2;
negative_terminal_diameter_mm = 10;

// Edge rounding + connectivity overlap
edge_fillet_radius_mm = 0.5;
connect_overlap_mm    = 0.8;

// Derived body height so total height matches exactly
body_height_mm = height_mm - positive_terminal_height_mm - negative_terminal_height_mm;

// Clamp fillets to valid ranges
fillet_body = min(edge_fillet_radius_mm, min(radius_mm, body_height_mm/2) - 0.01);
fillet_pos  = min(edge_fillet_radius_mm,
                  min(positive_terminal_diameter_mm/2, positive_terminal_height_mm/2) - 0.01);

// Rounded cylinder helper (centered)
module rounded_cylinder(r, h, fillet_r) {
    minkowski() {
        cylinder(r = r - fillet_r, h = h - 2*fillet_r, center = true);
        sphere(r = fillet_r);
    }
}

// Battery cell body (centered at origin)
module cylindrical_cell_body() {
    rounded_cylinder(radius_mm, body_height_mm, fillet_body);
}

// Positive terminal button (+Z end), connected with overlap
module positive_terminal_button() {
    translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - connect_overlap_mm])
        rounded_cylinder(positive_terminal_diameter_mm/2, positive_terminal_height_mm, fillet_pos);
}

// Negative terminal flat end (-Z end), connected with overlap
module negative_terminal_flat_end() {
    translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + connect_overlap_mm])
        cylinder(r = negative_terminal_diameter_mm/2, h = negative_terminal_height_mm, center = true);
}

// Complete battery assembly (one connected solid)
union() {
    cylindrical_cell_body();
    positive_terminal_button();
    negative_terminal_flat_end();
}