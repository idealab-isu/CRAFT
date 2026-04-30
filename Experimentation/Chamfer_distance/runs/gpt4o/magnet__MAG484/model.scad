cylinder_ring(outer_d=6.35, inner_d=3.175, height=6.35, corner_radius=0.5);

module cylinder_ring(outer_d, inner_d, height, corner_radius) {
    difference() {
        // Outer rounded cylinder
        cylinder(h=height, d=outer_d, $fn=64);
        // Inner cylinder
        translate([0, 0, -1]) // Slightly lower to ensure clean subtraction
            cylinder(h=height + 2, d=inner_d, $fn=64);
    }
    // Apply corner rounding
    translate([0, 0, height/2])
        rotate_extrude($fn=64)
            translate([outer_d/2 - corner_radius, 0, 0])
                circle(r=corner_radius, $fn=64);
}