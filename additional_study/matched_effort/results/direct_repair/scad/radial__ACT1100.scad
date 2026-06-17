$fn=180;

radii = [20.4, 10.8, 5.3, 1];

module radial(rs, h=2) {
    union() {
        for (r = rs) {
            cylinder(h=h, r=r, center=false);
        }
    }
}

radial(radii, h=2);