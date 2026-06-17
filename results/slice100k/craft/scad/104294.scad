// Long slotted rack/comb plate with pointed tip and mounting tab
// Bounding box target: 24.4 x 99.3 x 2.0 mm

$fn = 128;

// Parameters
bbox_L = 99.32;
bbox_W = 24.41;
T = 2;

strip_W = 14;

tab_L = 18;
tab_W = bbox_W;

transition_L = 6;

tip_L = 10;
tip_point_W = 2;

// Rack feature: series of rectangular slots (comb/rack look)
slot_L = 3.2;          // shorter so it reads as repeated slots, not one long slot
slot_W = 3.0;
slot_pitch = 4.2;
slot_start_from_tip = 14;
slot_end_before_tab = 6;

// Mount holes on tab
hole_D = 3.2;
hole_center_offset_from_tab_end = 6;
hole_spacing = 12;

// Central scalloped (gear-like) cutout on tab
scallop_outer_D = 10;
scallop_inner_D = 2.0;
scallop_teeth = 12;
scallop_center_offset_from_tab_end = 10;

// Optional lightening holes near transition
lighten_D = 6;
lighten_offset_from_transition = 6;

overlap = 1.2; // 1–2mm overlap for robust booleans

// 2D outline of the whole plate (single connected polygon)
module plate_outline_2d() {
    x_tip = -bbox_L/2;
    x_tip_base = x_tip + tip_L;

    x_tab_end = bbox_L/2;
    x_tab_start = x_tab_end - tab_L;

    x_trans_start = x_tab_start - transition_L;

    w_tip = tip_point_W;
    w_strip = strip_W;
    w_tab = tab_W;

    polygon(points=[
        [x_tip,         w_tip/2],
        [x_tip_base,    w_strip/2],
        [x_trans_start, w_strip/2],
        [x_tab_start,   w_tab/2],
        [x_tab_end,     w_tab/2],
        [x_tab_end,    -w_tab/2],
        [x_tab_start,  -w_tab/2],
        [x_trans_start, -w_strip/2],
        [x_tip_base,   -w_strip/2],
        [x_tip,        -w_tip/2]
    ]);
}

// Through-slot at x position (centered on strip)
module rack_slot_at(xc) {
    translate([xc, 0, 0])
        cube([slot_L, slot_W, T + 2*overlap], center=true);
}

// Scalloped (gear-like) cutout: outer circle with repeated inner "bites"
module scalloped_cutout_2d(outer_r, bite_r, teeth) {
    difference() {
        circle(r=outer_r);
        for (i = [0:teeth-1]) {
            rotate(i*360/teeth)
                translate([outer_r - bite_r*0.65, 0])
                    circle(r=bite_r);
        }
    }
}

module model() {
    // Derived positions
    x_tip = -bbox_L/2;
    x_tab_end = bbox_L/2;
    x_tab_start = x_tab_end - tab_L;
    x_trans_start = x_tab_start - transition_L;

    // Slot usable region (avoid tip and tab)
    x_slot_start = x_tip + slot_start_from_tip;
    x_slot_end   = x_tab_start - slot_end_before_tab;

    // Compute slot count from usable length (ensures repeated rack/comb look)
    usable_len = x_slot_end - x_slot_start;
    slot_N = max(2, floor((usable_len - slot_L)/slot_pitch) + 1);

    difference() {
        // Base plate (single connected solid)
        linear_extrude(height=T, center=true)
            plate_outline_2d();

        // Cutouts (all through, with overlap in Z for clean subtraction)
        union() {
            // Rack slots: evenly spaced rectangular slots along most of strip
            for (i = [0:slot_N-1]) {
                x = x_slot_start + i*slot_pitch;
                if (x - slot_L/2 >= x_slot_start && x + slot_L/2 <= x_slot_end)
                    rack_slot_at(x);
            }

            // Mount holes (two) on tab
            x_hole = x_tab_end - hole_center_offset_from_tab_end;
            translate([x_hole,  hole_spacing/2, 0])
                cylinder(d=hole_D, h=T + 2*overlap, center=true);
            translate([x_hole, -hole_spacing/2, 0])
                cylinder(d=hole_D, h=T + 2*overlap, center=true);

            // Central scalloped cutout on tab
            x_scallop = x_tab_end - scallop_center_offset_from_tab_end;
            translate([x_scallop, 0, 0])
                linear_extrude(height=T + 2*overlap, center=true)
                    scalloped_cutout_2d(scallop_outer_D/2, scallop_inner_D/2, scallop_teeth);

            // Lightening holes near transition (kept within strip width)
            x_light = x_trans_start - lighten_offset_from_transition;
            translate([x_light,  strip_W/4, 0])
                cylinder(d=lighten_D, h=T + 2*overlap, center=true);
            translate([x_light, -strip_W/4, 0])
                cylinder(d=lighten_D, h=T + 2*overlap, center=true);
        }
    }
}

model();