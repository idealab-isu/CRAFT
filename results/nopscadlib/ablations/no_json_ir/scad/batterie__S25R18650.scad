// Parameters for the battery cell
battery_height = 65.0;
battery_diameter = 18.3;
terminal_button_height = 1.5;
terminal_button_diameter = 5.0;

// Main battery cell body
module cylindrical_cell_body() {
    cylinder(h = battery_height - terminal_button_height, d = battery_diameter, center = false);
}

// Positive terminal button
module positive_terminal_button() {
    translate([0, 0, battery_height - terminal_button_height])
        cylinder(h = terminal_button_height, d = terminal_button_diameter, center = false);
}

// Negative terminal endcap (flat)
module negative_terminal_endcap() {
    // The negative end is flat, so no additional geometry is needed
}

// Complete battery model
module battery() {
    cylindrical_cell_body();
    positive_terminal_button();
    negative_terminal_endcap();
}

// Render the battery
battery();