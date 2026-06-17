// Compact symmetric bracket-like block with wedge wings, stepped pockets/slots,
// diamond through-holes on wings, and a V-notch along one edge.
// Scaled small but non-zero so geometry renders robustly.

$fn = 48;

// -------------------- Parameters --------------------
bb_x = 0.07;
bb_y = 0.05;
bb_z = 0.04;

body_x = 0.032;
body_y = 0.028;
body_z = bb_z;

wing_span_x_each = (bb_x - body_x)/2;          // overall X matches bb_x
wing_flare_y_at_body = body_y;
wing_flare_y_at_tip  = bb_y;
wing_z = bb_z;

step1_depth_z = 0.008;
step1_x = 0.024;
step1_y = 0.020;

step2_depth_z = 0.006;
step2_x = 0.018;
step2_y = 0.014;

slot_w = 0.004;
slot_l = 0.014;
slot_depth_z = 0.010;
slot_spacing_x = 0.006;

v_notch_depth_x = 0.010;
v_notch_opening_y = 0.016;

diamond_hole_flat = 0.004;
diamond_hole_angle_deg = 45;
diamond_hole_offset_x_from_center = body_x/2 + wing_span_x_each*0.62; // on wing region
diamond_hole_offset_y = bb_y*0.28;

pocket_depth_z = 0.004;

eps = 0.001;                 // increased for robust booleans at tiny scale
cut_through = bb_z + 4*eps;

// -------------------- Helpers --------------------
module wing_wedge(sign=1) {
    // Build wedge in +X, then mirror for left side to avoid self-crossing polygons.
    // Attached to body with slight overlap.
    if (sign < 0) {
        mirror([1,0,0]) wing_wedge(1);
    } else {
        translate([body_x/2 - eps, 0, 0])
            linear_extrude(height=wing_z, center=true)
                polygon(points=[
                    [0, -wing_flare_y_at_body/2],
                    [wing_span_x_each, -wing_flare_y_at_tip/2],
                    [wing_span_x_each,  wing_flare_y_at_tip/2],
                    [0,  wing_flare_y_at_body/2]
                ]);
    }
}

module base_solid() {
    union() {
        cube([body_x, body_y, body_z], center=true);
        wing_wedge(-1);
        wing_wedge(+1);
    }
}

// Stepped recesses on the TOP face (subtract)
module top_step_recesses() {
    translate([0, 0, body_z/2 - step1_depth_z/2 + eps])
        cube([step1_x, step1_y, step1_depth_z + 2*eps], center=true);

    translate([0, 0, body_z/2 - step1_depth_z - step2_depth_z/2 + eps])
        cube([step2_x, step2_y, step2_depth_z + 2*eps], center=true);
}

// Three rectangular slots/pockets on the TOP face (subtract)
module top_slots() {
    for (sx = [-slot_spacing_x, 0, slot_spacing_x]) {
        translate([sx, 0, body_z/2 - slot_depth_z/2 + eps])
            cube([slot_l, slot_w, slot_depth_z + 2*eps], center=true);
    }
}

// Additional small bottom pocket (subtract)
module bottom_pocket() {
    translate([0, 0, -body_z/2 + pocket_depth_z/2 - eps])
        cube([step2_x*0.55, step2_y*0.55, pocket_depth_z + 2*eps], center=true);
}

// V-notch along the +X outer edge (subtract), visible in top/bottom views
module v_notch() {
    // Use a centered 2D triangle and place it so its left edge sits on +X outer face.
    translate([bb_x/2 - v_notch_depth_x/2, 0, 0])
        linear_extrude(height=cut_through, center=true)
            polygon(points=[
                [-v_notch_depth_x/2, -v_notch_opening_y/2],
                [ v_notch_depth_x/2,  0],
                [-v_notch_depth_x/2,  v_notch_opening_y/2]
            ]);
}

// Diamond/square through-holes on wing regions (subtract)
module diamond_holes() {
    for (sx = [-1, 1]) {
        translate([sx*diamond_hole_offset_x_from_center, sx*diamond_hole_offset_y, 0])
            rotate([0, 0, diamond_hole_angle_deg])
                cube([diamond_hole_flat, diamond_hole_flat, cut_through], center=true);
    }
}

// -------------------- Final Model --------------------
difference() {
    base_solid();

    top_step_recesses();
    top_slots();
    bottom_pocket();
    v_notch();
    diamond_holes();
}