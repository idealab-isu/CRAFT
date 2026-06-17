$fn=128;

bore_d = 6.0;
outer_d = 13.0;
width = 5.0;

inner_ring_od = 8.2;
outer_ring_id = 10.8;

race_groove_r = 0.75;
ball_d = 1.5;
ball_count = 8;

module ring_with_grooves(od, id, w, groove_r, groove_offset_r) {
    difference() {
        difference() {
            cylinder(d=od, h=w, center=true);
            cylinder(d=id, h=w+0.2, center=true);
        }
        for (z = [-w/4, w/4]) {
            translate([groove_offset_r, 0, z])
                rotate([0,90,0])
                    cylinder(r=groove_r, h=od+2, center=true);
        }
    }
}

module balls(count, pitch_r, d, w) {
    for (i = [0:count-1]) {
        a = 360*i/count;
        rotate([0,0,a])
            translate([pitch_r, 0, 0])
                sphere(d=d);
    }
}

module bearing() {
    union() {
        ring_with_grooves(outer_d, outer_ring_id, width, race_groove_r, (outer_ring_id/2 + outer_d/2)/2);
        ring_with_grooves(inner_ring_od, bore_d, width, race_groove_r, (bore_d/2 + inner_ring_od/2)/2);
        balls(ball_count, (inner_ring_od/2 + outer_ring_id/2)/2, ball_d, width);
    }
}

bearing();