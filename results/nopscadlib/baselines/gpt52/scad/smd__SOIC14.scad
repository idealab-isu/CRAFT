$fn=64;

module smd_body(size=[8.70, 3.90, 1.25]) {
    translate([0,0,size[2]/2])
        cube(size, center=true);
}

smd_body([8.70, 3.90, 1.25]);