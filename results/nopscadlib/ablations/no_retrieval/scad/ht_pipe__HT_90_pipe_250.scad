$fn = 128;

// =====================
// Parameters (mm)
// =====================
dn = 90;                 // HT 90
pipe_od = 90;            // outside diameter
wall_thk = 3.5;          // typical HT wall
bend_angle_deg = 90;     // elbow angle
centerline_radius = 125; // elbow CLR (adjust as needed)
socket_length = 250;     // requested: 250 mm (each straight socket length)
socket_od = 96;          // socket OD (slightly larger than pipe OD)
socket_stop_lip_thk = 2;
socket_stop_lip_len = 6;
overlap = 1;             // small overlap to ensure watertight unions/differences
chamfer_len = 3;
groove_depth = 1.5;
groove_width = 6;
groove_offset_from_mouth = 18;

// =====================
// Derived
// =====================
pipe_id = pipe_od - 2*wall_thk;
socket_id = pipe_id;                 // socket bore matches pipe ID
elbow_outer_r = pipe_od/2;
elbow_inner_r = pipe_id/2;

socket_outer_r = socket_od/2;
socket_inner_r = socket_id/2;

// =====================
// Helpers
// =====================
module ring_arc_2d(r_outer, r_inner, a0, a1) {
    // 2D annular sector in XY plane, centered at origin
    difference() {
        polygon(points = concat(
            [ for (a = [a0 : 2 : a1]) [r_outer*cos(a), r_outer*sin(a)] ],
            [ for (a = [a1 : -2 : a0]) [r_inner*cos(a), r_inner*sin(a)] ]
        ));
    }
}

module elbow_shell_90(clr, r_outer, r_inner, angle_deg) {
    // Create a 90° (or angle_deg) elbow by rotating an annular sector around Z
    // Centerline radius = clr
    rotate_extrude(angle = angle_deg, convexity = 10)
        translate([clr, 0, 0])
            ring_arc_2d(r_outer, r_inner, 0, 360);
}

module tube_x(len, r_outer, r_inner) {
    // centered along X
    difference() {
        cylinder(h = len, r = r_outer, center = true);
        cylinder(h = len + 2*overlap, r = r_inner, center = true);
    }
}

module tube_y(len, r_outer, r_inner) {
    // centered along Y
    rotate([0,0,90]) tube_x(len, r_outer, r_inner);
}

module chamfer_x_at_mouth(mouth_x, r_outer, len) {
    // chamfer at open end plane x = mouth_x, pointing inward (-X)
    translate([mouth_x - len/2, 0, 0])
        rotate([0,90,0])
            cylinder(h = len, r1 = r_outer, r2 = max(0.01, r_outer - len), center = true);
}

module chamfer_y_at_mouth(mouth_y, r_outer, len) {
    translate([0, mouth_y - len/2, 0])
        rotate([-90,0,0])
            cylinder(h = len, r1 = r_outer, r2 = max(0.01, r_outer - len), center = true);
}

module groove_x(mouth_x, offset, w, r_groove) {
    // subtract a shallow ring groove inside socket near mouth
    // groove centered at x = mouth_x - offset
    translate([mouth_x - offset, 0, 0])
        rotate([0,90,0])
            cylinder(h = w, r = r_groove, center = true);
}

module groove_y(mouth_y, offset, w, r_groove) {
    translate([0, mouth_y - offset, 0])
        rotate([-90,0,0])
            cylinder(h = w, r = r_groove, center = true);
}

module stop_lip_x(mouth_x, len, r_outer, r_inner) {
    // internal stop ring near the inner end of socket (towards elbow)
    // place it at x = (mouth_x - socket_length) + len/2
    x0 = mouth_x - socket_length + len/2;
    translate([x0, 0, 0])
        rotate([0,90,0])
            difference() {
                cylinder(h = len, r = r_outer, center = true);
                cylinder(h = len + 2*overlap, r = r_inner, center = true);
            }
}

module stop_lip_y(mouth_y, len, r_outer, r_inner) {
    y0 = mouth_y - socket_length + len/2;
    translate([0, y0, 0])
        rotate([-90,0,0])
            difference() {
                cylinder(h = len, r = r_outer, center = true);
                cylinder(h = len + 2*overlap, r = r_inner, center = true);
            }
}

// =====================
// Model
// Coordinate system:
// - Elbow centerline is a quarter-circle from +X to +Y around Z.
// - End centerlines are at:
//   X-end: (clr, 0, 0) with axis along +X
//   Y-end: (0, clr, 0) with axis along +Y
// Sockets extend OUTWARD from those ends by socket_length.
// =====================
module ht_elbow_90_with_sockets() {

    // Mouth planes (open ends) for sockets:
    mouth_x = centerline_radius + socket_length; // open end at +X
    mouth_y = centerline_radius + socket_length; // open end at +Y

    difference() {
        union() {
            // Elbow body (hollow)
            elbow_shell_90(centerline_radius, elbow_outer_r, elbow_inner_r, bend_angle_deg);

            // Socket on X end: centered at x = clr + socket_length/2, axis along X
            translate([centerline_radius + socket_length/2 - overlap/2, 0, 0])
                rotate([0,90,0])
                    tube_x(socket_length + overlap, socket_outer_r, socket_inner_r);

            // Socket on Y end: centered at y = clr + socket_length/2, axis along Y
            translate([0, centerline_radius + socket_length/2 - overlap/2, 0])
                rotate([-90,0,0])
                    tube_x(socket_length + overlap, socket_outer_r, socket_inner_r);

            // Internal stop lips (rings) near elbow side of each socket
            stop_lip_x(mouth_x, socket_stop_lip_len,
                       socket_inner_r, max(0.01, socket_inner_r - socket_stop_lip_thk));
            stop_lip_y(mouth_y, socket_stop_lip_len,
                       socket_inner_r, max(0.01, socket_inner_r - socket_stop_lip_thk));

            // Outer chamfers at mouths
            chamfer_x_at_mouth(mouth_x, socket_outer_r, chamfer_len);
            chamfer_y_at_mouth(mouth_y, socket_outer_r, chamfer_len);
        }

        // Sealing grooves (subtractive) inside sockets near mouths
        union() {
            groove_x(mouth_x, groove_offset_from_mouth, groove_width,
                     socket_inner_r + groove_depth);
            groove_y(mouth_y, groove_offset_from_mouth, groove_width,
                     socket_inner_r + groove_depth);
        }
    }
}

color("Silver") ht_elbow_90_with_sockets();