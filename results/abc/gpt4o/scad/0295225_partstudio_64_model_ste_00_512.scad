module faceted_bowl() {
    difference() {
        // Outer shape: truncated cone
        scale([1, 1, 0.5])
            cylinder(h=20, r1=30, r2=20, $fn=64);
        
        // Inner cavity: hemisphere
        translate([0, 0, -10])
            sphere(r=20, $fn=64);
        
        // Side notches
        for (angle = [0, 180]) {
            rotate([0, 0, angle])
                translate([25, 0, 10])
                    cube([10, 5, 5], center=true);
        }
    }
}

translate([0, 0, 10])
    faceted_bowl();