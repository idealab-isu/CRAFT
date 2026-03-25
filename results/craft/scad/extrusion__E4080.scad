// 40x80 aluminium extrusion profile (connected solid), 100mm long
// Fixes: ensure outer body is NOT split by slot cuts; ensure internal webs connect to outer walls;
// add slight overlaps (1-2mm) for robust connectivity.

cross_section_width_mm  = 40;   // X
cross_section_height_mm = 80;   // Y
length_mm               = 100;  // Z

wall_thickness_mm       = 2.5;

slot_opening_mm         = 6;
slot_depth_mm           = 8;
slot_cavity_width_mm    = 12;

web_thickness_mm        = 3;

center_bore_diameter_mm = 10;

cornerHole                      = 1;
corner_hole_diameter_mm         = 6;
corner_hole_offset_from_edges_mm= 10;

// Use 1-2mm overlap to guarantee attachment/union robustness
overlap_mm = 1.2;
$fn = 64;

// --- Helpers: T-slot cutters with a "bridge keepout" so the outer body never gets split ---
module tslot_cut_x(side=1) { // side: +1 right, -1 left
    x_face        = side * cross_section_width_mm/2;
    x_open_center = x_face - side * (slot_depth_mm/2);
    x_cav_center  = x_face - side * (slot_depth_mm*0.65);

    // Keep a thin bridge of material at the centerline (y=0) so left/right halves remain connected.
    // This does NOT change the overall look much, but prevents a full-depth cut that splits the body.
    bridge_keep_y = web_thickness_mm + 2*overlap_mm;

    difference() {
        union() {
            translate([x_open_center, 0, 0])
                cube([slot_depth_mm + 2*overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);

            translate([x_cav_center, 0, 0])
                cube([slot_depth_mm + 2*overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        }

        // Remove the cutter volume around y=0 so a small connecting rib remains in the final part
        translate([x_face - side*(slot_depth_mm/2), 0, 0])
            cube([slot_depth_mm + 6*overlap_mm, bridge_keep_y, length_mm + 6*overlap_mm], center=true);
    }
}

module tslot_cut_y(side=1) { // side: +1 top, -1 bottom
    y_face        = side * cross_section_height_mm/2;
    y_open_center = y_face - side * (slot_depth_mm/2);
    y_cav_center  = y_face - side * (slot_depth_mm*0.65);

    // Keep a thin bridge of material at the centerline (x=0) so top/bottom halves remain connected.
    bridge_keep_x = web_thickness_mm + 2*overlap_mm;

    difference() {
        union() {
            translate([0, y_open_center, 0])
                cube([slot_opening_mm, slot_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);

            translate([0, y_cav_center, 0])
                cube([slot_cavity_width_mm, slot_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
        }

        // Remove the cutter volume around x=0 so a small connecting rib remains in the final part
        translate([0, y_face - side*(slot_depth_mm/2), 0])
            cube([bridge_keep_x, slot_depth_mm + 6*overlap_mm, length_mm + 6*overlap_mm], center=true);
    }
}

// --- Main profile (single connected solid) ---
module extrusion_4080_connected() {

    // Dimensions for inner void
    inner_w = cross_section_width_mm  - 2*wall_thickness_mm;
    inner_h = cross_section_height_mm - 2*wall_thickness_mm;

    // Webs must physically touch the outer walls; make them slightly longer than the inner void
    // so they overlap into the wall thickness by ~overlap_mm on each side.
    web_x_len = inner_w + 2*overlap_mm; // horizontal web spans X
    web_y_len = inner_h + 2*overlap_mm; // vertical web spans Y

    // Build as: (outer shell with internal webs) - (slots + holes)
    difference() {
        union() {
            // Outer shell (outer minus inner)
            difference() {
                cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);

                // Inner void (slightly longer in Z to avoid coplanar faces)
                cube([inner_w, inner_h, length_mm + 2*overlap_mm], center=true);
            }

            // Internal webs (explicit solids) to ensure they are attached to the outer shell
            // Horizontal web
            cube([web_x_len, web_thickness_mm, length_mm + 2*overlap_mm], center=true);

            // Vertical web
            cube([web_thickness_mm, web_y_len, length_mm + 2*overlap_mm], center=true);
        }

        // T-slots on all four faces (with centerline bridge keepouts to prevent splitting)
        tslot_cut_x(+1);
        tslot_cut_x(-1);
        tslot_cut_y(+1);
        tslot_cut_y(-1);

        // Center bore
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 4*overlap_mm, center=true);

        // Corner holes (optional)
        if (cornerHole) {
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([
                    sx * (cross_section_width_mm/2  - corner_hole_offset_from_edges_mm),
                    sy * (cross_section_height_mm/2 - corner_hole_offset_from_edges_mm),
                    0
                ])
                    cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 4*overlap_mm, center=true);
            }
        }
    }
}

color("Silver") extrusion_4080_connected();