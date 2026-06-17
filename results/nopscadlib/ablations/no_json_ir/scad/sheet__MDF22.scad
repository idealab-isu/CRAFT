// Parameters for the MDF sheet
sheet_length = 200; // Length of the sheet in mm
sheet_width = 100;  // Width of the sheet in mm
sheet_thickness = 10; // Thickness of the sheet in mm

// Chamfer and rounding parameters
edge_chamfer = 2; // Chamfer size in mm
corner_rounding = 5; // Corner rounding radius in mm

// Function to create a chamfered and rounded rectangle
module mdf_sheet_panel() {
    difference() {
        offset(r = corner_rounding) {
            offset(delta = -corner_rounding) {
                square([sheet_length, sheet_width], center = true);
            }
        }
        offset(delta = -edge_chamfer) {
            square([sheet_length - 2 * edge_chamfer, sheet_width - 2 * edge_chamfer], center = true);
        }
    }
}

// Module to add material label text
module material_label_text() {
    translate([0, 0, sheet_thickness + 0.1]) // Slightly above the surface
    linear_extrude(height = 1) {
        text("MDF", size = 10, halign = "center", valign = "center");
    }
}

// Main model
translate([0, 0, sheet_thickness / 2])
    mdf_sheet_panel();

// Add material label
material_label_text();