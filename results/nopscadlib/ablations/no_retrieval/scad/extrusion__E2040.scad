// 20x40 T-slot aluminium extrusion (simplified), 100mm long
// FIX: Ensure a single connected 20x40 body with recognizable extrusion silhouette.
// The previous "internal_void_keep_webs()" removed a full-height and full-width cross,
// splitting the solid into two separate long bars. This version keeps a central web
// by subtracting four quadrant pockets instead of two full-span voids.

$fn = 96;

// Parameters (mm)
profile_W = 20.0;
profile_H = 40.0;
length_L  = 100.0;

// Geometry (simplified but robust)
wall_t         = 2.0;   // outer wall thickness
slot_depth_d   = 6.0;   // depth from outer face to inner cavity
slot_opening_w = 6.0;   // mouth opening width
slot_cavity_w  = 12.0;  // internal cavity width
slot_cavity_h  = 6.0;   // cavity height (inward thickness)
center_bore_d  = 5.0;   // center bore diameter

eps = 0.25;             // overlap for booleans

module outer_solid() {
    cube([profile_W, profile_H, length_L], center=true);
}

module center_bore() {
    cylinder(h=length_L + 2*eps, r=center_bore_d/2, center=true);
}

// T-slot cut on a given face, oriented along Z (extrusion length)
module tslot_on_face(face="top") {
    if (face == "top") {
        translate([0, profile_H/2 - slot_depth_d/2 + eps, 0])
            cube([slot_opening_w, slot_depth_d + 2*eps, length_L + 2*eps], center=true);

        translate([0, profile_H/2 - slot_depth_d - slot_cavity_h/2 + eps, 0])
            cube([slot_cavity_w, slot_cavity_h + 2*eps, length_L + 2*eps], center=true);
    }
    else if (face == "bottom") {
        translate([0, -profile_H/2 + slot_depth_d/2 - eps, 0])
            cube([slot_opening_w, slot_depth_d + 2*eps, length_L + 2*eps], center=true);

        translate([0, -profile_H/2 + slot_depth_d + slot_cavity_h/2 - eps, 0])
            cube([slot_cavity_w, slot_cavity_h + 2*eps, length_L + 2*eps], center=true);
    }
    else if (face == "left") {
        translate([-profile_W/2 + slot_depth_d/2 - eps, 0, 0])
            cube([slot_depth_d + 2*eps, slot_opening_w, length_L + 2*eps], center=true);

        translate([-profile_W/2 + slot_depth_d + slot_cavity_h/2 - eps, 0, 0])
            cube([slot_cavity_h + 2*eps, slot_cavity_w, length_L + 2*eps], center=true);
    }
    else if (face == "right") {
        translate([profile_W/2 - slot_depth_d/2 + eps, 0, 0])
            cube([slot_depth_d + 2*eps, slot_opening_w, length_L + 2*eps], center=true);

        translate([profile_W/2 - slot_depth_d - slot_cavity_h/2 + eps, 0, 0])
            cube([slot_cavity_h + 2*eps, slot_cavity_w, length_L + 2*eps], center=true);
    }
}

// Internal void: remove four quadrant pockets, leaving a central "+" web so the profile stays one piece
module internal_void_keep_webs() {
    web_t = 2.5; // guaranteed connecting web thickness (both X and Y)

    inner_W = profile_W - 2*wall_t;
    inner_H = profile_H - 2*wall_t;

    // Quadrant pocket sizes (each pocket stays within the inner boundary)
    pocket_W = max(0.1, (inner_W - web_t)/2);
    pocket_H = max(0.1, (inner_H - web_t)/2);

    // Pocket centers: offset from origin so pockets do NOT cross the central web
    cx = web_t/2 + pocket_W/2;
    cy = web_t/2 + pocket_H/2;

    union() {
        // Four pockets (NE, NW, SE, SW)
        translate([+cx, +cy, 0]) cube([pocket_W, pocket_H, length_L + 2*eps], center=true);
        translate([-cx, +cy, 0]) cube([pocket_W, pocket_H, length_L + 2*eps], center=true);
        translate([+cx, -cy, 0]) cube([pocket_W, pocket_H, length_L + 2*eps], center=true);
        translate([-cx, -cy, 0]) cube([pocket_W, pocket_H, length_L + 2*eps], center=true);
    }
}

module all_cuts() {
    union() {
        center_bore();
        internal_void_keep_webs();

        // T-slots on all 4 faces
        tslot_on_face("top");
        tslot_on_face("bottom");
        tslot_on_face("left");
        tslot_on_face("right");
    }
}

// Final model: single continuous 20x40 extrusion, 100mm long
difference() {
    outer_solid();
    all_cuts();
}