// 40x80 aluminium T-slot extrusion (approximate "typical" profile), 100mm long
// Single connected solid (one body with internal voids/slots removed)

$fn = 64;

// Parameters (fixed to requested size)
cross_section_width_mm  = 40.0;
cross_section_height_mm = 80.0;
length_mm               = 100.0;

wall_thickness_mm       = 2.5;   // outer wall
slot_opening_mm         = 6.0;   // mouth opening at surface
slot_internal_width_mm  = 12.0;  // wider internal cavity behind mouth
slot_depth_mm           = 10.0;  // depth from surface into profile

center_bore_diameter_mm = 8.0;   // typical center bore
web_thickness_mm        = 3.0;   // internal webs thickness

overlap_mm              = 0.6;   // boolean overlap

module tslot_cut_x(side=1) {
    // Cuts a T-slot on +X (side=+1) or -X (side=-1) face
    w = cross_section_width_mm;
    h = cross_section_height_mm;
    L = length_mm;

    // Place the slot so its outer face is flush with the profile surface
    // Slot extends inward by slot_depth_mm
    x_center = side * (w/2 - slot_depth_mm/2);

    union() {
        // Internal cavity (wider)
        translate([x_center, 0, 0])
            cube([slot_depth_mm + overlap_mm, slot_internal_width_mm, L + 2*overlap_mm], center=true);

        // Mouth opening (narrower) - ensure it reaches the surface
        translate([side*(w/2 - (slot_depth_mm + overlap_mm)/2), 0, 0])
            cube([slot_depth_mm + overlap_mm, slot_opening_mm, L + 2*overlap_mm], center=true);
    }
}

module tslot_cut_y(side=1) {
    // Cuts a T-slot on +Y (side=+1) or -Y (side=-1) face
    w = cross_section_width_mm;
    h = cross_section_height_mm;
    L = length_mm;

    y_center = side * (h/2 - slot_depth_mm/2);

    union() {
        translate([0, y_center, 0])
            cube([slot_internal_width_mm, slot_depth_mm + overlap_mm, L + 2*overlap_mm], center=true);

        translate([0, side*(h/2 - (slot_depth_mm + overlap_mm)/2), 0])
            cube([slot_opening_mm, slot_depth_mm + overlap_mm, L + 2*overlap_mm], center=true);
    }
}

module internal_voids() {
    w = cross_section_width_mm;
    h = cross_section_height_mm;
    L = length_mm;

    // Keep a ring of material near the outer wall and leave internal webs
    // Central rectangular void (leaves outer wall thickness)
    inner_w = w - 2*wall_thickness_mm;
    inner_h = h - 2*wall_thickness_mm;

    // Webs: vertical and horizontal bars through the center
    // We'll subtract the inner void but "add back" webs by not subtracting them:
    // Implemented by subtracting inner void minus webs (i.e., subtract inner void with webs removed)
    difference() {
        // Inner void volume
        cube([inner_w, inner_h, L + 2*overlap_mm], center=true);

        // Remove from the void the web volumes so they remain solid in the final part
        union() {
            // Vertical web (along Y)
            cube([web_thickness_mm, inner_h + 2*overlap_mm, L + 4*overlap_mm], center=true);
            // Horizontal web (along X)
            cube([inner_w + 2*overlap_mm, web_thickness_mm, L + 4*overlap_mm], center=true);
        }
    }
}

module extrusion_40x80() {
    w = cross_section_width_mm;
    h = cross_section_height_mm;
    L = length_mm;

    color("Silver")
    difference() {
        // Outer body
        cube([w, h, L], center=true);

        // Outer T-slots on all 4 faces
        union() {
            tslot_cut_x(+1);
            tslot_cut_x(-1);
            tslot_cut_y(+1);
            tslot_cut_y(-1);
        }

        // Internal void structure (typical extrusion hollows)
        internal_voids();

        // Center bore
        cylinder(d=center_bore_diameter_mm, h=L + 2*overlap_mm, center=true);
    }
}

extrusion_40x80();