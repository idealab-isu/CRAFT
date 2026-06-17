// 15x15 aluminium extrusion profile, 100mm long
// Robust, visible geometry: 15x15 outer with 4 shallow T-slot-like grooves

$fn = 32;

// Parameters (mm)
profile_W = 15.0;
profile_H = 15.0;
length_L  = 100.0;

// Groove parameters (kept conservative so the body remains clearly visible)
slot_depth = 2.0;   // how far the groove cuts in from each face
slot_width = 5.0;   // main groove width
slot_lip   = 2.0;   // narrower "lip" width near the outer face

eps = 0.05;         // small overlap for clean booleans

module extrusion_body() {
    cube([profile_W, profile_H, length_L], center=true);
}

// Cut a single face groove on +X or -X
module face_groove_x(sign=1) {
    // Place groove so its outer face is slightly outside the profile face (guaranteed cut)
    x_center = sign * (profile_W/2 - slot_depth/2 + eps/2);

    // Lip is closer to the outer face than the main slot
    lip_center = sign * (profile_W/2 - (slot_depth*0.35)/2 + eps/2);

    union() {
        // Main rectangular groove
        translate([x_center, 0, 0])
            cube([slot_depth + eps, slot_width, length_L + 2*eps], center=true);

        // Narrower lip near the opening
        translate([lip_center, 0, 0])
            cube([slot_depth*0.35 + eps, slot_lip, length_L + 2*eps], center=true);
    }
}

// Cut a single face groove on +Y or -Y
module face_groove_y(sign=1) {
    y_center = sign * (profile_H/2 - slot_depth/2 + eps/2);
    lip_center = sign * (profile_H/2 - (slot_depth*0.35)/2 + eps/2);

    union() {
        translate([0, y_center, 0])
            cube([slot_width, slot_depth + eps, length_L + 2*eps], center=true);

        translate([0, lip_center, 0])
            cube([slot_lip, slot_depth*0.35 + eps, length_L + 2*eps], center=true);
    }
}

module all_grooves() {
    union() {
        face_groove_x( 1);
        face_groove_x(-1);
        face_groove_y( 1);
        face_groove_y(-1);
    }
}

color("Silver")
difference() {
    extrusion_body();
    all_grooves();
}