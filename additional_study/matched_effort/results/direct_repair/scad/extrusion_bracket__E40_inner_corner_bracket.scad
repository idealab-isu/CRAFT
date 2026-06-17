$fn = 64;

size = [38, 31, 8.5];   // overall [X, Y, Z] in mm

// Bracket parameters (reasonable defaults for an extrusion-style corner bracket)
wall = 4;               // leg thickness
corner_r = 2;           // outer corner fillet radius (approx via minkowski)
hole_d = 5.2;           // clearance for M5
csk_d = 9.5;            // counterbore diameter
csk_depth = 3.0;        // counterbore depth
hole_offset = 12;       // distance from each outer edge to hole center

module rounded_block(sz, r=0) {
    if (r <= 0) {
        cube(sz, center=false);
    } else {
        minkowski() {
            cube([sz[0]-2*r, sz[1]-2*r, sz[2]-2*r], center=false);
            sphere(r=r);
        }
    }
}

module bracket() {
    difference() {
        // L-shape body
        union() {
            // Leg along X
            rounded_block([size[0], wall, size[2]], r=corner_r);
            // Leg along Y
            rounded_block([wall, size[1], size[2]], r=corner_r);
        }

        // Through holes (one per leg), with counterbore from top
        // Hole in X-leg
        translate([hole_offset, wall/2, 0])
            cylinder(h=size[2]+0.2, d=hole_d, center=false);

        translate([hole_offset, wall/2, size[2]-csk_depth])
            cylinder(h=csk_depth+0.3, d=csk_d, center=false);

        // Hole in Y-leg
        translate([wall/2, hole_offset, 0])
            cylinder(h=size[2]+0.2, d=hole_d, center=false);

        translate([wall/2, hole_offset, size[2]-csk_depth])
            cylinder(h=csk_depth+0.3, d=csk_d, center=false);
    }
}

bracket();