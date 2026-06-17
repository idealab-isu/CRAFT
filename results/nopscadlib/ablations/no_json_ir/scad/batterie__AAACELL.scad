// Battery Cylindrical Cell Model

// Parameters
battery_height = 44.5;
battery_diameter = 10.5;
positive_terminal_height = 1.5;
positive_terminal_diameter = 4.0;

// Battery cylindrical body
module battery_cylindrical_body() {
    cylinder(h = battery_height - positive_terminal_height, d = battery_diameter, center = false);
}

// Positive terminal button
module positive_terminal_button() {
    translate([0, 0, battery_height - positive_terminal_height])
        cylinder(h = positive_terminal_height, d = positive_terminal_diameter, center = false);
}

// Negative terminal contact face
module negative_terminal_contact_face() {
    translate([0, 0, 0])
        cylinder(h = 0.1, d = battery_diameter, center = false);
}

// Complete battery model
module battery() {
    battery_cylindrical_body();
    positive_terminal_button();
    negative_terminal_contact_face();
}

// Render the battery
battery();