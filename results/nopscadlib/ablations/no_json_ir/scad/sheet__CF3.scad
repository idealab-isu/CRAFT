// Parameters
length = 100; // Length of the sheet
width = 50; // Width of the sheet
thickness = 2; // Thickness of the sheet
corner_radius = 5; // Radius for rounded corners
edge_chamfer = 1; // Chamfer size for edges
hole_diameter = 5; // Diameter of mounting holes
hole_spacing = 20; // Spacing between holes
label_text = "Carbon Fiber Sheet"; // Text for engraving

// Main module
module carbon_fiber_sheet() {
    // Base plate with rounded corners
    difference() {
        offset(r=corner_radius) {
            square([length - 2*corner_radius, width - 2*corner_radius], center=true);
        }
        translate([0, 0, -1])
            offset(delta=-edge_chamfer)
                square([length, width], center=true);
    }
    
    // Mounting holes
    for (x = [-hole_spacing, hole_spacing])
        for (y = [-hole_spacing, hole_spacing])
            translate([x, y, thickness/2])
                cylinder(h=thickness+1, d=hole_diameter, center=true);
    
    // Engraved label
    translate([0, 0, thickness/2])
        linear_extrude(height=0.5)
            text(label_text, size=5, halign="center", valign="center");
}

// Render the model
carbon_fiber_sheet();