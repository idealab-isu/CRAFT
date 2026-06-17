// Thin elongated plate with rounded ends, one large octagonal through-hole near one end,
// and four evenly spaced T-shaped through-slots along the centerline.

// ---------- Parameters (mm) ----------
L = 0.11;                 // overall length
W = 0.04;                 // overall width
T = 0.01;                 // thickness (plate-like)
end_r = W/2;              // capsule ends (true rounded ends)

hole_flat_d = 0.02;       // octagon "across flats" diameter
hole_sides = 8;           // octagon
hole_offset_from_end = 0.022; // from LEFT end to hole center along X (kept consistent)

t_count = 4;
t_pitch = 0.018;          // spacing between T-slot centers
t_stem_w = 0.006;
t_stem_l = 0.012;
t_head_w = 0.018;
t_head_l = 0.006;

t_centerline_y = 0.0;
slot_layout_center_x = 0.0;

overlap = 0.001;          // ensures clean through-cuts

$fn = 96;

// ---------- Helpers ----------
module capsule_plate_2d(len, wid, r) {
    // 2D capsule using hull of two circles; r should be wid/2 for true rounded ends
    hull() {
        translate([-(len/2 - r), 0]) circle(r=r);
        translate([ (len/2 - r), 0]) circle(r=r);
    }
}

module octagon_2d(flat_d, sides=8) {
    // Across-flats = 2*apothem = 2*R*cos(pi/n) => R = flat_d/(2*cos(pi/n))
    R = flat_d / (2*cos(180/sides));
    rotate(180/sides) circle(r=R, $fn=sides);
}

module t_slot_2d() {
    // T shape centered at origin, stem along +X, head at +X end of stem
    union() {
        square([t_stem_l, t_stem_w], center=true);
        translate([t_stem_l/2 - t_head_l/2, 0])
            square([t_head_l, t_head_w], center=true);
    }
}

module t_slots_2d(count, pitch, center_x=0, y=0) {
    for (i = [0:count-1]) {
        x = center_x + (i - (count-1)/2) * pitch;
        translate([x, y]) t_slot_2d();
    }
}

// ---------- Model ----------
module plate_solid() {
    linear_extrude(height=T, center=true)
        capsule_plate_2d(L, W, end_r);
}

module cutouts() {
    linear_extrude(height=T + 2*overlap, center=true) {
        // Large octagonal hole near LEFT end (fixed orientation/placement)
        translate([-(L/2) + hole_offset_from_end, 0])
            octagon_2d(hole_flat_d, hole_sides);

        // Four repeated T-shaped slots along centerline
        translate([0, t_centerline_y])
            t_slots_2d(t_count, t_pitch, slot_layout_center_x, 0);
    }
}

difference() {
    plate_solid();
    cutouts();
}