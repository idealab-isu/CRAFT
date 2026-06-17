// Aluminium rectangular box section: 38.1mm x 25.4mm x 1.6mm wall
// Length adjustable via L (mm)

W = 38.1;   // outer width (mm)
H = 25.4;   // outer height (mm)
t = 1.6;    // wall thickness (mm)
L = 100;    // length (mm)

$fn = 64;

module box_section_rectangular(W, H, t, L) {
    eps = 0.05; // small overlap to avoid coplanar faces

    innerW = W - 2*t;
    innerH = H - 2*t;

    assert(innerW > 0 && innerH > 0, "Wall thickness too large for given outer dimensions.");

    // Build as a single connected solid: outer tube minus inner void
    difference() {
        // Outer solid (not centered so top/bottom views clearly show the opening)
        cube([W, H, L], center=false);

        // Inner void: offset by wall thickness, extend slightly to guarantee through-cut
        translate([t, t, -eps])
            cube([innerW, innerH, L + 2*eps], center=false);
    }
}

box_section_rectangular(W, H, t, L);