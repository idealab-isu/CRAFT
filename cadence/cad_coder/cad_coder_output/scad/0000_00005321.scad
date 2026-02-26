EPS = 0.01;

module sketch0() {
    translate([-0.34375, 0, 0]) {
        difference() {
            union() {
                translate([0.34342105263157896, 0, 0])
                    cylinder(h=0.1015625, r=0.34342105263157896, center=true);
                translate([0.20748355263157894, -0.22894736842105262, 0])
                    cylinder(h=0.1015625, r=0.028618421052631578, center=true);
                translate([0.20748355263157894, 0.22894736842105262, 0])
                    cylinder(h=0.1015625, r=0.028618421052631578, center=true);
                translate([0.6009868421052631, 0, 0])
                    cylinder(h=0.1015625, r=0.028618421052631578, center=true);
            }
            translate([0.34342105263157896, 0, 0])
                cylinder(h=0.1015625 + EPS, r=0.19317434210526316, center=true);
        }
    }
}

module sketch1() {
    translate([-0.1953125, 0, 0]) {
        difference() {
            translate([0.19736842105263158, 0, 0])
                cylinder(h=0.75, r=0.19736842105263158, center=true);
            translate([0.19736842105263158, 0, 0])
                cylinder(h=0.75 + EPS, r=0.16036184210526314, center=true);
        }
    }
}

union() {
    sketch0();
    sketch1();
}