$fn=128;

module washer(id=2.0, od=5.0, thickness=0.3) {
    difference() {
        cylinder(h=thickness, d=od, center=true);
        cylinder(h=thickness+0.2, d=id, center=true);
    }
}

washer();