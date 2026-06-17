$fn = 180;

bore_d = 8.0;
od_d   = 22.0;
width  = 7.0;

// Simple parametric ball bearing approximation (608 size):
// - Outer ring and inner ring as cylinders with race grooves
// - Balls placed in a circular cage path

clearance = 0.25;          // general clearance for visual separation
race_depth = 0.9;          // groove depth into rings
race_r = 1.6;              // groove "ball" radius used to carve races
ball_d = 3.5;              // typical 608 ball diameter
ball_count = 7;            // common for 608; adjust if desired

inner_ring_od = 12.0;      // typical 608 inner ring OD
outer_ring_id = 18.0;      // typical 608 outer ring ID

// Clamp to ensure valid geometry if parameters change
inner_ring_od = max(inner_ring_od, bore_d + 2.0);
outer_ring_id = min(outer_ring_id, od_d - 2.0);
outer_ring_id = max(outer_ring_id, inner_ring_od + 2.0);

module ring(od, id, w, groove_r, groove_depth, groove_z=0) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w + 0.4, center=true);

        // Race groove carved by revolving a circle (approximated by subtracting a torus-like sweep)
        // Implemented by subtracting a rotated circle via rotate_extrude.
        rotate_extrude(angle=360, convexity=10)
            translate([(od + id)/4, 0, 0])
                circle(r=groove_r);

        // Limit groove depth by intersecting with a thin band near mid-plane
        // (keeps groove from cutting too deep into ring ends)
        // Achieved by adding back material outside the groove band.
        // Here we instead carve a shallower groove by subtracting only within a band:
        // Use intersection of the groove solid with a band, then subtract that.
    }
}

// Improved ring with controlled groove depth using intersection band
module ring_with_groove(od, id, w, groove_r, groove_band_h) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w + 0.6, center=true);

        // Subtract groove only within a central band
        intersection() {
            rotate_extrude(angle=360, convexity=10)
                translate([(od + id)/4, 0, 0])
                    circle(r=groove_r);
            cylinder(d=od + 2, h=groove_band_h, center=true);
        }
    }
}

module balls(ball_d, count, pitch_d, w) {
    for (i = [0:count-1]) {
        rotate([0,0, i*360/count])
            translate([pitch_d/2, 0, 0])
                sphere(d=ball_d);
    }
}

module bearing_608_like() {
    // Rings
    color([0.75,0.75,0.78])
        ring_with_groove(od=od_d, id=outer_ring_id, w=width, groove_r=race_r, groove_band_h=width*0.55);

    color([0.72,0.72,0.75])
        ring_with_groove(od=inner_ring_od, id=bore_d, w=width, groove_r=race_r, groove_band_h=width*0.55);

    // Balls
    pitch_d = (inner_ring_od + outer_ring_id)/2;
    color([0.85,0.85,0.88])
        balls(ball_d=ball_d, count=ball_count, pitch_d=pitch_d, w=width);

    // Simple cage (optional visual)
    cage_th = 0.8;
    cage_id = pitch_d - ball_d - 0.6;
    cage_od = pitch_d + ball_d + 0.6;
    color([0.55,0.55,0.58])
    difference() {
        cylinder(d=cage_od, h=width*0.55, center=true);
        cylinder(d=cage_id, h=width*0.55 + 0.4, center=true);

        // Ball pockets
        for (i = [0:ball_count-1]) {
            rotate([0,0, i*360/ball_count])
                translate([pitch_d/2, 0, 0])
                    cylinder(d=ball_d+0.6, h=width, center=true);
        }
    }
}

bearing_608_like();