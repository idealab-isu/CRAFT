module armored_vehicle() {
    hull();
    end_pods();
    turret();
    barrel();
    fins();
}

module hull() {
    translate([-50, -10, -5])
        cube([100, 20, 10]);
}

module end_pods() {
    translate([-55, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=20, r=10, $fn=64);
    translate([55, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=20, r=10, $fn=64);
}

module turret() {
    translate([-10, -5, 5])
        scale([1, 1, 0.5])
        rotate([0, 0, 45])
        cube([20, 10, 10]);
}

module barrel() {
    translate([60, 0, 0])
        rotate([0, 90, 0])
        cylinder(h=30, r=2, $fn=32);
}

module fins() {
    translate([-20, 10, 0])
        rotate([0, 0, 45])
        cube([10, 2, 5]);
    translate([20, 10, 0])
        rotate([0, 0, -45])
        cube([10, 2, 5]);
}

armored_vehicle();