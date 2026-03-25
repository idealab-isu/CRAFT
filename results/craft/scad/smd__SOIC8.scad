// SMD package envelope (must match exactly)
body_length = 4.90;   // X
body_width  = 3.90;   // Y
body_height = 1.25;   // Z

// Detail parameters (kept strictly INSIDE the envelope)
chamfer_xy = 0.30;          // corner chamfer in XY
top_edge_bevel = 0.12;      // slight top edge bevel (visual)
polarity_mark_radius = 0.35;
polarity_mark_depth  = 0.08; // engraved (subtracted), stays inside
polarity_mark_inset  = 0.60; // from top-left corner

eps = 0.02;
$fn = 64;

// 2D chamfered rectangle for robust 3D extrusion
module chamfered_rect_2d(L, W, c) {
    c2 = min(c, min(L, W)/2 - eps);
    polygon(points=[
        [ L/2 - c2,  W/2],
        [-L/2 + c2,  W/2],
        [-L/2,       W/2 - c2],
        [-L/2,      -W/2 + c2],
        [-L/2 + c2, -W/2],
        [ L/2 - c2, -W/2],
        [ L/2,      -W/2 + c2],
        [ L/2,       W/2 - c2]
    ]);
}

// Main body: chamfered footprint + slight top bevel (all within envelope)
module main_body() {
    // Bottom footprint (slightly more chamfered)
    c_bot = chamfer_xy;

    // Top footprint (slightly inset to create a bevel)
    inset = min(top_edge_bevel, min(body_length, body_width)/4);
    L_top = body_length - 2*inset;
    W_top = body_width  - 2*inset;
    c_top = max(chamfer_xy - inset, 0);

    // Ensure valid top dimensions
    L_top2 = max(L_top, eps*4);
    W_top2 = max(W_top, eps*4);

    // Build as a single solid via hull between bottom and top profiles
    hull() {
        translate([0, 0, -body_height/2])
            linear_extrude(height=eps, center=false)
                chamfered_rect_2d(body_length, body_width, c_bot);

        translate([0, 0,  body_height/2 - eps])
            linear_extrude(height=eps, center=false)
                chamfered_rect_2d(L_top2, W_top2, c_top);
    }
}

// Engraved polarity mark (subtracted) on top face, fully inside
module polarity_mark_cut() {
    x0 = -body_length/2 + polarity_mark_inset;
    y0 =  body_width/2  - polarity_mark_inset;

    // Clamp to keep circle fully inside top face
    x = min(max(x0, -body_length/2 + polarity_mark_radius + eps),
                 body_length/2 - polarity_mark_radius - eps);
    y = min(max(y0, -body_width/2  + polarity_mark_radius + eps),
                 body_width/2  - polarity_mark_radius - eps);

    // Cut down from the top surface
    translate([x, y, body_height/2 - polarity_mark_depth/2])
        cylinder(r=polarity_mark_radius, h=polarity_mark_depth + 2*eps, center=true);
}

module smd_complete() {
    // ONE connected solid, exact envelope, with visible SMD-like details
    difference() {
        main_body();
        polarity_mark_cut();
    }
}

smd_complete();