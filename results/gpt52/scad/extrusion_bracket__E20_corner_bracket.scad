$fn=64;

size = [28,28,20];
wall = 4;
hole_d = 5.2;
hole_offset = 7;

module corner_bracket(sz=[28,28,20], w=4){
    difference(){
        union(){
            translate([-sz[0]/2, -sz[1]/2, 0]) cube([sz[0], sz[1], sz[2]], center=false);
            translate([-sz[0]/2, -sz[1]/2, 0]) cube([sz[0], sz[1], w], center=false);
            translate([-sz[0]/2, -sz[1]/2, 0]) cube([sz[0], w, sz[2]], center=false);
            translate([-sz[0]/2, -sz[1]/2, 0]) cube([w, sz[1], sz[2]], center=false);
        }
        translate([-sz[0]/2 + w, -sz[1]/2 + w, w])
            cube([sz[0]-w, sz[1]-w, sz[2]-w], center=false);

        for (x = [-sz[0]/2 + hole_offset, sz[0]/2 - hole_offset])
            for (y = [-sz[1]/2 + hole_offset, sz[1]/2 - hole_offset])
                translate([x, y, -0.1])
                    cylinder(d=hole_d, h=w+0.2, center=false);

        for (x = [-sz[0]/2 + hole_offset, sz[0]/2 - hole_offset])
            for (z = [hole_offset, sz[2] - hole_offset])
                translate([x, -sz[1]/2 + w/2, z])
                    rotate([90,0,0])
                        cylinder(d=hole_d, h=w+0.2, center=true);

        for (y = [-sz[1]/2 + hole_offset, sz[1]/2 - hole_offset])
            for (z = [hole_offset, sz[2] - hole_offset])
                translate([-sz[0]/2 + w/2, y, z])
                    rotate([0,90,0])
                        cylinder(d=hole_d, h=w+0.2, center=true);
    }
}

corner_bracket(size, wall);