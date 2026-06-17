// Dimension-calibrated (target: 0.04 x 0.05 x 0.07 mm)
scale([0.000960, 0.000940, 0.000764])
{
// Wedge-shaped mounting bracket/block (single connected solid)

// ---------- Parameters ----------
L = 70; //[35:140:1]
W = 50; //[25:100:1]
H = 40; //[20:80:1]

// Wedge / slope definition along X (from left end toward right end)
slope_start_x = 15; //[7.5:30:1]   // distance from left end where slope begins
slope_end_x   = 70; //[35:140:1]   // distance from left end where slope ends (typically L)
slope_drop    = 22; //[11:44:1]    // how much lower the top is at slope_end vs full height

// Left end flange/step
flange_len     = 12; //[6:24:1]
flange_extra_h = 10; //[5:20:1]

// Lower foot protrusion (left end)
foot_len = 10; //[5:20:1]
foot_h   = 8;  //[4:16:1]
foot_w   = 30; //[15:60:1]

// Side/sloped-region fastener features
hole_d        = 4;  //[2:8:0.5]
hole_offset_x = 40; //[20:80:1]   // from left end
hole_offset_z = 20; //[10:40:1]   // from bottom
hole_spacing  = 12; //[6:24:1]
hole_count    = 2;  //[1:4:1]

recess_d     = 7; //[3.5:14:0.5]
recess_depth = 3; //[1.5:6:0.5]

// Edge details
chamfer = 2; //[1:4:0.5]
notch_w = 6; //[3:12:0.5]
notch_h = 6; //[3:12:0.5]
notch_depth = 4; //[2:8:0.5]

overlap = 0.8; //[0.5:2:0.1]
$fn = 64;

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Convert "distance from left end" to centered X coordinate
function x_from_left(d) = -L/2 + d;

// ---------- Core geometry ----------
module base_block() {
    cube([L, W, H], center=true);
}

// Cut away the top to form a wedge (top slopes down along +X)
module wedge_top_cut() {
    // Ensure sane values
    sx = clamp(slope_start_x, 0, L);
    ex = clamp(slope_end_x, sx + 0.01, L);
    drop = clamp(slope_drop, 0, H - 0.01);

    // In X-Z plane (Y extruded), remove region above the desired top surface.
    // Desired top surface:
    //  - for x <= sx: z = +H/2
    //  - for x >= ex: z = +H/2 - drop
    //  - linear between
    //
    // We subtract a polygon that covers "above" that surface.
    linear_extrude(height=W + 2*overlap, center=true)
        polygon(points=[
            // Far left, very high
            [-L/2 - 2*overlap,  H/2 + 3*H],
            // Far right, very high
            [ L/2 + 2*overlap,  H/2 + 3*H],

            // Right end: start of cut boundary at lowered top
            [ x_from_left(ex) + 2*overlap,  H/2 - drop],
            // Slope start: full top height
            [ x_from_left(sx),              H/2],
            // Left end: full top height
            [-L/2 - 2*overlap,              H/2]
        ]);
}

// Left end flange/step (taller vertical face)
module end_flange_step() {
    translate([x_from_left(flange_len/2) - overlap/2, 0, flange_extra_h/2])
        cube([flange_len + overlap, W, H + flange_extra_h], center=true);
}

// Lower foot protrusion at left end (adds material)
module lower_foot_protrusion() {
    translate([x_from_left(foot_len/2) - overlap/2, 0, -H/2 - foot_h/2 + overlap/2])
        cube([foot_len + overlap, foot_w, foot_h], center=true);
}

// Through-hole from the sloped/side region: drill along Y (side-to-side)
module hole_through_at(xc, zc) {
    translate([xc, 0, zc])
        rotate([90, 0, 0])
            cylinder(d=hole_d, h=W + 4*overlap, center=true);
}

// Recess/counterbore from +Y side only (shallow)
module hole_recess_at(xc, zc) {
    translate([xc, W/2 - (recess_depth/2) + overlap/2, zc])
        rotate([90, 0, 0])
            cylinder(d=recess_d, h=recess_depth + 2*overlap, center=true);
}

// Simple top edge chamfers (front/back)
module chamfer_cut(y_pos) {
    translate([0, y_pos, H/2 - chamfer/2 + overlap/2])
        rotate([45, 0, 0])
            cube([L + 4*overlap, chamfer*2, chamfer*2], center=true);
}

// Small alignment notch on left end (cuts into the left face)
module small_alignment_notch(y_pos) {
    translate([-L/2 + (notch_depth/2) - overlap/2, y_pos, -H/2 + notch_h/2])
        cube([notch_depth + 2*overlap, notch_w, notch_h], center=true);
}

// ---------- Final model ----------
module final_model() {
    sx = clamp(slope_start_x, 0, L);
    ex = clamp(slope_end_x, sx + 0.01, L);
    drop = clamp(slope_drop, 0, H - 0.01);

    // Place holes on the sloped region (in X), and around mid-height (in Z)
    // Keep them within the wedge body
    hole_x0 = clamp(hole_offset_x, 0, L);
    hole_z  = clamp(hole_offset_z, 0, H);

    difference() {
        union() {
            // Main body with wedge top
            difference() {
                base_block();
                wedge_top_cut();
            }

            // Add flange and foot (connected with overlap)
            end_flange_step();
            lower_foot_protrusion();
        }

        // Side/sloped-region holes + recesses
        for (i = [0:hole_count-1]) {
            xi = clamp(hole_x0 + i*hole_spacing, 0, L);
            xc = x_from_left(xi);
            zc = -H/2 + hole_z;

            hole_through_at(xc, zc);
            hole_recess_at(xc, zc);
        }

        // Chamfers on front/back top edges
        chamfer_cut( W/2 - chamfer/2);
        chamfer_cut(-W/2 + chamfer/2);

        // Notches near left end on both sides
        small_alignment_notch( W/2 - notch_w/2);
        small_alignment_notch(-W/2 + notch_w/2);
    }
}

color("Silver") final_model();
}
