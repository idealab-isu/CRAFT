// 40x40 T-slot aluminium extrusion (simplified, standard-looking), 100mm long
// One connected solid; all placements derived from dimensions.

$fn = 96;

// Parameters
profile_W = 40.0;
profile_H = 40.0;
length_L  = 100.0;

// Typical 40-series features (approximate)
corner_radius_r = 2.0;

center_bore_d = 6.8;          // through bore
slot_opening_w = 8.0;         // mouth width at outer face
slot_opening_depth = 2.2;     // how far the narrow mouth goes in
slot_cavity_w = 14.0;         // wider internal cavity width
slot_cavity_depth = 9.0;      // depth of cavity from outer face

// Keep enough material between cavity and center bore
slot_web_thickness = 2.0;

overlap_eps = 0.2;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded outer body (2D) then extrude
module rounded_rect_2d(w, h, r) {
    r2 = clamp(r, 0, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
    }
}

module outer_body() {
    linear_extrude(height=length_L, center=true)
        rounded_rect_2d(profile_W, profile_H, corner_radius_r);
}

module center_bore() {
    cylinder(h=length_L + 2*overlap_eps, r=center_bore_d/2, center=true);
}

// Single side T-slot cut (points outward along +X), then rotate for other sides
module tslot_cut_posX() {
    // Limit cavity depth so it doesn't break into the center bore web
    max_cavity_depth = profile_W/2 - center_bore_d/2 - slot_web_thickness;
    cav_d = clamp(slot_cavity_depth, 0, max_cavity_depth);

    // Mouth: narrow slot near the outer face
    mouth_center_x = profile_W/2 - slot_opening_depth/2;
    // Cavity: wider slot behind the mouth
    cavity_center_x = profile_W/2 - cav_d/2;

    union() {
        translate([mouth_center_x, 0, 0])
            cube([slot_opening_depth + 2*overlap_eps,
                  slot_opening_w,
                  length_L + 2*overlap_eps], center=true);

        translate([cavity_center_x, 0, 0])
            cube([cav_d + 2*overlap_eps,
                  slot_cavity_w,
                  length_L + 2*overlap_eps], center=true);
    }
}

module all_tslots() {
    union() {
        tslot_cut_posX();
        rotate([0,0,180]) tslot_cut_posX();
        rotate([0,0, 90]) tslot_cut_posX();
        rotate([0,0,-90]) tslot_cut_posX();
    }
}

// Final model
difference() {
    outer_body();
    center_bore();
    all_tslots();
}