$fn = 96;

// -------------------- Parameters (mm) --------------------
bbox_L = 46.2;
bbox_W = 40.0;
bbox_T = 7.0;

// Hex profile (point-to-point along X, flat-to-flat along Y)
hex_point_to_point_L = bbox_L;
hex_flat_to_flat_W   = bbox_W;

// Features
hole_d = 4.0;
hole_x_off = 0.0;
hole_y_off = 0.0;

groove_w = 6.0;
groove_depth = 1.2;
groove_angle_deg = 30;
groove_center_x = 0.0;
groove_center_y = 0.0;

end_step_len = 3.0;
end_step_depth = 0.6;

notch_w = 6.0;
notch_len = 4.0;
notch_depth = 1.0;

// Small edge break (avoid heavy Minkowski rounding that distorts hole/groove)
edge_chamfer = 0.35;

// Robust boolean overlap
overlap = 0.6;

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Hex 2D polygon (point-to-point in X, flat-to-flat in Y)
module hex2d(pp = hex_point_to_point_L, ff = hex_flat_to_flat_W) {
    polygon(points=[
        [ pp/2, 0],
        [ pp/4,  ff/2],
        [-pp/4,  ff/2],
        [-pp/2, 0],
        [-pp/4, -ff/2],
        [ pp/4, -ff/2]
    ]);
}

// Slight chamfered prism via hull of two extrusions (keeps features crisp)
module chamfered_hex_prism(t=bbox_T, cham=edge_chamfer) {
    cham2 = clamp(cham, 0, t/2 - 0.01);
    hull() {
        translate([0,0,0])
            linear_extrude(height=cham2)
                offset(delta=-cham2) hex2d();
        translate([0,0,cham2])
            linear_extrude(height=t-2*cham2)
                hex2d();
        translate([0,0,t-cham2])
            linear_extrude(height=cham2)
                offset(delta=-cham2) hex2d();
    }
}

// -------------------- Features (subtractive) --------------------
module through_hole() {
    translate([hole_x_off, hole_y_off, bbox_T/2])
        cylinder(d=hole_d, h=bbox_T + 2*overlap, center=true);
}

// Diagonal recessed band on the TOP broad face (Z+)
module diagonal_face_groove() {
    // Cut only into top face by groove_depth
    translate([groove_center_x, groove_center_y, bbox_T - groove_depth/2])
        rotate([0,0,groove_angle_deg])
            cube([bbox_L + 2*overlap, groove_w, groove_depth + 2*overlap], center=true);
}

// Slight end step/chamfer-like relief on one end (top face)
module end_step_relief() {
    translate([bbox_L/2 - end_step_len/2, 0, bbox_T - end_step_depth/2])
        cube([end_step_len + 2*overlap, bbox_W + 2*overlap, end_step_depth + 2*overlap], center=true);
}

// Notch-like relief on same end (top face), narrower than full width
module end_notch_relief() {
    translate([bbox_L/2 - notch_len/2, 0, bbox_T - notch_depth/2])
        cube([notch_len + 2*overlap, notch_w, notch_depth + 2*overlap], center=true);
}

// -------------------- Final solid --------------------
difference() {
    chamfered_hex_prism();
    through_hole();
    diagonal_face_groove();
    end_step_relief();
    end_notch_relief();
}