// Rounded-rectangle plate with stepped thickness (L-profile), 3-row dogbone/keyhole slots,
// shallow corner recess rings, and mid-side edge notches.
// Bounding box: 40 x 40 x 16 mm

$fn = 96;

// -------------------- Parameters --------------------
bb_x = 40;
bb_y = 40;
bb_z = 16;

corner_r = 5;          // outer corner radius

base_t = 8;            // thin region thickness
boss_t = bb_z;         // thick region thickness (max)
boss_len = 14;         // length of thick region along +Y end

// Slots (3 rows x 2 cols)
slot_rows = 3;
slot_cols = 2;
slot_pitch_y = 10.5;
slot_pitch_x = 16;

slot_throat_w = 4;
slot_head_d = 7;
slot_len = 12;
dogbone_relief_d = 3;
slot_through = bb_z + 2;   // ensure full cut

// Edge notches (mid-sides)
notch_w = 3;
notch_d = 1.5;
notch_h = base_t + 0.8;    // only bites into thin region

// Corner recess outlines (shallow rings)
recess_d = 8;
recess_depth = 0.6;
recess_ring_w = 0.7;
recess_offset_from_corner = 7;

// Robust boolean overlap
overlap = 0.6;

// -------------------- Helpers --------------------
module rounded_rect_2d(w, h, r) {
    // true rounded rectangle (not octagon)
    offset(r=r)
        square([w - 2*r, h - 2*r], center=true);
}

module plate_base() {
    // Thin plate spans full 40x40
    linear_extrude(height=base_t, center=false)
        rounded_rect_2d(bb_x, bb_y, corner_r);
}

module boss_region() {
    // Thickened end at +Y, same XY outline, only over boss_len
    // Adds (boss_t - base_t) on top of base, creating L-shaped side silhouette.
    extra = boss_t - base_t;
    translate([0, bb_y/2 - boss_len/2, base_t - overlap])
        linear_extrude(height=extra + overlap, center=false)
            rounded_rect_2d(bb_x, boss_len, corner_r);
}

module dogbone_keyhole_slot_2d(throat_w, head_d, len, relief_d) {
    // Slot oriented along +Y (length direction).
    // Head at -Y end, throat extends toward +Y, with dogbone relief at far end.
    head_r = head_d/2;
    relief_r = relief_d/2;

    union() {
        // head
        translate([0, -len/2 + head_r]) circle(r=head_r);

        // throat
        translate([0, 0])
            square([throat_w, len - head_d], center=true);

        // dogbone relief at +Y end (two circles)
        y_rel = len/2 - head_r - relief_r;
        translate([ throat_w/2,  y_rel]) circle(r=relief_r);
        translate([-throat_w/2,  y_rel]) circle(r=relief_r);
    }
}

module slots_all() {
    // Through-cut slots (3 rows x 2 cols)
    for (ix = [0:slot_cols-1]) {
        x = (ix - (slot_cols-1)/2) * slot_pitch_x;
        for (iy = [0:slot_rows-1]) {
            y = (iy - (slot_rows-1)/2) * slot_pitch_y;
            translate([x, y, -overlap])
                linear_extrude(height=bb_z + 2*overlap, center=false)
                    dogbone_keyhole_slot_2d(slot_throat_w, slot_head_d, slot_len, dogbone_relief_d);
        }
    }
}

module mid_side_notches() {
    // Small notches at mid of left/right edges, cut into thin region only
    zc = notch_h/2;
    translate([-(bb_x/2 - notch_d/2) + overlap, 0, zc])
        cube([notch_d + 2*overlap, notch_w, notch_h], center=true);

    translate([(bb_x/2 - notch_d/2) - overlap, 0, zc])
        cube([notch_d + 2*overlap, notch_w, notch_h], center=true);
}

module corner_recess_rings() {
    // Shallow circular recess outlines (rings) on top face
    // Placed near corners, visible as outlines in orthographic views.
    r_out = recess_d/2;
    r_in  = max(0.1, r_out - recess_ring_w);

    module ring() {
        difference() {
            cylinder(h=recess_depth + overlap, r=r_out, center=false);
            translate([0,0,-overlap]) cylinder(h=recess_depth + 3*overlap, r=r_in, center=false);
        }
    }

    ztop = boss_t - recess_depth; // always on very top surface
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(bb_x/2 - recess_offset_from_corner),
                   sy*(bb_y/2 - recess_offset_from_corner),
                   ztop])
            ring();
    }
}

// -------------------- Final Model --------------------
difference() {
    union() {
        plate_base();
        boss_region();
    }

    // Through features
    slots_all();

    // Edge notches
    mid_side_notches();

    // Shallow recess rings on top
    corner_recess_rings();
}