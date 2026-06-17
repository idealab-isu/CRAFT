// Penny washer: 3.0mm inner hole, 12.0mm outer diameter, 0.8mm thickness

$fn = 180;  // high resolution for true circular edges

inner_diameter = 3.0;
outer_diameter = 12.0;
thickness      = 0.8;

module penny_washer(id=inner_diameter, od=outer_diameter, t=thickness) {
    difference() {
        cylinder(h=t, d=od, center=true);
        cylinder(h=t + 0.2, d=id, center=true);  // slight overshoot ensures clean through-hole
    }
}

penny_washer();