// Hex nut for 2.0mm screw
// Target: 4.9mm across flats, 1.6mm thick, through-hole 2.0mm

$fn = 96;

// Parameters
across_flats   = 4.9;   // mm
thickness      = 1.6;   // mm
hole_diameter  = 2.0;   // mm (clearance/through-hole)
chamfer        = 0.2;   // mm (edge bevel on top/bottom)
eps            = 0.02;  // mm (robust boolean overlap)

// Derived: circumradius (center to vertex) for a regular hex with given across-flats
hex_R = across_flats / sqrt(3);   // because across_flats = sqrt(3) * R

module hex_prism(h=thickness, R=hex_R) {
    cylinder(h=h, r=R, center=true, $fn=6);
}

module chamfer_cut(zsign=1) {
    // zsign = +1 for top, -1 for bottom
    // Use a conical frustum to remove material and create a bevel.
    // Place it so it intersects only the corresponding face.
    translate([0, 0, zsign*(thickness/2 - chamfer/2)])
        cylinder(
            h = chamfer + 2*eps,
            r1 = hex_R + chamfer,
            r2 = hex_R - chamfer,
            center = true,
            $fn = 6
        );
}

difference() {
    // Outer hex body with parallel top/bottom faces
    hex_prism();

    // Through-hole for screw
    cylinder(h=thickness + 2*eps, r=hole_diameter/2, center=true);

    // Top and bottom chamfers (subtractive)
    chamfer_cut(+1);
    chamfer_cut(-1);
}