// PTFE tubing parameters
inner_diameter = 2.0; // Inner diameter in mm
outer_diameter = 4.0; // Outer diameter in mm
length = 100.0; // Length of the tubing in mm

// Material properties for PTFE (for reference, not used in rendering)
ptfe_density = 2.2; // g/cm^3
ptfe_color = [0.9, 0.9, 0.9]; // Approximate color for PTFE

// Function to create the tubing body
module tubing_body(inner_d, outer_d, len) {
    difference() {
        cylinder(h = len, d = outer_d, $fn = 100);
        translate([0, 0, -1]) // Slightly extend the inner cylinder to ensure proper subtraction
            cylinder(h = len + 2, d = inner_d, $fn = 100);
    }
}

// Main tubing module
module tubing() {
    color(ptfe_color)
        tubing_body(inner_diameter, outer_diameter, length);
}

// Render the tubing
tubing();