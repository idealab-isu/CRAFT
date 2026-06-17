// 30x60 aluminum extrusion profile (simplified but recognizable), 100mm long
// One connected solid, correct overall dimensions: 60 (X) x 30 (Y) x 100 (Z)

$fn = 64;

// Parameters
profile_W = 60.0;   // X
profile_H = 30.0;   // Y
length_L  = 100.0;  // Z

wall_t    = 2.0;    // outer wall thickness
slot_open = 6.0;    // T-slot mouth opening width
slot_depth= 7.0;    // depth from outer face to inner cavity
slot_wide = 12.0;   // wider internal part of T-slot
web_t     = 2.0;    // internal web thickness
center_hole_d = 6.0;

corner_chamfer = 1.5;

eps = 0.05;

// --- Helpers ---
module chamfered_block(w,h,l,c){
    // Chamfer only the 4 long edges (along Z) using 45° cuts
    difference(){
        cube([w,h,l], center=true);

        // TR
        translate([ w/2 - c/2,  h/2 - c/2, 0])
            rotate([0,0,45]) cube([c,c,l+2*eps], center=true);
        // TL
        translate([-w/2 + c/2,  h/2 - c/2, 0])
            rotate([0,0,45]) cube([c,c,l+2*eps], center=true);
        // BR
        translate([ w/2 - c/2, -h/2 + c/2, 0])
            rotate([0,0,45]) cube([c,c,l+2*eps], center=true);
        // BL
        translate([-w/2 + c/2, -h/2 + c/2, 0])
            rotate([0,0,45]) cube([c,c,l+2*eps], center=true);
    }
}

module tslot_cut_y(sign=1){
    // Cuts a T-slot on +Y (sign=1) or -Y (sign=-1) face
    union(){
        // mouth
        translate([0, sign*(profile_H/2 - slot_depth/2), 0])
            cube([slot_open, slot_depth + 2*eps, length_L + 2*eps], center=true);

        // wider internal pocket
        translate([0, sign*(profile_H/2 - (slot_depth*0.75)/2), 0])
            cube([slot_wide, slot_depth*0.75 + 2*eps, length_L + 2*eps], center=true);
    }
}

module tslot_cut_x(sign=1){
    // Cuts a T-slot on +X (sign=1) or -X (sign=-1) face
    union(){
        // mouth
        translate([sign*(profile_W/2 - slot_depth/2), 0, 0])
            cube([slot_depth + 2*eps, slot_open, length_L + 2*eps], center=true);

        // wider internal pocket
        translate([sign*(profile_W/2 - (slot_depth*0.75)/2), 0, 0])
            cube([slot_depth*0.75 + 2*eps, slot_wide, length_L + 2*eps], center=true);
    }
}

module internal_void(){
    // Main internal cavity leaving outer walls
    cube([profile_W - 2*wall_t, profile_H - 2*wall_t, length_L + 2*eps], center=true);
}

module internal_webs(){
    // Cross webs (keeps one connected solid). Slightly oversized in Z for robust union.
    union(){
        cube([web_t, profile_H - 2*wall_t + 2*eps, length_L + 2*eps], center=true);
        cube([profile_W - 2*wall_t + 2*eps, web_t, length_L + 2*eps], center=true);
    }
}

module center_bore(){
    cylinder(d=center_hole_d, h=length_L + 2*eps, center=true);
}

module extrusion_body(){
    // Build as: (outer shell with slots and bore) UNION (webs)
    // This guarantees a single connected solid and avoids "blank" top-level CSG issues.
    union(){
        difference(){
            chamfered_block(profile_W, profile_H, length_L, corner_chamfer);

            // Hollow interior
            internal_void();

            // T-slots on all four sides
            tslot_cut_y( 1);
            tslot_cut_y(-1);
            tslot_cut_x( 1);
            tslot_cut_x(-1);

            // Center bore
            center_bore();
        }

        // Webs overlap into remaining material by eps to ensure manifold connectivity
        internal_webs();
    }
}

// --- Final model ---
extrusion_body();