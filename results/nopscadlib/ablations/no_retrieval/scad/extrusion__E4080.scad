// 40x80 aluminium extrusion profile, 100mm long
// Featureful, standard-ish 40x80 T-slot style approximation.
// One connected solid; all placements derived from dimensions.

$fn = 96;

// ---------------- Parameters ----------------
profile_W = 40.0;   // X
profile_H = 80.0;   // Y
length_L  = 100.0;  // Z

wall_t    = 2.6;    // outer wall thickness
web_t     = 2.4;    // internal web thickness (keeps model connected)
slot_open = 8.2;    // slot mouth opening (at surface)
slot_neck = 5.8;    // neck width just inside mouth
slot_depth= 12.0;   // depth from outer face to inner slot cavity
slot_cav_w= 14.0;   // inner cavity width (T-nut area)
slot_cav_d= 6.0;    // inner cavity depth (beyond neck)

center_void_W = 18.0;
center_void_H = 58.0;

corner_r  = 1.0;    // small outer corner rounding (approx)
detail_r  = 1.2;    // internal relief radius
overlap   = 0.25;   // robust boolean overlap

// ---------------- Helpers ----------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

minHalf = min(profile_W, profile_H)/2;

// Clamp to keep valid geometry
wall_t_eff = clamp(wall_t, 1.0, minHalf-1.0);
web_t_eff  = clamp(web_t,  1.0, minHalf-1.0);

slot_depth_eff = clamp(slot_depth, 2.0, minHalf - wall_t_eff - 2.0);
slot_open_eff  = clamp(slot_open,  2.0, min(profile_W, profile_H) - 2*wall_t_eff - 2.0);
slot_neck_eff  = clamp(slot_neck,  2.0, slot_open_eff - 0.5);
slot_cav_w_eff = clamp(slot_cav_w, slot_neck_eff + 0.5, min(profile_W, profile_H) - 2*wall_t_eff - 1.0);
slot_cav_d_eff = clamp(slot_cav_d, 2.0, slot_depth_eff - 1.0);

center_void_W_eff = clamp(center_void_W, 6.0, profile_W - 2*wall_t_eff - 2*web_t_eff - 2.0);
center_void_H_eff = clamp(center_void_H, 6.0, profile_H - 2*wall_t_eff - 2*web_t_eff - 2.0);

corner_r_eff = clamp(corner_r, 0.0, minHalf-0.5);
detail_r_eff = clamp(detail_r, 0.0, 3.0);

// 2D rounded rectangle (for outer silhouette)
module rounded_rect_2d(w, h, r) {
    r2 = clamp(r, 0, min(w,h)/2 - 0.01);
    if (r2 <= 0)
        square([w,h], center=true);
    else
        offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

// ---------------- Base body ----------------
module extrusion_body() {
    // Slightly rounded outer corners to look more like real extrusion
    linear_extrude(height=length_L, center=true)
        rounded_rect_2d(profile_W, profile_H, corner_r_eff);
}

// ---------------- Internal voids ----------------
module internal_void_center() {
    cube([center_void_W_eff, center_void_H_eff, length_L + 2*overlap], center=true);
}

// Internal webs to keep a realistic connected profile (material left behind)
// (These are NOT subtracted; they remain as solid.)
module internal_webs_solid() {
    union() {
        // Vertical web (along Y)
        cube([web_t_eff, profile_H - 2*wall_t_eff, length_L], center=true);
        // Horizontal web (along X)
        cube([profile_W - 2*wall_t_eff, web_t_eff, length_L], center=true);
    }
}

// ---------------- T-slot cutters (subtracted) ----------------
// Each face gets a "T" shaped channel: mouth -> neck -> cavity.
// Implemented as union of rectangles, positioned by formulas.

module tslot_cutter_face(dir=[0,1,0]) {
    // dir indicates outward normal: [0,1,0]=top, [0,-1,0]=bottom, [1,0,0]=right, [-1,0,0]=left
    // Build in local coordinates where +Y is outward, then rotate to face.
    // Local: profile spans X (width) and Y (thickness into part), extruded along Z.

    // Mouth thickness (small) and neck/cavity depths
    mouth_d = wall_t_eff + 0.8; // small cut through outer wall to open slot
    mouth_d_eff = clamp(mouth_d, 1.0, slot_depth_eff-1.0);

    // Ensure cavity sits inside the slot depth
    neck_d = slot_depth_eff - slot_cav_d_eff;
    neck_d_eff = clamp(neck_d, 1.0, slot_depth_eff-1.0);

    // Local placement: outer surface at y = +profile_face/2
    // We'll place cutters so their outermost face slightly exceeds the surface (overlap).
    module local_cutter() {
        union() {
            // Mouth opening (at surface)
            translate([0, (profile_H/2) - mouth_d_eff/2 + overlap/2, 0])
                cube([slot_open_eff, mouth_d_eff + overlap, length_L + 2*overlap], center=true);

            // Neck (narrower) from just inside mouth to cavity start
            translate([0,
                       (profile_H/2) - mouth_d_eff - neck_d_eff/2,
                       0])
                cube([slot_neck_eff, neck_d_eff + overlap, length_L + 2*overlap], center=true);

            // Inner cavity (wider) deeper inside
            translate([0,
                       (profile_H/2) - mouth_d_eff - neck_d_eff - slot_cav_d_eff/2,
                       0])
                cube([slot_cav_w_eff, slot_cav_d_eff + overlap, length_L + 2*overlap], center=true);
        }
    }

    // Rotate local cutter to requested face
    // Local assumes top face (+Y). Map to other faces.
    if (dir[0]==0 && dir[1]==1) {
        local_cutter();
    } else if (dir[0]==0 && dir[1]==-1) {
        rotate([0,0,180]) local_cutter();
    } else if (dir[0]==1 && dir[1]==0) {
        rotate([0,0,-90]) local_cutter();
    } else if (dir[0]==-1 && dir[1]==0) {
        rotate([0,0,90]) local_cutter();
    } else {
        local_cutter();
    }
}

// For left/right faces, we need the local cutter to use profile_W as "height" instead of profile_H.
// Easiest: reuse same local cutter but swap axes by rotating 90° about Z already handled above,
// however local cutter uses profile_H/2 for surface position. So we provide two variants.

module tslot_cutter_topbottom(sign=1) { // sign=+1 top, -1 bottom
    mouth_d = clamp(wall_t_eff + 0.8, 1.0, slot_depth_eff-1.0);
    neck_d  = clamp(slot_depth_eff - slot_cav_d_eff, 1.0, slot_depth_eff-1.0);

    union() {
        // Mouth
        translate([0, sign*(profile_H/2 - mouth_d/2 + overlap/2), 0])
            cube([slot_open_eff, mouth_d + overlap, length_L + 2*overlap], center=true);
        // Neck
        translate([0, sign*(profile_H/2 - mouth_d - neck_d/2), 0])
            cube([slot_neck_eff, neck_d + overlap, length_L + 2*overlap], center=true);
        // Cavity
        translate([0, sign*(profile_H/2 - mouth_d - neck_d - slot_cav_d_eff/2), 0])
            cube([slot_cav_w_eff, slot_cav_d_eff + overlap, length_L + 2*overlap], center=true);
    }
}

module tslot_cutter_leftright(sign=1) { // sign=+1 right, -1 left
    mouth_d = clamp(wall_t_eff + 0.8, 1.0, slot_depth_eff-1.0);
    neck_d  = clamp(slot_depth_eff - slot_cav_d_eff, 1.0, slot_depth_eff-1.0);

    union() {
        // Mouth
        translate([sign*(profile_W/2 - mouth_d/2 + overlap/2), 0, 0])
            cube([mouth_d + overlap, slot_open_eff, length_L + 2*overlap], center=true);
        // Neck
        translate([sign*(profile_W/2 - mouth_d - neck_d/2), 0, 0])
            cube([neck_d + overlap, slot_neck_eff, length_L + 2*overlap], center=true);
        // Cavity
        translate([sign*(profile_W/2 - mouth_d - neck_d - slot_cav_d_eff/2), 0, 0])
            cube([slot_cav_d_eff + overlap, slot_cav_w_eff, length_L + 2*overlap], center=true);
    }
}

module all_tslots_cutters() {
    union() {
        tslot_cutter_topbottom(+1);
        tslot_cutter_topbottom(-1);
        tslot_cutter_leftright(+1);
        tslot_cutter_leftright(-1);
    }
}

// Internal reliefs (small cylinders) to mimic extrusion fillets/reliefs
module internal_reliefs_cutters() {
    if (detail_r_eff > 0) {
        // Place near inner corners of the outer wall (not at the center void corners)
        // These are SUBTRACTED to create small reliefs.
        for (xs = [-1, 1])
            for (ys = [-1, 1])
                translate([xs*(profile_W/2 - wall_t_eff - detail_r_eff),
                           ys*(profile_H/2 - wall_t_eff - detail_r_eff),
                           0])
                    cylinder(r=detail_r_eff, h=length_L + 2*overlap, center=true);
    }
}

// ---------------- Final model ----------------
module complete_model() {
    // Build as: outer body MINUS (center void + t-slots + small reliefs) PLUS internal webs
    // Use union at top-level to ensure one connected solid (webs connect to outer walls).
    difference() {
        union() {
            extrusion_body();
            internal_webs_solid();
        }
        union() {
            internal_void_center();
            all_tslots_cutters();
            internal_reliefs_cutters();
        }
    }
}

complete_model();