// Axial reference: vector [5.21, 2.72, 0]
// One connected solid, no text, oriented along the given vector in the XY plane.

module axial_reference(v = [5.21, 2.72, 0]) {
    // Geometry parameters (scaled up slightly to avoid "blank" renders from too-thin features)
    rod_r   = 0.25;
    tip_len = 0.90;
    tip_r   = 0.55;
    cap_r   = 0.40;
    cap_h   = 0.45;
    overlap = 0.05;

    L = max(norm(v), 0.001);
    ang = atan2(v[1], v[0]);

    // Build arrow along +X (easier: no 90° remap needed), then rotate in XY by ang.
    module arrow_along_x() {
        union() {
            // Main rod from x=0 to x=L-tip_len (with overlap into tip)
            translate([ (L - tip_len + overlap)/2, 0, 0 ])
                rotate([0, 90, 0])
                    cylinder(h = max(L - tip_len + overlap, 0.001), r = rod_r, center = true);

            // Base cap at x=0 (overlaps rod)
            translate([ -cap_h/2 + overlap, 0, 0 ])
                rotate([0, 90, 0])
                    cylinder(h = cap_h + overlap, r = cap_r, center = true);

            // Tip (cone) from x=L-tip_len to x=L (overlaps rod)
            translate([ L - tip_len, 0, 0 ])
                rotate([0, 90, 0])
                    cylinder(h = tip_len, r1 = tip_r, r2 = 0, center = false);

            // Collar ring just before tip (overlaps rod/tip junction)
            translate([ L - tip_len - cap_h/2 + overlap, 0, 0 ])
                rotate([0, 90, 0])
                    cylinder(h = cap_h, r = cap_r, center = true);
        }
    }

    rotate([0, 0, ang]) arrow_along_x();
}

axial_reference([5.21, 2.72, 0]);