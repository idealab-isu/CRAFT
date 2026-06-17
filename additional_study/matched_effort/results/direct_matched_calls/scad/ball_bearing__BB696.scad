$fn = 180;

// Ball bearing dimensions (mm)
bore_d = 6.0;
outer_d = 16.0;
width  = 5.0;

// Simple deep-groove bearing approximation
ring_clearance = 0.6;          // radial clearance between inner/outer rings
race_depth     = 1.0;          // groove depth into each ring
race_width     = 2.2;          // groove width (axial)
shield_thick   = 0.35;         // thin shields on both sides
shield_gap     = 0.25;         // gap between shield and rings
ball_count     = 8;            // typical for this size
ball_d         = 2.4;          // approximate ball diameter

module ring(od, id, w) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module race_groove(r_mid, w, depth) {
    // Cut a toroidal-ish groove by revolving a circle around Z
    rotate_extrude(convexity=10)
        translate([r_mid, 0, 0])
            circle(r=depth, $fn=96);
}

module shield(od, id, t) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t+0.2, center=true);
    }
}

module bearing() {
    inner_od = bore_d + 2*( (outer_d - bore_d)/2 - ring_clearance ) * 0.35; // heuristic
    inner_od = max(inner_od, bore_d + 2.0);

    // Ensure inner ring doesn't exceed available space
    inner_od = min(inner_od, outer_d - 2*ring_clearance - 2.0);

    // Ring widths (leave room for shields)
    ring_w = width - 2*(shield_thick + shield_gap);
    ring_w = max(ring_w, width*0.6);

    // Ball pitch radius
    r_bore  = bore_d/2;
    r_outer = outer_d/2;
    r_pitch = (r_bore + r_outer)/2;

    // Groove radii (midpoints)
    r_inner_groove = inner_od/2 - race_depth*0.6;
    r_outer_groove = inner_od/2 + ring_clearance + race_depth*0.6;

    union() {
        // Outer ring with groove
        difference() {
            ring(outer_d, inner_od + 2*ring_clearance, ring_w);
            // groove centered axially
            translate([0,0,0])
                race_groove(r_pitch, race_width, race_depth);
        }

        // Inner ring with groove
        difference() {
            ring(inner_od, bore_d, ring_w);
            translate([0,0,0])
                race_groove(r_pitch, race_width, race_depth);
        }

        // Balls
        for (i = [0:ball_count-1]) {
            ang = 360/ball_count * i;
            rotate([0,0,ang])
                translate([r_pitch, 0, 0])
                    sphere(d=ball_d, $fn=96);
        }

        // Shields (optional visual)
        translate([0,0, (width/2 - shield_thick/2)])
            shield(outer_d - 0.4, bore_d + 1.2, shield_thick);
        translate([0,0, -(width/2 - shield_thick/2)])
            shield(outer_d - 0.4, bore_d + 1.2, shield_thick);
    }
}

bearing();