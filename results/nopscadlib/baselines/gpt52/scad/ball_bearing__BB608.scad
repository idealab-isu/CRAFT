$fn=128;

bore_d = 8.0;
od_d = 22.0;
width = 7.0;

inner_ring_od = 12.0;
outer_ring_id = 18.0;

race_groove_r = 1.2;
race_groove_offset = 0.9;

ball_d = 3.0;
ball_count = 8;

module ring_with_race(od, id, w, groove_r, groove_offset, is_outer=false) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.4, center=true);
        rotate_extrude(angle=360)
            translate([ (is_outer ? (id/2 + groove_offset) : (od/2 - groove_offset)), 0, 0 ])
                circle(r=groove_r);
    }
}

module balls(count, pitch_d, ball_d, w) {
    for (i = [0:count-1]) {
        rotate([0,0, i*360/count])
            translate([pitch_d/2, 0, 0])
                sphere(d=ball_d);
    }
}

module bearing_608_like() {
    union() {
        ring_with_race(od=inner_ring_od, id=bore_d, w=width, groove_r=race_groove_r, groove_offset=race_groove_offset, is_outer=false);
        ring_with_race(od=od_d, id=outer_ring_id, w=width, groove_r=race_groove_r, groove_offset=race_groove_offset, is_outer=true);
        balls(ball_count, pitch_d=(inner_ring_od + outer_ring_id)/2, ball_d=ball_d, w=width);
    }
}

bearing_608_like();