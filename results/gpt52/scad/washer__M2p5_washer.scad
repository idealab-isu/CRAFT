$fn=128;

module washer(id=2.5, od=5.9, thickness=0.5) {
    difference() {
        cylinder(h=thickness, d=od, center=true);
        cylinder(h=thickness + 0.2, d=id, center=true);
    }
}

washer();