// Cylindrical battery cell model (one connected solid)

// Parameters (mm)
battery_height = 70.2;
battery_diameter = 32.4;

terminal_button_height = 2;
terminal_button_diameter = 10;

negative_terminal_height = 1;

overlap = 0.2; // small overlap to guarantee connectivity

$fn = 128;

// Main battery body
module cylindrical_cell_body() {
    cylinder(h = battery_height, d = battery_diameter, center = true);
}

// Positive terminal button (connected to top face with overlap)
module positive_terminal_button() {
    translate([0, 0, battery_height/2 + terminal_button_height/2 - overlap])
        cylinder(h = terminal_button_height, d = terminal_button_diameter, center = true);
}

// Negative terminal flat end (slightly inset so it overlaps INTO the body)
module negative_terminal_flat_end() {
    translate([0, 0, -battery_height/2 + negative_terminal_height/2 - overlap])
        cylinder(h = negative_terminal_height, d = battery_diameter, center = true);
}

// Complete battery model (single connected solid)
module battery() {
    union() {
        cylindrical_cell_body();
        positive_terminal_button();
        negative_terminal_flat_end();
    }
}

battery();