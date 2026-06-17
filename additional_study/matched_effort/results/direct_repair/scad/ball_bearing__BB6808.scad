$fn = 180;

bore_d = 40.0;
outer_d = 52.0;
width = 7.0;

// Simple bearing representation: outer ring + inner ring + ball set + (optional) thin shields
clearance = 0.25;          // radial clearance between rings and balls
race_thickness = 2.0;      // radial thickness of each ring
shield_thickness = 0.35;   // thin cover plates
shield_gap = 0.15;         // inset from faces

module ring(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module bearing() {
    inner_od = bore_d + 2*race_thickness;
    outer_id = outer_d - 2*race_thickness;

    // Ball sizing and placement
    ball_d = min( (outer_id - inner_od) - 2*clearance, width - 1.0 );
    ball_d = max(ball_d, 2.0);
    pitch_d = (inner_od + outer_id)/2;

    // Outer ring
    ring(outer_d, outer_id, width);

    // Inner ring
    ring(inner_od, bore_d, width);

    // Shields (very thin discs with center opening)
    for (z = [-(width/2 - shield_thickness/2 - shield_gap), (width/2 - shield_thickness/2 - shield_gap)]) {
        translate([0,0,z])
            ring(outer_id - 0.2, inner_od + 0.2, shield_thickness);
    }

    // Balls
    n_balls = 12;
    for (i = [0:n_balls-1]) {
        angle = 360*i/n_balls;
        rotate([0,0,angle])
            translate([pitch_d/2, 0, 0])
                sphere(d=ball_d);
    }
}

bearing();