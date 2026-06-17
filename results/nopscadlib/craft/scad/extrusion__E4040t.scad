// 40x40 aluminum extrusion (generic 8mm-slot style), 100mm long
// Single connected solid only (no floating helper parts)

$fn = 64;

// Parameters (kept, but defaulted to requested target)
cross_section_width_mm  = 40.0;
cross_section_height_mm = 40.0;
length_mm              = 100.0;

// Profile details (typical-ish for 40-series)
slot_opening_mm        = 8.0;   // mouth opening at the outer face
slot_depth_mm          = 12.0;  // how far slot cavity goes inward from outer face
slot_neck_mm           = 4.0;   // narrow neck inside the slot
center_bore_diameter_mm= 8.0;   // center through-bore
corner_fillet_radius_mm= 2.0;   // outer corner rounding (approx)
overlap_mm             = 0.2;   // small overlap for robust boolean ops

// Derived
w = cross_section_width_mm;
h = cross_section_height_mm;
L = length_mm;

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

// 2D cross-section of the extrusion (to be linearly extruded)
module extrusion_cross_section_2d() {
    // Keep everything formula-based and symmetric
    outer_r = corner_fillet_radius_mm;

    // Slot geometry (2D)
    mouth_w = slot_opening_mm;
    neck_w  = slot_neck_mm;

    // Ensure slot depth doesn't exceed half-width
    sd = min(slot_depth_mm, min(w, h)/2 - 1);

    // Place slot so its outer edge is flush with the outer face, with a tiny overlap
    // Outer face at +w/2 (or +h/2). Slot rectangle center is at:
    // x = +w/2 - sd/2 + overlap
    slot_center = (w/2 - sd/2 + overlap_mm);

    // Neck is slightly more inward than the mouth cavity
    neck_depth = sd * 0.55;
    neck_center = (w/2 - neck_depth/2 + overlap_mm);

    // Internal voids to make it look like a real extrusion (lightweight approximation)
    // Four inner pockets near corners
    pocket_inset = 8.0;
    pocket_r = 3.0;

    difference() {
        // Outer boundary
        rounded_rect_2d(w, h, outer_r);

        // Center bore
        circle(d = center_bore_diameter_mm);

        // Four T-slots (subtract)
        union() {
            // +X slot
            translate([ slot_center, 0])
                square([sd + 2*overlap_mm, mouth_w], center=true);
            translate([ neck_center, 0])
                square([neck_depth + 2*overlap_mm, neck_w], center=true);

            // -X slot
            translate([-slot_center, 0])
                square([sd + 2*overlap_mm, mouth_w], center=true);
            translate([-neck_center, 0])
                square([neck_depth + 2*overlap_mm, neck_w], center=true);

            // +Y slot
            translate([0, slot_center])
                square([mouth_w, sd + 2*overlap_mm], center=true);
            translate([0, neck_center])
                square([neck_w, neck_depth + 2*overlap_mm], center=true);

            // -Y slot
            translate([0, -slot_center])
                square([mouth_w, sd + 2*overlap_mm], center=true);
            translate([0, -neck_center])
                square([neck_w, neck_depth + 2*overlap_mm], center=true);
        }

        // Inner corner pockets (subtract) to avoid a "solid block" look
        // Positioned by formulas from dimensions
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(w/2 - pocket_inset), sy*(h/2 - pocket_inset)])
                circle(r=pocket_r);
        }

        // Small diagonal reliefs (subtract) to hint at internal webs
        // (kept subtle so the body remains one connected solid)
        relief_w = 6.0;
        relief_h = 2.5;
        relief_off = 10.0;
        for (a = [45, 135, 225, 315]) {
            rotate(a)
                translate([relief_off, 0])
                    square([relief_w, relief_h], center=true);
        }
    }
}

module extrusion_40x40_L() {
    color("Silver")
        linear_extrude(height=L, center=true, convexity=10)
            extrusion_cross_section_2d();
}

// Single connected solid output
extrusion_40x40_L();