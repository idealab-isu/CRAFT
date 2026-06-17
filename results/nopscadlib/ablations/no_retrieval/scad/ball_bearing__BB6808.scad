// Ball bearing (single connected solid)
// Bore = 40.0mm, OD = 52.0mm, Width = 7.0mm

$fn = 220;

// --- Target dimensions ---
bore_d  = 40.0;
outer_d = 52.0;
width_w = 7.0;

// --- Connectivity / robustness ---
overlap = 0.30;   // guaranteed overlap between touching parts

// --- Bearing feature parameters (fit within 6mm radial space) ---
radial_space = (outer_d - bore_d)/2;          // = 6mm
ring_radial_thk = 1.60;                      // each ring thickness (radial)
race_gap = radial_space - 2*ring_radial_thk; // remaining for balls/races

ball_d = min(3.2, max(2.6, race_gap*0.92));  // keep balls visible but fitting
ball_count = 14;

// Ball pitch radius centered in the race gap
pitch_r = bore_d/2 + ring_radial_thk + race_gap/2;

// Race groove (visual) parameters
race_groove_r = ball_d*0.55;
race_groove_depth = ball_d*0.28;

// Cage parameters (thin, intersects balls slightly to keep ONE solid)
cage_enabled = 1;
cage_thk = 1.2;
cage_radial_thk = 0.75;
cage_pocket_clear = 0.25;

// Shields (thin discs) to make it look like a bearing from front/back
shields_enabled = 1;
shield_thk = 0.45;
shield_overlap_into_rings = 0.35; // overlap into rings for connectivity
shield_inner_r = bore_d/2 + ring_radial_thk + 0.25; // leaves bore open
shield_outer_r = outer_d/2 - ring_radial_thk - 0.25;

// --- Helpers ---
module cyl(r,h) { cylinder(r=r, h=h, center=true); }

module torus(R, r) {
    rotate_extrude(convexity=10)
        translate([R, 0, 0])
            circle(r=r);
}

// --- Rings (raw) ---
module outer_ring_raw() {
    difference() {
        cyl(outer_d/2, width_w);
        // inner of outer ring
        cyl(bore_d/2 + ring_radial_thk, width_w + 2*overlap);
    }
}

module inner_ring_raw() {
    difference() {
        // outer of inner ring
        cyl(bore_d/2 + ring_radial_thk, width_w);
        // bore
        cyl(bore_d/2, width_w + 2*overlap);
    }
}

// --- Race grooves (cutters) ---
module outer_race_groove_cutter() {
    // Intersect inner face of outer ring near pitch radius
    torus(pitch_r + (ball_d/2 - race_groove_depth), race_groove_r);
}

module inner_race_groove_cutter() {
    // Intersect outer face of inner ring near pitch radius
    torus(pitch_r - (ball_d/2 - race_groove_depth), race_groove_r);
}

module outer_ring_with_race() {
    difference() {
        outer_ring_raw();
        outer_race_groove_cutter();
    }
}

module inner_ring_with_race() {
    difference() {
        inner_ring_raw();
        inner_race_groove_cutter();
    }
}

// --- Balls (slightly enlarged to ensure intersection with grooves/rings => one solid) ---
module ball_set() {
    for (i = [0:ball_count-1]) {
        a = 360/ball_count * i;
        translate([pitch_r*cos(a), pitch_r*sin(a), 0])
            sphere(r=ball_d/2 + 0.10);
    }
}

// --- Cage (thin ring with pockets), positioned at mid-plane ---
module cage_retainer() {
    difference() {
        // Outer/inner cage cylinders
        cyl(pitch_r + ball_d/2 + cage_radial_thk, cage_thk);
        cyl(pitch_r - ball_d/2 - cage_radial_thk, cage_thk + 2*overlap);

        // Pockets
        for (i = [0:ball_count-1]) {
            a = 360/ball_count * i;
            translate([pitch_r*cos(a), pitch_r*sin(a), 0])
                rotate([90, 0, a])
                    cylinder(r=ball_d/2 + cage_pocket_clear,
                             h=cage_thk + 2*overlap, center=true);
        }
    }
}

// --- Shields (thin discs near faces), overlapped into rings for connectivity ---
module shields() {
    // Place each shield so it overlaps into the bearing by shield_overlap_into_rings
    zpos = width_w/2 - shield_thk/2 - shield_overlap_into_rings;

    for (s = [-1, 1]) {
        translate([0, 0, s*zpos])
            difference() {
                cyl(shield_outer_r, shield_thk);
                cyl(shield_inner_r, shield_thk + 2*overlap);
            }
    }
}

// --- Final bearing (ONE connected solid) ---
module bearing_complete() {
    union() {
        outer_ring_with_race();
        inner_ring_with_race();
        ball_set();
        if (cage_enabled) cage_retainer();
        if (shields_enabled) shields();
    }
}

bearing_complete();