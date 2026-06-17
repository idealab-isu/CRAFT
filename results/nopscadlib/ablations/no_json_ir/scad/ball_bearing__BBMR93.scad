$fn = 160;

// Ball bearing: 3.0mm bore, 9.0mm OD, 4.0mm width
module ball_bearing_3x9x4(bore_d=3.0, outer_d=9.0, width=4.0) {

    // --- Primary dimensions (must match spec) ---
    bore_r  = bore_d/2;
    outer_r = outer_d/2;

    // --- Modeling parameters (kept within 3x9x4 envelope) ---
    eps = 0.02;                 // tiny overlap for manifold unions
    ring_radial_thk = 1.0;      // radial thickness of inner/outer rings
    gap_radial = 0.35;          // visible radial gap between inner and outer rings (race space)
    ball_d = 1.0;
    num_balls = 8;

    // Shields (thin discs) to keep everything one connected solid while leaving bore open
    shield_h = 0.35;
    shield_r = outer_r - 0.25;  // near OD so it clearly reads as a shield

    // Derived ring radii
    inner_outer_r = bore_r + ring_radial_thk;      // outer radius of inner ring
    outer_inner_r = outer_r - ring_radial_thk;     // inner radius of outer ring

    // Ensure a visible race gap (do not let rings touch)
    // (If parameters are changed, keep: outer_inner_r > inner_outer_r + gap_radial)
    ball_r = ball_d/2;
    ball_path_r = (inner_outer_r + outer_inner_r)/2;

    // Axial placement for balls so they touch shields (connectivity) but stay within width
    // Keep balls inside the bearing width: |z| + ball_r <= width/2
    ball_z = min(width/2 - ball_r - eps, width/2 - shield_h - ball_r + eps);

    // Small "web" that connects inner ring to shields without blocking the bore
    // (a thin annulus just outside the bore)
    web_r1 = bore_r + 0.15;
    web_r2 = bore_r + 0.55;
    web_h  = shield_h; // same as shield thickness

    union() {

        // OUTER RING
        difference() {
            cylinder(r=outer_r, h=width, center=true);
            cylinder(r=outer_inner_r, h=width + 2, center=true);
        }

        // INNER RING (with true through-bore)
        difference() {
            cylinder(r=inner_outer_r, h=width, center=true);
            cylinder(r=bore_r, h=width + 2, center=true);
        }

        // SHIELDS (connected to outer ring by overlap; do not cover the bore)
        for (zsgn = [-1, 1]) {
            translate([0, 0, zsgn*(width/2 - shield_h/2 - eps)])
                difference() {
                    cylinder(r=shield_r, h=shield_h, center=true);
                    // keep bore open
                    cylinder(r=bore_r, h=shield_h + 2, center=true);
                }
        }

        // INNER WEB RINGS (connect inner ring to shields while keeping bore open)
        for (zsgn = [-1, 1]) {
            translate([0, 0, zsgn*(width/2 - web_h/2 - eps)])
                difference() {
                    cylinder(r=web_r2, h=web_h, center=true);
                    cylinder(r=web_r1, h=web_h + 2, center=true);
                }
        }

        // BALLS (placed in the race gap; touch shields for connectivity)
        for (i = [0:num_balls-1]) {
            rotate([0, 0, i*360/num_balls])
                translate([ball_path_r, 0, ball_z])
                    sphere(r=ball_r);
        }
    }
}

ball_bearing_3x9x4(3.0, 9.0, 4.0);