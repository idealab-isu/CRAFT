// Thin tapered ID/mounting plate with concave semicircular cutout, 4 through-slots,
// stencil-style cut-through text "EEZYbot ARM MK2", and TWO underside mounting feet.
// Structural fixes applied:
// - Slots are guaranteed to be inside the plate (and not inside the cutout) by computing
//   the local plate half-width at the slot X positions and clamping Y positions.
// - Two underside feet are created and forced to intersect the plate with overlap.
// - All translate() values are derived from dimensions (no arbitrary offsets).

$fn = 96;

// -------------------- Parameters (mm-ish units; keep small as provided) --------------------
plate_L        = 0.078;
plate_W_wide   = 0.078;
plate_W_narrow = 0.050;
plate_t        = 0.006;

cutout_r = 0.022;                 // concave semicircle radius at the narrow end

slot_L = 0.018;
slot_W = 0.003;
slot_pair_spacing = 0.010;        // spacing between the two slot rows (Y)
slot_edge_margin  = 0.006;        // keep slots away from cutout opening
slot_col_spacing  = 0.012;        // separation between the two columns (X)
slot_y_margin     = 0.002;        // keep slots away from plate edges

foot_L = 0.012;
foot_W = 0.008;
foot_drop = 0.004;
foot_from_cutout_end = 0.060;     // from cutout end along +X
foot_lateral_offset = 0.018;

overlap = 0.0015;                 // small overlap to guarantee connectivity

// Text (cut-through)
text_str = "EEZYbot ARM MK2";
text_size = 0.010;
text_spacing = 1.0;
text_font = "Liberation Sans:style=Bold";
text_y_offset = 0;
text_x_offset = 0.010;

// Stencil bridges
bridge_w = 0.0012;
bridge_h = 0.0040;
bridge_count = 14;

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = (v < lo) ? lo : (v > hi) ? hi : v;

// Linear taper: half-width at a given x along the plate
function plate_halfW_at_x(x) =
    let(t = (x + plate_L/2) / plate_L)  // 0 at narrow end (-L/2), 1 at wide end (+L/2)
    (plate_W_narrow/2) + t * ((plate_W_wide - plate_W_narrow)/2);

module tapered_plate_2d() {
    polygon(points = [
        [-plate_L/2, -plate_W_narrow/2],
        [-plate_L/2,  plate_W_narrow/2],
        [ plate_L/2,  plate_W_wide/2],
        [ plate_L/2, -plate_W_wide/2]
    ]);
}

// Concave semicircular cutout that opens into the plate from the narrow end.
module concave_semicircular_end_cutout_2d() {
    end_x = -plate_L/2;
    cx = end_x; // center on the end line for a clean semicircle opening

    intersection() {
        translate([cx, 0]) circle(r = cutout_r);
        // Keep x >= end_x portion of the circle (the part overlapping the plate)
        translate([end_x - overlap, -2*cutout_r])
            square([2*cutout_r + 4*overlap, 4*cutout_r], center=false);
    }
}

module rounded_slot_2d(cx, cy, L, W) {
    r = max(W/2, 0.0001);
    hull() {
        translate([cx - L/2, cy]) circle(r = r);
        translate([cx + L/2, cy]) circle(r = r);
    }
}

module all_slots_2d() {
    end_x = -plate_L/2;

    // Place slots just past the cutout opening, clearly within the plate
    x1 = end_x + cutout_r + slot_edge_margin + slot_L/2;
    x2 = x1 + slot_col_spacing;

    // Compute safe Y positions based on local plate width at each column X
    // so slots cannot end up outside the tapered outline.
    y_lim1 = plate_halfW_at_x(x1) - (slot_W/2) - slot_y_margin;
    y_lim2 = plate_halfW_at_x(x2) - (slot_W/2) - slot_y_margin;

    // Desired pair positions, then clamped to fit both columns
    y_des = slot_pair_spacing/2;
    y1 = clamp( y_des, 0, min(y_lim1, y_lim2));
    y2 = -y1;

    union() {
        rounded_slot_2d(x1, y1, slot_L, slot_W);
        rounded_slot_2d(x2, y1, slot_L, slot_W);
        rounded_slot_2d(x1, y2, slot_L, slot_W);
        rounded_slot_2d(x2, y2, slot_L, slot_W);
    }
}

module stencil_text_minus_bridges_2d() {
    approx_w = max(text_size * len(text_str) * 0.58, text_size*2);
    x_min = -approx_w/2 + text_x_offset;

    difference() {
        translate([text_x_offset, text_y_offset])
            text(text_str, size=text_size, font=text_font, spacing=text_spacing,
                 halign="center", valign="center");

        for (i = [0:bridge_count-1]) {
            xi = x_min + (i + 0.5) * (approx_w / bridge_count);
            translate([xi, text_y_offset])
                square([bridge_w, bridge_h], center=true);
        }
    }
}

module plate_solid() {
    difference() {
        linear_extrude(height = plate_t, center = true, convexity=10)
            tapered_plate_2d();

        // Concave semicircular bite (horn corners)
        linear_extrude(height = plate_t + 2*overlap, center = true, convexity=10)
            concave_semicircular_end_cutout_2d();

        // Four through-slots near cutout end
        linear_extrude(height = plate_t + 2*overlap, center = true, convexity=10)
            all_slots_2d();

        // Cut-through stencil text
        linear_extrude(height = plate_t + 2*overlap, center = true, convexity=10)
            stencil_text_minus_bridges_2d();
    }
}

module underside_foot(x, y) {
    // Intersect the plate by 'overlap' to guarantee a single connected solid
    translate([x, y, -(plate_t/2 + foot_drop/2) + overlap])
        cube([foot_L, foot_W, foot_drop], center=true);
}

module final_plate_with_feet() {
    end_x = -plate_L/2;
    foot_x = end_x + foot_from_cutout_end;

    // Ensure feet are within the local plate width at foot_x
    y_lim = plate_halfW_at_x(foot_x) - foot_W/2 - overlap;
    foot_y = clamp(foot_lateral_offset, 0, y_lim);

    union() {
        plate_solid();

        // TWO feet/tabs (symmetrical), both connected
        underside_foot(foot_x,  foot_y);
        underside_foot(foot_x, -foot_y);
    }
}

// Render
color("Silver") final_plate_with_feet();