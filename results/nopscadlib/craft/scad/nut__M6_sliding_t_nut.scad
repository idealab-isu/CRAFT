$fn = 96;

// -------------------- Parameters (requested key dims) --------------------
screw_diameter_mm = 6.0;                 // M6 nominal
internal_hex_across_flats_mm = 8.0;      // hex socket AF
thickness_mm = 6.6;                      // overall nut thickness (Z)
body_length_mm = 18;                     // along slot (X)

// Typical 3030/3060 style T-slot nut envelope (can be adjusted)
t_slot_width_mm = 13.8;                  // max width that sits under slot lips (Y)
t_slot_opening_width_mm = 8.2;           // slot opening/neck width (Y)
t_slot_lip_thickness_mm = 1.2;           // lip capture height (Z) on each side
chamfer_mm = 0.5;
overlap_mm = 0.6;

// Hole options
hole_type_is_tapped = 1;                 // 1=tapped pilot, 0=clearance
clearance_diameter_mm = 6.6;
tapped_pilot_diameter_mm = 5.0;

// Hex socket depth (from top face down)
hex_socket_depth_mm = 4.5;

// -------------------- Helpers --------------------
function hex_circumradius_from_af(af) = af / (2 * cos(30)); // AF -> circumscribed radius

module chamfer_ends(len, wid, h, c) {
    // subtract two wedges to chamfer the X ends
    // uses hull between a thin slice and a shifted slice to create a 45-ish chamfer
    for (sx = [-1, 1]) {
        translate([sx*(len/2 - c/2), 0, 0])
            hull() {
                translate([sx*c/2, 0, 0]) cube([c, wid + 2*overlap_mm, h + 2*overlap_mm], center=true);
                translate([-sx*c/2, 0, 0]) cube([0.01, wid + 2*overlap_mm, h + 2*overlap_mm], center=true);
            }
    }
}

// -------------------- Main T-slot nut --------------------
module tslot_nut() {
    // Derived geometry for a recognizable T-slot nut profile:
    // - Bottom "head" width = t_slot_width_mm
    // - Top "neck" width = t_slot_opening_width_mm
    // - Neck height = thickness - lip_thickness (captures under lips)
    // - Head height = lip_thickness (sits below opening)
    head_h = t_slot_lip_thickness_mm;
    neck_h = thickness_mm - head_h;

    // Ensure sane
    head_h2 = max(0.6, min(head_h, thickness_mm - 0.6));
    neck_h2 = thickness_mm - head_h2;

    difference() {
        // ONE connected solid: union of head + neck with overlap
        union() {
            // Bottom head (wider) centered at bottom portion
            translate([0, 0, -thickness_mm/2 + head_h2/2])
                cube([body_length_mm, t_slot_width_mm, head_h2], center=true);

            // Top neck (narrower) centered above, overlapping slightly into head
            translate([0, 0, -thickness_mm/2 + head_h2 + neck_h2/2 - overlap_mm/2])
                cube([body_length_mm, t_slot_opening_width_mm, neck_h2 + overlap_mm], center=true);
        }

        // End chamfers (subtract from the combined body)
        chamfer_ends(body_length_mm, t_slot_width_mm, thickness_mm, chamfer_mm);

        // Through hole (pilot for tapping or clearance)
        cylinder(d = (hole_type_is_tapped ? tapped_pilot_diameter_mm : clearance_diameter_mm),
                 h = thickness_mm + 2*overlap_mm, center=true);

        // Internal hex socket from top face down
        translate([0, 0, thickness_mm/2 - hex_socket_depth_mm/2 + overlap_mm/2])
            cylinder(r = hex_circumradius_from_af(internal_hex_across_flats_mm),
                     h = hex_socket_depth_mm + overlap_mm, center=true, $fn=6);
    }
}

// -------------------- Assembly (single connected solid) --------------------
tslot_nut();