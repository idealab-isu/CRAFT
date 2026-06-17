$fn = 64;

size = [28, 28, 20];   // overall bounding box [X,Y,Z]
wall = 3;              // leg thickness (X and Y directions)
hole_d = 5;            // mounting hole diameter
hole_edge = 8;         // distance from outer edges to hole centers
fillet_r = 2;          // outer corner rounding

eps = 0.2;

module rounded_box(sz=[10,10,10], r=1){
    r2 = min(r, sz[0]/2, sz[1]/2);
    linear_extrude(height=sz[2], center=false, convexity=10)
        offset(r=r2)
            square([sz[0]-2*r2, sz[1]-2*r2], center=false);
}

module extrusion_bracket(){
    difference(){
        union(){
            // Leg along X (thickness in Y = wall)
            rounded_box([size[0], wall, size[2]], fillet_r);

            // Leg along Y (thickness in X = wall)
            rounded_box([wall, size[1], size[2]], fillet_r);

            // Ensure a robust connected solid at the inside corner
            cube([wall+eps, wall+eps, size[2]], center=false);
        }

        // Holes through Z on X-leg (two holes)
        for (xpos = [hole_edge, size[0]-hole_edge])
            translate([xpos, wall/2, -eps])
                cylinder(d=hole_d, h=size[2]+2*eps, center=false);

        // Hole through Z on Y-leg (one hole)
        translate([wall/2, size[1]-hole_edge, -eps])
            cylinder(d=hole_d, h=size[2]+2*eps, center=false);
    }
}

extrusion_bracket();