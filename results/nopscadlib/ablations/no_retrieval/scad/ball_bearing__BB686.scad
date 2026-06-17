// Ball bearing (simplified, single connected solid)
// Target envelope: 6.0mm bore, 13.0mm outer diameter, 5.0mm width
// Fixes: ensure visible ring geometry, guaranteed connectivity, no floating parts,
// and avoid "blank view" by keeping all geometry within the stated envelope.

$fn = 128;

// Requested dimensions
bore_d  = 6.0;
outer_d = 13.0;
width   = 5.0;

// Derived radii
bore_r  = bore_d/2;
outer_r = outer_d/2;

// Small overlap to guarantee manifold connections (mm)
join_eps = 0.20;

// Ring radial thicknesses (kept within envelope)
inner_ring_radial = 1.25;   // from bore outward
outer_ring_radial = 1.25;   // from OD inward

inner_ring_outer_r = bore_r + inner_ring_radial;
outer_ring_inner_r = outer_r - outer_ring_radial;

// Ball parameters (visual only; fused to rings via bridges)
ball_d     = 2.0;
ball_count = 8;

// Ball pitch radius centered between rings
pitch_r = (inner_ring_outer_r + outer_ring_inner_r)/2;

// Race groove (visual only; shallow)
groove_r      = 0.35;          // smaller so it doesn't wipe out thin rings
race_z_offset = width * 0.18;

// Shields (visual; fused to outer ring by overlap)
shield_thk = 0.35;
shield_gap = 0.15;
// Keep shield within OD so silhouette stays correct; rely on Z overlap for fusion
shield_r = outer_r - 0.05;

// Connectivity bridges (balls to rings)
bridge_r = 0.25;

// Validity checks
assert(inner_ring_outer_r < outer_ring_inner_r, "Rings overlap radially; adjust ring thicknesses.");
assert(pitch_r > inner_ring_outer_r + ball_d/2*0.55, "Pitch radius too small for balls.");
assert(pitch_r < outer_ring_inner_r - ball_d/2*0.55, "Pitch radius too large for balls.");

module torus(R, r) {
    rotate_extrude(convexity=10)
        translate([R, 0, 0])
            circle(r=r);
}

module ring(ri, ro, h) {
    difference() {
        cylinder(r=ro, h=h, center=true);
        cylinder(r=ri, h=h + 2*join_eps, center=true);
    }
}

module shield_disk(zsign=1) {
    // Place shield so it overlaps the outer ring in Z (guaranteed union connection)
    // zpos is computed from width and shield thickness (no arbitrary values)
    zpos = zsign * (width/2 - shield_thk/2 - shield_gap - join_eps);

    translate([0,0,zpos])
        difference() {
            cylinder(r=shield_r, h=shield_thk, center=true);
            // Clear inner area so it doesn't touch the inner ring
            cylinder(r=inner_ring_outer_r + 0.35, h=shield_thk + 2*join_eps, center=true);
        }
}

module ball_with_bridges(theta) {
    ball_r = ball_d/2;

    // Compute bridge lengths so they reach into rings with overlap
    in_gap  = (pitch_r - ball_r) - inner_ring_outer_r;
    out_gap = outer_ring_inner_r - (pitch_r + ball_r);

    in_len  = max(0.8, in_gap  + 2*join_eps);
    out_len = max(0.8, out_gap + 2*join_eps);

    rotate([0,0,theta]) {
        // Ball
        translate([pitch_r, 0, 0]) sphere(r=ball_r);

        // Inward bridge (X-axis), centered between inner ring and ball surface
        in_center_x = (inner_ring_outer_r + (pitch_r - ball_r)) / 2;
        translate([in_center_x, 0, 0])
            rotate([0,90,0])
                cylinder(r=bridge_r, h=in_len, center=true);

        // Outward bridge (X-axis), centered between ball surface and outer ring inner radius
        out_center_x = ((pitch_r + ball_r) + outer_ring_inner_r) / 2;
        translate([out_center_x, 0, 0])
            rotate([0,90,0])
                cylinder(r=bridge_r, h=out_len, center=true);
    }
}

module bearing() {
    union() {
        // Outer ring with shallow race grooves (visual only)
        difference() {
            ring(outer_ring_inner_r, outer_r, width);
            translate([0,0, race_z_offset]) torus(pitch_r, groove_r);
            translate([0,0,-race_z_offset]) torus(pitch_r, groove_r);
        }

        // Inner ring with shallow race grooves (visual only)
        difference() {
            ring(bore_r, inner_ring_outer_r, width);
            translate([0,0, race_z_offset]) torus(pitch_r, groove_r);
            translate([0,0,-race_z_offset]) torus(pitch_r, groove_r);
        }

        // Balls fused via bridges (guaranteed to reach rings)
        for (i = [0:ball_count-1])
            ball_with_bridges(i*360/ball_count);

        // Shields fused to outer ring by Z overlap (kept within OD)
        shield_disk( 1);
        shield_disk(-1);
    }
}

bearing();