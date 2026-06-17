// Parameters for the battery cell
battery_diameter = 18; // Diameter of the battery
battery_height = 65;   // Overall height of the battery

// Parameters for the positive terminal
positive_terminal_diameter = 6; // Diameter of the positive terminal button
positive_terminal_height = 2;   // Height of the positive terminal button

// Parameters for the negative terminal
negative_terminal_diameter = battery_diameter; // Diameter of the negative terminal flat contact
negative_terminal_height = 1; // Height of the negative terminal flat contact

// Main battery cell body
module cylindrical_cell_body() {
    cylinder(h = battery_height, d = battery_diameter, center = true);
}

// Positive terminal button
module positive_terminal_button() {
    translate([0, 0, battery_height / 2])
        cylinder(h = positive_terminal_height, d = positive_terminal_diameter, center = false);
}

// Negative terminal flat contact
module negative_terminal_flat_contact() {
    translate([0, 0, -battery_height / 2 - negative_terminal_height])
        cylinder(h = negative_terminal_height, d = negative_terminal_diameter, center = false);
}

// Complete battery model
module battery() {
    cylindrical_cell_body();
    positive_terminal_button();
    negative_terminal_flat_contact();
}

// Render the battery
battery();