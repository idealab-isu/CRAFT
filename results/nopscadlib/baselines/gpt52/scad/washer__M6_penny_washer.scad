$fn=128;

module penny_washer(id=6.0, od=26.0, thickness=1.5) {
    difference() {
        cylinder(d=od, h=thickness, center=true);
        cylinder(d=id, h=thickness + 0.2, center=true);
    }
}

penny_washer();