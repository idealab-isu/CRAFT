$fn = 128;

module radial(params=[2.0, 0, 6]) {
    r = params[0];
    a = params[1];
    h = params[2];

    rotate([0,0,a])
        cylinder(h=h, r=r, center=false);
}

radial([2.0, 0, 6]);