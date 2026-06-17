// Sheet DiBond - corrected (non-blank, single connected solid)

// Parameters
sheet_length = 1000; //[500:2000:1]
sheet_width = 500;   //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.1]
corner_radius = 10;  //[0:40:1]
hole_diameter = 6;   //[2:12:0.5]
hole_edge_offset_x = 25; //[10:100:1]
hole_edge_offset_y = 25; //[10:100:1]
edge_chamfer = 1;    //[0:3:0.1]
overlap = 1;         //[0.5:2:0.1]

$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep radii/offsets valid
cr = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2);
hx = clamp(hole_edge_offset_x, hole_diameter/2 + 0.5, sheet_length/2 - hole_diameter/2 - 0.5);
hy = clamp(hole_edge_offset_y, hole_diameter/2 + 0.5, sheet_width/2  - hole_diameter/2 - 0.5);
ch = clamp(edge_chamfer, 0, min(sheet_thickness/2, min(sheet_length, sheet_width)/4));

// Rounded rectangle 2D profile
module rounded_rect_2d(L, W, R) {
    if (R <= 0) {
        square([L, W], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - R), sy*(W/2 - R)])
                    circle(r=R);
        }
    }
}

// Main solid sheet with rounded corners
module sheet_solid() {
    linear_extrude(height=sheet_thickness, center=true, convexity=10)
        rounded_rect_2d(sheet_length, sheet_width, cr);
}

// Mounting holes (4 corners)
module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(sheet_length/2 - hx), sy*(sheet_width/2 - hy), 0])
            cylinder(h=sheet_thickness + 2*overlap, r=hole_diameter/2, center=true);
}

// Edge chamfer cuts (simple corner bevels on top and bottom)
module chamfer_cuts() {
    if (ch > 0) {
        zc_top =  sheet_thickness/2 - ch/2;
        zc_bot = -sheet_thickness/2 + ch/2;

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(sheet_length/2 - ch/2), sy*(sheet_width/2 - ch/2), zc_top])
                rotate([0, 0, 45])
                    cube([2*ch, 2*ch, ch + 2*overlap], center=true);

            translate([sx*(sheet_length/2 - ch/2), sy*(sheet_width/2 - ch/2), zc_bot])
                rotate([0, 0, 45])
                    cube([2*ch, 2*ch, ch + 2*overlap], center=true);
        }
    }
}

// Final panel
difference() {
    sheet_solid();
    mounting_holes();
    chamfer_cuts();
}