// Sheet acrylic (rounded rectangle with 4 mounting holes)
// Fixed: robust rounded corners via hull(), proper chamfer via minkowski(),
// no near-zero thickness artifacts, one connected solid.

$fn = 96;

// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6;  //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
chamfer_size = 1;   //[0.5:3:0.25]

// Small tolerance
eps = 0.02;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

corner_r = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2 - eps);
hole_r   = hole_diameter/2;

// Keep holes inside the rounded area
hole_off = clamp(hole_edge_offset, hole_r + eps, min(sheet_length, sheet_width)/2 - corner_r - hole_r - eps);

// Chamfer limited to half thickness and corner radius
ch = clamp(chamfer_size, 0, min(sheet_thickness/2 - eps, corner_r - eps));

// 2D rounded rectangle
module rounded_rect_2d(L, W, R) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R)])
                circle(r=R);
    }
}

// Base sheet (no chamfer)
module sheet_base() {
    linear_extrude(height=sheet_thickness, center=true)
        rounded_rect_2d(sheet_length, sheet_width, corner_r);
}

// Chamfered sheet using minkowski with a small "diamond" in Z
module sheet_chamfered() {
    if (ch <= 0) {
        sheet_base();
    } else {
        minkowski() {
            // Shrink base so final outer size remains correct after minkowski
            linear_extrude(height=sheet_thickness - 2*ch, center=true)
                rounded_rect_2d(sheet_length - 2*ch, sheet_width - 2*ch, corner_r - ch);

            // Diamond (45°) in Z to create chamfer
            rotate([0, 45, 0])
                cube([2*ch, 2*ch, 2*ch], center=true);
        }
    }
}

// Mounting holes (through)
module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(sheet_length/2 - hole_off), sy*(sheet_width/2 - hole_off), 0])
            cylinder(r=hole_r, h=sheet_thickness + 2*eps, center=true);
}

// Final Output (one connected solid)
difference() {
    sheet_chamfered();
    mounting_holes();
}