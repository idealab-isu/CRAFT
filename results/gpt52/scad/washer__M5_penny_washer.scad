$fn=128;

module penny_washer(id=5.0, od=20.0, thickness=1.4) {
    difference() {
        cylinder(d=od, h=thickness, center=true);
        cylinder(d=id, h=thickness+0.2, center=true);
    }
}

penny_washer();