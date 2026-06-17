// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 10; //[5:20:1]
hole_diameter = 6;  //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
chamfer_size = 1;   //[0.5:3:0.25]
overlap = 1;        //[0.5:2:0.5]

$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep parameters valid
corner_r = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2);
hole_off = clamp(hole_edge_offset, hole_diameter/2 + 0.1, min(sheet_length, sheet_width)/2 - corner_r - 0.1);
chamfer = clamp(chamfer_size, 0, min(sheet_length, sheet_width, sheet_thickness)/2 - 0.01);

// Rounded rectangle sheet (single connected solid)
module rounded_sheet(L, W, T, R) {
    linear_extrude(height=T, center=true, convexity=10)
        offset(r=R)
            square([L - 2*R, W - 2*R], center=true);
}

module holes(L, W, T, off, d) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(L/2 - off), sy*(W/2 - off), 0])
            cylinder(h=T + 2*overlap, r=d/2, center=true);
}

// Simple edge chamfer by subtracting a slightly smaller rounded sheet
module chamfer_cut(L, W, T, R, c) {
    if (c > 0)
        translate([0, 0, c/2])
            linear_extrude(height=T + 2*overlap, center=true, convexity=10)
                offset(r=max(R - c, 0))
                    square([L - 2*R - 2*c, W - 2*R - 2*c], center=true);
}

// Final model
difference() {
    rounded_sheet(sheet_length, sheet_width, sheet_thickness, corner_r);
    holes(sheet_length, sheet_width, sheet_thickness, hole_off, hole_diameter);
    chamfer_cut(sheet_length, sheet_width, sheet_thickness, corner_r, chamfer);
}