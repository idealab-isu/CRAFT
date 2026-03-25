// Long narrow strap with through-holes and a forked U-slot end
// Bounding box target: ~105.06 x 9.72 x 12 mm (X x Y x Z)

$fn = 64;

// Parameters
L = 105.06;                 // overall length (X)
W = 9.72;                   // overall width  (Y)
H = 12;                     // thickness      (Z)

hole_d = 4;
hole_count = 6;
hole_pitch = 14;
hole_edge_margin = 10;
hole_centerline_offset_y = 0;

fork_depth = 18;            // depth of fork cut from the end (along X)
fork_slot_w = 4.2;          // slot width (along Y)
fork_slot_end_clearance = 1.5; // extra radius at slot inner end
tine_min_wall = 2.5;        // minimum wall each side of slot
overlap = 0.5;              // boolean overlap

// Derived / clamped values to ensure valid geometry
slot_w = min(fork_slot_w, max(0.1, W - 2*tine_min_wall));
slot_end_r = slot_w/2 + fork_slot_end_clearance;

// Main bar body
module main_bar_body() {
    cube([L, W, H], center=true);
}

// Through holes
module through_hole_pattern() {
    for (i = [0:hole_count-1]) {
        translate([-L/2 + hole_edge_margin + i*hole_pitch, hole_centerline_offset_y, 0])
            cylinder(d=hole_d, h=H + 2*overlap, center=true);
    }
}

// Fork U-slot (rectangular slot + rounded inner end)
module fork_u_slot() {
    // Slot runs from the fork end (x = +L/2) inward by fork_depth
    // Place a rectangular cut that reaches the end, plus a round end at the inner termination.
    union() {
        // Rectangular portion reaching the end
        translate([L/2 - fork_depth/2, 0, 0])
            cube([fork_depth + overlap, slot_w, H + 2*overlap], center=true);

        // Rounded inner end (at x = L/2 - fork_depth)
        translate([L/2 - fork_depth, 0, 0])
            cylinder(r=slot_end_r, h=H + 2*overlap, center=true);
    }
}

// Final model (single connected solid)
module final_model() {
    difference() {
        main_bar_body();
        union() {
            through_hole_pattern();
            fork_u_slot();
        }
    }
}

color("Silver") final_model();