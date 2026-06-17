// 20x60 aluminium extrusion profile, 100mm long (single connected solid)

// ---------- Parameters ----------
profile_width_mm  = 20.0;   // X
profile_height_mm = 60.0;   // Y
length_mm         = 100.0;  // Z

wall_thickness_mm = 2.0;

// T-slot geometry (approximate 20-series look)
slot_opening_mm       = 6.0;    // mouth width at outer face
slot_depth_mm         = 6.0;    // depth from outer face to cavity start
slot_cavity_width_mm  = 12.0;   // internal cavity width behind mouth
slot_cavity_depth_mm  = 10.0;   // cavity depth inward from mouth end

center_bore_diameter_mm = 6.0;

overlap_mm = 0.2; // small overlap for robust booleans
$fn = 64;

// ---------- Helpers ----------
module tslot_cut_x(side=1, len=length_mm) { // side: +1 right, -1 left
    // Mouth (narrow)
    translate([ side*(profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2), 0, 0 ])
        cube([slot_depth_mm + overlap_mm, slot_opening_mm, len + 2*overlap_mm], center=true);

    // Cavity (wide) behind mouth
    translate([ side*(profile_width_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2), 0, 0 ])
        cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, len + 2*overlap_mm], center=true);
}

module tslot_cut_y(side=1, len=length_mm) { // side: +1 top, -1 bottom
    // Mouth (narrow)
    translate([ 0, side*(profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2), 0 ])
        cube([slot_opening_mm, slot_depth_mm + overlap_mm, len + 2*overlap_mm], center=true);

    // Cavity (wide) behind mouth
    translate([ 0, side*(profile_height_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2), 0 ])
        cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, len + 2*overlap_mm], center=true);
}

// ---------- Main extrusion ----------
module extrusion_20x60(len=length_mm) {
    // Keep a continuous outer ring and leave internal material so the part stays ONE connected solid.
    inner_w = max(0.1, profile_width_mm  - 2*wall_thickness_mm);
    inner_h = max(0.1, profile_height_mm - 2*wall_thickness_mm);

    // Prevent the internal pocket from breaking into the slot cavities:
    // leave a "web" thickness between pocket and the slot cavity inner edge.
    web_mm = 2.0;

    // Slot cavity inner edge from center:
    // x/y position of cavity inner face = profile/2 - slot_depth - slot_cavity_depth
    cavity_inner_x = profile_width_mm/2  - slot_depth_mm - slot_cavity_depth_mm;
    cavity_inner_y = profile_height_mm/2 - slot_depth_mm - slot_cavity_depth_mm;

    // Pocket half-size must be <= cavity_inner - web
    pocket_half_w = min(inner_w/2, max(0.1, cavity_inner_x - web_mm));
    pocket_half_h = min(inner_h/2, max(0.1, cavity_inner_y - web_mm));

    pocket_w = 2*pocket_half_w;
    pocket_h = 2*pocket_half_h;

    color("Silver")
    difference() {
        // Outer envelope (20 x 60 x 100)
        cube([profile_width_mm, profile_height_mm, len], center=true);

        // Subtractions
        union() {
            // T-slots on all four faces
            tslot_cut_y(+1, len);
            tslot_cut_y(-1, len);
            tslot_cut_x(+1, len);
            tslot_cut_x(-1, len);

            // Center bore
            cylinder(d=center_bore_diameter_mm, h=len + 2*overlap_mm, center=true);

            // Internal lightening pocket (kept smaller so it doesn't merge with slots)
            cube([pocket_w, pocket_h, len + 2*overlap_mm], center=true);
        }
    }
}

// ---------- Build ----------
extrusion_20x60(length_mm);