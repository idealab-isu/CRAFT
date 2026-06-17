// Parameters
plate_length = 200; // Length of the plate
plate_width = 100;  // Width of the plate
plate_thickness = 10; // Thickness of the plate
chamfer_size = 1;   // Size of the edge chamfer
corner_radius = 5;  // Radius of the corners
hole_diameter = 5;  // Diameter of the mounting holes
hole_spacing_x = 150; // Spacing of holes along the length
hole_spacing_y = 50;  // Spacing of holes along the width
label_text = "Tooling Plate"; // Text for engraving
label_depth = 0.5;   // Depth of the engraving

// Main function
module tooling_plate() {
    difference() {
        // Plate with rounded corners
        offset(r=corner_radius) {
            square([plate_length - 2*corner_radius, plate_width - 2*corner_radius], center=true);
        }
        // Chamfer the edges
        offset(delta=-chamfer_size) {
            offset(r=corner_radius) {
                square([plate_length - 2*corner_radius, plate_width - 2*corner_radius], center=true);
            }
        }
        // Mounting holes
        for (x = [-hole_spacing_x/2, hole_spacing_x/2])
            for (y = [-hole_spacing_y/2, hole_spacing_y/2])
                translate([x, y, -1])
                    cylinder(h=plate_thickness + 2, d=hole_diameter, center=true);
    }
}

// Engraved label
module engraved_label() {
    translate([0, 0, -label_depth])
        linear_extrude(height=label_depth)
            text(label_text, size=10, halign="center", valign="center");
}

// Assemble the model
tooling_plate();
translate([0, 0, plate_thickness/2])
    engraved_label();