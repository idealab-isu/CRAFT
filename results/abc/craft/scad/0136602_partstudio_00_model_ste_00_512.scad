// Dimension-calibrated (target: 0.07 x 0.05 x 0.04 mm)
scale([0.000991, 0.001089, 0.003167])
{
// Compact symmetric bracket-like block with wedge wings, stepped pockets, V-notch, and diamond through-holes.
// Fixes:
// - Use realistic mm-scale dimensions (avoid near-zero that can render "blank").
// - Ensure wings are connected (no accidental rotation/offset separation).
// - Make V-notch truly V-shaped in top/bottom by cutting a triangular prism from the -Y edge.
// - Keep all translations dimension-derived.

$fn = 64;

// -------------------- Parameters (mm) --------------------
body_x = 32;
body_y = 28;
body_z = 12;

wing_span_x_each = 19;     // extension beyond body on each side
wing_y_root      = body_y; // width at body interface
wing_y_tip       = 45;     // width at outer tip
wing_z           = body_z;

v_notch_depth_y   = 10;    // how far the V goes inward from -Y edge
v_notch_opening_x = 18;    // opening width along X at the edge

step_depth_x  = 6;         // stepped face pocket depth (from +X side)
step_height_z = 5;         // pocket height near top

slot_count     = 3;
slot_x         = 16;
slot_y         = 6;
slot_depth_z   = 7;
slot_spacing_y = 8;

micro_pocket_x = 6;
micro_pocket_y = 4;
micro_pocket_z = 4;

diamond_hole_d = 6;        // square size (rotated 45° to look diamond)
overlap        = 0.2;      // small overlap to avoid coincident faces

// -------------------- Derived --------------------
total_x = body_x + 2*wing_span_x_each;
total_y = max(body_y, wing_y_tip);
total_z = body_z;

// -------------------- Helpers --------------------
module wing_wedge(side=1) {
    // side: +1 right, -1 left
    // Wedge in XY, extruded in Z, attached flush to body side with overlap.
    // Polygon spans x=[0..wing_span_x_each] so we place its x=0 edge at body side.
    translate([side*(body_x/2 - overlap), 0, 0])
        mirror([side==-1 ? 1 : 0, 0, 0])  // mirror for left side
            linear_extrude(height=wing_z, center=true)
                polygon(points=[
                    [0,               -wing_y_root/2],
                    [wing_span_x_each, -wing_y_tip/2],
                    [wing_span_x_each,  wing_y_tip/2],
                    [0,                wing_y_root/2]
                ]);
}

module v_notch_cut() {
    // True V-shaped notch along the -Y edge, visible in top/bottom.
    // Cut a triangular prism that extends inward (+Y) by v_notch_depth_y.
    // Triangle defined in XY, extruded through Z.
    translate([0, 0, 0])
        linear_extrude(height=total_z + 2*overlap, center=true)
            polygon(points=[
                [-v_notch_opening_x/2, -total_y/2 - overlap],
                [ v_notch_opening_x/2, -total_y/2 - overlap],
                [0,                    -total_y/2 + v_notch_depth_y]
            ]);
}

module top_step_pocket() {
    // Pocket on +X face near top (stepped face)
    translate([ (body_x/2 - step_depth_x/2 + overlap/2), 0,
                (body_z/2 - step_height_z/2 + overlap/2) ])
        cube([step_depth_x + overlap, body_y + 2*overlap, step_height_z + overlap], center=true);
}

module slots_pockets() {
    // Three rectangular slots/pockets cut from top surface
    zpos = (body_z/2 - slot_depth_z/2 + overlap/2);
    for (i = [0:slot_count-1]) {
        y = (i - (slot_count-1)/2) * slot_spacing_y;
        translate([0, y, zpos])
            cube([slot_x, slot_y, slot_depth_z + overlap], center=true);
    }

    // Small micro pockets on bottom surface
    zneg = -(body_z/2 - micro_pocket_z/2 + overlap/2);
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(body_x/4), sy*(body_y/4), zneg])
            cube([micro_pocket_x, micro_pocket_y, micro_pocket_z + overlap], center=true);
    }
}

module diamond_through_holes() {
    // Two diamond/square through-holes on the sloped wing regions.
    // Place them outside the body, within each wing.
    xh = body_x/2 + wing_span_x_each*0.60;
    yh = wing_y_tip*0.22;

    for (sx = [-1, 1]) {
        translate([sx*xh, yh, 0])
            rotate([0,0,45])
                cube([diamond_hole_d, diamond_hole_d, total_z + 4*overlap], center=true);
    }
}

// -------------------- Main Model --------------------
module final_model() {
    difference() {
        union() {
            // Central body
            cube([body_x, body_y, body_z], center=true);

            // Connected symmetric wings
            wing_wedge(+1);
            wing_wedge(-1);
        }

        // V-notch opening
        v_notch_cut();

        // Stepped face pocket
        top_step_pocket();

        // Slots and micro pockets
        slots_pockets();

        // Diamond through-holes
        diamond_through_holes();
    }
}

final_model();
}
