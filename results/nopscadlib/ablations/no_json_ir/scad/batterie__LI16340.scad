// Parameters for the battery cell
battery_diameter = 18; // Diameter of the battery
battery_height = 65;   // Total height of the battery

// Parameters for the positive terminal
positive_terminal_diameter = 5;
positive_terminal_height = 2;

// Parameters for the negative terminal
negative_terminal_diameter = 16;
negative_terminal_height = 1;

// Function to create the cylindrical cell body
module cylindrical_cell_body() {
    cylinder(d = battery_diameter, h = battery_height - positive_terminal_height - negative_terminal_height, center = true);
}

// Function to create the positive terminal button
module positive_terminal_button() {
    translate([0, 0, battery_height/2 - positive_terminal_height/2])
        cylinder(d = positive_terminal_diameter, h = positive_terminal_height, center = true);
}

// Function to create the negative terminal contact
module negative_terminal_contact() {
    translate([0, 0, -battery_height/2 + negative_terminal_height/2])
        cylinder(d = negative_terminal_diameter, h = negative_terminal_height, center = true);
}

// Main battery module
module battery() {
    cylindrical_cell_body();
    positive_terminal_button();
    negative_terminal_contact();
}

// Render the battery
battery();