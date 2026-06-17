$fn = 128;

bore_d = 3.0;
od_d   = 9.0;
width  = 4.0;

// Simple ball bearing representation: outer ring + inner ring + ball set + cage
clearance = 0.15;          // radial clearance between rings and balls
ring_gap  = 0.35;          // radial gap between inner/outer race regions
race_depth = 0.55;         // approximate race groove depth (visual)
cage_thickness = 0.6;      // axial thickness of cage
cage_clear = 0.25;         // radial clearance around balls for cage

inner_ring_od = 5.2;       // chosen to look plausible for 3x9x4 bearing
outer_ring_id = 7.0;       // chosen to look plausible for 3x9x4 bearing

ball_d = 1.2;
ball_count = 8;

module ring(od, id, w) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module race_groove(d_mid, groove_d, w, depth) {
    // subtract a torus-like groove by revolving a circle (approximated via rotate_extrude)
    // groove centered at radius d_mid/2, with circle diameter groove_d, scaled in Z for depth
    rotate_extrude(convexity=10)
        translate([d_mid/2, 0, 0])
            scale([1, depth/(groove_d/2)])
                circle(d=groove_d, $fn=64);
}

module bearing() {
    // Outer ring with inner race groove
    difference() {
        ring(od_d, outer_ring_id, width);
        // groove on inner side of outer ring
        intersection() {
            // limit groove to ring volume
            cylinder(d=od_d+0.2, h=width+0.2, center=true);
            race_groove((outer_ring_id + od_d)/2, ball_d + 0.25, width, race_depth);
        }
    }

    // Inner ring with outer race groove
    difference() {
        ring(inner_ring_od, bore_d, width);
        intersection() {
            cylinder(d=inner_ring_od+0.2, h=width+0.2, center=true);
            race_groove((bore_d + inner_ring_od)/2, ball_d + 0.25, width, race_depth);
        }
    }

    // Balls
    ball_path_d = (inner_ring_od + outer_ring_id)/2 - clearance;
    for (i = [0:ball_count-1]) {
        rotate([0,0, i*360/ball_count])
            translate([ball_path_d/2, 0, 0])
                sphere(d=ball_d);
    }

    // Cage (simple ring with pockets)
    cage_od = outer_ring_id - ring_gap;
    cage_id = inner_ring_od + ring_gap;
    difference() {
        cylinder(d=cage_od, h=cage_thickness, center=true);
        cylinder(d=cage_id, h=cage_thickness+0.2, center=true);

        // ball pockets
        for (i = [0:ball_count-1]) {
            rotate([0,0, i*360/ball_count])
                translate([ball_path_d/2, 0, 0])
                    cylinder(d=ball_d + 2*cage_clear, h=cage_thickness+0.4, center=true);
        }
    }
}

bearing();