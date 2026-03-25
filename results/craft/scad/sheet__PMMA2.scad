// Parameters
sheet_length = 300; //[150:600:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]

// Render helpers
$fn = 96;

// Small bevel to create visible edges/highlights (still one connected solid)
bevel = min(0.6, sheet_thickness/3, sheet_length/200, sheet_width/200);

module acrylic_sheet() {
    // Acrylic-like tint + transparency
    color([0.92, 0.97, 1.00, 0.25])
    minkowski() {
        cube([sheet_length - 2*bevel, sheet_width - 2*bevel, sheet_thickness - 2*bevel], center=true);
        sphere(r=bevel);
    }
}

// Final Output
acrylic_sheet();