$fn = 180;

module penny_washer(id=4.0, od=14.0, t=0.8) {
    eps = 0.02; // small extra to guarantee a clean through-hole cut

    difference() {
        cylinder(h=t, d=od, center=true);
        cylinder(h=t + 2*eps, d=id, center=true);
    }
}

penny_washer();