// Parameters
sheet_length = 200; // Length of the acrylic sheet
sheet_width = 100;  // Width of the acrylic sheet
sheet_thickness = 5; // Thickness of the acrylic sheet
corner_radius = 10;  // Radius for rounded corners
hole_diameter = 5;   // Diameter of mounting holes
chamfer_size = 2;    // Size of the edge chamfer
hole_offset = 15;    // Offset from the edges for mounting holes

// Main module
module acrylic_sheet() {
    difference() {
        // Base sheet with rounded corners
        rounded_rectangle(sheet_length, sheet_width, corner_radius, sheet_thickness);
        
        // Mounting holes
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x * (sheet_length / 2 - hole_offset), y * (sheet_width / 2 - hole_offset), 0])
                cylinder(h = sheet_thickness + 1, d = hole_diameter, center = true);
        }
    }
    // Edge chamfer
    chamfer_edges(sheet_length, sheet_width, sheet_thickness, chamfer_size);
}

// Function to create a rounded rectangle
module rounded_rectangle(length, width, radius, thickness) {
    minkowski() {
        cube([length - 2 * radius, width - 2 * radius, thickness], center = true);
        cylinder(r = radius, h = thickness, center = true);
    }
}

// Function to chamfer the edges
module chamfer_edges(length, width, thickness, chamfer) {
    translate([-length / 2, -width / 2, 0])
        offset(delta = -chamfer)
            offset(delta = chamfer)
                cube([length, width, thickness]);
}

// Render the acrylic sheet
acrylic_sheet();