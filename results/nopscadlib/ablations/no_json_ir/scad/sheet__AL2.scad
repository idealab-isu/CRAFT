// Parameters
plate_length = 200; // Length of the plate in mm
plate_width = 100;  // Width of the plate in mm
plate_thickness = 10; // Thickness of the plate in mm
chamfer_size = 2; // Size of the chamfer on edges
corner_radius = 5; // Radius for corner rounding
mounting_hole_diameter = 5; // Diameter of mounting holes
mounting_hole_spacing = 50; // Spacing between mounting holes
label_text = "Aluminium Plate"; // Text for engraving

// Main function to create the tooling plate
module tooling_plate() {
    difference() {
        // Base plate with corner rounding
        offset(r=corner_radius) {
            square([plate_length - 2*corner_radius, plate_width - 2*corner_radius], center=true);
        }
        // Chamfer the edges
        offset(delta=-chamfer_size) {
            square([plate_length, plate_width], center=true);
        }
        // Extrude to thickness
        linear_extrude(height=plate_thickness) {
            offset(r=corner_radius) {
                square([plate_length - 2*corner_radius, plate_width - 2*corner_radius], center=true);
            }
        }
        // Mounting holes pattern
        translate([-plate_length/2 + mounting_hole_spacing/2, -plate_width/2 + mounting_hole_spacing/2, 0])
        for (x = [0 : mounting_hole_spacing : plate_length - mounting_hole_spacing])
            for (y = [0 : mounting_hole_spacing : plate_width - mounting_hole_spacing])
                translate([x, y, 0])
                    cylinder(h=plate_thickness + 1, d=mounting_hole_diameter, center=true);
    }
}

// Engraved label
module engraved_label() {
    translate([0, 0, plate_thickness/2])
    linear_extrude(height=0.5)
    text(label_text, size=5, valign="center", halign="center");
}

// Surface finish marking (simple pattern)
module surface_finish() {
    translate([0, 0, plate_thickness])
    for (x = [-plate_length/2 : 10 : plate_length/2])
        for (y = [-plate_width/2 : 10 : plate_width/2])
            translate([x, y, 0])
                rotate([0, 0, 45])
                    square([2, 0.5], center=true);
}

// Assemble the tooling plate
tooling_plate();
engraved_label();
surface_finish();