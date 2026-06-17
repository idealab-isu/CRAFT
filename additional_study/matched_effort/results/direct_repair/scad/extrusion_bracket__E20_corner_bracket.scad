$fn = 64;

size = [28, 28, 20];   // overall bounding box [X,Y,Z]
wall = 3;              // wall thickness
leg = 18;              // length of each leg along X and Y
hole_d = 5.2;          // clearance hole
csk_d = 9.5;           // countersink diameter
csk_h = 2.5;           // countersink height
fillet_r = 2;          // outer corner fillet radius

module rounded_box(sz=[10,10,10], r=1){
    r2 = min(r, sz[0]/2, sz[1]/2);
    linear_extrude(height=sz[2])
        offset(r=r2)
            square([sz[0]-2*r2, sz[1]-2*r2], center=true);
}

module extrusion_bracket(){
    // L-bracket body (two legs)
    difference(){
        union(){
            // Outer shape with filleted outer corner
            translate([size[0]/2, size[1]/2, 0])
                rounded_box([size[0], size[1], size[2]], fillet_r);

            // Remove the missing quadrant to form an L (keep two legs)
            // We'll subtract a block from the top-right area leaving legs of length 'leg'
        }
        // Cut out the quadrant to make L shape
        translate([leg, leg, -0.1])
            cube([size[0]-leg+0.2, size[1]-leg+0.2, size[2]+0.2], center=false);

        // Hollow underside to create bracket walls (optional pocket)
        translate([wall, wall, wall])
            cube([size[0]-wall+0.01, size[1]-wall+0.01, size[2]-wall+0.2], center=false);

        // Through holes: one on each leg
        // X-leg hole
        translate([leg/2, wall + (leg-wall)/2, size[2]/2])
            rotate([90,0,0])
                cylinder(d=hole_d, h=size[1]+2, center=true);

        // Y-leg hole
        translate([wall + (leg-wall)/2, leg/2, size[2]/2])
            rotate([0,90,0])
                cylinder(d=hole_d, h=size[0]+2, center=true);

        // Countersinks on top face for both holes
        // X-leg countersink
        translate([leg/2, wall + (leg-wall)/2, size[2]-csk_h])
            rotate([90,0,0])
                cylinder(d1=csk_d, d2=hole_d, h=csk_h+0.01, center=false);

        // Y-leg countersink
        translate([wall + (leg-wall)/2, leg/2, size[2]-csk_h])
            rotate([0,90,0])
                cylinder(d1=csk_d, d2=hole_d, h=csk_h+0.01, center=false);
    }
}

extrusion_bracket();