$fn = 128;

radii = [20.4, 10.8, 5.3, 1];

module radial(rs, h=1) {
    union() {
        for (r = rs) {
            cylinder(r=r, h=h, center=false);
        }
    }
}

radial(radii, 1);