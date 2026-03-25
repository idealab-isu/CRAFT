// Dimension-calibrated (target: 0.11 x 0.04 x 0.01 mm)
scale([0.001036, 0.000875, 0.003333])
{
// Thin elongated plate with rounded ends, one large octagonal through-hole near one end,
// and four evenly spaced T-shaped through-slots along the centerline.

// ---------- Parameters (mm) ----------
L = 110;                 // overall length
W = 40;                  // overall width
T = 3;                   // thickness (plate-like)

end_radius = W/2;        // rounded ends (capsule)

hole_center_x_from_end = 18;   // from left end along length
oct_hole_flat_d = 18;          // across flats of octagon

t_count = 4;
t_pitch = 18;            // spacing between T-slots
t_stem_w = 4;
t_stem_l = 12;
t_head_w = 12;
t_head_l = 4;
t_start_x = 40;          // from left end to first T-slot center

eps_overlap = 0.2;       // for clean through-cuts

$fn = 96;

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Regular octagon: given across-flats D, circumradius R = D/(2*cos(22.5))
function oct_R_from_flats(D) = D / (2 * cos(22.5));

// ---------- Base geometry ----------
module capsule_plate_2d(len, wid) {
    // 2D capsule (rounded rectangle) centered at origin
    hull() {
        translate([-(len/2 - wid/2), 0]) circle(r=wid/2);
        translate([ (len/2 - wid/2), 0]) circle(r=wid/2);
    }
}

module plate_outer() {
    linear_extrude(height=T, center=true)
        capsule_plate_2d(L, W);
}

// ---------- Cutouts ----------
module octagonal_through_hole() {
    // Place near LEFT end, on centerline
    R = oct_R_from_flats(oct_hole_flat_d);
    x = -L/2 + hole_center_x_from_end;
    translate([x, 0, 0])
        rotate([0, 0, 22.5])  // flat side roughly horizontal
            linear_extrude(height=T + 2*eps_overlap, center=true)
                circle(r=R, $fn=8);
}

module t_slot_2d() {
    // T shape centered at origin, stem extends in +X direction
    union() {
        // stem
        translate([t_stem_l/2, 0])
            square([t_stem_l, t_stem_w], center=true);
        // head at the far end of stem
        translate([t_stem_l - t_head_l/2, 0])
            square([t_head_l, t_head_w], center=true);
    }
}

module t_slot_through(x_center) {
    translate([x_center, 0, 0])
        linear_extrude(height=T + 2*eps_overlap, center=true)
            t_slot_2d();
}

module all_cutouts() {
    union() {
        octagonal_through_hole();

        // Evenly spaced T-slots along centerline
        for (i = [0 : t_count-1]) {
            x_i = -L/2 + t_start_x + i*t_pitch;
            t_slot_through(x_i);
        }
    }
}

// ---------- Final model ----------
difference() {
    plate_outer();
    all_cutouts();
}
}
