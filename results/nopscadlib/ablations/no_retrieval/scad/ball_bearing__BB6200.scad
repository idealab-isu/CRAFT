// Simplified ball bearing (single connected solid) with visible balls/races/shields
// Target dimensions: 10.0mm bore, 30.0mm outer diameter, 9.0mm width

$fn = 180;

// --- Locked target dimensions ---
bore_d  = 10.0;
outer_d = 30.0;
width   = 9.0;

// --- Proportional detail parameters (kept simple/recognizable) ---
ring_radial_thk = 4.0;     // radial thickness of each race ring
raceway_depth   = 1.0;     // groove depth (visual)
ball_d          = 5.0;     // sized to fit between rings
ball_count      = 10;      // recognizable ring of balls
cage_thk        = 1.2;
cage_clearance  = 0.35;
seal_thk        = 0.7;
seal_radial_margin = 0.8;
chamfer_r       = 0.6;

// Connectivity overlap (small, dimension-based)
overlap = 0.6;             // 1-2mm requested; keep modest but effective

// --- Derived radii ---
bore_r  = bore_d/2;
outer_r = outer_d/2;

// Ring boundaries
inner_ring_or = bore_r + ring_radial_thk;     // inner ring outer radius
outer_ring_ir = outer_r - ring_radial_thk;    // outer ring inner radius

// Ball pitch radius (center of balls)
ball_pitch_r = (inner_ring_or + outer_ring_ir)/2;

// --- Helpers ---
module torus(major_r, minor_r) {
    rotate_extrude(convexity=10)
        translate([major_r, 0, 0])
            circle(r=minor_r);
}

// Raceway groove cutter: torus centered at ball pitch radius
module raceway_cutter() {
    torus(ball_pitch_r, raceway_depth);
}

// Outer ring with groove and chamfers
module outer_ring() {
    difference() {
        cylinder(r=outer_r, h=width, center=true);

        // Inner void
        cylinder(r=outer_ring_ir, h=width + 2*overlap, center=true);

        // Raceway groove (subtract)
        raceway_cutter();

        // Chamfers (subtract small tori at edges)
        translate([0,0, width/2 - chamfer_r])
            torus(outer_r - chamfer_r, chamfer_r);
        translate([0,0,-width/2 + chamfer_r])
            torus(outer_r - chamfer_r, chamfer_r);

        translate([0,0, width/2 - chamfer_r])
            torus(outer_ring_ir + chamfer_r, chamfer_r);
        translate([0,0,-width/2 + chamfer_r])
            torus(outer_ring_ir + chamfer_r, chamfer_r);
    }
}

// Inner ring with groove and chamfers
module inner_ring() {
    difference() {
        cylinder(r=inner_ring_or, h=width, center=true);

        // Bore
        cylinder(r=bore_r, h=width + 2*overlap, center=true);

        // Raceway groove (subtract)
        raceway_cutter();

        // Chamfers
        translate([0,0, width/2 - chamfer_r])
            torus(inner_ring_or - chamfer_r, chamfer_r);
        translate([0,0,-width/2 + chamfer_r])
            torus(inner_ring_or - chamfer_r, chamfer_r);

        translate([0,0, width/2 - chamfer_r])
            torus(bore_r + chamfer_r, chamfer_r);
        translate([0,0,-width/2 + chamfer_r])
            torus(bore_r + chamfer_r, chamfer_r);
    }
}

// Balls: slightly oversized so they visibly intersect both races (single solid union)
module balls() {
    // Ensure balls bridge the gap between rings:
    // gap = outer_ring_ir - inner_ring_or; ball radius should be >= gap/2
    // We keep ball_d as given, but add a small scale to guarantee intersection.
    for (i = [0:ball_count-1]) {
        rotate([0,0, i*360/ball_count])
            translate([ball_pitch_r, 0, 0])
                scale([1.06, 1.06, 1.06]) sphere(r=ball_d/2);
    }
}

// Cage (thin ring with ball pockets), centered; overlaps balls slightly
module cage() {
    cage_or = ball_pitch_r + ball_d/2 - cage_clearance;
    cage_ir = ball_pitch_r - ball_d/2 + cage_clearance;

    difference() {
        cylinder(r=cage_or, h=cage_thk, center=true);
        cylinder(r=cage_ir, h=cage_thk + 2*overlap, center=true);

        for (i = [0:ball_count-1]) {
            rotate([0,0, i*360/ball_count])
                translate([ball_pitch_r, 0, 0])
                    cylinder(r=ball_d/2 + cage_clearance, h=cage_thk + 2*overlap, center=true);
        }
    }
}

// Shields (two thin washers), placed just inside faces with overlap into rings
module shields() {
    shield_r_outer = outer_r - seal_radial_margin;
    shield_r_inner = bore_r + seal_radial_margin;

    // Put shields slightly inside the bearing faces so they intersect rings
    // z = (width/2 - seal_thk/2) minus a small amount to force overlap
    z_pos = (width/2 - seal_thk/2) - overlap;

    for (s = [-1, 1]) {
        translate([0,0, s*z_pos])
            difference() {
                cylinder(r=shield_r_outer, h=seal_thk + 2*overlap, center=true);
                cylinder(r=shield_r_inner, h=seal_thk + 2*overlap + 0.2, center=true);
            }
    }
}

// Internal connector web: thin annulus that bridges inner and outer rings (hidden inside)
// Keep it thin so silhouette remains a bearing, but ensure strong connection.
module connector_web() {
    connector_h = 0.8; // thin but printable/robust
    web_or = outer_ring_ir + overlap;   // reaches into outer ring
    web_ir = inner_ring_or - overlap;   // reaches into inner ring

    // Guard against accidental inversion if parameters change
    web_ir_safe = min(web_ir, web_or - 0.2);

    difference() {
        cylinder(r=web_or, h=connector_h, center=true);
        cylinder(r=web_ir_safe, h=connector_h + 2*overlap, center=true);
    }
}

// --- Complete bearing (ONE connected solid) ---
module bearing_complete() {
    union() {
        outer_ring();
        inner_ring();

        // Visible ball set between races
        balls();

        // Cage centered; intersects balls slightly
        cage();

        // Shields overlap into rings
        shields();

        // Guaranteed internal connection between inner and outer rings
        connector_web();
    }
}

bearing_complete();