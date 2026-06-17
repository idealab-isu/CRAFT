$fn=128;

module washer(id=6.0, od=12.5, thickness=1.5) {
    difference() {
        cylinder(h=thickness, d=od, center=true);
        cylinder(h=thickness + 0.2, d=id, center=true);
    }
}

washer();