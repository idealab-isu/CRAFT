module sleeve_cap() {
    difference() {
        union() {
            // Main cylindrical body
            cylinder(h=10, r=20, $fn=64);
            
            // Chamfered/rounded edges
            translate([0, 0, 10])
                cylinder(h=2, r1=20, r2=18, $fn=64);
            translate([0, 0, 0])
                cylinder(h=2, r1=18, r2=20, $fn=64);
            
            // Circumferential step/groove
            translate([0, 0, 8])
                cylinder(h=2, r=18, $fn=64);
            
            // Asymmetric rectangular lug/flat
            translate([-5, -25, 5])
                cube([10, 10, 5]);
        }
        
        // Notch cutout in the lug
        translate([-2.5, -25, 7])
            cube([5, 5, 5]);
    }
}

translate([0, 0, -5])
    sleeve_cap();