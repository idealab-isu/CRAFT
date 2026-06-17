module hex_collar() {
    rotate([0, 0, 90])
    cylinder(h=0.02, r=0.05, $fn=6);
}

module central_opening() {
    rotate([0, 0, 90])
    cylinder(h=0.02, r=0.02, $fn=64);
}

module shank() {
    difference() {
        cube([0.08, 0.02, 0.02], center=true);
        translate([-0.04, 0, 0])
            rotate([0, 90, 0])
            cylinder(h=0.02, r=0.005, $fn=64);
        translate([0.04, 0, 0])
            rotate([0, 90, 0])
            cylinder(h=0.02, r=0.005, $fn=64);
    }
}

module rib() {
    translate([0, 0, -0.01])
    cube([0.08, 0.005, 0.02], center=true);
}

module mechanical_fitting() {
    union() {
        translate([0, 0, 0.04])
            hex_collar();
        translate([0, 0, 0.04])
            central_opening();
        translate([0, 0, -0.01])
            shank();
        rib();
    }
}

translate([0, 0, -0.05])
mechanical_fitting();