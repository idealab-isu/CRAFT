$fn = 96;

module battery(d=10.3, h=28.5) {
    union() {
        cylinder(d=d, h=h, center=true);
        translate([0,0,h/2 + 0.4/2]) cylinder(d=4.2, h=0.4, center=true); // positive nub
    }
}

battery();