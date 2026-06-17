module linear_guide_rail() {
    rail_body();
    mounting_holes();
    end_chamfers();
    edge_fillets();
    engraved_markings();
}

module rail_body() {
    translate([0, 0, 0])
        cube([100, 7, 5], center = false);
}

module mounting_holes() {
    for (x = [10, 30, 50, 70, 90]) {
        translate([x, 3.5, 2.5])
            rotate([90, 0, 0])
                cylinder(h = 5, r = 1, center = true);
    }
}

module end_chamfers() {
    translate([0, 0, 0])
        linear_extrude(height = 7)
            polygon(points = [[0, 0], [5, 0], [0, 5]]);
    translate([95, 0, 0])
        linear_extrude(height = 7)
            polygon(points = [[0, 0], [5, 0], [0, 5]]);
}

module edge_fillets() {
    for (x = [0, 100]) {
        for (y = [0, 7]) {
            translate([x, y, 0])
                rotate([0, 90, 0])
                    cylinder(h = 5, r = 0.5, center = false);
        }
    }
}

module engraved_markings() {
    translate([50, 3.5, 5.1])
        rotate([0, 0, 0])
            text("Guide Rail", size = 2, valign = "center", halign = "center");
}

linear_guide_rail();