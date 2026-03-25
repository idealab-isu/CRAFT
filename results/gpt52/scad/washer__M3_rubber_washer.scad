$fn=128;

module washer(id=3.0, od=10.0, thickness=1.5) {
    difference() {
        cylinder(h=thickness, d=od, center=true);
        cylinder(h=thickness + 0.2, d=id, center=true);
    }
}

washer(id=3.0, od=10.0, thickness=1.5);