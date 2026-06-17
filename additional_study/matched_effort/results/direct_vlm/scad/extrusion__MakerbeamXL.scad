$fn = 64;

// 15x15 aluminium extrusion profile, 100mm long (T-slot style)
length = 100;
size   = 15;

// Profile parameters (kept simple but clearly "T-slot-like")
wall   = 1.5;   // outer wall thickness
slot_w = 6.0;   // slot opening width on each face
slot_d = 4.0;   // depth of slot cut from each face
core   = 6.0;   // central square void size

eps = 0.02;

module extrusion15_profile_2d() {
    // Ensure we never subtract away the entire body
    assert(size > 0 && length > 0);
    assert(core < size - 2*wall);
    assert(slot_d < size/2 - wall/2);
    assert(slot_w < size - 2*wall);

    difference() {
        // Outer boundary (15 x 15)
        square([size, size], center=true);

        // Central void
        square([core, core], center=true);

        // Four face slots (cut-ins) - positioned by formula, not arbitrary
        for (a = [0, 90, 180, 270]) {
            rotate(a)
                translate([size/2 - slot_d/2 + eps, 0])
                    square([slot_d + 2*eps, slot_w], center=true);
        }

        // Corner reliefs: keep them inside the wall so the outer perimeter remains intact
        // (prevents accidental "blank" results from over-subtraction)
        corner_relief = min(2.0, max(0.8, wall - 0.2));
        corner_pos = size/2 - wall/2; // stays within the outer wall region
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*corner_pos, sy*corner_pos])
                square([corner_relief, corner_relief], center=true);
        }
    }
}

color([0.75, 0.78, 0.82])
linear_extrude(height=length, center=false, convexity=20)
    extrusion15_profile_2d();