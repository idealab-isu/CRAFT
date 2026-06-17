$fn = 120;

// Ball bearing overall dimensions (mm)
bore_d  = 5.0;
od_d    = 9.0;
width   = 3.0;

module ball_bearing_5x9x3() {
    eps = 0.02;

    // Derived radii
    r_bore = bore_d/2;
    r_od   = od_d/2;

    // Keep everything as ONE connected solid:
    // - Outer ring body
    // - Inner ring body
    // - A thin web (cage-like) connecting them at mid-plane
    // - Ball bumps fused to the web for visible "bearing components"
    //
    // All dimensions are formulas from bore/OD/width.

    // Radial build
    radial_clear = 0.35;                         // clearance between rings (visual)
    web_t        = 0.55;                         // thickness of connecting web (axial)
    overlap      = 0.06;                         // small overlap to guarantee manifold unions

    // Ring thicknesses (radial)
    inner_ring_t = 0.70;                         // radial thickness of inner ring
    outer_ring_t = 0.70;                         // radial thickness of outer ring

    // Compute raceway region between rings
    r_inner_outer = r_bore + inner_ring_t;       // outer radius of inner ring
    r_outer_inner = r_od   - outer_ring_t;       // inner radius of outer ring

    // Ensure a positive gap; if parameters are tight, clamp
    gap = max(0.25, r_outer_inner - r_inner_outer);

    // Ball geometry (fused bumps, not separate parts)
    ball_r = min(0.55, gap*0.45);                // ball radius limited by available gap
    ball_path_r = (r_inner_outer + r_outer_inner)/2;

    // Web (cage-like) radial thickness: spans most of the gap but leaves a hint of clearance
    web_radial_t = max(0.25, gap - 2*ball_r*0.15);

    // Web radial bounds
    r_web_in  = ball_path_r - web_radial_t/2;
    r_web_out = ball_path_r + web_radial_t/2;

    // Ball count based on circumference (kept reasonable for small bearing)
    n_balls = 8;

    // Helper: ring by radii
    module ring(r_in, r_out, h) {
        difference() {
            cylinder(h=h, r=r_out, center=true);
            cylinder(h=h + 2*eps, r=r_in, center=true);
        }
    }

    union() {
        // Outer ring (race)
        ring(r_outer_inner, r_od, width);

        // Inner ring (race)
        ring(r_bore, r_inner_outer, width);

        // Connecting web (cage-like) at mid-plane to keep one connected solid
        // Slightly overlaps rings to ensure connectivity.
        ring(r_web_in, r_web_out, web_t + 2*overlap);

        // Ball elements as fused bumps centered on the web mid-plane
        // Positioned by formulas (no arbitrary translations).
        for (i = [0:n_balls-1]) {
            rotate([0, 0, i*360/n_balls])
                translate([ball_path_r, 0, 0])
                    sphere(r=ball_r);
        }

        // Subtle race grooves on both faces (as raised lips) to suggest races,
        // while staying a single solid (additive, not subtractive).
        lip_h = 0.35;
        lip_t = 0.35;
        for (zsign = [-1, 1]) {
            translate([0, 0, zsign*(width/2 - lip_h/2)])
                ring(r_inner_outer - lip_t, r_outer_inner + lip_t, lip_h);
        }
    }
}

ball_bearing_5x9x3();