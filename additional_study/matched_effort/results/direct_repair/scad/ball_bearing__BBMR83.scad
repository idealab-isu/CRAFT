$fn = 128;

bore_d = 3.0;
od_d   = 8.0;
width  = 3.0;

// Simple ball bearing representation: outer ring + inner ring + ball cage with balls
outer_ring_th = 1.0;   // radial thickness of outer ring
inner_ring_th = 1.0;   // radial thickness of inner ring
clearance     = 0.15;  // radial clearance between rings and balls

module ring(od, id, w) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module bearing() {
    // Derived diameters
    inner_od = bore_d + 2*inner_ring_th;
    outer_id = od_d   - 2*outer_ring_th;

    // Ball path
    ball_path_d = (inner_od + outer_id)/2;
    ball_d = min( (outer_id - inner_od) - 2*clearance, width*0.75 );
    ball_d = max(ball_d, 0.6); // ensure renderable

    // Number of balls around circumference
    nballs = max(6, floor( (PI*ball_path_d) / (ball_d*1.25) ));

    union() {
        // Outer ring
        ring(od_d, outer_id, width);

        // Inner ring
        ring(inner_od, bore_d, width);

        // Balls
        for (i = [0:nballs-1]) {
            rotate([0,0, i*360/nballs])
                translate([ball_path_d/2, 0, 0])
                    sphere(d=ball_d);
        }
    }
}

bearing();