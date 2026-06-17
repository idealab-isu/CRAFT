module hex_hole(size, height) {
    rotate([0, 0, 90])
    linear_extrude(height)
    polygon(points=[
        [size * cos(0), size * sin(0)],
        [size * cos(60), size * sin(60)],
        [size * cos(120), size * sin(120)],
        [size * cos(180), size * sin(180)],
        [size * cos(240), size * sin(240)],
        [size * cos(300), size * sin(300)]
    ]);
}

module tool_body() {
    difference() {
        union() {
            // Main cylindrical body
            cylinder(h=60, r=15, $fn=64);
            // Stepped collar
            translate([0, 0, 50])
            cylinder(h=10, r1=15, r2=18, $fn=64);
            // Domed cap
            translate([0, 0, 60])
            sphere(r=18, $fn=64);
        }
        // Central hexagonal through-bore
        translate([0, 0, -5])
        hex_hole(5, 70);
        // Smaller hexagonal through-holes around the central bore
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
            translate([10, 0, -5])
            hex_hole(2, 70);
        }
    }
}

translate([0, 0, -30])
tool_body();