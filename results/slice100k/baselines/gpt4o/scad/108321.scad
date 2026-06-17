module hexagonal_ring() {
    difference() {
        // Outer hexagonal shape
        scale([1, 1, 0.1])
            rotate([0, 0, 90])
                cylinder(d=46.2, h=10, $fn=6);
        
        // Central circular through-opening
        translate([0, 0, -1])
            cylinder(d=30, h=12, $fn=64);
        
        // Recessed inner annulus
        translate([0, 0, 1])
            cylinder(d=35, h=8, $fn=64);
        
        // Rectangular lugs/teeth
        for (i = [0 : 9]) {
            rotate([0, 0, i * 36])
                translate([15, 0, -1])
                    cube([5, 3, 12], center=true);
        }
    }
}

hexagonal_ring();