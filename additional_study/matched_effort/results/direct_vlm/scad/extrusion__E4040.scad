$fn = 96;

length = 100;
size   = 40;

module extrusion_4040(len=100, s=40) {
    // 40x40 aluminum extrusion (approx.) with 4 symmetric T-slots.
    // One connected solid: outer prism minus internal voids/slots.
    eps = 0.05;

    // Geometry (tuned to look like a typical 4040 profile)
    core_sq   = 14;    // central square void
    slot_open = 8.2;   // opening at the face
    slot_in   = 11.0;  // depth of narrow opening cut
    head_w    = 15.0;  // wider internal pocket width (T-head)
    head_in   = 17.0;  // depth of wider pocket from face
    corner_r  = 1.2;   // slight outer corner rounding (visual)

    // Helper: rounded square prism (keeps model robust and visible)
    module rounded_square_prism(w, h, r, z) {
        linear_extrude(height=z, center=false)
            offset(r=r)
                square([w-2*r, h-2*r], center=true);
    }

    color([0.75, 0.75, 0.78])
    difference() {
        // Outer body (centered in XY, extruded along +Z)
        translate([s/2, s/2, 0])
            rounded_square_prism(s, s, corner_r, len);

        // Central square void
        translate([s/2 - core_sq/2, s/2 - core_sq/2, -eps])
            cube([core_sq, core_sq, len + 2*eps], center=false);

        // Four symmetric T-slots (one per face)
        for (a = [0, 90, 180, 270]) {
            rotate([0, 0, a]) {
                // Narrow opening from face inward (face is at y=0 after rotation)
                translate([s/2 - slot_open/2, -eps, -eps])
                    cube([slot_open, slot_in + eps, len + 2*eps], center=false);

                // Wider internal pocket (T-head), starts at slot_in
                translate([s/2 - head_w/2, slot_in - eps, -eps])
                    cube([head_w, (head_in - slot_in) + 2*eps, len + 2*eps], center=false);
            }
        }

        // Small corner relief holes (common in many extrusions), kept inside walls
        hole = 3.2;
        inset = 6.0;
        for (ix = [inset, s - inset], iy = [inset, s - inset]) {
            translate([ix - hole/2, iy - hole/2, -eps])
                cube([hole, hole, len + 2*eps], center=false);
        }
    }
}

extrusion_4040(length, size);