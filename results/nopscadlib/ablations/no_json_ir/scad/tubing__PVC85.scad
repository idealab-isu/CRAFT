$fn = 128;

// Parameters for the PVC aquarium tubing
outer_diameter = 20; // Outer diameter of the tube
inner_diameter = 15; // Inner diameter of the tube
length = 100;        // Length of the tube
centered = true;     // Center the tube on the origin

// Robust overlap to avoid coplanar/degenerate subtraction issues
eps = 0.5;

module tubing(od, id, h, center=true) {
    // Ensure valid wall thickness
    id2 = min(id, od - 2*eps);

    difference() {
        cylinder(d=od, h=h, center=center);
        // Offset the inner cylinder slightly in Z so faces never coincide
        translate([0, 0, (center ? 0 : h/2) + eps])
            cylinder(d=id2, h=h + 2*eps, center=center);
    }
}

tubing(outer_diameter, inner_diameter, length, centered);