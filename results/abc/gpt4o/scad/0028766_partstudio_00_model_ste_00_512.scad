$fn=64;

module handle() {
    union() {
        // Grip
        translate([0, 0, 5])
        rotate([0, 90, 0])
        scale([1, 0.2, 0.1])
        rotate([0, 0, 10])
        cube([10, 1, 1], center=true);

        // Diamond-shaped recessed feature
        translate([-5, 0, 5])
        rotate([0, 90, 0])
        scale([1, 0.2, 0.1])
        rotate([0, 0, 10])
        difference() {
            cube([10, 1, 1], center=true);
            translate([0, 0, -0.1])
            rotate([0, 0, 45])
            scale([0.5, 0.5, 0.5])
            cube([2, 2, 2], center=true);
        }

        // Stem
        translate([0, 0, 0])
        cylinder(h=5, r1=1, r2=1, center=true);

        // Flanged base
        translate([0, 0, -2.5])
        cylinder(h=1, r1=2, r2=2, center=true);

        // Gusset-like transitions
        translate([0, 0, 2.5])
        rotate([90, 0, 0])
        scale([1, 0.2, 0.1])
        rotate([0, 0, 10])
        intersection() {
            cube([10, 1, 1], center=true);
            translate([0, 0, -0.5])
            rotate([0, 0, 45])
            scale([0.5, 0.5, 0.5])
            cube([2, 2, 2], center=true);
        }
    }
}

handle();