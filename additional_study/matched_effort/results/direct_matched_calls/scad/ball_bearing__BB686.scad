$fn = 180;

bore_d = 6.0;
od_d   = 13.0;
width  = 5.0;

// Simple ball bearing representation: outer ring, inner ring, and balls in a cage-like gap.
inner_ring_od = 8.2;   // approximate
outer_ring_id = 10.8;  // approximate
ball_d        = 1.6;   // approximate
ball_count    = 10;

module ring(od, id, w) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module balls(count, pitch_d, ball_d, w) {
    for (i = [0:count-1]) {
        a = 360*i/count;
        rotate([0,0,a])
            translate([pitch_d/2, 0, 0])
                sphere(d=ball_d);
    }
}

difference() {
    union() {
        // Outer ring
        ring(od_d, outer_ring_id, width);

        // Inner ring
        ring(inner_ring_od, bore_d, width);

        // Balls (centered in the gap)
        balls(ball_count, (inner_ring_od + outer_ring_id)/2, ball_d, width);
    }

    // Ensure bore is clean through everything
    cylinder(d=bore_d, h=width+2, center=true);
}