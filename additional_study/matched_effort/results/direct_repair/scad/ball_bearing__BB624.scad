$fn = 180;

bore_d = 4.0;
od_d   = 13.0;
width  = 5.0;

// Simple parametric ball bearing representation:
// - Outer ring and inner ring as annular cylinders
// - Ball set in a circular race between rings
// Dimensions match: bore, outer diameter, width.

module bearing(bore_d, od_d, width) {
    // Ring proportions (visual approximation)
    ring_wall = (od_d - bore_d) * 0.22;          // radial thickness of each ring
    ring_wall = min(ring_wall, (od_d - bore_d)/2 - 0.2);
    ring_wall = max(ring_wall, 0.8);

    inner_od = bore_d + 2*ring_wall;
    outer_id = od_d   - 2*ring_wall;

    // Ball sizing and placement
    race_gap = max(0.3, (outer_id - inner_od) * 0.15);
    ball_d = max(0.8, min(width*0.55, (outer_id - inner_od) - 2*race_gap));
    ball_r = ball_d/2;

    pitch_d = (inner_od + outer_id)/2;
    pitch_r = pitch_d/2;

    // Choose ball count based on circumference and ball size
    n = max(6, floor((2*PI*pitch_r) / (ball_d*1.25)));

    union() {
        // Outer ring
        difference() {
            cylinder(d=od_d, h=width, center=true);
            cylinder(d=outer_id, h=width+0.2, center=true);
        }

        // Inner ring
        difference() {
            cylinder(d=inner_od, h=width, center=true);
            cylinder(d=bore_d, h=width+0.2, center=true);
        }

        // Balls
        for (i = [0:n-1]) {
            rotate([0,0, i*360/n])
                translate([pitch_r, 0, 0])
                    sphere(d=ball_d);
        }
    }
}

bearing(bore_d=bore_d, od_d=od_d, width=width);