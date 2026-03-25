// Dimension-calibrated (target: 0.03 x 0.04 x 0.01 mm)
scale([0.001333, 0.000425, 0.003667])
{
$fn = 96;

// Units: mm
thickness_z = 3.0;

body_w   = 22.0;
body_l   = 56.0;

flange_w = 30.0;
flange_l = 24.0;

hole_d = 4.0;
hole_edge_margin_x = 4.0;
hole_edge_margin_y = 4.0;

chamfer_len = 6.0;

feature_depth = 0.6;   // shallow recess
overlap = 0.2;

// Derived
total_l = body_l + flange_l;

// 2D outline (top view) with stepped flange and chamfered far end corners
module outline_2d() {
    // Coordinate system: Y along length, flange at +Y end
    // Body spans: y = [-total_l/2, +total_l/2 - flange_l]
    // Flange spans: y = [+total_l/2 - flange_l, +total_l/2]
    y_body_min = -total_l/2;
    y_body_max =  total_l/2 - flange_l;
    y_flange_min = y_body_max;
    y_flange_max = total_l/2;

    // Chamfer only on the far (non-flange) end: y_body_min corners
    polygon(points=[
        // start at left edge near flange, go CCW
        [-body_w/2, y_body_max],
        [-body_w/2, y_body_min + chamfer_len],
        [-body_w/2 + chamfer_len, y_body_min],
        [ body_w/2 - chamfer_len, y_body_min],
        [ body_w/2, y_body_min + chamfer_len],
        [ body_w/2, y_body_max],

        // step out to flange width
        [ flange_w/2, y_flange_min],
        [ flange_w/2, y_flange_max],
        [-flange_w/2, y_flange_max],
        [-flange_w/2, y_flange_min]
    ]);
}

// Through holes in flange (near its two top corners)
module flange_holes() {
    y_flange_center = total_l/2 - flange_l/2;
    y_hole = y_flange_center + (flange_l/2 - hole_edge_margin_y);

    for (sx = [-1, 1]) {
        translate([sx*(flange_w/2 - hole_edge_margin_x), y_hole, 0])
            cylinder(h=thickness_z + 2*overlap, d=hole_d, center=true);
    }
}

// Shallow V/arrow recess on both broad faces (top and bottom)
module v_recess(zsign=1) {
    // Place on body area, slightly toward the middle
    y0 = -total_l/2 + body_l*0.55;

    // 2D V shape
    v_w = body_w * 0.45;
    v_h = body_w * 0.22;
    v_th = body_w * 0.10;

    translate([0, y0, zsign*(thickness_z/2 - feature_depth/2)])
        linear_extrude(height=feature_depth + overlap, center=true)
            polygon(points=[
                [0,  v_h],
                [ v_w/2, -v_h],
                [ v_w/2 - v_th, -v_h],
                [0,  v_h*0.15],
                [-v_w/2 + v_th, -v_h],
                [-v_w/2, -v_h]
            ]);
}

module complete_model() {
    difference() {
        // Main plate as a single connected solid
        linear_extrude(height=thickness_z, center=true)
            outline_2d();

        // Holes
        flange_holes();

        // Face features (recessed on both sides)
        v_recess( 1);
        v_recess(-1);
    }
}

color("Silver") complete_model();
}
