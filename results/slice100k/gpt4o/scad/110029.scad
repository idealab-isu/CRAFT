module prong() {
    difference() {
        union() {
            translate([0, 0, -1])
                cylinder(h=2, r=1.5, $fn=64);
            translate([0, 0, 0.5])
                cube([3, 3, 1], center=true);
        }
        translate([0, 0, 0.5])
            cube([1.5, 3, 1], center=true);
    }
}

module forked_end() {
    union() {
        translate([-1.5, 0, 0])
            prong();
        translate([1.5, 0, 0])
            prong();
    }
}

module tapered_transition() {
    difference() {
        cylinder(h=2, r1=2, r2=1.5, $fn=64);
        translate([0, 0, 0.5])
            cube([3, 3, 1], center=true);
    }
}

module sleeve() {
    union() {
        translate([0, 0, -9.4])
            cylinder(h=18.8, r=1.5, $fn=64);
        translate([0, 0, -10.4])
            tapered_transition();
        translate([0, 0, 8.4])
            tapered_transition();
    }
}

module double_ended_clevis() {
    union() {
        translate([0, 0, -10.4])
            forked_end();
        translate([0, 0, 10.4])
            forked_end();
        sleeve();
    }
}

double_ended_clevis();