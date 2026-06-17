$fn=64;

module smd(size=[3,1.4,1.0]) {
    l = size[0];
    w = size[1];
    h = size[2];

    // Slight edge rounding for a typical SMD body look
    r = min(l, w, h) * 0.08;

    minkowski() {
        cube([l-2*r, w-2*r, h-2*r], center=true);
        sphere(r=r);
    }
}

smd([3, 1.4, 1.0]);