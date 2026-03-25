$fn=128;

module washer(id=5.0, od=10.0, thickness=1.0) {
    difference() {
        cylinder(d=od, h=thickness, center=true);
        cylinder(d=id, h=thickness+0.2, center=true);
    }
}

washer();