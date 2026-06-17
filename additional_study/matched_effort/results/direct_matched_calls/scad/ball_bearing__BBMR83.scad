$fn = 128;

bore_d = 3.0;
outer_d = 8.0;
width = 3.0;

// Simple ball bearing representation: outer ring + inner ring + ball cage (balls)
clearance = 0.15;          // radial clearance between rings and balls
ring_gap = 0.35;           // radial gap between inner/outer rings (raceway space)
race_depth = 0.35;         // how much to "groove" the rings (visual)
ball_d = 1.2;              // ball diameter (visual approximation)
ball_count = 8;

module ring(od, id, w) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module grooved_ring(od, id, w, groove_r, groove_offset_r) {
    // groove_offset_r is radius from center where groove is cut
    difference() {
        ring(od, id, w);
        // Cut a torus-like groove by subtracting a rotated circle (approximated with rotate_extrude)
        rotate_extrude(convexity=10)
            translate([groove_offset_r, 0, 0])
                circle(r=groove_r);
    }
}

module balls(ball_d, count, radius, w) {
    for (i = [0:count-1]) {
        rotate([0,0, i*360/count])
            translate([radius, 0, 0])
                sphere(d=ball_d);
    }
}

inner_od = bore_d + 2.0;                 // inner ring outer diameter (approx)
outer_id = outer_d - 2.0;                // outer ring inner diameter (approx)

// Ensure geometry is consistent
inner_od = min(inner_od, outer_id - 0.6);
outer_id = max(outer_id, inner_od + 0.6);

race_mid_r = (inner_od/2 + outer_id/2)/2;
groove_r = race_depth;
groove_offset_r_inner = inner_od/2 - groove_r*0.6;
groove_offset_r_outer = outer_id/2 + groove_r*0.6;

ball_path_r = (inner_od/2 + outer_id/2)/2;
ball_path_r = max(ball_path_r, bore_d/2 + ball_d/2 + clearance);
ball_path_r = min(ball_path_r, outer_d/2 - ball_d/2 - clearance);

union() {
    // Outer ring with inner groove
    grooved_ring(outer_d, outer_id, width, groove_r, groove_offset_r_outer);

    // Inner ring with outer groove
    grooved_ring(inner_od, bore_d, width, groove_r, groove_offset_r_inner);

    // Balls
    intersection() {
        balls(ball_d, ball_count, ball_path_r, width);
        // Keep balls within bearing width
        cylinder(d=outer_d, h=width-0.2, center=true);
    }
}