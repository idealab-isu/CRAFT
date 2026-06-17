// Sheet DiBond (aluminum composite panel) with rounded corners and mounting holes.
// Single connected solid (one extruded body) for reliable rendering.

// ---------- Parameters ----------
sheet_length = 1000; //[500:2000:1]
sheet_width  = 500;  //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.1]

corner_radius = 10;  //[0:50:1]

hole_diameter = 6;   //[2:20:0.5]
hole_edge_offset = 25; //[10:100:1]

overlap = 0.5;       //[0.1:2:0.1]

$fn = 64;

// ---------- Helpers ----------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

L = sheet_length;
W = sheet_width;
T = sheet_thickness;

r = clamp(corner_radius, 0, min(L, W)/2 - 0.01);
hole_r = hole_diameter/2;

// Keep holes inside the panel
hole_off = clamp(hole_edge_offset, hole_r + 0.5, min(L, W)/2 - hole_r - 0.5);

// ---------- 2D Profile ----------
module rounded_rect_2d(len, wid, rad) {
    rad2 = clamp(rad, 0, min(len, wid)/2);
    if (rad2 <= 0) {
        square([len, wid], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(len/2 - rad2), sy*(wid/2 - rad2)])
                    circle(r=rad2);
        }
    }
}

module holes_2d() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(L/2 - hole_off), sy*(W/2 - hole_off)])
            circle(r=hole_r);
}

// ---------- Final Solid ----------
linear_extrude(height=T, center=true, convexity=10)
difference() {
    rounded_rect_2d(L, W, r);
    holes_2d();
}