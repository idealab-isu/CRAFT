// Dimension-calibrated (target: 0.01 x 0.00 x 0.01 mm)
scale([0.000520, 0.000500, 0.000500])
{
// Hex nut-like ring (hex prism with centered circular through-hole)
// Fixed: removed degenerate intersections and incorrect chamfer solids.
// Produces one connected solid with slight edge rounding via Minkowski.

$fn = 96;

// Parameters (mm)
outer_flat_to_flat = 10;     // across flats
thickness          = 4;      // height
hole_d             = 5;      // through-hole diameter
edge_round         = 0.3;    // small rounding/chamfer-like effect
eps_overlap        = 0.02;   // boolean robustness

// Derived
outer_R = outer_flat_to_flat / sqrt(3); // circumradius for a hex with given flat-to-flat

module hex2d(flat_to_flat){
    R = flat_to_flat / sqrt(3);
    polygon(points=[
        [ R, 0],
        [ R/2,  R*sqrt(3)/2],
        [-R/2,  R*sqrt(3)/2],
        [-R, 0],
        [-R/2, -R*sqrt(3)/2],
        [ R/2, -R*sqrt(3)/2]
    ]);
}

module nut_ring(){
    // Keep rounding small enough to preserve the hole and outer flats
    r = min(edge_round, (outer_flat_to_flat - hole_d)/4, thickness/4);
    r = max(r, 0);

    difference(){
        // Outer body with slight rounding
        if (r > 0)
            minkowski(){
                linear_extrude(height=thickness - 2*r, center=true)
                    hex2d(outer_flat_to_flat - 2*r);
                sphere(r=r);
            }
        else
            linear_extrude(height=thickness, center=true)
                hex2d(outer_flat_to_flat);

        // Through-hole (coaxial, full thickness)
        cylinder(d=hole_d, h=thickness + 2*eps_overlap, center=true);
    }
}

color("Silver") nut_ring();
}
