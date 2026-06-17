// Aluminium tooling plate (single connected solid with through mounting holes)

// Parameters
plate_L = 300; //[150:600:1]
plate_W = 200; //[100:400:1]
plate_T = 12;  //[6:24:1]

edge_margin = 20;     //[10:40:1]
mount_hole_d = 10;    //[5:20:1]

corner_fillet_r = 0;  //[0:10:1]
edge_chamfer = 0;     //[0:3:0.5]

connect_overlap = 1;  //[0.5:2:0.5]
$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep features valid for given plate size
fillet_r = clamp(corner_fillet_r, 0, min(plate_L, plate_W)/2 - 0.01);
chamfer  = clamp(edge_chamfer, 0, min(plate_L, plate_W)/2 - 0.01);

// 2D rounded rectangle for robust, non-blank rendering
module rounded_rect_2d(L, W, r) {
    if (r <= 0) {
        square([L, W], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - r), sy*(W/2 - r)]) circle(r=r);
        }
    }
}

// Base plate (optionally filleted corners)
module plate_body() {
    linear_extrude(height=plate_T, center=true, convexity=10)
        rounded_rect_2d(plate_L, plate_W, fillet_r);
}

// Optional edge chamfer (top & bottom) while keeping one connected solid
module plate_with_optional_chamfer() {
    if (chamfer <= 0) {
        plate_body();
    } else {
        // Create a simple 45°-ish chamfer by hulling a slightly smaller top/bottom profile
        hull() {
            translate([0, 0, -plate_T/2])
                linear_extrude(height=connect_overlap, center=false, convexity=10)
                    rounded_rect_2d(plate_L, plate_W, fillet_r);

            translate([0, 0, -plate_T/2 + chamfer])
                linear_extrude(height=plate_T - 2*chamfer, center=false, convexity=10)
                    rounded_rect_2d(plate_L - 2*chamfer, plate_W - 2*chamfer, max(fillet_r - chamfer, 0));

            translate([0, 0, plate_T/2 - connect_overlap])
                linear_extrude(height=connect_overlap, center=false, convexity=10)
                    rounded_rect_2d(plate_L, plate_W, fillet_r);
        }
    }
}

// Through holes (subtractive)
module mounting_holes() {
    hole_h = plate_T + 2*connect_overlap; // guaranteed to cut through
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(plate_L/2 - edge_margin), sy*(plate_W/2 - edge_margin), 0])
            cylinder(d=mount_hole_d, h=hole_h, center=true);
    }
}

// Final model: ONE connected solid
difference() {
    plate_with_optional_chamfer();
    mounting_holes();
}