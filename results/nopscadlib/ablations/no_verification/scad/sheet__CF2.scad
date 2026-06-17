// Sheet: carbon fiber (visual approximation via dark color + subtle surface grooves)

// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 10; //[0:25:1]
hole_diameter = 6;  //[0:12:0.5]
hole_edge_offset = 15; //[0:40:1]

// Quality
$fn = 96;

// Small overlap to avoid coplanar/zero-thickness artifacts in booleans
eps = 0.02;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded rectangle 2D profile (robust, single connected solid after linear_extrude)
module rounded_rect_2d(L, W, R) {
    R2 = clamp(R, 0, min(L, W)/2);
    if (R2 <= 0) {
        square([L, W], center=true);
    } else {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                    circle(r=R2);
        }
    }
}

module mounting_holes_2d(L, W, off, d) {
    if (d > 0) {
        r = d/2;
        ox = clamp(off, r, L/2 - r);
        oy = clamp(off, r, W/2 - r);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - ox), sy*(W/2 - oy)])
                circle(r=r);
    }
}

// Subtle "carbon fiber" surface grooves (kept shallow so sheet remains one solid)
module carbon_grooves(L, W, t) {
    groove_depth = min(0.12, t*0.18);
    if (groove_depth > 0) {
        pitch = 6;
        groove_w = 0.6;
        // Cut shallow grooves on top face only
        translate([0, 0, t/2 - groove_depth/2 + eps])
        union() {
            // +45 deg
            rotate([0, 0, 45])
                for (i = [-ceil((L+W)/pitch) : ceil((L+W)/pitch)])
                    translate([i*pitch, 0, 0])
                        cube([groove_w, (L+W)*2, groove_depth + 2*eps], center=true);
            // -45 deg
            rotate([0, 0, -45])
                for (i = [-ceil((L+W)/pitch) : ceil((L+W)/pitch)])
                    translate([i*pitch, 0, 0])
                        cube([groove_w, (L+W)*2, groove_depth + 2*eps], center=true);
        }
    }
}

// Final sheet (single connected solid)
module sheet_final() {
    difference() {
        // Main solid
        linear_extrude(height=sheet_thickness, center=true, convexity=10)
            difference() {
                rounded_rect_2d(sheet_length, sheet_width, corner_radius);
                mounting_holes_2d(sheet_length, sheet_width, hole_edge_offset, hole_diameter);
            }

        // Visual surface texture (shallow cuts)
        carbon_grooves(sheet_length, sheet_width, sheet_thickness);
    }
}

// Render
color([0.08, 0.08, 0.09]) sheet_final();