$fn = 64;

// Parameters
sheet_length    = 200;
sheet_width     = 100;
sheet_thickness = 5;

corner_radius   = 5;   // rounded/chamfer-like corners (MDF sheet edge finish)
hole_diameter   = 3;
hole_edge_inset = 10;  // distance from each edge to hole center

// MDF-like color (visual only)
mdf_color = [0.78, 0.67, 0.50];

// 2D rounded rectangle (robust, non-blank)
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                circle(r = R2);
    }
}

// Main sheet solid
module sheet_solid() {
    linear_extrude(height = sheet_thickness, center = true)
        rounded_rect_2d(sheet_length, sheet_width, corner_radius);
}

// Mounting holes (through)
module holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([
            sx*(sheet_length/2 - hole_edge_inset),
            sy*(sheet_width/2  - hole_edge_inset),
            0
        ])
            cylinder(h = sheet_thickness + 0.2, d = hole_diameter, center = true);
    }
}

// Final model: one connected solid (sheet with holes)
color(mdf_color)
difference() {
    sheet_solid();
    holes();
}