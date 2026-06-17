module smd_package() {
    smd_body();
    pin_1_mark();
    side_chamfers();
    top_marking_text();
}

module smd_body() {
    translate([-4.90/2, -3.90/2, 0])
        cube([4.90, 3.90, 1.25]);
}

module pin_1_mark() {
    translate([-4.90/2 + 0.5, -3.90/2 + 0.5, 1.25])
        cylinder(h = 0.1, r = 0.3);
}

module side_chamfers() {
    // Chamfer on the length sides
    translate([-4.90/2, -3.90/2, 0])
        hull() {
            translate([0, 0, 0])
                cube([0.5, 3.90, 1.25]);
            translate([4.90, 0, 0])
                cube([0.5, 3.90, 1.25]);
        }
    // Chamfer on the width sides
    translate([-4.90/2, -3.90/2, 0])
        hull() {
            translate([0, 0, 0])
                cube([4.90, 0.5, 1.25]);
            translate([0, 3.90, 0])
                cube([4.90, 0.5, 1.25]);
        }
}

module top_marking_text() {
    translate([-4.90/2 + 1, -3.90/2 + 1, 1.25])
        linear_extrude(height = 0.1)
            text("SMD", size = 1, valign = "center", halign = "center");
}

smd_package();