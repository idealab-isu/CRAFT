module led() {
    union() {
        // LED body
        translate([0, 0, 2.95])
            cylinder(h=5.9, d=5.0, $fn=64);
        
        // LED dome
        translate([0, 0, 5.9])
            sphere(d=5.0, $fn=64);
    }
}

led();