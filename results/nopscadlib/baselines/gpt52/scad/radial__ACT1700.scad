$fn=64;

module radial(size=[10.8,10.8,5.3,1]) {
    w = size[0];
    d = size[1];
    h = size[2];
    r = size[3];
    r2 = min(r, w/2, d/2);

    linear_extrude(height=h, center=true)
        offset(r=r2)
            square([w-2*r2, d-2*r2], center=true);
}

radial([10.8, 10.8, 5.3, 1]);