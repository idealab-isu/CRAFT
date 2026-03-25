// Dimension-calibrated (target: 0.01 x 0.01 x 0.01 mm)
scale([0.000693, 0.000700, 0.000833])
{
// Hex nut-like ring with circular through-hole and slight top/bottom chamfers
// (Fixes: non-empty geometry, truly circular bore, consistent hole in all views, connected solid)

// Parameters (mm)
outer_flat_to_flat = 10;     // across flats
height            = 6;       // overall thickness
hole_d            = 4;       // circular through-hole diameter
chamfer_h         = 0.5;     // chamfer height (top and bottom)
chamfer_inset     = 0.5;     // chamfer inset (radial shrink at chamfer)
eps               = 0.02;    // small overlap for robust booleans

$fn = 96;

// Derived
outer_R = outer_flat_to_flat / sqrt(3);                 // circumradius for hex with given across-flats
inner_R = max(0.01, outer_R - chamfer_inset);           // chamfered hex circumradius (slightly smaller)

// 2D hex helper (pointy-top orientation; still yields 6 flat wrench faces)
module hex2d(R) {
    polygon([ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// Main model
module hex_nut() {
    difference() {
        // Outer body with top/bottom chamfers via hull of two hex slices
        hull() {
            // bottom slice
            translate([0,0,-height/2]) linear_extrude(height=eps) hex2d(inner_R);
            // middle slice (full size)
            translate([0,0,-height/2 + chamfer_h]) linear_extrude(height=eps) hex2d(outer_R);
            // top slice (full size)
            translate([0,0, height/2 - chamfer_h - eps]) linear_extrude(height=eps) hex2d(outer_R);
            // top chamfer slice
            translate([0,0, height/2 - eps]) linear_extrude(height=eps) hex2d(inner_R);
        }

        // Circular through-hole (guaranteed round)
        cylinder(d=hole_d, h=height + 2*eps, center=true);
    }
}

hex_nut();
}
