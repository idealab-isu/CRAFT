// 20x60 aluminium extrusion profile, 100mm long (simplified, correct 20:60 cross-section)

// Parameters
profile_W = 20;   // X (mm)
profile_H = 60;   // Y (mm)
length_L  = 100;  // Z (mm)

// Small overlap to avoid coplanar artifacts
eps = 0.02;

// Profile detail parameters (simplified but proportionally plausible)
wall_t      = 2.0;   // outer wall thickness
slot_open   = 6.0;   // T-slot mouth opening at surface
slot_depth  = 6.0;   // depth from surface to inner cavity
slot_cavity = 12.0;  // inner cavity width behind the mouth
core_r      = 6.0;   // central bore radius

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Clamp slot sizes to fit each face independently (20mm faces vs 60mm faces)
slot_open_W   = clamp(slot_open, 2, profile_W - 2*wall_t - 1);
slot_open_H   = clamp(slot_open, 2, profile_H - 2*wall_t - 1);

slot_depth_W  = clamp(slot_depth, 2, profile_W/2 - wall_t - 1);
slot_depth_H  = clamp(slot_depth, 2, profile_H/2 - wall_t - 1);

slot_cavity_W = clamp(slot_cavity, slot_open_W + 2, profile_W - 2*wall_t - 2);
slot_cavity_H = clamp(slot_cavity, slot_open_H + 2, profile_H - 2*wall_t - 2);

module tslot_on_face(face="top", L=length_L) {
    // Cuts a simplified T-slot on one face of the 20x60 rectangle.
    // All translate() values are derived from profile dimensions.
    if (face == "top") {
        // Opens to +Y face (width along X)
        translate([0, profile_H/2 - slot_depth_H/2 + eps, 0])
            cube([slot_open_H, slot_depth_H + 2*eps, L + 2*eps], center=true);

        translate([0, profile_H/2 - slot_depth_H - wall_t - slot_depth_H/2 + eps, 0])
            cube([slot_cavity_H, slot_depth_H + 2*eps, L + 2*eps], center=true);
    } else if (face == "bottom") {
        // Opens to -Y face
        translate([0, -profile_H/2 + slot_depth_H/2 - eps, 0])
            cube([slot_open_H, slot_depth_H + 2*eps, L + 2*eps], center=true);

        translate([0, -profile_H/2 + slot_depth_H + wall_t + slot_depth_H/2 - eps, 0])
            cube([slot_cavity_H, slot_depth_H + 2*eps, L + 2*eps], center=true);
    } else if (face == "right") {
        // Opens to +X face (width along Y)
        translate([profile_W/2 - slot_depth_W/2 + eps, 0, 0])
            cube([slot_depth_W + 2*eps, slot_open_W, L + 2*eps], center=true);

        translate([profile_W/2 - slot_depth_W - wall_t - slot_depth_W/2 + eps, 0, 0])
            cube([slot_depth_W + 2*eps, slot_cavity_W, L + 2*eps], center=true);
    } else if (face == "left") {
        // Opens to -X face
        translate([-profile_W/2 + slot_depth_W/2 - eps, 0, 0])
            cube([slot_depth_W + 2*eps, slot_open_W, L + 2*eps], center=true);

        translate([-profile_W/2 + slot_depth_W + wall_t + slot_depth_W/2 - eps, 0, 0])
            cube([slot_depth_W + 2*eps, slot_cavity_W, L + 2*eps], center=true);
    }
}

module extrusion_20x60(L=length_L) {
    color("Silver")
    difference() {
        // Outer body: correct 20 x 60 cross-section, length L
        cube([profile_W, profile_H, L], center=true);

        // Central bore (through)
        cylinder(r=core_r, h=L + 2*eps, center=true, $fn=64);

        // Four T-slots: one on each face (top/bottom use 60mm face, left/right use 20mm face)
        tslot_on_face("top",    L);
        tslot_on_face("bottom", L);
        tslot_on_face("left",   L);
        tslot_on_face("right",  L);

        // Corner relief pockets (kept inside walls; derived from dimensions)
        pocket_r = 4.5;
        pocket_x = profile_W/2 - wall_t - pocket_r - 0.5;
        pocket_y = profile_H/2 - wall_t - pocket_r - 0.5;

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*pocket_x, sy*pocket_y, 0])
                cylinder(r=pocket_r, h=L + 2*eps, center=true, $fn=48);
        }
    }
}

// Render
extrusion_20x60(length_L);