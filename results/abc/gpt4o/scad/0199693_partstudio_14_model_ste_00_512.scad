module u_shaped_bracket() {
    difference() {
        union() {
            // Crossbar
            translate([0, 0, 10])
            cube([100, 10, 5], center=true);

            // Side cheeks
            translate([-50, 0, 15])
            side_cheek();
            translate([50, 0, 15])
            side_cheek();
        }

        // Lightening windows in crossbar
        translate([-30, 0, 10])
        rotate([0, 0, 90])
        hex_window();
        translate([30, 0, 10])
        rotate([0, 0, 90])
        hex_window();
        translate([0, 0, 10])
        diamond_window();
    }
}

module side_cheek() {
    difference() {
        // Main circular end plate
        cylinder(h=30, r=25, center=true, $fn=64);

        // Large central circular opening
        cylinder(h=35, r=15, center=true, $fn=64);

        // Smaller cutouts
        translate([-10, 0, 0])
        cylinder(h=35, r=5, center=true, $fn=64);
        translate([10, 0, 0])
        cylinder(h=35, r=5, center=true, $fn=64);
    }
}

module hex_window() {
    polygon(points=[[0, 0], [10, 0], [15, 5], [10, 10], [0, 10], [-5, 5]]);
    linear_extrude(height=5)
    offset(r=1);
}

module diamond_window() {
    polygon(points=[[0, 0], [5, 5], [0, 10], [-5, 5]]);
    linear_extrude(height=5)
    offset(r=1);
}

u_shaped_bracket();