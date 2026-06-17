module split_cylindrical_sleeve() {
    difference() {
        // Outer cylinder
        cylinder(h=78.5, r=9.45, $fn=64);
        
        // Inner bore with steps
        union() {
            // Main inner bore
            cylinder(h=78.5, r=7.5, $fn=64);
            
            // Steps/notches near one end
            translate([0, 0, 70])
                cylinder(h=8.5, r=6.5, $fn=64);
            translate([0, 0, 74])
                cylinder(h=4.5, r=5.5, $fn=64);
        }
        
        // Axial gap
        translate([-9.45, 0, 0])
            cube([19.5, 18.9, 78.5]);
    }
}

split_cylindrical_sleeve();