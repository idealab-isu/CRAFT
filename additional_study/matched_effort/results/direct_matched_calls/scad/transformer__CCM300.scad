$fn = 64;

module mains_transformer(size=[120,88,120], corner_r=3) {
    x = size[0];
    y = size[1];
    z = size[2];

    color([0.15,0.15,0.15])
    translate([0,0,z/2])
    minkowski() {
        cube([x-2*corner_r, y-2*corner_r, z-2*corner_r], center=true);
        sphere(r=corner_r);
    }
}

mains_transformer([120.0, 88.0, 120.0], corner_r=3);