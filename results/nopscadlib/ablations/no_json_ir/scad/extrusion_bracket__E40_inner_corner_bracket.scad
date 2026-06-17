// Extrusion bracket overall size (X,Y,Z) = [38, 31, 8.5]
length = 38;
width  = 31;
thickness = 8.5;

// Bracket style parameters (kept within overall envelope)
corner_r = 3;          // rounded outer corners
hole_d = 5;            // through holes
hole_edge = 7;         // hole center distance from each outer edge
relief_w = 10;         // clearance relief width
relief_d = 3.5;        // clearance relief depth (into thickness)
$fn = 64;

module rounded_plate_xy(L, W, H, R) {
    // 2D rounded rectangle extruded to thickness
    linear_extrude(height=H)
        hull() {
            translate([R,     R])     circle(r=R);
            translate([L - R, R])     circle(r=R);
            translate([R,     W - R]) circle(r=R);
            translate([L - R, W - R]) circle(r=R);
        }
}

module extrusion_bracket() {
    eps = 0.02;

    difference() {
        // Main connected solid (single body)
        rounded_plate_xy(length, width, thickness, corner_r);

        // 4 mounting holes (typical corner bracket pattern)
        for (x = [hole_edge, length - hole_edge])
            for (y = [hole_edge, width - hole_edge])
                translate([x, y, thickness/2])
                    cylinder(h=thickness + 2*eps, d=hole_d, center=true);

        // Clearance reliefs on underside (do not cut through)
        // Long relief along X, centered in Y
        translate([0, (width - relief_w)/2, thickness - relief_d])
            cube([length, relief_w, relief_d + eps], center=false);

        // Long relief along Y, centered in X
        translate([(length - relief_w)/2, 0, thickness - relief_d])
            cube([relief_w, width, relief_d + eps], center=false);
    }
}

extrusion_bracket();