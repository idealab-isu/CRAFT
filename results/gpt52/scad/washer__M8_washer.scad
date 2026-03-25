$fn=128;

module washer(id=8.0, od=17.0, thickness=1.6) {
    difference() {
        cylinder(h=thickness, d=od, center=true);
        cylinder(h=thickness+0.2, d=id, center=true);
    }
}

washer();