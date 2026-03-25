module prismatic_rod() {
    rotate([0, 0, 45])
    scale([1, 1, 10])
    cylinder(h=0.1, r1=0.005, r2=0.005, $fn=8);
}

module rectangular_block() {
    translate([0, 0, 0.03])
    scale([1, 2, 1])
    hull() {
        translate([-0.01, -0.02, 0])
        cube([0.02, 0.04, 0.02], center=true);
        translate([-0.01, 0.02, 0])
        cube([0.02, 0.04, 0.02], center=true);
    }
}

module faceted_knob() {
    rotate([0, 0, 22.5])
    scale([1, 1, 1])
    cylinder(h=0.01, r1=0.01, r2=0.01, $fn=8);
}

module assembly() {
    union() {
        prismatic_rod();
        rectangular_block();
        translate([0, 0, 0.05])
        faceted_knob();
        translate([0, 0, 0.08])
        faceted_knob();
    }
}

assembly();