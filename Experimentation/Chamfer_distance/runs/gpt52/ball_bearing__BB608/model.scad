$fn = 96;

module bearing_608(bore_d=8, outer_d=22, width=7) {
    ring_wall = 2.2;                 // approximate radial thickness of each ring
    race_clear = 0.4;                // clearance between inner and outer rings
    inner_od = bore_d + 2*ring_wall; // inner ring outer diameter
    outer_id = outer_d - 2*ring_wall;// outer ring inner diameter

    // Ball sizing & placement (approximate)
    pitch_d = (inner_od + outer_id)/2;
    ball_d = min(3.2, (outer_id - inner_od) - 0.6);
    nballs = 9;

    union() {
        // Outer ring
        difference() {
            cylinder(d=outer_d, h=width, center=true);
            cylinder(d=outer_id, h=width+0.6, center=true);
        }

        // Inner ring
        difference() {
            cylinder(d=inner_od, h=width, center=true);
            cylinder(d=bore_d, h=width+0.6, center=true);
        }

        // Balls
        for (i = [0:nballs-1]) {
            angle = 360*i/nballs;
            translate([ (pitch_d/2)*cos(angle), (pitch_d/2)*sin(angle), 0 ])
                sphere(d=ball_d);
        }

        // Simple cage (thin band with pockets)
        difference() {
            cylinder(d=pitch_d + ball_d*0.85, h=width*0.55, center=true);
            cylinder(d=pitch_d - ball_d*0.85, h=width*0.60, center=true);
            for (i = [0:nballs-1]) {
                angle = 360*i/nballs;
                translate([ (pitch_d/2)*cos(angle), (pitch_d/2)*sin(angle), 0 ])
                    sphere(d=ball_d*1.08);
            }
        }
    }
}

bearing_608();