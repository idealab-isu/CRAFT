module annular_ring_body(outer_radius, thickness, inner_radius) {
    difference() {
        cylinder(h = thickness, r = outer_radius);
        translate([0, 0, -1]) // Slightly lower to ensure clean subtraction
            cylinder(h = thickness + 2, r = inner_radius);
    }
}

// Example usage
annular_ring_body(outer_radius = 20, thickness = 5, inner_radius = 10);