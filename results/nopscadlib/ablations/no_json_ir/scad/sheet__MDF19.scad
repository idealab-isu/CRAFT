// Parameters
sheet_length = 100;
sheet_width = 50;
sheet_thickness = 2;
corner_radius = 5;
hole_diameter = 3;
chamfer_size = 1;

// Main module
module sheet_body() {
    difference() {
        // Base rectangle with rounded corners
        offset(r=corner_radius) {
            square([sheet_length - 2*corner_radius, sheet_width - 2*corner_radius], center=true);
        }
        // Mounting holes
        for (x = [-sheet_length/2 + corner_radius, sheet_length/2 - corner_radius])
            for (y = [-sheet_width/2 + corner_radius, sheet_width/2 - corner_radius])
                translate([x, y, 0])
                    cylinder(h=sheet_thickness + 1, d=hole_diameter, center=true);
    }
}

// Chamfer edges
module chamfer_edges() {
    linear_extrude(height=sheet_thickness)
        offset(delta=-chamfer_size)
            offset(r=corner_radius + chamfer_size) {
                square([sheet_length - 2*(corner_radius + chamfer_size), sheet_width - 2*(corner_radius + chamfer_size)], center=true);
            }
}

// Combine all parts
union() {
    sheet_body();
    chamfer_edges();
}