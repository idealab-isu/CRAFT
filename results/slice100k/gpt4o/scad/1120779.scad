module cross_hub() {
    // Central cylinder
    cylinder(h=6.3, d=5, $fn=64);

    // Tab dimensions
    tab_length = 11.7;
    tab_width = 2.85;
    tab_height = 6.3;

    // Create a single tab
    module tab() {
        cube([tab_length, tab_width, tab_height], center=true);
    }

    // Position and union the tabs around the cylinder
    union() {
        translate([0, 0, 3.15]) cylinder(h=6.3, d=5, $fn=64);
        translate([0, 0, 0])
            for (angle = [0, 90, 180, 270])
                rotate([0, 0, angle])
                    translate([tab_length/2, 0, 0])
                        tab();
    }
}

cross_hub();