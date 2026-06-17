$fn = 64;

// Aluminium extrusion profile: 30mm x 30mm cross-section, 100mm long
length = 100;
size   = 30;

// Profile parameters (approx. 3030 T-slot style)
slot_w      = 6.2;   // slot opening width at surface
slot_depth  = 7.0;   // depth of slot cut from each face
core_square = 12.0;  // central cavity size (square)
web_thick   = 2.0;   // material between core and slot pocket

module extrusion_3030(len=100, s=30) {
    // Derived pocket dimensions (kept connected by web_thick)
    pocket_w = 12.0;
    pocket_d = max(0.1, slot_depth - web_thick);

    // Small overlap to avoid coincident faces in boolean ops
    eps = 0.02;

    difference() {
        // Outer body centered at origin for reliable viewing/orientation
        translate([-s/2, -s/2, -len/2])
            cube([s, s, len], center=false);

        // Central cavity (runs full length)
        translate([-core_square/2, -core_square/2, -len/2 - eps])
            cube([core_square, core_square, len + 2*eps], center=false);

        // Four T-slot openings (one per face)
        // +X face slot
        translate([ s/2 - slot_depth, -slot_w/2, -len/2 - eps])
            cube([slot_depth + eps, slot_w, len + 2*eps], center=false);

        // -X face slot
        translate([-s/2 - eps, -slot_w/2, -len/2 - eps])
            cube([slot_depth + eps, slot_w, len + 2*eps], center=false);

        // +Y face slot
        translate([-slot_w/2,  s/2 - slot_depth, -len/2 - eps])
            cube([slot_w, slot_depth + eps, len + 2*eps], center=false);

        // -Y face slot
        translate([-slot_w/2, -s/2 - eps, -len/2 - eps])
            cube([slot_w, slot_depth + eps, len + 2*eps], center=false);

        // Relief pockets behind each slot (suggest undercut), leaving web_thick
        // +X pocket
        translate([ s/2 - pocket_d, -pocket_w/2, -len/2 - eps])
            cube([pocket_d + eps, pocket_w, len + 2*eps], center=false);

        // -X pocket
        translate([-s/2 - eps, -pocket_w/2, -len/2 - eps])
            cube([pocket_d + eps, pocket_w, len + 2*eps], center=false);

        // +Y pocket
        translate([-pocket_w/2,  s/2 - pocket_d, -len/2 - eps])
            cube([pocket_w, pocket_d + eps, len + 2*eps], center=false);

        // -Y pocket
        translate([-pocket_w/2, -s/2 - eps, -len/2 - eps])
            cube([pocket_w, pocket_d + eps, len + 2*eps], center=false);
    }
}

color([0.75, 0.78, 0.82])
extrusion_3030(length, size);