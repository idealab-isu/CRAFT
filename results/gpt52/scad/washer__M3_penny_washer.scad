$fn=128;

module penny_washer(id=3.0, od=12.0, thickness=0.8) {
    difference() {
        cylinder(h=thickness, d=od, center=true);
        cylinder(h=thickness+0.2, d=id, center=true);
    }
}

penny_washer();