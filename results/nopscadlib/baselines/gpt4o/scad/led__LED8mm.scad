module led() {
    union() {
        // LED body
        translate([0, 0, 4.6])
            cylinder(h=9.2, d=8.0, $fn=64);
        
        // LED dome
        translate([0, 0, 9.2])
            sphere(d=8.0, $fn=64);
    }
}

led();