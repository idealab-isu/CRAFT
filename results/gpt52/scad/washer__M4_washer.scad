$fn=128;

module washer(id=4.0, od=9.0, thickness=0.8) {
    difference() {
        cylinder(h=thickness, d=od, center=true);
        cylinder(h=thickness + 0.2, d=id, center=true);
    }
}

washer(id=4.0, od=9.0, thickness=0.8);