module faceted_annular_ring() {
    difference() {
        // Outer faceted cylinder
        scale([0.1, 0.1, 0.1])
        rotate([0, 0, 0])
        cylinder(h=1, r=0.5, $fn=8);
        
        // Inner circular bore
        translate([0, 0, -0.5])
        cylinder(h=2, r=0.3, $fn=64);
    }
}

faceted_annular_ring();