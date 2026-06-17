// Dimension-calibrated (target: 48.00 x 10.00 x 16.00 mm)
scale([1.000000, 1.000000, 0.602410])
{
// U-shaped / saddle-style mounting strap (flat bar)
// Bounding box target: 48 x 10 x 16 mm (X x Y x Z)

$fn = 96;

// Parameters
L = 48.0;                 // overall length (X)
W = 10.0;                 // strap width (Y)
H = 16.0;                 // overall height (Z)
t = 2.0;                  // bar thickness (radial thickness of arch)
tab_len = 16.0;           // straight end tab length each side (X)
hole_d = 4.0;             // through-hole diameter
hole_x_from_end = 6.0;    // hole center from each end along X
hole_y_center = 0.0;      // hole center offset in Y
overlap = 0.6;            // boolean overlap

// Derived
arch_span = L - 2*tab_len;          // length occupied by the arch along X
arch_R_outer = H/2;                // outer radius to hit overall height
arch_R_inner = arch_R_outer - t;   // inner radius (clearance radius)
arch_center_z = arch_R_outer;      // center of the semicircle so bottom touches Z=0

module strap_solid() {
    union() {
        // Straight end tabs (flat bar)
        translate([-(L/2 - tab_len/2), 0, t/2])
            cube([tab_len, W, t], center=true);

        translate([(L/2 - tab_len/2), 0, t/2])
            cube([tab_len, W, t], center=true);

        // Semicircular arched center section (half-ring extruded along Y)
        // Oriented so the arch spans X, rises in Z, and is centered in Y.
        translate([0, 0, arch_center_z])
            rotate([90, 0, 0])  // extrude along Y
                rotate_extrude(angle=180, convexity=10)
                    translate([arch_R_outer - t/2, 0, 0])
                        square([t, arch_span], center=true);

        // Small overlaps to ensure watertight connection between arch ends and tabs
        // (connect at the arch endpoints x=±arch_R_outer)
        for (sx = [-1, 1]) {
            translate([sx*arch_R_outer, 0, t/2])
                cube([overlap*2, W, t + overlap*2], center=true);
        }
    }
}

module holes() {
    // Through-holes in end tabs: drill along Z through the flat bar thickness
    for (sx = [-1, 1]) {
        translate([sx*(L/2 - hole_x_from_end), hole_y_center, 0])
            cylinder(d=hole_d, h=H + 2*overlap, center=true);
    }
}

difference() {
    strap_solid();
    holes();
}
}
