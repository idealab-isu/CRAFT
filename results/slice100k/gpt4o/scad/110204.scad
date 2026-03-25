module spool() {
    difference() {
        union() {
            // Outer flanges
            cylinder(h=2.5, r=5, $fn=64);
            translate([0, 0, 4.5])
                cylinder(h=2.5, r=5, $fn=64);
            
            // Central double-conical waist
            translate([0, 0, 2.5])
                cylinder(h=5, r1=5, r2=2, $fn=64);
        }
        // Central through-bore
        translate([0, 0, -1])
            cylinder(h=12, r=1, $fn=64);
    }
}

translate([0, 0, -5])
    spool();