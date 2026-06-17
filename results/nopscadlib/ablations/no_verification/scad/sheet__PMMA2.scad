// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150;  //[75:300:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 10; //[5:20:1]
hole_diameter = 6;  //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
chamfer_size = 1;   //[0.5:3:0.25]
eps = 0.01;         //[0.005:0.05:0.005]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep parameters valid so geometry never disappears
cr = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2 - eps);
ho = clamp(hole_edge_offset, hole_diameter/2 + eps, min(sheet_length, sheet_width)/2 - eps);
ch = clamp(chamfer_size, 0, sheet_thickness/2 - eps);

// Rounded rectangle 2D profile
module rounded_rect_2d(L, W, R) {
    if (R <= 0)
        square([L, W], center=true);
    else
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - R), sy*(W/2 - R)])
                    circle(r=R, $fn=64);
        }
}

// Main sheet (single connected solid) with rounded corners, holes, and optional chamfer
module acrylic_sheet() {
    difference() {
        // Base solid
        linear_extrude(height=sheet_thickness, center=true, convexity=10)
            rounded_rect_2d(sheet_length, sheet_width, cr);

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(sheet_length/2 - ho), sy*(sheet_width/2 - ho), 0])
                cylinder(h=sheet_thickness + 2*eps, r=hole_diameter/2, center=true, $fn=64);

        // Edge chamfer (implemented as top/bottom bevel cuts)
        if (ch > 0) {
            // Top bevel cut
            translate([0, 0, sheet_thickness/2 - ch/2])
                linear_extrude(height=ch + 2*eps, center=true, convexity=10, scale=[
                    (sheet_length - 2*ch)/sheet_length,
                    (sheet_width  - 2*ch)/sheet_width
                ])
                    rounded_rect_2d(sheet_length, sheet_width, cr);

            // Bottom bevel cut
            translate([0, 0, -sheet_thickness/2 + ch/2])
                linear_extrude(height=ch + 2*eps, center=true, convexity=10, scale=[
                    (sheet_length - 2*ch)/sheet_length,
                    (sheet_width  - 2*ch)/sheet_width
                ])
                    rounded_rect_2d(sheet_length, sheet_width, cr);
        }
    }
}

// Final Output
color([0.85, 0.85, 0.8])
acrylic_sheet();