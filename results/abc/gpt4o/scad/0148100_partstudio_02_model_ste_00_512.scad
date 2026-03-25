module rounded_plate() {
    difference() {
        union() {
            translate([0, 0, -0.5])
                cylinder(h=1, r=5, $fn=64);
            translate([90, 0, -0.5])
                cylinder(h=1, r=5, $fn=64);
            translate([45, 0, 0])
                cube([50, 10, 1], center=true);
        }
        translate([35, 0, -1])
            cylinder(h=2, r=10, $fn=8);
        for (i = [-30, -10, 10, 30]) {
            translate([i, 0, -1])
                t_slot();
        }
    }
}

module t_slot() {
    difference() {
        translate([-2.5, -1, -1])
            cube([5, 2, 2], center=true);
        translate([-1, -3, -1])
            cube([2, 6, 2], center=true);
    }
}

rounded_plate();