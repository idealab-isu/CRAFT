// Flat hex plate with through-hole, two shallow diagonal grooves on one face,
// and a small perimeter step (thickness change) visible in top/bottom views.
// Bounding box target: ~46.2 x 40.0 x 8.0 mm

$fn = 96;

// --- Parameters (mm) ---
bbox_L = 46.19;
bbox_W = 40.00;
bbox_H = 8.00;

plate_thickness = bbox_H;

// Hex sizing (point-to-point in X, flat-to-flat in Y)
hex_point_to_point_L = bbox_L;   // across points
hex_flat_to_flat_W   = bbox_W;   // across flats

// Hole
hole_d = 8.0;
hole_offset_x = 0.0;
hole_offset_y = 0.0;

// Grooves (on top face)
groove_w = 2.0;
groove_depth = 0.8;
groove_spacing = 6.0;
groove_angle_deg = 30;
groove_len = 70;          // long enough to fully cross the hex
groove_end_r = 1.0;       // rounded ends

// Perimeter step (a shallow recess on the bottom face near the edge)
step_inset = 1.2;         // how far in from the perimeter the step boundary is
step_height = 1.0;        // depth of the recess from the bottom face

// Robust boolean overlap
eps = 0.05;

// --- Helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Regular hex polygon by point-to-point (across vertices) and flat-to-flat
module hex2d(ptp, ftf) {
    polygon(points = [
        [ ptp/2, 0],
        [ ptp/4,  ftf/2],
        [-ptp/4,  ftf/2],
        [-ptp/2, 0],
        [-ptp/4, -ftf/2],
        [ ptp/4, -ftf/2]
    ]);
}

module hex_prism(h) {
    linear_extrude(height=h, center=true, convexity=10)
        hex2d(hex_point_to_point_L, hex_flat_to_flat_W);
}

// Inner hex used to define the perimeter step boundary
module inner_hex_prism(h) {
    // Keep inset sane so polygon doesn't invert
    inset = clamp(step_inset, 0, min(hex_point_to_point_L/6, hex_flat_to_flat_W/6));
    linear_extrude(height=h, center=true, convexity=10)
        hex2d(hex_point_to_point_L - 2*inset, hex_flat_to_flat_W - 2*inset);
}

// Through hole
module through_hole() {
    translate([hole_offset_x, hole_offset_y, 0])
        cylinder(d=hole_d, h=plate_thickness + 2, center=true);
}

// Rounded-end groove cutter (capsule-like) extruded to groove depth
module groove_cutter(ypos) {
    zc = plate_thickness/2 - groove_depth/2; // cut into top face
    translate([0, ypos, zc])
        rotate([0, 0, groove_angle_deg])
            linear_extrude(height=groove_depth + 2*eps, center=true, convexity=10)
                hull() {
                    translate([ groove_len/2 - groove_end_r, 0]) circle(r=groove_end_r);
                    translate([-groove_len/2 + groove_end_r, 0]) circle(r=groove_end_r);
                }
}

// Perimeter step: remove a shallow ring from the bottom face near the edge
module perimeter_step_cut() {
    // Cut volume occupies bottom step_height
    zc = -plate_thickness/2 + step_height/2;
    translate([0, 0, zc])
        difference() {
            // Outer boundary: full hex footprint
            hex_prism(step_height + 2*eps);
            // Inner boundary: inset hex footprint
            inner_hex_prism(step_height + 4*eps);
        }
}

// --- Final model ---
difference() {
    // Main solid
    hex_prism(plate_thickness);

    // Subtractions
    union() {
        through_hole();

        // Two shallow, parallel diagonal grooves on ONE face (top)
        groove_cutter(0);
        groove_cutter(groove_spacing);

        // Perimeter step-like thickness change (bottom recess ring)
        perimeter_step_cut();
    }
}