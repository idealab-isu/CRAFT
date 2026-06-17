// Parameters for the cylindrical battery cell
battery_height = 70.7;
battery_diameter = 18.4;
terminal_button_height = 1.5;
terminal_button_diameter = 5.0;
negative_terminal_height = 0.5;

// Main battery cell body
module cylindrical_cell_body() {
    cylinder(h = battery_height, d = battery_diameter, center = true);
}

// Positive terminal button
module positive_terminal_button() {
    translate([0, 0, battery_height / 2])
        cylinder(h = terminal_button_height, d = terminal_button_diameter, center = false);
}

// Negative terminal flat end
module negative_terminal_flat_end() {
    translate([0, 0, -battery_height / 2])
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