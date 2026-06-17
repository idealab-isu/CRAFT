// Parameters
sheet_L = 600; //[300:1200:1]
sheet_W = 400; //[200:800:1]
sheet_T = 18;  //[9:36:1]
corner_R = 8;  //[2:20:1]
chamfer_C = 1.5; //[0.5:4:0.5]
texture_depth = 0.3; //[0.1:1:0.1]
texture_pitch = 12; //[6:30:1]
texture_groove_W = 1.2; //[0.6:3:0.1]
texture_margin = 10; //[5:30:1]
overlap = 1; //[0.5:2:0.5]

$fn = 64;

// Base
module mdf_sheet_panel() {
    cube([sheet_L, sheet_W, sheet_T], center=true);
}

// Rounded-rectangle outline (2D), then extrude to thickness
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                circle(r=R2);
    }
}

// Chamfer cutters (remove material along edges)
module chamfer_cutters() {
    // Long edges (along Y), cutters placed at +/-X faces
    for (sx = [-1, 1])
        translate([sx*(sheet_L/2 - chamfer_C/2), 0, 0])
            rotate([0, 45, 0])
                cube([chamfer_C, sheet_W + 2*overlap, sheet_T + 2*overlap], center=true);

    // Short edges (along X), cutters placed at +/-Y faces
    for (sy = [-1, 1])
        translate([0, sy*(sheet_W/2 - chamfer_C/2), 0])
            rotate([45, 0, 0])
                cube([sheet_L + 2*overlap, chamfer_C, sheet_T + 2*overlap], center=true);
}

// Surface texture grooves (subtractive), repeated across width
module surface_texture_grain() {
    zpos = sheet_T/2 - (texture_depth + overlap)/2; // slightly into top face
    usable_W = sheet_W - 2*texture_margin;
    n = floor(usable_W / texture_pitch);
    for (i = [-n/2 : n/2]) {
        y = i * texture_pitch;
        if (abs(y) <= usable_W/2 + 1e-6)
            translate([0, y, zpos])
                cube([sheet_L - 2*texture_margin, texture_groove_W, texture_depth + overlap], center=true);
    }
}

// Final Output: one connected solid
difference() {
    // Main sheet with rounded corners
    linear_extrude(height=sheet_T, center=true)
        rounded_rect_2d(sheet_L, sheet_W, corner_R);

    // Edge chamfers
    chamfer_cutters();

    // Top surface grain
    surface_texture_grain();
}