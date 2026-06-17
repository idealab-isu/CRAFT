$fn = 128;

// Parameters for the tubing (carbon fiber)
outer_diameter = 20;   // mm
inner_diameter = 18;   // mm
length         = 100;  // mm
centered       = true; // center on origin

// Carbon fiber appearance (simple dark gray)
module material_appearance_carbon_fiber() {
    color([0.08, 0.08, 0.09, 1]) children();
}

// Hollow tube (robust subtraction; avoids coplanar artifacts that can look "blank")
module hollow_bore(outer_d, inner_d, len, centered=true) {
    eps = 0.2; // small overlap to guarantee clean subtraction

    difference() {
        cylinder(d=outer_d, h=len, center=centered);

        // Shift inner cutter along Z so its faces are not coplanar with the outer tube faces
        translate([0, 0, centered ? 0 : eps])
            cylinder(d=inner_d, h=len + 2*eps, center=centered);
    }
}

// Main tubing segment
module tubing_segment() {
    material_appearance_carbon_fiber()
        hollow_bore(outer_diameter, inner_diameter, length, centered);
}

tubing_segment();