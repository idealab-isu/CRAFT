$fn=64;

scale([0.1,0.1,0.1]) fitting();

module fitting() {
    union() {
        collar();
        translate([0,0,6]) shank();
    }
}

module collar() {
    difference() {
        union() {
            cylinder(h=6, r=5, $fn=6);
            translate([0,0,5.2]) cylinder(h=1.2, r=4.2, $fn=6);
        }
        translate([0,0,-0.5]) cylinder(h=7.5, r=2.0, $fn=64);
    }
}

module shank() {
    difference() {
        union() {
            translate([0,0,10]) cube([6,8,20], center=true);
            rib();
        }
        slot_pair();
    }
}

module rib() {
    translate([0,0,10]) cube([1.2,8,20], center=true);
}

module slot_pair() {
    translate([0,0,10]) {
        translate([0, 2.2, 0]) rotate([0,90,0]) capsule_x(len=4.6, r=0.9, h=6.6);
        translate([0,-2.2, 0]) rotate([0,90,0]) capsule_x(len=4.6, r=0.9, h=6.6);
    }
}

module capsule_x(len=4.6, r=0.9, h=6.6) {
    linear_extrude(height=h, center=true)
        hull() {
            translate([-len/2,0]) circle(r=r, $fn=48);
            translate([ len/2,0]) circle(r=r, $fn=48);
        }
}