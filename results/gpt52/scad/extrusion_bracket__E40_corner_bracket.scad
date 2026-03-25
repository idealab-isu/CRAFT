$fn=64;

size = [40,40,35];

module extrusion_bracket(sz=[40,40,35], wall=4, rib=4, hole_d=6.5, hole_offset=12) {
    x=sz[0]; y=sz[1]; z=sz[2];

    difference() {
        union() {
            translate([-x/2, -y/2, 0]) cube([x, wall, z], center=false);
            translate([-x/2, -y/2, 0]) cube([wall, y, z], center=false);

            translate([-x/2, -y/2, 0])
                linear_extrude(height=z)
                    polygon(points=[[0,0],[x,0],[0,y]]);
            
            translate([-x/2, -y/2, 0])
                linear_extrude(height=z)
                    polygon(points=[[0,0],[x,0],[x,wall],[wall,wall],[wall,y],[0,y]]);
        }

        for (zz = [z*0.33, z*0.66]) {
            translate([0, -y/2 + wall/2, zz])
                rotate([90,0,0])
                    cylinder(h=wall+2, d=hole_d, center=true);

            translate([-x/2 + wall/2, 0, zz])
                rotate([0,90,0])
                    cylinder(h=wall+2, d=hole_d, center=true);
        }

        translate([hole_offset - x/2, -y/2 + wall/2, z/2])
            rotate([90,0,0])
                cylinder(h=wall+2, d=hole_d, center=true);

        translate([-x/2 + wall/2, hole_offset - y/2, z/2])
            rotate([0,90,0])
                cylinder(h=wall+2, d=hole_d, center=true);
    }
}

extrusion_bracket(size);