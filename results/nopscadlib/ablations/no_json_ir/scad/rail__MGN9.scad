module rail_body() {
    cube([100, 9, 6], center = true);
}

module end_chamfers() {
    translate([-50, 0, 0])
        rotate([0, 45, 0])
        cube([6, 9, 6], center = true);
    translate([50, 0, 0])
        rotate([0, -45, 0])
        cube([6, 9, 6], center = true);
}

module edge_fillets() {
    for (x = [-50, 50])
        for (y = [-4.5, 4.5])
            for (z = [-3, 3])
                translate([x, y, z])
                    sphere(r = 1);
}

module engraved_markings() {
    translate([-40, 0, 3.1])
        linear_extrude(height = 0.2)
            text("Guide Rail", size = 3, valign = "center", halign = "center");
}

module linear_guide_rail() {
    difference() {
        rail_body();
        end_chamfers();
    }
    edge_fillets();
    engraved_markings();
}

linear_guide_rail();