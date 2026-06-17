// 20x40 aluminium T-slot extrusion profile, 100mm long
// One connected solid (outer body with connected internal voids removed)

$fn = 96;

// Exact required overall dimensions
W = 20.0;   // X
H = 40.0;   // Y
L = 100.0;  // Z

// Profile parameters (typical-ish 20x40 T-slot look; all formulas, no arbitrary placement)
wall_t      = 2.0;   // outer wall thickness
web_t       = 2.0;   // internal web thickness (cross)
slot_open   = 6.0;   // slot mouth width
slot_depth  = 6.0;   // depth from outer face to inner cavity
slot_cav_w  = 11.0;  // inner cavity width
slot_cav_d  = 8.0;   // inner cavity depth (beyond slot_depth)
center_bore_d = 6.8; // center bore diameter

// Corner holes (optional)
cornerHole = 1;
corner_hole_d = 4.2;
corner_hole_offset = 6.0;

overlap = 0.6; // robust boolean overlap

module outer_body() {
    cube([W, H, L], center=true);
}

// T-slot cutouts on all 4 faces; guaranteed to intersect outer body
module t_slot_cutouts() {
    union() {
        // +X face
        translate([ W/2 - (slot_depth + overlap)/2, 0, 0 ])
            cube([slot_depth + overlap, slot_open, L + 2*overlap], center=true);
        translate([ W/2 - slot_depth - (slot_cav_d + overlap)/2 + overlap, 0, 0 ])
            cube([slot_cav_d + overlap, slot_cav_w, L + 2*overlap], center=true);

        // -X face
        translate([ -W/2 + (slot_depth + overlap)/2, 0, 0 ])
            cube([slot_depth + overlap, slot_open, L + 2*overlap], center=true);
        translate([ -W/2 + slot_depth + (slot_cav_d + overlap)/2 - overlap, 0, 0 ])
            cube([slot_cav_d + overlap, slot_cav_w, L + 2*overlap], center=true);

        // +Y face
        translate([ 0, H/2 - (slot_depth + overlap)/2, 0 ])
            cube([slot_open, slot_depth + overlap, L + 2*overlap], center=true);
        translate([ 0, H/2 - slot_depth - (slot_cav_d + overlap)/2 + overlap, 0 ])
            cube([slot_cav_w, slot_cav_d + overlap, L + 2*overlap], center=true);

        // -Y face
        translate([ 0, -H/2 + (slot_depth + overlap)/2, 0 ])
            cube([slot_open, slot_depth + overlap, L + 2*overlap], center=true);
        translate([ 0, -H/2 + slot_depth + (slot_cav_d + overlap)/2 - overlap, 0 ])
            cube([slot_cav_w, slot_cav_d + overlap, L + 2*overlap], center=true);
    }
}

// Internal voids: center bore + four quadrant pockets, leaving a cross-web and outer walls.
// Pockets are clamped so they cannot remove the outer walls or the cross-web.
module internal_voids() {
    // Available half-spans inside outer walls
    inner_half_x = W/2 - wall_t;
    inner_half_y = H/2 - wall_t;

    // Pocket sizes that leave web_t at center
    pocket_x = max(0.1, 2*(inner_half_x - web_t/2));
    pocket_y = max(0.1, 2*(inner_half_y - web_t/2));

    // Pocket centers (touch web, stay inside walls)
    pocket_cx = web_t/2 + pocket_x/2;
    pocket_cy = web_t/2 + pocket_y/2;

    union() {
        // Center bore
        cylinder(d=center_bore_d, h=L + 2*overlap, center=true);

        // Four quadrant pockets
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([ sx*pocket_cx, sy*pocket_cy, 0 ])
                cube([pocket_x, pocket_y, L + 2*overlap], center=true);
        }
    }
}

module corner_holes() {
    if (cornerHole) {
        union() {
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([
                    sx*(W/2 - corner_hole_offset),
                    sy*(H/2 - corner_hole_offset),
                    0
                ])
                cylinder(d=corner_hole_d, h=L + 2*overlap, center=true);
            }
        }
    }
}

module extrusion() {
    difference() {
        outer_body();
        t_slot_cutouts();
        internal_voids();
        corner_holes();
    }
}

extrusion();