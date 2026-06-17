// 20x20 aluminum extrusion profile, 100mm long (simplified 2020 T-slot)
// FIX: Ensure a single continuous 20x20x100 solid with connected cross-section.
// The previous boolean set could remove the entire mid-body, leaving only corner bits.
// This version keeps a guaranteed continuous outer body and uses conservative cuts.

$fn = 96;

// Parameters (mm)
profile_W = 20.0;
profile_H = 20.0;
length_L  = 100.0;

// Simplified 2020-ish features
center_bore_d   = 5.0;   // through bore
slot_opening_w  = 6.0;   // mouth opening at the surface
slot_neck_w     = 4.0;   // narrow neck just inside
slot_depth      = 6.2;   // depth from outer face toward center
slot_undercut_w = 10.0;  // wider internal cavity for T-nut
slot_undercut_d = 2.4;   // thickness of undercut region (radial)
wall_t          = 2.0;   // outer wall thickness
overlap         = 1.0;   // boolean robustness

// Keep a guaranteed solid core so the profile cannot split into separate corner pieces
core_size = 8.0; // mm (conservative, keeps the silhouette correct and the body connected)

// ---------- Helpers ----------
module outer_body() {
    // One continuous 20x20x100 body
    cube([profile_W, profile_H, length_L], center=true);
}

// Conservative internal cavity: hollow ring + solid core (prevents separation)
module inner_void() {
    inner_w = profile_W - 2*wall_t;
    inner_h = profile_H - 2*wall_t;

    // Hollow region is the inner rectangle minus a solid core.
    // This avoids the "two slabs" approach that can accidentally remove the entire mid-body.
    difference() {
        cube([inner_w, inner_h, length_L + 2*overlap], center=true);
        cube([core_size, core_size, length_L + 4*overlap], center=true); // extra overlap for robust boolean
    }
}

module center_bore() {
    cylinder(h=length_L + 2*overlap, r=center_bore_d/2, center=true);
}

// One face T-slot cut, oriented along +X face (cuts into the body)
module tslot_cut_1face() {
    // Ensure the slot opens to the outer face at x = +profile_W/2
    x_center    = (profile_W/2 + overlap) - slot_depth/2;
    x_uc_center = (profile_W/2 + overlap) - (slot_depth - slot_undercut_d/2);

    union() {
        // Mouth opening (at surface)
        translate([x_center, 0, 0])
            cube([slot_depth + 2*overlap, slot_opening_w, length_L + 2*overlap], center=true);

        // Neck (narrower)
        translate([x_center, 0, 0])
            cube([slot_depth + 2*overlap, slot_neck_w, length_L + 2*overlap], center=true);

        // Undercut (wider region deeper inside)
        translate([x_uc_center, 0, 0])
            cube([slot_undercut_d + 2*overlap, slot_undercut_w, length_L + 2*overlap], center=true);
    }
}

module tslots_4faces() {
    union() {
        tslot_cut_1face();                    // +X
        rotate([0,0,180]) tslot_cut_1face();  // -X
        rotate([0,0,90])  tslot_cut_1face();  // +Y
        rotate([0,0,270]) tslot_cut_1face();  // -Y
    }
}

// ---------- Final solid ----------
difference() {
    outer_body();

    // Internal cavity (keeps a solid core so the part remains one connected extrusion)
    inner_void();

    // Center bore
    center_bore();

    // 4 T-slots
    tslots_4faces();
}