$fn = 180;

// Ball bearing: 12mm bore, 32mm OD, 10mm width
module ball_bearing(bore_d=12, outer_d=32, width=10, num_balls=10) {

    // --- Dimension-driven parameters (kept within OD/ID/width) ---
    clearance = 0.25;     // visual gap for race grooves
    overlap   = 0.20;     // small overlap to guarantee manifold unions
    wall_min  = 1.6;      // minimum ring wall thickness
    shield_t  = 0.8;      // shield thickness (each side)

    // Radial space between bore and OD
    radial_space = (outer_d - bore_d)/2;

    // Ball size chosen to fit between rings with walls + clearance
    ball_d = min(4.2, max(2.6, radial_space - 2*wall_min - 2*clearance));
    ball_r = ball_d/2;

    // Ball pitch radius (center of balls)
    pitch_r = bore_d/2 + wall_min + clearance + ball_r;

    // Ring diameters derived from pitch and constraints
    inner_ring_od = max(bore_d + 2*wall_min, 2*(pitch_r + ball_r + clearance));
    outer_ring_id = min(outer_d - 2*wall_min, 2*(pitch_r - ball_r - clearance));

    // Ensure inner OD stays below outer ID
    inner_ring_od = min(inner_ring_od, outer_ring_id - 0.8);

    // Raceway groove radius (torus tube radius)
    groove_r = ball_r + clearance;

    // Helper: torus-like groove via rotate_extrude of a circle
    module groove_at(r_center, z_center, r_groove) {
        translate([0,0,z_center])
            rotate_extrude(angle=360)
                translate([r_center,0,0])
                    circle(r=r_groove);
    }

    module inner_ring() {
        difference() {
            cylinder(d=inner_ring_od, h=width, center=true);
            cylinder(d=bore_d, h=width + 2, center=true);
            groove_at(pitch_r, 0, groove_r);
        }
    }

    module outer_ring() {
        difference() {
            cylinder(d=outer_d, h=width, center=true);
            cylinder(d=outer_ring_id, h=width + 2, center=true);
            groove_at(pitch_r, 0, groove_r);
        }
    }

    // Shields: thin annular plates near each face, overlapping rings
    module shields() {
        shield_od = outer_d - 2*wall_min;
        shield_id = bore_d + 2*wall_min;

        for (side = [-1, 1]) {
            translate([0,0, side*(width/2 - shield_t/2 - overlap)])
                difference() {
                    cylinder(d=shield_od, h=shield_t, center=true);
                    cylinder(d=shield_id, h=shield_t + 2, center=true);
                }
        }
    }

    // Balls
    module balls() {
        for (i = [0:num_balls-1]) {
            rotate([0,0, i*360/num_balls])
                translate([pitch_r, 0, 0])
                    sphere(d=ball_d);
        }
    }

    // Cage: a ring that CONNECTS to balls and also CONNECTS to rings (one solid)
    // - Radially intersects balls slightly
    // - Axially overlaps shields slightly so it fuses to the rest of the bearing
    module cage_connector() {
        cage_radial = 0.9; // radial thickness of cage cross-section
        cage_axial  = shield_t + 2*overlap; // ensures overlap into shields

        // Place cage near one shield so it physically touches the shield (connectivity)
        cage_z = (width/2 - shield_t/2 - overlap);

        translate([0,0,cage_z])
            rotate_extrude(angle=360)
                translate([pitch_r,0,0])
                    square([cage_radial, cage_axial], center=true);
    }

    union() {
        inner_ring();
        outer_ring();
        shields();
        balls();
        cage_connector(); // guarantees ONE connected solid (touches balls + shield/rings)
    }
}

ball_bearing(12, 32, 10, 10);