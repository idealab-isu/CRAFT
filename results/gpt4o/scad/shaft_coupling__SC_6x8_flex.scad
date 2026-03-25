module flexible_shaft_coupling() {
    difference() {
        // Outer cylinder
        cylinder(h=25.0, d=19.0, $fn=64);
        
        // 6.0mm bore
        translate([0, 0, -1])
            cylinder(h=27.0, d=6.0, $fn=64);
        
        // 8.0mm bore
        translate([0, 0, 12.5])
            cylinder(h=27.0, d=8.0, $fn=64);
    }
}

flexible_shaft_coupling();