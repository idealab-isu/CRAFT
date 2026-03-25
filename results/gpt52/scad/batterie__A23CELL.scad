$fn=96;

module battery_cell(h=28.5, d=10.3, cap_h=1.2, cap_d=4.8, nub_h=0.6, nub_d=2.6) {
    union() {
        translate([0,0,-h/2]) cylinder(h=h, d=d);
        translate([0,0,h/2 - cap_h]) cylinder(h=cap_h, d=cap_d);
        translate([0,0,h/2]) cylinder(h=nub_h, d=nub_d);
    }
}

battery_cell();