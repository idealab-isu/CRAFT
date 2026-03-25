$fn=64;

module arm() {
    difference() {
        scale([1, 1, 0.5])
            rotate([90, 0, 0])
                translate([0, 0, -5])
                    cylinder(h=10, r1=10, r2=5);
        translate([0, 0, -5])
            scale([1, 1, 0.5])
                rotate([90, 0, 0])
                    cylinder(h=10, r1=7, r2=3);
    }
}

module hub() {
    difference() {
        translate([-5, -5, -7.15])
            cube([10, 10, 14.3]);
        translate([-3, -3, -7.15])
            cube([6, 6, 14.3]);
    }
}

module peg() {
    translate([0, 0, 7.15])
        cylinder(h=3, r=2.5);
}

module cross() {
    union() {
        hub();
        peg();
        for (i = [0, 90, 180, 270]) {
            rotate([0, 0, i])
                translate([15, 0, 0])
                    arm();
        }
    }
}

translate([-23.9, -23.9, -7.15])
    cross();