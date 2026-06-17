// Battery cell (single connected solid)
// Fixes: bottom thin ring/edge floating + small gap by making the bottom face
// overlap into the main body and uniting all parts.

$fn = 128;

// Parameters (as requested)
battery_height = 50.0;      // Overall height
battery_diameter = 26.2;    // Outer diameter
terminal_button_height = 2; // Height of the positive terminal button
terminal_button_diameter = 5; // Diameter of the positive terminal button

// Connectivity controls
overlap = 1.5;              // 1–2mm overlap to guarantee attachment
bottom_face_thickness = 1.0; // Make the bottom "ring/edge" a real attached feature

// Main battery cell body (centered)
module cylindrical_cell_body() {
    // Body height excludes the button height, centered at origin
    cylinder(h = battery_height - terminal_button_height, d = battery_diameter, center = true);
}

// Positive terminal button (top), overlapped into body
module positive_terminal_button() {
    // Place so it intersects the top of the body by 'overlap'
    // Body top Z = (battery_height - terminal_button_height)/2
    translate([0, 0, (battery_height - terminal_button_height)/2 + terminal_button_height/2 - overlap])
        cylinder(h = terminal_button_height, d = terminal_button_diameter, center = true);
}

// Negative terminal contact face (bottom), thickened and overlapped into body
module negative_terminal_contact_face() {
    // Body bottom Z = -(battery_height - terminal_button_height)/2
    // Place a thin disk so it intersects the body by 'overlap'
    translate([0, 0, -(battery_height - terminal_button_height)/2 - bottom_face_thickness/2 + overlap])
        cylinder(h = bottom_face_thickness, d = battery_diameter, center = true);
}

// Complete battery model (single solid)
module battery() {
    union() {
        cylindrical_cell_body();
        positive_terminal_button();
        negative_terminal_contact_face();
    }
}

// Render the battery
battery();