module chamfered_cube(size, chamfer) {
    difference() {
        cube(size, center=true);
        for (x=[-1,1], y=[-1,1], z=[-1,1]) {
            translate([x*(size[0]/2-chamfer), y*(size[1]/2-chamfer), z*(size[2]/2-chamfer)])
                cube([chamfer*2, chamfer*2, chamfer*2], center=true);
        }
    }
}

module l_shaped_block() {
    difference() {
        union() {
            translate([-0.05, -0.05, -0.025])
                chamfered_cube([0.1, 0.1, 0.05], 0.005);
            translate([-0.025, -0.05, 0.025])
                chamfered_cube([0.05, 0.1, 0.05], 0.005);
        }
        translate([-0.05, -0.05, -0.05])
            cube([0.05, 0.05, 0.1], center=false);
        translate([-0.025, -0.05, 0.025])
            cube([0.05, 0.05, 0.025], center=false);
    }
}

l_shaped_block();