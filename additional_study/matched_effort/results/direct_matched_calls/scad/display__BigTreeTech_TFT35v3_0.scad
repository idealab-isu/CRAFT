$fn=64;

// Display Module v3.0
// Overall size: 84.5mm x 54.5mm

module display_module_v3(
    L=84.5,   // length (X)
    W=54.5,   // width  (Y)
    T=1.6,    // PCB thickness
    corner_r=2.5,

    // Mounting holes (typical)
    hole_d=3.2,
    hole_edge_x=3.5,
    hole_edge_y=3.5,

    // Display window / cutout (representative)
    window_L=70.0,
    window_W=40.0,
    window_margin_top=6.0,   // from top edge (positive Y side)
    window_margin_left=7.25, // from left edge (negative X side)
    window_depth=0.9,        // recess depth into PCB

    // Header footprint (representative)
    header_pins=8,
    header_pitch=2.54,
    header_pad_L=header_pins*2.54 + 2.0,
    header_pad_W=6.0,
    header_margin_bottom=4.0, // from bottom edge (negative Y side)
    header_margin_left=7.0,   // from left edge (negative X side)
    header_recess=0.4
) {
    module rounded_rect_2d(x, y, r){
        r2 = min(r, min(x,y)/2);
        hull() {
            for (sx=[-1,1], sy=[-1,1])
                translate([sx*(x/2-r2), sy*(y/2-r2)]) circle(r=r2);
        }
    }

    difference() {
        // PCB body
        linear_extrude(height=T)
            rounded_rect_2d(L, W, corner_r);

        // Mounting holes
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(L/2 - hole_edge_x), sy*(W/2 - hole_edge_y), -0.1])
                cylinder(d=hole_d, h=T+0.2);
        }

        // Display window recess (top face)
        // Position: from left and top margins
        win_cx = -L/2 + window_margin_left + window_L/2;
        win_cy =  W/2 - window_margin_top - window_W/2;
        translate([win_cx, win_cy, T-window_depth])
            linear_extrude(height=window_depth+0.05)
                rounded_rect_2d(window_L, window_W, 1.5);

        // Header recess (bottom-left area)
        hdr_cx = -L/2 + header_margin_left + header_pad_L/2;
        hdr_cy = -W/2 + header_margin_bottom + header_pad_W/2;
        translate([hdr_cx, hdr_cy, T-header_recess])
            linear_extrude(height=header_recess+0.05)
                rounded_rect_2d(header_pad_L, header_pad_W, 1.0);
    }

    // Optional: simple pin markers (non-subtractive), slightly above PCB
    // Comment out if undesired.
    pin_start_x = -L/2 + header_margin_left + 1.0;
    pin_y = -W/2 + header_margin_bottom + header_pad_W/2;
    for (i=[0:header_pins-1]) {
        translate([pin_start_x + i*header_pitch, pin_y, T])
            color([0.8,0.7,0.2]) cylinder(d=1.2, h=2.5);
    }
}

display_module_v3();