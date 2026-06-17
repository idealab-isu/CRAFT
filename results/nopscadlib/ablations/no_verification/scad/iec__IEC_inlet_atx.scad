$fn = 96;

// =====================
// IEC C14 / ATX inlet module (approximate geometry)
// Panel cutout: 40.0mm x 27.0mm (X x Y)
// One connected solid (single printable part)
// =====================

// --- Requested cutout dimensions ---
cutout_w = 40.0;   // X
cutout_h = 27.0;   // Y

// --- Panel / carrier (kept as part of the single solid) ---
panel_t   = 2.0;
panel_m   = 15.0;

// --- General tolerances / boolean robustness ---
clr     = 0.20;
overlap = 0.80;

// --- Module outer geometry (approx) ---
body_depth  = 30.0;   // behind panel (negative Z)
bezel_t     = 3.0;    // in front of panel (positive Z)
bezel_extra_w = 10.0;
bezel_extra_h = 10.0;

// --- Front IEC opening (approx C14 look) ---
front_open_w = 28.5;
front_open_h = 20.0;
front_recess_d = 6.0;     // recess depth from bezel front inward
front_frame_wall = 2.2;   // step/lip thickness

// --- Pin cavities (rear) ---
pin_slot_w = 6.2;
pin_slot_h = 4.2;
pin_slot_d = 10.0;
pin_pitch_x = 10.0;       // spacing between L and N
pin_pitch_y = 6.0;        // PE above L/N

// --- Side latch bumps (approx) ---
latch_w = 3.0;
latch_h = 10.0;
latch_d = 8.0;

// --- Optional mounting holes (off by default) ---
include_mounting_holes = 0; // [0:1:1]
mount_hole_d = 3.2;
mount_hole_pitch_x = 0;
mount_hole_pitch_y = 0;

// =====================
// Helpers
// =====================
module rounded_rect_prism(size=[10,10,10], r=1, center=true) {
    x=size[0]; y=size[1]; z=size[2];
    rr = min(r, min(x,y)/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=rr)
                square([x-2*rr, y-2*rr], center=true);
}

module panel_solid() {
    cube([cutout_w + 2*panel_m,
          cutout_h + 2*panel_m,
          panel_t], center=true);
}

module panel_cutout() {
    cube([cutout_w + 2*clr,
          cutout_h + 2*clr,
          panel_t + 2*overlap], center=true);
}

module mounting_holes_cut() {
    px = (mount_hole_pitch_x > 0) ? mount_hole_pitch_x : (cutout_w + 10);
    py = (mount_hole_pitch_y > 0) ? mount_hole_pitch_y : (cutout_h + 10);
    for (sx=[-1,1], sy=[-1,1])
        translate([sx*px/2, sy*py/2, 0])
            cylinder(d=mount_hole_d + 2*clr, h=panel_t + 2*overlap, center=true);
}

// =====================
// Outer solid (bezel + body + latches), all connected
// =====================
module iec_outer_solid() {
    union() {
        // Bezel in front of panel (overlaps into panel by overlap)
        translate([0,0, panel_t/2 + bezel_t/2 - overlap])
            rounded_rect_prism(
                [cutout_w + bezel_extra_w,
                 cutout_h + bezel_extra_h,
                 bezel_t],
                r=2.0, center=true
            );

        // Main body behind panel (slightly smaller than cutout)
        translate([0,0, -panel_t/2 - body_depth/2 + overlap])
            rounded_rect_prism(
                [cutout_w - 2*clr,
                 cutout_h - 2*clr,
                 body_depth],
                r=1.2, center=true
            );

        // Side latch bumps (connected to body)
        body_w = cutout_w - 2*clr;
        latch_zc = -panel_t/2 - body_depth/2 + overlap;
        for (sx=[-1,1]) {
            translate([sx*(body_w/2 + latch_w/2 - overlap),
                       0,
                       latch_zc])
                rounded_rect_prism([latch_w, latch_h, latch_d], r=0.8, center=true);
        }
    }
}

// =====================
// Internal cuts to create recognizable IEC inlet geometry
// =====================
module iec_internal_cuts() {
    union() {
        // Coordinate references
        z_bezel_front = panel_t/2 + bezel_t - overlap; // slightly inside front face for robust cut
        z_bezel_front_exact = panel_t/2 + bezel_t/2 - overlap + bezel_t/2; // equals panel_t/2 + bezel_t - overlap

        // 1) Front recess opening (rectangular pocket)
        recess_d = front_recess_d + overlap;
        recess_zc = (panel_t/2 + bezel_t) - recess_d/2 - overlap;
        translate([0,0,recess_zc])
            rounded_rect_prism([front_open_w, front_open_h, recess_d], r=1.6, center=true);

        // 2) Inner step (smaller opening deeper) to suggest IEC frame/lip
        step_d = 4.0;
        step_zc = recess_zc - recess_d/2 - step_d/2 + overlap;
        translate([0,0,step_zc])
            rounded_rect_prism([front_open_w - 2*front_frame_wall,
                                front_open_h - 2*front_frame_wall,
                                step_d + 2*overlap],
                               r=1.0, center=true);

        // 3) Rear pin cavity block (pocket) + 3 pin slots
        // Place pin features near the rear of the body
        z_body_back = -panel_t/2 - body_depth + overlap; // near very back
        // Pocket starts a bit forward from the back so it doesn't break through
        pocket_d = 14.0;
        pocket_zc = z_body_back + pocket_d/2 + 2.0; // 2mm forward from back, formula-based
        translate([0,0,pocket_zc])
            rounded_rect_prism([24.0, 16.0, pocket_d + 2*overlap], r=1.0, center=true);

        // Pin slots (3 rectangular cavities) inside the pocket
        slot_d = pin_slot_d + 2*overlap;
        slot_zc = z_body_back + pin_slot_d/2 + 2.0; // aligned with pocket, formula-based
        // L and N (bottom row), PE (top center)
        for (p = [
            [-pin_pitch_x/2, -pin_pitch_y/2],
            [ pin_pitch_x/2, -pin_pitch_y/2],
            [ 0,              pin_pitch_y/2]
        ]) {
            translate([p[0], p[1], slot_zc])
                rounded_rect_prism([pin_slot_w, pin_slot_h, slot_d], r=0.6, center=true);
        }

        // 4) Simple keying chamfer-ish cut at the front opening (wider near front)
        chamfer_len = 6.0;
        z1 = (panel_t/2 + bezel_t) - chamfer_len/2 - overlap;
        z2 = z1 - chamfer_len/2;
        hull() {
            translate([0,0,z1])
                rounded_rect_prism([front_open_w + 2.0, front_open_h + 2.0, 0.8], r=1.6, center=true);
            translate([0,0,z2])
                rounded_rect_prism([front_open_w, front_open_h, 0.8], r=1.6, center=true);
        }
    }
}

// =====================
// Final connected model
// =====================
difference() {
    union() {
        panel_solid();
        iec_outer_solid();
    }
    union() {
        // Panel cutout (40x27) so the requested dimension is explicit/visible
        panel_cutout();

        // IEC inlet geometry cuts (front opening + rear pin cavities)
        iec_internal_cuts();

        if (include_mounting_holes) mounting_holes_cut();
    }
}