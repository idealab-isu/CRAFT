// Ball bearing (single connected solid) with visible features
// Target envelope: 12.0mm bore, 32.0mm outer diameter, 10.0mm width

$fn = 160;

// --- Primary dimensions (mm)
bore_d  = 12.0;
outer_d = 32.0;
width_w = 10.0;

// --- Feature parameters (kept proportional and derived where possible)
ball_count = 8;
ball_d     = 4.8;

// Ball pitch diameter must fit between bore and OD with clearance for balls
// Clamp to a safe range derived from geometry.
function clamp(x, a, b) = min(max(x, a), b);

radial_clear = 0.6; // clearance between ball and rings (radial)
ball_pitch_d = clamp(22.0,
                     bore_d + ball_d + 2*radial_clear,
                     outer_d - ball_d - 2*radial_clear);

raceway_r = ball_d/2 + 0.35; // groove radius (slightly larger than ball radius)

// Ring thicknesses (radial)
inner_ring_radial = 3.2; // from bore outward
outer_ring_radial = 3.2; // from OD inward

inner_od = bore_d + 2*inner_ring_radial;
outer_id = outer_d - 2*outer_ring_radial;

// Ensure there is space between rings for balls
// If not, slightly reduce ring thicknesses (simple safeguard)
gap_radial = (outer_id - inner_od)/2;
inner_ring_radial_eff = (gap_radial < (ball_d/2 + radial_clear)) ? (inner_ring_radial - ((ball_d/2 + radial_clear) - gap_radial)) : inner_ring_radial;
outer_ring_radial_eff = (gap_radial < (ball_d/2 + radial_clear)) ? (outer_ring_radial - ((ball_d/2 + radial_clear) - gap_radial)) : outer_ring_radial;

inner_od_eff = bore_d + 2*inner_ring_radial_eff;
outer_id_eff = outer_d - 2*outer_ring_radial_eff;

// Axial feature sizes
seal_thk       = 0.8;
cage_thk       = 1.2;
overlap        = 0.25;  // small overlap to guarantee connectivity
micro          = 0.02;  // tiny epsilon for robust booleans

// Cage radial band around ball pitch
cage_radial_w  = 2.2;

// --- Helpers
module ring(r_out, r_in, h) {
    difference() {
        cylinder(r=r_out, h=h, center=true);
        cylinder(r=r_in,  h=h + 2*micro, center=true);
    }
}

module torus_groove(r_center, r_groove, h_limit) {
    // A torus-like groove limited in Z by intersecting with a slab
    intersection() {
        rotate_extrude(convexity=10)
            translate([r_center, 0, 0])
                circle(r=r_groove);
        cylinder(r=outer_d, h=h_limit, center=true);
    }
}

module balls() {
    for (i = [0:ball_count-1]) {
        rotate([0,0,i*360/ball_count])
            translate([ball_pitch_d/2, 0, 0])
                sphere(r=ball_d/2);
    }
}

module cage() {
    // Cage is a thin ring around the balls with pockets cut out.
    // It is connected to the rest via a tiny overlap into the outer ring.
    cage_r_out = ball_pitch_d/2 + cage_radial_w/2;
    cage_r_in  = ball_pitch_d/2 - cage_radial_w/2;

    difference() {
        // Slightly extend cage thickness so it intersects rings (connectivity)
        translate([0,0,0])
            ring(cage_r_out, cage_r_in, cage_thk + 2*overlap);

        // Ball pockets
        for (i = [0:ball_count-1]) {
            rotate([0,0,i*360/ball_count])
                translate([ball_pitch_d/2, 0, 0])
                    // Pocket slightly larger than ball
                    sphere(r=ball_d/2 + 0.35);
        }
    }
}

module seals() {
    // Simple shields/seals as thin annular discs near both faces.
    // They are made to overlap into the outer ring to ensure connectivity.
    seal_r_out = outer_d/2 - micro;
    seal_r_in  = outer_id_eff/2 + 0.6; // leave a visible step

    zL = -width_w/2 + seal_thk/2;
    zR =  width_w/2 - seal_thk/2;

    union() {
        translate([0,0,zL])
            ring(seal_r_out, seal_r_in, seal_thk + 2*overlap);
        translate([0,0,zR])
            ring(seal_r_out, seal_r_in, seal_thk + 2*overlap);
    }
}

module bearing_solid_connected() {
    // Build as ONE connected solid:
    // - Outer ring and inner ring are connected via a thin "web" at mid-plane.
    // - Balls are fused to the web (tiny overlap) so they are not floating.
    // - Cage and seals overlap into outer ring.
    //
    // This preserves the correct bore/OD/width while keeping a single manifold.

    // Web thickness and radii (connect inner and outer rings without blocking bore)
    web_thk = 0.6;
    web_r_in  = inner_od_eff/2 - 0.4;  // starts near inner ring OD
    web_r_out = outer_id_eff/2 + 0.4;  // reaches near outer ring ID

    union() {
        // Outer ring with raceway groove
        difference() {
            ring(outer_d/2, outer_id_eff/2, width_w);

            // Raceway groove (outer)
            torus_groove(ball_pitch_d/2, raceway_r, width_w - 2*seal_thk);
        }

        // Inner ring with raceway groove
        difference() {
            ring(inner_od_eff/2, bore_d/2, width_w);

            // Raceway groove (inner)
            torus_groove(ball_pitch_d/2, raceway_r, width_w - 2*seal_thk);
        }

        // Connecting web at center plane (ensures single connected solid)
        // Slight overlap into both rings.
        ring(web_r_out, web_r_in, web_thk + 2*overlap);

        // Balls (fused to web by a tiny overlap: web intersects balls at z=0)
        balls();

        // Cage (overlaps into rings via thickness extension)
        cage();

        // Seals/shields
        seals();
    }
}

// Render
bearing_solid_connected();