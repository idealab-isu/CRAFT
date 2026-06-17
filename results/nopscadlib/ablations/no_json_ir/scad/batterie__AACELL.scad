// Cylindrical battery cell model

// Parameters
battery_height = 50.5;
battery_diameter = 14.5;
positive_terminal_height = 1.5;
positive_terminal_diameter = 5;
negative_terminal_height = 0.5;

// Main battery body
module cylindrical_cell_body() {
    cylinder(h = battery_height - positive_terminal_height, d = battery_diameter, center = false);
}

// Positive terminal button
module positive_terminal_button() {
    translate([0, 0, battery_height - positive_terminal_height])
        cylinder(h = positive_terminal_height, d = positive_terminal_diameter, center = false);
}

// Negative terminal flat end
module negative_terminal_flat_end() {
    translate([0, 0, -negative_terminal_height])
        cylinder(h = negative_terminal_height, d = battery_diameter, center = false);
}

// Complete battery model
module battery() {
    cylindrical_cell_body();
    positive_terminal_button();
    negative_terminal_flat_end();
}

// Render the battery
battery();