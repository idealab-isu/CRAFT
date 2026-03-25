$fn=128;

radii = [20.4, 10.8, 5.3, 1];

module radial_stack(rs, h=1) {
    union() {
        for (i = [0:len(rs)-1]) {
            cylinder(h=h, r=rs[i], center=true);
        }
    }
}

radial_stack(radii, h=1);