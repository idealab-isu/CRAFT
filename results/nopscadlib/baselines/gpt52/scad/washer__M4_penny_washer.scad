$fn=128;

module penny_washer(id=4.0, od=14.0, thickness=0.8) {
    difference() {
        cylinder(h=thickness, d=od, center=true);
        cylinder(h=thickness+0.2, d=id, center=true);
    }
}

penny_washer();