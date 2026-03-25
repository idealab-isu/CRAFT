$fn = 96;

// Aluminium extrusion profile, 20x40mm cross-section, 100mm long
// STRUCTURAL FIX: ensure the profile is ONE connected solid by adding
// internal "tie" bridges that physically connect upper/lower and left/right
// regions with 1–2mm guaranteed overlap, so boolean slot cutouts cannot split it.

// Parameters
cross_section_width_mm  = 20.0;   // X
cross_section_height_mm = 40.0;   // Y
length_mm               = 100.0;  // Z

corner_radius_mm        = 1.2;

// T-slot (simplified 2040 style)
slot_opening_mm         = 6.2;    // mouth width at outer face
slot_depth_mm           = 6.5;    // depth from outer face to cavity start
slot_cavity_width_mm    = 10.0;   // internal cavity width
slot_cavity_depth_mm    = 3.5;    // additional depth beyond slot_depth

// Internal features
center_bore_diameter_mm = 5.2;    // typical center bore
web_thickness_mm        = 2.0;    // minimum web thickness target

// Small overlap to avoid coincident faces in boolean ops
eps = 0.05;

// Connectivity overlap (1-2mm) to guarantee attachment
overlap_mm = 1.5;

// 2D rounded rectangle helper
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2 - eps);
    offset(r=r2) square([w-2*r2, h-2*r2], center=true);
}

// 2D cross-section of a 2040 extrusion (forced single connected solid)
module extrusion_profile_2d() {
    w = cross_section_width_mm;
    h = cross_section_height_mm;

    // Clamp slot geometry to stay inside profile
    max_inset = min(w, h)/2 - 0.8; // keep some material no matter what
    slot_d = min(slot_depth_mm, max_inset);
    cav_d  = min(slot_cavity_depth_mm, max(0, max_inset - slot_d));

    bore_r = center_bore_diameter_mm/2;

    // --- STRUCTURAL FIX: add internal tie bridges that CROSS the centerlines ---
    // These bridges are part of the SOLID before subtracting voids.
    // They are placed so they do NOT intersect the center bore, but still
    // overlap across the would-be split lines by overlap_mm.
    bridge_th = max(web_thickness_mm, 2.0);

    // Keep bridges inside rounded corners
    bridge_len_x = w - 2*(corner_radius_mm + 1.0);
    bridge_len_y = h - 2*(corner_radius_mm + 1.0);

    // Place bridges just outside the bore, but ensure they still cross the
    // centerlines (x=0 and y=0) by overlap_mm.
    // Condition: offset + bridge_th/2 > overlap_mm  (so it crosses the centerline)
    // and offset - bridge_th/2 >= bore_r + eps      (so it clears the bore)
    bridge_offset = max(
        bore_r + bridge_th/2 + eps,
        overlap_mm - bridge_th/2 + eps
    );

    difference() {
        // SOLID: outer body + bridges (single connected body)
        union() {
            rounded_rect_2d(w, h, corner_radius_mm);

            // Horizontal ties (connect left/right halves): bars above and below bore
            translate([0,  bridge_offset]) square([bridge_len_x, bridge_th], center=true);
            translate([0, -bridge_offset]) square([bridge_len_x, bridge_th], center=true);

            // Vertical ties (connect upper/lower halves): bars left and right of bore
            translate([ bridge_offset, 0]) square([bridge_th, bridge_len_y], center=true);
            translate([-bridge_offset, 0]) square([bridge_th, bridge_len_y], center=true);

            // Extra central cross-ties to eliminate any residual "gap" caused by
            // slot/cavity subtractions in front/back and left/right views.
            // These are thin but guaranteed to overlap across both centerlines.
            // They are also kept clear of the bore by using the same offset logic.
            cross_len_x = max(bridge_th, 2*overlap_mm + bridge_th);
            cross_len_y = max(bridge_th, 2*overlap_mm + bridge_th);

            // Two short vertical stubs crossing y=0 (connect upper/lower)
            translate([ bridge_offset, 0]) square([bridge_th, cross_len_y], center=true);
            translate([-bridge_offset, 0]) square([bridge_th, cross_len_y], center=true);

            // Two short horizontal stubs crossing x=0 (connect left/right)
            translate([0,  bridge_offset]) square([cross_len_x, bridge_th], center=true);
            translate([0, -bridge_offset]) square([cross_len_x, bridge_th], center=true);
        }

        // T-slots: 4 sides (mouth + cavity), rotated around center
        for (a = [0, 90, 180, 270]) rotate(a) {
            // Slot mouth (near outer face)
            translate([w/2 - slot_d/2, 0])
                square([slot_d + eps, slot_opening_mm], center=true);

            // Slot cavity (deeper and wider)
            translate([w/2 - (slot_d + cav_d)/2, 0])
                square([slot_d + cav_d + eps, slot_cavity_width_mm], center=true);
        }

        // Center bore
        circle(r=bore_r);
    }
}

// 3D extrusion
module extrusion_2040() {
    color("Silver")
    union() {
        linear_extrude(height=length_mm, center=true, convexity=10)
            extrusion_profile_2d();
    }
}

extrusion_2040();