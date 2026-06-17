// Ball bearing (single connected solid) with:
// Bore = 12.0mm, OD = 32.0mm, Width = 10.0mm
// Connectivity-fixed: all parts are physically fused with 1–2mm overlaps.

$fn = 160;

// Target dimensions
bore_diameter_mm  = 12.0;
outer_diameter_mm = 32.0;
width_mm          = 10.0;

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Design parameters (kept realistic but simplified)
ring_wall_mm        = 3.0;   // radial thickness of each ring
race_depth_mm       = 1.2;   // groove depth into rings
race_radius_mm      = 2.2;   // groove "tube" radius (controls groove roundness)
ball_diameter_mm    = 4.0;
num_balls           = 9;

cage_thickness_mm   = 1.2;   // axial thickness of cage band
cage_radial_mm      = 1.0;   // radial thickness of cage band

// CRITICAL: overlap for guaranteed fusion (1–2mm as required)
connect_overlap_mm  = 1.2;

// Computed radii for ring bodies
outer_ring_inner_r = outer_r - ring_wall_mm;
inner_ring_outer_r = bore_r + ring_wall_mm;

// Ball path radius (between rings)
ball_path_r = (outer_ring_inner_r + inner_ring_outer_r)/2;

// Keep grooves within ring material
race_r = min(race_radius_mm, (ring_wall_mm/2) - 0.2);
race_r = max(race_r, 0.8);

// Groove centers (slightly biased into each ring)
outer_groove_center_r = outer_ring_inner_r + race_depth_mm;
inner_groove_center_r = inner_ring_outer_r - race_depth_mm;

// Helper: torus via rotate_extrude of a circle
module torus(R, r) {
    rotate_extrude(angle=360)
        translate([R, 0, 0])
            circle(r=r);
}

// Outer ring with race groove
module outer_ring() {
    difference() {
        cylinder(r=outer_r, h=width_mm, center=true);
        // bore out the inside of outer ring
        cylinder(r=outer_ring_inner_r, h=width_mm + 2*connect_overlap_mm, center=true);
        // race groove (subtractive)
        torus(outer_groove_center_r, race_r);
    }
}

// Inner ring with race groove
module inner_ring() {
    difference() {
        cylinder(r=inner_ring_outer_r, h=width_mm, center=true);
        // bore hole
        cylinder(r=bore_r, h=width_mm + 2*connect_overlap_mm, center=true);
        // race groove (subtractive)
        torus(inner_groove_center_r, race_r);
    }
}

// Balls + cage, but ALSO add "fusion bridges" that physically connect:
// - balls to cage
// - cage to inner ring
// - cage to outer ring
// This removes all floating/disconnected parts and makes one printable solid.
module balls_cage_and_bridges() {

    // Cage band centered on ball path
    cage_r_in  = ball_path_r - cage_radial_mm/2;
    cage_r_out = ball_path_r + cage_radial_mm/2;

    // Make cage thick enough axially to intersect rings by overlap
    cage_h = width_mm + 2*connect_overlap_mm;

    // Radial bridges: ensure cage/balls fuse into BOTH rings (1–2mm overlap)
    // These are thin ribs that span the radial gaps and intersect ring material.
    bridge_w_tan = 2.0; // tangential width of rib
    bridge_h_ax  = width_mm + 2*connect_overlap_mm;

    // Inner bridge spans from inner ring outer surface into cage region
    inner_bridge_len = (cage_r_in - inner_ring_outer_r) + 2*connect_overlap_mm;
    inner_bridge_r   = inner_ring_outer_r + inner_bridge_len/2 - connect_overlap_mm;

    // Outer bridge spans from cage region into outer ring inner surface
    outer_bridge_len = (outer_ring_inner_r - cage_r_out) + 2*connect_overlap_mm;
    outer_bridge_r   = cage_r_out + outer_bridge_len/2 - connect_overlap_mm;

    union() {
        // Cage band (solid ring)
        difference() {
            cylinder(r=cage_r_out, h=cage_h, center=true);
            cylinder(r=cage_r_in,  h=cage_h + 2*connect_overlap_mm, center=true);
        }

        // Balls placed around; they intersect the cage (cage passes through their mid-plane)
        for (i = [0:num_balls-1]) {
            rotate([0, 0, i*360/num_balls])
                translate([ball_path_r, 0, 0])
                    sphere(r=ball_diameter_mm/2);
        }

        // Bridges at each ball position to guarantee fusion to BOTH rings
        for (i = [0:num_balls-1]) {
            rotate([0, 0, i*360/num_balls]) {
                // Bridge to inner ring
                translate([inner_bridge_r, 0, 0])
                    cube([inner_bridge_len, bridge_w_tan, bridge_h_ax], center=true);

                // Bridge to outer ring
                translate([outer_bridge_r, 0, 0])
                    cube([outer_bridge_len, bridge_w_tan, bridge_h_ax], center=true);
            }
        }
    }
}

// Final assembly: single connected solid
module bearing() {
    union() {
        outer_ring();
        inner_ring();
        balls_cage_and_bridges();
    }
}

bearing();