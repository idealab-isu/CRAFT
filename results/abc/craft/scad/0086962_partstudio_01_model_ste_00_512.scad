// Dimension-calibrated (target: 0.02 x 0.01 x 0.02 mm)
scale([1.000549, 1.000549, 0.500084])
{
// Spur-gear-like wheel with external teeth and central hex through-bore
// Single solid, constant thickness, flat parallel faces

$fn = 128;

// Parameters (meters in original; keep as-is)
bbox_X = 0.02; //[0.01:0.04:0.001]
bbox_Y = 0.01; //[0.005:0.02:0.001]
bbox_Z = 0.02; //[0.01:0.04:0.001]

thickness_Y = 0.01; //[0.005:0.02:0.001]
outer_diam_XZ = 0.02; //[0.01:0.04:0.001]     // tip diameter (approx)
body_diam_XZ  = 0.016; //[0.008:0.032:0.001]   // root/body diameter

tooth_count = 12; //[6:40:1]
tooth_depth_rad = 0.002; //[0.001:0.004:0.0005]
tooth_tip_width_arc  = 0.003; //[0.0015:0.006:0.0005] // tangential width at tip
tooth_root_width_arc = 0.002; //[0.001:0.004:0.0005]  // tangential width at root

hex_flat_to_flat = 0.008; //[0.004:0.016:0.0005]
hex_clearance = 0.0002; //[0.0:0.001:0.0001]

overlap = 0.0005; //[0.0001:0.002:0.0001]
chamfer_size = 0.0005; //[0.0:0.002:0.0001]

// Derived
body_r = body_diam_XZ/2;
tooth_len = tooth_depth_rad;
tooth_w_root = tooth_root_width_arc;
tooth_w_tip  = tooth_tip_width_arc;

// Ensure teeth actually reach (or slightly exceed) requested outer diameter
// If outer_diam_XZ is larger than body+tooth_depth, extend tooth length to match.
tooth_len_eff = max(tooth_len, outer_diam_XZ/2 - body_r);

// Hex geometry: for a regular hex, flat-to-flat = sqrt(3)*R (circumradius)
hex_R = (hex_flat_to_flat + hex_clearance)/sqrt(3);

// 2D hex polygon (point-up orientation)
module hex2d(R) {
    polygon(points=[
        [ R, 0],
        [ R/2,  R*sqrt(3)/2],
        [-R/2,  R*sqrt(3)/2],
        [-R, 0],
        [-R/2, -R*sqrt(3)/2],
        [ R/2, -R*sqrt(3)/2]
    ]);
}

// Single tooth as a constant-thickness prism (extruded along Y)
module single_tooth() {
    // Place tooth so it overlaps into the body by "overlap" to guarantee connectivity
    // Inner radius = body_r - overlap
    // Outer radius = body_r + tooth_len_eff
    r_in  = body_r - overlap;
    r_out = body_r + tooth_len_eff;

    // 2D trapezoid in XZ plane, then extrude along Y
    linear_extrude(height=thickness_Y, center=true)
        polygon(points=[
            [r_in,  -tooth_w_root/2],
            [r_out, -tooth_w_tip/2],
            [r_out,  tooth_w_tip/2],
            [r_in,   tooth_w_root/2]
        ]);
}

// External teeth ring (evenly spaced around Z axis)
module external_teeth_ring() {
    for (i = [0:tooth_count-1])
        rotate([0, 0, i*360/tooth_count])
            single_tooth();
}

// Main gear blank (circular body)
module gear_body_disc() {
    cylinder(r=body_r, h=thickness_Y, center=true);
}

// Optional edge chamfer cutters (keep faces flat/parallel; chamfer only at rim)
module edge_chamfer_cutters() {
    // Cut a small 45-ish chamfer at top and bottom outer edge
    // Use cones that intersect only near the rim.
    r_outer = body_r + tooth_len_eff + overlap;
    r_inner = max(0, r_outer - chamfer_size);

    // Top chamfer cutter
    translate([0, thickness_Y/2 - chamfer_size/2, 0])
        cylinder(r1=r_outer, r2=r_inner, h=chamfer_size + 2*overlap, center=true);

    // Bottom chamfer cutter
    translate([0, -thickness_Y/2 + chamfer_size/2, 0])
        cylinder(r1=r_inner, r2=r_outer, h=chamfer_size + 2*overlap, center=true);
}

// Central hex through-bore
module central_hex_through_bore() {
    linear_extrude(height=thickness_Y + 2*overlap, center=true)
        hex2d(hex_R);
}

// Final part
module final_gear() {
    difference() {
        // One connected solid: body + teeth
        difference() {
            union() {
                gear_body_disc();
                external_teeth_ring();
            }
            if (chamfer_size > 0)
                edge_chamfer_cutters();
        }

        // Through-bore only (remove any extra cylindrical subtraction that would distort the hex)
        central_hex_through_bore();
    }
}

final_gear();
}
