$fn=64;

module shaft_coupling() {
    difference() {
        // Outer cylinder
        cylinder(h=25.0, d=12.5, center=true);
        
        // 5.0mm bore
        translate([0, 0, -12.5])
            cylinder(h=25.0, d=5.0, center=true);
        
        // 8.0mm bore
        translate([0, 0, -12.5])
            cylinder(h=25.0, d=8.0, center=true);
    }
}

shaft_coupling();