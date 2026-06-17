module annular_ring_with_teeth() {
    difference() {
        // Main ring
        cylinder(h=7, r=11.75, $fn=64);
        
        // Central bore
        translate([0, 0, -1])
            cylinder(h=9, r=5, $fn=64);
    }
}

module tooth() {
    translate([-1.5, 11.75, 0])
        cube([3, 3, 7]);
}

module ring_with_teeth() {
    annular_ring_with_teeth();
    for (i = [0:11]) {
        rotate([0, 0, i * 30])
            tooth();
    }
}

ring_with_teeth();