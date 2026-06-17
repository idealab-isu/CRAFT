$fn = 64;

// 20x40 aluminum extrusion-like profile (simplified), 100mm long
// Cross-section: 20mm x 40mm with central bore and four T-slots (approximate)

length = 100;

w = 20;
h = 40;

// Outer corner radius (approx)
r_outer = 1.0;

// Wall thickness (approx)
wall = 2.0;

// Central bore (approx)
bore_d = 5.2;

// Slot parameters (approx)
slot_open = 6.0;     // opening at the face
slot_neck = 3.2;     // narrow neck
slot_depth = 6.5;    // depth from face inward
slot_head_w = 10.0;  // wider internal cavity
slot_head_d = 3.0;   // additional depth for head cavity

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r2);
    }
}

module tslot_cut_2d(face_w, face_h, along_x=true) {
    // Creates a T-slot cut from a face inward.
    // along_x=true means slot opens on +/-X faces; otherwise on +/-Y faces.
    // The slot is centered on the face.
    // Constructed as union of a tapered neck and a wider head cavity.
    if (along_x) {
        // Slot opens on +X face; caller can mirror for -X
        translate([face_w/2 - slot_depth/2, 0])
            square([slot_depth, slot_open], center=true);

        // Neck (narrower) slightly deeper
        translate([face_w/2 - (slot_depth + slot_head_d)/2, 0])
            square([slot_depth + slot_head_d, slot_neck], center=true);

        // Head cavity (wider) deeper inside
        translate([face_w/2 - (slot_depth + slot_head_d) + slot_head_d/2 - 0.01, 0])
            square([slot_head_d + 0.02, slot_head_w], center=true);
    } else {
        // Slot opens on +Y face; caller can mirror for -Y
        translate([0, face_h/2 - slot_depth/2])
            square([slot_open, slot_depth], center=true);

        translate([0, face_h/2 - (slot_depth + slot_head_d)/2])
            square([slot_neck, slot_depth + slot_head_d], center=true);

        translate([0, face_h/2 - (slot_depth + slot_head_d) + slot_head_d/2 - 0.01])
            square([slot_head_w, slot_head_d + 0.02], center=true);
    }
}

module profile_20x40_2d() {
    difference() {
        // Outer shape
        rounded_rect_2d(w, h, r_outer);

        // Inner hollow (approx)
        rounded_rect_2d(w - 2*wall, h - 2*wall, max(0, r_outer - 0.5));

        // Central bore
        circle(d=bore_d);

        // T-slots on all four faces (approx)
        // +X and -X
        tslot_cut_2d(w, h, along_x=true);
        mirror([1,0,0]) tslot_cut_2d(w, h, along_x=true);

        // +Y and -Y
        tslot_cut_2d(w, h, along_x=false);
        mirror([0,1,0]) tslot_cut_2d(w, h, along_x=false);
    }
}

linear_extrude(height=length, center=false, convexity=10)
    profile_20x40_2d();