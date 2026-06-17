$fn = 128;

module washer(id=5.0, od=10.0, t=1.0) {
    difference() {
        cylinder(h=t, d=od, center=true);
        cylinder(h=t + 0.2, d=id, center=true);
    }
}

washer();