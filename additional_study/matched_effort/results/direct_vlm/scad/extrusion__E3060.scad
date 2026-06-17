$fn = 96;

// ===== Parameters (mm) =====
length = 100;   // extrusion length (Z)
w = 60;         // X size
h = 30;         // Y size

// Typical 30x60-ish profile features (simplified but not just a tube)
wall = 2.0;             // outer wall thickness
slot_open_w = 8.0;      // slot mouth width at surface
slot_depth = 7.0;       // how far slot cuts inward from each face
slot_cavity_w = 14.0;   // wider internal cavity width (T-slot undercut)
slot_cavity_depth = 3.5;// depth of the wider cavity (from slot bottom inward)
center_hole_d = 6.0;    // center bore

// Internal webs to keep one connected solid and look like extrusion
web_t = 2.0;            // web thickness
web_clear = 1.0;        // clearance from inner cavity to web ends

eps = 0.05;

// 2D T-slot cut oriented to cut from +Y face inward (toward -Y)
module tslot2d(face_len, depth, open_w, cavity_w, cavity_depth) {
    // Build a "T" void: narrow mouth + wider undercut near the bottom.
    // Coordinates: y=0 at face, y increases inward.
    union() {
        // Mouth
        translate([-open_w/2, 0])
            square([open_w, depth + eps], center=false);

        // Undercut cavity near the bottom of the slot
        translate([-cavity_w/2, depth - cavity_depth])
            square([cavity_w, cavity_depth + eps], center=false);
    }
}

module extrusion_30x60(len=100) {
    // Create 2D cross-section then extrude along Z
    linear_extrude(height=len, center=false, convexity=10)
    difference() {
        // ---- Solid base: outer rectangle + internal webs (so it's not just a tube) ----
        union() {
            // Outer boundary
            square([w, h], center=true);

            // Internal webs (cross) to mimic typical extrusion structure
            // Vertical web
            square([web_t, (h - 2*wall) - 2*web_clear], center=true);
            // Horizontal web
            square([(w - 2*wall) - 2*web_clear, web_t], center=true);
        }

        // ---- Main inner cavity (keeps outer walls) ----
        square([w - 2*wall, h - 2*wall], center=true);

        // ---- Center bore ----
        circle(d=center_hole_d);

        // ---- T-slots on all four faces (2D cuts) ----
        // Top (+Y): place slot so its mouth starts at y=+h/2 and cuts inward
        translate([0, h/2 - slot_depth])
            tslot2d(w, slot_depth, slot_open_w, slot_cavity_w, slot_cavity_depth);

        // Bottom (-Y)
        mirror([0, 1, 0])
            translate([0, h/2 - slot_depth])
                tslot2d(w, slot_depth, slot_open_w, slot_cavity_w, slot_cavity_depth);

        // Right (+X): rotate slot to cut from +X inward
        rotate(90)
            translate([0, w/2 - slot_depth])
                tslot2d(h, slot_depth, slot_open_w, slot_cavity_w, slot_cavity_depth);

        // Left (-X)
        rotate(90)
            mirror([0, 1, 0])
                translate([0, w/2 - slot_depth])
                    tslot2d(h, slot_depth, slot_open_w, slot_cavity_w, slot_cavity_depth);
    }
}

extrusion_30x60(length);