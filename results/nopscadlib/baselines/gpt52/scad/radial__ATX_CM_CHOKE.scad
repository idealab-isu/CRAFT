$fn=128;

radii = [17.4, 11.4, 9, 0.5];

module radial_profile(rs, h=1) {
    union() {
        for (i = [0 : len(rs)-1]) {
            cylinder(h=h, r=rs[i], center=true);
        }
    }
}

radial_profile(radii, h=1);