$fn=32;

module faceted_sphere() {
    difference() {
        sphere(r=50, $fn=16);
        translate([-60, 0, 0])
            cube([120, 20, 100], center=true);
        translate([0, -60, 0])
            cube([20, 120, 100], center=true);
        rotate([0, 45, 0])
            translate([0, -60, 0])
                cube([20, 120, 100], center=true);
        rotate([0, -45, 0])
            translate([0, -60, 0])
                cube([20, 120, 100], center=true);
    }
}

module polygonal_cap() {
    rotate([0, 0, 0])
        cylinder(h=10, r1=50, r2=30, $fn=6);
}

module pyramidal_tip() {
    translate([0, 0, 50])
        rotate([180, 0, 0])
            cone(h=20, r1=30, r2=0, $fn=4);
}

module lantern() {
    union() {
        faceted_sphere();
        translate([0, 0, 50])
            polygonal_cap();
        pyramidal_tip();
    }
}

translate([0, 0, -50])
    lantern();