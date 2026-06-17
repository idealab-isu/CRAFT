$fn = 128;

bore_d = 5.0;
od_d   = 9.0;
width  = 3.0;

eps = 0.02;

// Ring helper (centered)
module ring(od, id, w) {
    difference() {
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w + 2*eps, center=true);
    }
}

// Simple torus helper (centered at origin, in XY plane)
module torus(R, r) {
    rotate_extrude(angle=360)
        translate([R, 0, 0])
            circle(r=r);
}

module bearing_5x9x3() {
    // Envelope constraints:
    // OD = 9.0, Bore = 5.0, Width = 3.0

    // Choose internal geometry that reads as a bearing while staying within envelope.
    inner_ring_od = 6.2;   // > bore_d
    outer_ring_id = 7.6;   // < od_d

    // Ball path between rings
    ball_d = 0.90;
    nballs = 8;
    ball_R = (inner_ring_od/2 + outer_ring_id/2) / 2;  // center radius of balls

    // Thin "web" to guarantee ONE connected solid (ties inner and outer rings)
    web_th = 0.30;
    web_id = inner_ring_od - 0.10;
    web_od = outer_ring_id + 0.10;

    // Raceway grooves (subtractive), shallow and kept inside material
    groove_r = 0.32;
    groove_R = ball_R;
    groove_z = 0;

    // Make balls visible in orthographic views by creating shallow pockets on both faces
    // (does not change OD/bore/width)
    pocket_r = ball_d * 0.55;
    pocket_z = width/2 - pocket_r; // tangent to face

    difference() {
        union() {
            // Outer ring
            ring(od_d, outer_ring_id, width);

            // Inner ring
            ring(inner_ring_od, bore_d, width);

            // Connectivity web (overlaps both rings)
            ring(web_od, web_id, web_th);

            // Balls (fused into assembly via overlap with web/rings)
            for (i = [0:nballs-1]) {
                rotate([0, 0, i * 360/nballs])
                    translate([ball_R, 0, 0])
                        sphere(d=ball_d);
            }
        }

        // Ensure bore is a clean through-hole (verifiable in top/bottom views)
        cylinder(d=bore_d, h=width + 2*eps, center=true);

        // Raceway groove (torus cut)
        translate([0, 0, groove_z])
            torus(groove_R, groove_r);

        // Face pockets to reveal ball positions in orthographic side/top/bottom renders
        for (i = [0:nballs-1]) {
            rotate([0, 0, i * 360/nballs]) {
                translate([ball_R, 0,  pocket_z]) sphere(r=pocket_r);
                translate([ball_R, 0, -pocket_z]) sphere(r=pocket_r);
            }
        }
    }
}

bearing_5x9x3();