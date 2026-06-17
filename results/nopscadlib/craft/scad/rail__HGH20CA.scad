// Miniature linear guide rail (profiled rail) - 20.0mm W, 17.5mm H, 100mm L
// One connected solid, with raceways + mounting holes + top relief features

$fn = 64;

// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 20.0;  //[10.0:40.0:0.5]
rail_H = 17.5;  //[8.75:35.0:0.5]

hole_d = 3.5;           //[1.75:7.0:0.1]
hole_pitch = 25.0;      //[12.5:50.0:0.5]
hole_edge_offset = 12.5;//[5.0:20.0:0.5]  // distance from each end to first hole center
hole_count = 4;         //[2:8:1]
hole_clearance = 0.2;   //[0.0:0.5:0.05]

overlap = 0.6;          //[0.2:2.0:0.1]

// Rail feature parameters (kept within overall W/H)
top_flat_W = 12.0;      //[6.0:18.0:0.5]   // top land width
top_relief_depth = 1.2; //[0.5:3.0:0.1]    // shallow top relief depth
side_step_in = (rail_W - top_flat_W)/2;   // per-side inset from full width to top land

race_r = 2.2;           //[1.0:3.5:0.1]    // raceway groove radius
race_depth = 1.2;       //[0.5:2.5:0.1]    // how far groove cuts into side
race_z = 0.0;           // centered vertically

bottom_relief_depth = 0.8; //[0.0:2.0:0.1]
bottom_relief_W = 10.0;    //[4.0:16.0:0.5]

end_bevel = 1.5;        //[0.5:3.0:0.1]
chamfer = 0.8;          //[0.0:2.0:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rail_envelope() {
    // Base rectangular envelope at exact requested dimensions
    cube([rail_L, rail_W, rail_H], center=true);
}

module end_bevel_cut(signx=1, signz=1) {
    // 45° bevel at ends, computed from dimensions (no arbitrary offsets)
    // signx: +1 for +X end, -1 for -X end
    // signz: +1 for top corner, -1 for bottom corner
    translate([signx*(rail_L/2 - end_bevel/2 + overlap/2), 0, signz*(rail_H/2 - end_bevel/2 + overlap/2)])
        rotate([0, signx*signz*45, 0])
            cube([end_bevel + overlap, rail_W + 2*overlap, rail_H + 2*overlap], center=true);
}

module edge_chamfer_cut(signy=1, signz=1) {
    // Long chamfer along edges (Y/Z edges), computed from dimensions
    translate([0,
               signy*(rail_W/2 - chamfer/2 + overlap/2),
               signz*(rail_H/2 - chamfer/2 + overlap/2)])
        rotate([0,0, signy*signz*45])
            cube([rail_L + 2*overlap, chamfer + overlap, chamfer + overlap], center=true);
}

module mounting_holes() {
    // Through holes along Y (top-to-bottom direction is Z; holes go through width Y)
    // Positions computed from hole_count, pitch, and edge offset.
    for (i = [0:hole_count-1]) {
        x = -rail_L/2 + hole_edge_offset + i*hole_pitch;
        translate([x, 0, 0])
            rotate([90,0,0])
                cylinder(h=rail_W + 2*overlap, r=(hole_d + hole_clearance)/2, center=true);
        // Counterbore-like shallow top relief around hole (carriage interface cue)
        // Kept shallow so overall height remains rail_H.
        cb_r = (hole_d + hole_clearance)/2 + 1.6;
        cb_h = clamp(top_relief_depth, 0, rail_H/3);
        translate([x, 0, rail_H/2 - cb_h/2 + overlap/2])
            cylinder(h=cb_h + overlap, r=cb_r, center=true);
    }
}

module top_relief() {
    // Shallow recessed channel on top to suggest carriage running surface
    // Cuts only into top face; width equals top_flat_W.
    d = clamp(top_relief_depth, 0, rail_H/2);
    translate([0, 0, rail_H/2 - d/2 + overlap/2])
        cube([rail_L + 2*overlap, top_flat_W, d + overlap], center=true);
}

module bottom_relief() {
    // Shallow relief on bottom (common rail underside feature)
    d = clamp(bottom_relief_depth, 0, rail_H/2);
    translate([0, 0, -rail_H/2 + d/2 - overlap/2])
        cube([rail_L + 2*overlap, bottom_relief_W, d + overlap], center=true);
}

module side_raceways() {
    // Two longitudinal raceway grooves on the sides (left/right), cut as cylinders along X.
    // Cylinder axis along X; positioned so it intersects side faces by race_depth.
    // Ensure grooves stay within height.
    rz = clamp(race_z, -rail_H/2 + race_r + 0.2, rail_H/2 - race_r - 0.2);

    // Place cylinder centers slightly inside from side faces by (race_r - race_depth)
    inset = race_r - clamp(race_depth, 0, race_r-0.05);
    y_center = rail_W/2 - inset;

    for (sy = [-1, 1]) {
        translate([0, sy*y_center, rz])
            rotate([0,90,0])
                cylinder(h=rail_L + 2*overlap, r=race_r, center=true);
    }
}

module top_side_steps() {
    // Create a stepped profile: remove material from top outer shoulders,
    // leaving a narrower top land (top_flat_W).
    // This is a subtractive cut on both sides near the top.
    d = clamp(top_relief_depth*0.9 + 0.6, 0.6, rail_H/2);
    step_w = side_step_in;
    if (step_w > 0.01) {
        for (sy = [-1, 1]) {
            translate([0,
                       sy*(rail_W/2 - step_w/2),
                       rail_H/2 - d/2 + overlap/2])
                cube([rail_L + 2*overlap, step_w + overlap, d + overlap], center=true);
        }
    }
}

module rail_cuts() {
    union() {
        // Holes + counterbores
        mounting_holes();

        // Profile features
        top_relief();
        top_side_steps();
        bottom_relief();
        side_raceways();

        // Edge chamfers (all 4 long edges)
        if (chamfer > 0) {
            edge_chamfer_cut( 1, 1);
            edge_chamfer_cut(-1, 1);
            edge_chamfer_cut( 1,-1);
            edge_chamfer_cut(-1,-1);
        }

        // End bevels (4 corners at each end)
        if (end_bevel > 0) {
            end_bevel_cut( 1, 1);
            end_bevel_cut( 1,-1);
            end_bevel_cut(-1, 1);
            end_bevel_cut(-1,-1);
        }
    }
}

// Final model: one connected solid
difference() {
    rail_envelope();
    rail_cuts();
}