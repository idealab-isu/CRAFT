module axial_component() {
    axial_body();
    axial_bore();
    end_chamfers();
    edge_fillets();
}

module axial_body() {
    difference() {
        cylinder(h = 3.4, d = 1.75, $fn = 100);
        translate([0, 0, -0.1])
            cylinder(h = 3.6, d = 1.15, $fn = 100);
    }
}

module axial_bore() {
    translate([0, 0, -0.1])
        cylinder(h = 3.6, d = 1.15, $fn = 100);
}

module end_chamfers() {
    translate([0, 0, 3.4])
        rotate([180, 0, 0])
            chamfer();
    chamfer();
}

module chamfer() {
    difference() {
        cylinder(h = 0.3, d1 = 1.75, d2 = 1.15, $fn = 100);
        translate([0, 0, -0.1])
            cylinder(h = 0.4, d = 1.15, $fn = 100);
    }
}

module edge_fillets() {
    translate([0, 0, 3.4])
        rotate([180, 0, 0])
            fillet();
    fillet();
}

module fillet() {
    difference() {
        cylinder(h = 0.3, d = 1.75, $fn = 100);
        translate([0, 0, -0.1])
            cylinder(h = 0.4, d = 1.45, $fn = 100);
    }
}

axial_component();