// Parameters
sheet_length = 100;
sheet_width = 50;
sheet_thickness = 2;
corner_radius = 5;
hole_diameter = 3;
chamfer_size = 1; // simplified: used as a small edge inset (no 3D chamfer hull)

$fn = 32;

// 2D rounded rectangle (centered) using offset (fast)
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    offset(r=R2)
        square([max(0.01, L - 2*R2), max(0.01, W - 2*R2)], center=true);
}

// Main sheet solid (3D)
module sheet_solid() {
    linear_extrude(height=sheet_thickness, center=true, convexity=5)
        rounded_rect_2d(sheet_length, sheet_width, corner_radius);
}

// Mounting holes (through)
module mounting_holes() {
    hole_h = sheet_thickness + 2; // ensure full cut
    for (x = [-sheet_length/4, sheet_length/4])
        for (y = [-sheet_width/4, sheet_width/4])
            translate([x, y, 0])
                cylinder(h=hole_h, d=hole_diameter, center=true);
}

// Simplified edge detail: shallow inset pocket on top face (fast, avoids hull)
module edge_inset_pocket() {
    inset = max(0, chamfer_size);
    if (inset > 0) {
        pocket_depth = min(sheet_thickness*0.35, inset); // shallow
        translate([0,0, sheet_thickness/2 - pocket_depth/2])
            linear_extrude(height=pocket_depth, center=true, convexity=5)
                rounded_rect_2d(
                    sheet_length - 2*inset,
                    sheet_width  - 2*inset,
                    max(corner_radius - inset, 0)
                );
    }
}

// Assemble
difference() {
    sheet_solid();
    mounting_holes();
    edge_inset_pocket();
}