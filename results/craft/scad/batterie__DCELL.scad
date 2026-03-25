// Battery cell: 61.5mm tall, 34.2mm diameter
$fn = 128;

// Parameters
body_height_mm = 61.5;
body_diameter_mm = 34.2;

positive_terminal_diameter_mm = 10;
positive_terminal_height_mm   = 1.5;

negative_terminal_diameter_mm = 12;
negative_terminal_height_mm   = 0.5;

connect_overlap_mm = 0.8;

// Body
module battery_cell_body() {
    cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true);
}

// Positive terminal (top), connected with overlap
module positive_terminal_cap() {
    translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - connect_overlap_mm])
        cylinder(r=positive_terminal_diameter_mm/2, h=positive_terminal_height_mm, center=true);
}

// Negative terminal (bottom), connected with overlap
module negative_terminal_contact() {
    translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + connect_overlap_mm])
        cylinder(r=negative_terminal_diameter_mm/2, h=negative_terminal_height_mm, center=true);
}

// Complete battery (one connected solid)
union() {
    battery_cell_body();
    positive_terminal_cap();
    negative_terminal_contact();
}