$fn = 96;

module hex_nut(screw_d=8.0, across_flats=15.0, thickness=6.5, clearance=0.2) {
    hole_d = screw_d + clearance;                 // simple clearance hole (not threaded)
    hex_R  = across_flats / sqrt(3);              // circumradius for given across-flats

    difference() {
        // Hex body: 15.0mm across flats, 6.5mm thick
        cylinder(h=thickness, r=hex_R, $fn=6);

        // Central through-hole: fully cuts through with small extra height
        translate([0, 0, -0.1])
            cylinder(h=thickness + 0.2, d=hole_d);
    }
}

hex_nut();