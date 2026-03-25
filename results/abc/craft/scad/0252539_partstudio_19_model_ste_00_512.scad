// Render-safe OpenSCAD model: tapered plate with concave semicircular cutout (horns),
// four through-slots (two parallel pairs), stencil cut-through text,
// and two underside mounting feet/tabs. One connected solid.

$fn = 64;

// -------------------- Parameters --------------------
plate_L = 0.08;
plate_W_wide = 0.08;
plate_W_narrow = 0.055;
plate_thk = 0.006;

cutout_r = 0.028;
cutout_center_offset_from_end = 0.0;

// Slots: two parallel pairs near cutout end (all horizontal in plan view)
slot_L = 0.018;
slot_W = 0.003;
slot_pair_spacing = 0.008;              // spacing within each side pair (in Y)
slot_pair_offset_from_cutout_end = 0.016;
slot_pair_lateral_offset = 0.018;       // center of each side pair from centerline (in Y)

text_height = 0.008;                    // font size
text_stroke = 0.0012;                   // stencil bridge thickness
text_offset_from_cutout_end = 0.034;    // move text away from cutout
text_depth = 0.02;                      // ensure full cut-through (>= plate_thk)

foot_L = 0.012;
foot_W = 0.006;
foot_drop = 0.004;
foot_offset_from_cutout_end = 0.06;
foot_lateral_offset = 0.02;

eps = 0.001;

// -------------------- Helpers --------------------
module tapered_plate_2d() {
    polygon(points=[
        [-plate_L/2, -plate_W_wide/2],
        [-plate_L/2,  plate_W_wide/2],
        [ plate_L/2,  plate_W_narrow/2],
        [ plate_L/2, -plate_W_narrow/2]
    ]);
}

module tapered_plate_body() {
    linear_extrude(height=plate_thk, center=false)
        tapered_plate_2d();
}

// Concave semicircular cutout along the LEFT end (x = -plate_L/2).
module concave_semicircular_end_cutout() {
    translate([-plate_L/2 + cutout_center_offset_from_end, 0, plate_thk/2])
        cylinder(r=cutout_r, h=plate_thk + 2*eps, center=true);
}

// Rounded slot (capsule) via hull of two circles, then extrude.
module rounded_slot_3d(len, wid) {
    linear_extrude(height=plate_thk + 2*eps, center=true)
        hull() {
            translate([-(len/2 - wid/2), 0]) circle(r=wid/2, $fn=32);
            translate([ (len/2 - wid/2), 0]) circle(r=wid/2, $fn=32);
        }
}

// Four slots: two parallel pairs near cutout end (2 on +Y side, 2 on -Y side).
module all_through_slots() {
    x_center = -plate_L/2 + slot_pair_offset_from_cutout_end + slot_L/2;

    for (dy = [-(slot_pair_spacing/2), +(slot_pair_spacing/2)]) {
        translate([x_center,  slot_pair_lateral_offset + dy, plate_thk/2])
            rounded_slot_3d(slot_L, slot_W);
        translate([x_center, -slot_pair_lateral_offset + dy, plate_thk/2])
            rounded_slot_3d(slot_L, slot_W);
    }
}

// Stencil cut-through text: "EEZYbot ARM MK2"
// Fixes:
// - Ensure full string appears (no clipping) by scaling to fit available length.
// - Ensure readable from FRONT (not mirrored) by keeping normal orientation.
// - Keep stencil bridges but avoid over-subtracting.
module stencil_text_cutout() {
    x_text = -plate_L/2 + text_offset_from_cutout_end;
    zc = plate_thk/2;

    // Available length from x_text to near right end, keep a margin.
    avail_len = (plate_L/2 - x_text) - 0.004;

    module raw_text_2d() {
        text("EEZYbot ARM MK2",
             size=text_height,
             halign="left",
             valign="center",
             font="Liberation Sans:style=Bold");
    }

    // Measure and scale text to fit in X so it doesn't get clipped by the plate taper.
    module fitted_text_2d() {
        // Use textmetrics via text() bounding box approximation using offset+projection:
        // OpenSCAD lacks direct text bbox; use a conservative scale based on heuristic length.
        // Heuristic: average glyph width ~0.62*size; length ~ n*0.62*size.
        n = 14; // "EEZYbot ARM MK2" length incl spaces (approx)
        est_len = n * 0.62 * text_height;
        sx = min(1, avail_len / est_len);
        scale([sx, 1]) raw_text_2d();
    }

    module text_solid() {
        translate([x_text, 0, zc])
            linear_extrude(height=plate_thk + 2*eps, center=true)
                fitted_text_2d();
    }

    // Stencil bridges: thin vertical bars that REMOVE from the text-solid,
    // leaving small connections in the final cutout.
    module bridge_bars() {
        // Place several bars across the text span.
        // Use same heuristic span as above, but clamp to avail_len.
        n = 14;
        est_len = n * 0.62 * text_height;
        span = min(avail_len, est_len);
        bar_h = text_height * 1.8;

        for (i = [1:6]) {
            bx = x_text + i * span / 7;
            translate([bx, 0, zc])
                cube([text_stroke, bar_h, plate_thk + 4*eps], center=true);
        }
    }

    difference() {
        text_solid();
        bridge_bars();
    }
}

// Two underside mounting feet/tabs, connected to underside of plate.
// Ensure they overlap into the plate (z overlap) so union is one connected solid.
module underside_mounting_feet_tabs_x2() {
    x_foot_center = -plate_L/2 + foot_offset_from_cutout_end + foot_L/2;

    // Plate spans z=[0, plate_thk]. Feet should extend below 0 and overlap slightly into plate.
    z_foot_center = -foot_drop/2 + eps; // top of foot at z=eps (overlaps into plate)

    translate([x_foot_center,  foot_lateral_offset, z_foot_center])
        cube([foot_L, foot_W, foot_drop], center=true);

    translate([x_foot_center, -foot_lateral_offset, z_foot_center])
        cube([foot_L, foot_W, foot_drop], center=true);
}

// Main plate with cutouts
module plate_with_all_cutouts() {
    difference() {
        tapered_plate_body();
        concave_semicircular_end_cutout();
        all_through_slots();
        stencil_text_cutout();
    }
}

// Final connected model
union() {
    plate_with_all_cutouts();
    underside_mounting_feet_tabs_x2();
}