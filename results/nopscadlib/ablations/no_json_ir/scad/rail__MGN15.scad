module linear_guide_rail() {
    rail_body();
    end_chamfers();
    edge_fillets();
    engraved_markings();
}

module rail_body() {
    translate([0, 0, 0])
        cube([15, 100, 10], center = false);
}

module end_chamfers() {
    // Chamfer on both ends of the rail
    translate([0, 0, 0])
        difference() {
            cube([15, 100, 10], center = false);
            translate([-5, -5, 0])
                rotate([0, 45, 0])
                cube([15, 10, 10], center = false);
            translate([-5, 95, 0])
                rotate([0, -45, 0])
                cube([15, 10, 10], center = false);
        }
}

module edge_fillets() {
    // Fillet the edges of the rail
    for (x = [0, 15]) {
        for (y = [0, 100]) {
            translate([x, y, 0])
                cylinder(r = 1, h = 10, center = false);
        }
    }
}

module engraved_markings() {
    // Engrave markings on the top surface
    translate([7.5, 50, 10.1])
        rotate([90, 0, 0])
        text("Guide Rail", size = 3, valign = "center", halign = "center");
}

linear_guide_rail();