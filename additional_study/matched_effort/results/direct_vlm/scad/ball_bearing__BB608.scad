$fn = 180;

bore_d = 8.0;
od_d   = 22.0;
width  = 7.0;

eps = 0.05;
overlap = 0.20;

// Race proportions (kept within OD/ID constraints)
outer_ring_id = 18.0;
inner_ring_od = 12.0;

// Clamp to valid geometry
outer_ring_id = min(outer_ring_id, od_d - 1.0);
inner_ring_od = max(inner_ring_od, bore_d + 1.0);
inner_ring_od = min(inner_ring_od, outer_ring_id - 1.0);

// Ball/cage parameters
ball_count = 7;
ball_d = min(3.5, (outer_ring_id - inner_ring_od) * 0.70);
ball_d = max(ball_d, 2.2);

// Ball pitch circle between races
pitch_d = (inner_ring_od + outer_ring_id) / 2;
ball_path_r = pitch_d / 2;

// Web/cage that CONNECTS inner and outer rings (one connected solid)
web_w = clamp(width * 0.55, 2.0, width - 0.6);
web_r_in  = inner_ring_od/2 + 0.25;
web_r_out = outer_ring_id/2 - 0.25;
web_r_in  = min(web_r_in, web_r_out - 0.6);

module ring(outer_d, inner_d, w) {
    difference() {
        cylinder(d=outer_d, h=w, center=true);
        cylinder(d=inner_d, h=w + 2*eps, center=true);
    }
}

module annulus(r_out, r_in, h) {
    difference() {
        cylinder(r=r_out, h=h, center=true);
        cylinder(r=r_in,  h=h + 2*eps, center=true);
    }
}

module bearing_connected() {
    // Build as a single connected solid, then cut the true through-bore last.
    difference() {
        union() {
            // Outer ring
            ring(od_d, outer_ring_id, width);

            // Inner ring (solid ring; bore cut later to guarantee a clean through-hole)
            ring(inner_ring_od, 0.01, width);

            // Connecting web/cage (annulus) centered in width
            annulus(web_r_out, web_r_in, web_w + overlap);

            // Balls fused to the web (part of same connected solid)
            for (i = [0:ball_count-1]) {
                rotate([0,0, i*360/ball_count])
                    translate([ball_path_r, 0, 0])
                        sphere(d=ball_d);
            }
        }

        // True 8mm through-bore
        cylinder(d=bore_d, h=width + 2*eps, center=true);
    }
}

bearing_connected();