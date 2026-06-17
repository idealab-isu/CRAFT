$fn = 64;

size = [28, 28, 20];   // overall bounding box
wall = 4;              // bracket wall thickness
hole_d = 5;            // mounting hole diameter
hole_edge = 8;         // distance from outer edges to hole centers
fillet_r = 2;          // inner corner relief radius

module extrusion_bracket(sz=[28,28,20], wall=4, hole_d=5, hole_edge=8, fillet_r=2) {
    x = sz[0];
    y = sz[1];
    z = sz[2];

    difference() {
        // Outer solid
        cube([x, y, z], center=false);

        // L-shaped cavity (removes one quadrant, leaving two perpendicular legs)
        translate([wall, wall, -0.1])
            cube([x - wall + 0.2, y - wall + 0.2, z + 0.2], center=false);

        // Inner corner relief (quarter-cylinder) to reduce stress
        translate([wall, wall, -0.1])
            cylinder(h = z + 0.2, r = fillet_r, center=false);

        // Mounting holes: one on each leg
        // Hole through X-leg (along Y direction)
        translate([hole_edge, wall/2, z/2])
            rotate([90, 0, 0])
                cylinder(h = wall + 0.4, d = hole_d, center=true);

        // Hole through Y-leg (along X direction)
        translate([wall/2, hole_edge, z/2])
            rotate([0, 90, 0])
                cylinder(h = wall + 0.4, d = hole_d, center=true);
    }
}

extrusion_bracket(size, wall, hole_d, hole_edge, fillet_r);