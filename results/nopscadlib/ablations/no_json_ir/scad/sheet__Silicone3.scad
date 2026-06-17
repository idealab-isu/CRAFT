// Parameters
length = 100; // Length of the sheet
width = 50;  // Width of the sheet
thickness = 2; // Thickness of the sheet
corner_radius = 5; // Radius for rounded corners
chamfer_size = 1; // Size of the chamfer
label_text = "Gasket"; // Text for embossed label
label_depth = 0.5; // Depth of the embossed label
texture_depth = 0.1; // Depth of surface texture

// Main module
module silicone_sheet() {
    difference() {
        // Base sheet with rounded corners
        offset(r=corner_radius) {
            square([length - 2*corner_radius, width - 2*corner_radius], center=true);
        }
        // Chamfer edges
        chamfer_edges();
    }
    // Embossed label
    translate([0, 0, thickness - label_depth])
        emboss_label();
    // Surface texture
    translate([0, 0, thickness - texture_depth])
        surface_texture();
}

// Chamfer edges
module chamfer_edges() {
    for (x = [-1, 1])
        for (y = [-1, 1])
            translate([x * (length/2 - chamfer_size), y * (width/2 - chamfer_size), 0])
                rotate([0, 0, 45])
                    cube([chamfer_size * sqrt(2), chamfer_size * sqrt(2), thickness], center=true);
}

// Embossed label
module emboss_label() {
    linear_extrude(height=label_depth)
        text(label_text, size=5, valign="center", halign="center");
}

// Surface texture
module surface_texture() {
    for (x = [-length/2:5:length/2])
        for (y = [-width/2:5:width/2])
            translate([x, y, 0])
                cylinder(r=0.5, h=texture_depth, center=true);
}

// Render the silicone sheet
silicone_sheet();