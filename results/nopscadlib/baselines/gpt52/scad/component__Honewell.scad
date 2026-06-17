$fn=64;

module lead(len=30, dia=0.5) {
    color([0.75,0.75,0.78])
    translate([0,0,-len/2])
        cylinder(h=len, d=dia, center=true);
}

module epoxy_bead(body_len=3.6, body_d=2.2) {
    color([0.1,0.1,0.12])
    rotate([0,90,0])
        cylinder(h=body_len, d=body_d, center=true);
}

module thermistor_135_104LAC_J01() {
    union() {
        epoxy_bead(3.6, 2.2);

        translate([-1.8, 0, 0]) lead(30, 0.5);
        translate([ 1.8, 0, 0]) lead(30, 0.5);

        color([0.85,0.85,0.88]) translate([-1.8, 0, 1.2]) sphere(d=0.7);
        color([0.85,0.85,0.88]) translate([ 1.8, 0, 1.2]) sphere(d=0.7);
    }
}

thermistor_135_104LAC_J01();