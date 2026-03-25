module flange() {
    difference() {
        union() {
            translate([-15, -5, 0])
                scale([1, 1, 0.5])
                    cylinder(h=10, r=5, $fn=64);
            translate([-10, -5, 0])
                cube([20, 10, 5]);
        }
        translate([10, 0, 0])
            cylinder(h=10, r=1, $fn=64);
    }
    translate([10, 5, 2.5])
        cube([2, 2, 2]);
}

module web() {
    translate([-10, -2.5, -2.5])
        cube([20, 5, 5]);
}

module bracket() {
    union() {
        translate([-20, 0, 0])
            flange();
        translate([0, 0, 0])
            web();
        translate([20, 0, 0])
            flange();
    }
}

bracket();