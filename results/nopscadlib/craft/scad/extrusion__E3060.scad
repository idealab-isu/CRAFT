// 30x60 aluminium extrusion profile, 100mm long
// One connected solid: outer body minus connected internal voids/slots/bores

$fn = 96;

// Parameters
cross_section_width_mm  = 30.0;   // X
cross_section_height_mm = 60.0;   // Y
length_mm               = 100.0;  // Z
center_along_length     = 1;      // 1=centered, 0=starts at Z=0

wall_thickness_mm       = 2.5;
slot_opening_mm         = 6.0;    // mouth width at surface
slot_depth_mm           = 8.0;    // depth from surface to inner cavity
slot_cavity_width_mm    = 12.0;   // inner cavity width
web_thickness_mm        = 3.0;

center_bore_diameter_mm = 8.0;

include_corner_holes    = 0;
corner_hole_diameter_mm = 5.0;
corner_hole_inset_mm    = 7.5;

overlap_mm              = 0.6;

// Helpers
function zshift() = (center_along_length ? 0 : length_mm/2);

// Clamp helper (avoid impossible geometry that can blank renders)
function clamp(v, lo, hi) = (v < lo) ? lo : ((v > hi) ? hi : v);

// Derived safe dimensions
W  = cross_section_width_mm;
H  = cross_section_height_mm;
L  = length_mm;

wt = clamp(wall_thickness_mm, 0.8, min(W,H)/4);
web = clamp(web_thickness_mm, 1.0, min(W,H)/3);

slot_mouth = clamp(slot_opening_mm, 2.0, min(W,H)/2 - 2*wt);
slot_cav   = clamp(slot_cavity_width_mm, slot_mouth, min(W,H) - 2*wt - 2);
slot_d     = clamp(slot_depth_mm, 2.0, min(W,H)/2 - wt - 1.0);

// T-slot cuts (each is a single connected cut volume per face)
module tslot_cut_x(side=1) { // side=+1 right, -1 left
    // Mouth block touches outer surface; cavity block overlaps mouth to ensure connectivity
    mouth_len = slot_d;
    cav_len   = slot_d;

    // Mouth: from surface inward
    translate([side*(W/2 - mouth_len/2), 0, 0])
        cube([mouth_len + overlap_mm, slot_mouth, L + 2*overlap_mm], center=true);

    // Cavity: behind mouth, overlapping by overlap_mm
    translate([side*(W/2 - mouth_len - cav_len/2 + overlap_mm/2), 0, 0])
        cube([cav_len + overlap_mm, slot_cav, L + 2*overlap_mm], center=true);
}

module tslot_cut_y(side=1) { // side=+1 top, -1 bottom
    mouth_len = slot_d;
    cav_len   = slot_d;

    translate([0, side*(H/2 - mouth_len/2), 0])
        cube([slot_mouth, mouth_len + overlap_mm, L + 2*overlap_mm], center=true);

    translate([0, side*(H/2 - mouth_len - cav_len/2 + overlap_mm/2), 0])
        cube([slot_cav, cav_len + overlap_mm, L + 2*overlap_mm], center=true);
}

module extrusion_3060() {
    difference() {
        // Outer solid (single body)
        cube([W, H, L], center=true);

        // All voids are subtracted from the same outer body (keeps one connected solid)
        union() {
            // T-slots on all 4 faces
            tslot_cut_x(+1);
            tslot_cut_x(-1);
            tslot_cut_y(+1);
            tslot_cut_y(-1);

            // Center bore
            cylinder(d=center_bore_diameter_mm, h=L + 2*overlap_mm, center=true);

            // Internal hollows: create a connected "ring" void that does NOT cut through outer walls.
            // This avoids splitting the extrusion into separate bars.
            inner_w = W - 2*wt;
            inner_h = H - 2*wt;

            // Ensure inner void stays valid and leaves webs
            inner_w2 = max(1.0, inner_w);
            inner_h2 = max(1.0, inner_h);

            // Central rectangular void (kept inside walls)
            cube([inner_w2, inner_h2, L + 2*overlap_mm], center=true);

            // Add back material via "negative cuts" is not possible in difference(),
            // so instead we *limit* the central void to preserve a "+" web by subtracting
            // two smaller voids that overlap the central void, leaving webs uncut.
            // Implemented by cutting only the four corner pockets (connected via small overlaps).

            // Corner pocket sizes (leave webs of thickness 'web')
            pocket_w = (inner_w2 - web) / 2;
            pocket_h = (inner_h2 - web) / 2;

            // If pockets would be invalid, skip them (still yields a valid extrusion)
            if (pocket_w > 0.5 && pocket_h > 0.5) {
                // Remove only corner pockets instead of full inner rectangle:
                // Achieve this by first "undoing" the full inner rectangle cut:
                // We avoid that by not cutting the full inner rectangle when pockets are used.
                // So: conditionally replace the full inner rectangle with corner pockets.
            }
        }
    }
}

// Rebuild extrusion_3060 with correct internal void strategy (no splitting)
module extrusion_3060_fixed() {
    inner_w = W - 2*wt;
    inner_h = H - 2*wt;

    pocket_w = (inner_w - web) / 2;
    pocket_h = (inner_h - web) / 2;

    difference() {
        cube([W, H, L], center=true);

        union() {
            // T-slots
            tslot_cut_x(+1);
            tslot_cut_x(-1);
            tslot_cut_y(+1);
            tslot_cut_y(-1);

            // Center bore
            cylinder(d=center_bore_diameter_mm, h=L + 2*overlap_mm, center=true);

            // Internal hollows: four corner pockets (leave a connected "+" web)
            if (pocket_w > 0.5 && pocket_h > 0.5) {
                for (sx = [-1, 1], sy = [-1, 1]) {
                    translate([sx*(web/2 + pocket_w/2), sy*(web/2 + pocket_h/2), 0])
                        cube([pocket_w + overlap_mm, pocket_h + overlap_mm, L + 2*overlap_mm], center=true);
                }
            } else {
                // Fallback: simple inner rectangle (still connected solid)
                cube([max(1.0, inner_w), max(1.0, inner_h), L + 2*overlap_mm], center=true);
            }

            // Optional corner holes
            if (include_corner_holes) {
                for (sx = [-1, 1], sy = [-1, 1]) {
                    translate([sx*(W/2 - corner_hole_inset_mm),
                               sy*(H/2 - corner_hole_inset_mm),
                               0])
                        cylinder(d=corner_hole_diameter_mm, h=L + 2*overlap_mm, center=true);
                }
            }
        }
    }
}

// Assembly (single solid)
translate([0, 0, zshift()])
    color("Silver") extrusion_3060_fixed();