$fn = 128;

bore_d = 3.0;
od_d   = 9.0;
width  = 4.0;

// Simple ball bearing representation: outer ring, inner ring, and balls in between.
inner_ring_od = 5.2;   // approximate
outer_ring_id = 6.8;   // approximate
ball_d        = 1.2;   // approximate
ball_count    = 8;

module ring(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module balls(count, pitch_d, ball_d, h) {
    for (i = [0:count-1]) {
        angle = 360 * i / count;
        rotate([0,0,angle])
            translate([pitch_d/2, 0, 0])
                sphere(d=ball_d);
    }
}

module bearing() {
    // Ensure sensible geometry
    _inner_ring_od = max(inner_ring_od, bore_d + 0.6);
    _outer_ring_id = min(outer_ring_id, od_d - 0.6);
    _outer_ring_id = max(_outer_ring_id, _inner_ring_od + ball_d + 0.4);

    pitch_d = (_inner_ring_od + _outer_ring_id) / 2;

    union() {
        // Outer ring
        ring(od_d, _outer_ring_id, width);

        // Inner ring
        ring(_inner_ring_od, bore_d, width);

        // Balls (slightly inset to avoid protruding beyond faces)
        intersection() {
            balls(ball_count, pitch_d, ball_d, width);
            cylinder(d=od_d-0.2, h=width-0.2, center=true);
        }
    }
}

bearing();