module wheel_hub() {
    difference() {
        // Outer rim
        cylinder(h=10, r=50, $fn=64);
        
        // Recessed inner face
        translate([0, 0, 2])
            cylinder(h=8, r=45, $fn=64);
        
        // Central square through-hole
        translate([-5, -5, -1])
            cube([10, 10, 12]);
        
        // Bolt circle with octagonal through-holes
        for (i = [0:4]) {
            rotate([0, 0, i * 72])
                translate([30, 0, -1])
                    rotate([0, 0, 22.5])
                        cylinder(h=12, r=5, $fn=8);
        }
    }
}

wheel_hub();