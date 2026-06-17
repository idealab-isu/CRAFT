$fn = 128;

radii = [17.4, 11.4, 9, 0.5];

module radial(rs, h=1) {
    union() {
        for (r = rs)
            cylinder(h=h, r=r, center=true);
    }
}

radial(radii, h=1);