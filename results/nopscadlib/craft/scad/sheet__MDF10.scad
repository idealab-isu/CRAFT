// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150;  //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 10; //[3:25:1]
hole_diameter = 6;  //[3:12:0.5]
edge_margin = 15;   //[8:40:1]

// Quality
$fn = 64;

// Small overlap to avoid coplanar/blank render artifacts
eps = 0.01;

// Derived / clamped values to keep geometry valid
cr = min(corner_radius, min(sheet_length, sheet_width)/2 - eps);
em = min(edge_margin, min(sheet_length, sheet_width)/2 - hole_diameter/2 - eps);

// Rounded rectangle sheet (single solid before holes)
module rounded_sheet() {
    // Use hull of 4 corner cylinders to create a proper rounded-rectangle prism
    hull() {
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(sheet_length/2 - cr), sy*(sheet_width/2 - cr), 0])
                cylinder(r=cr, h=sheet_thickness, center=true);
        }
    }
}

module mounting_holes() {
    // Through-holes, slightly longer than thickness to guarantee clean subtraction
    hole_h = sheet_thickness + 2*eps;
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(sheet_length/2 - em), sy*(sheet_width/2 - em), 0])
            cylinder(r=hole_diameter/2, h=hole_h, center=true);
    }
}

// Final model: one connected solid (sheet with holes)
difference() {
    rounded_sheet();
    mounting_holes();
}