// Ball bearing: 3.0mm bore, 8.0mm outer diameter, 3.0mm width
// FIX: force ALL parts to be one connected solid by adding small "web" bridges
// between inner/outer races and the cage/balls (1–2mm overlaps).

$fn = 128;

// Requested dimensions
bore_diameter_mm  = 3.0;
outer_diameter_mm = 8.0;
width_mm          = 3.0;

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Design parameters (kept within the 8x3 envelope)
race_radial_thickness_mm = 1.0;
race_axial_thickness_mm  = 3.0;
ball_diameter_mm         = 1.2;
ball_count               = 8;

// Numerical epsilon for booleans
eps = 0.05;

// Connectivity overlap (critical): 1–2mm as requested
overlap_mm = 1.2;

// Computed geometry
inner_race_outer_r = bore_r + race_radial_thickness_mm;     // 2.5
outer_race_inner_r = outer_r - race_radial_thickness_mm;    // 3.0

// Ball path radius centered in the radial gap
ball_ring_r = (inner_race_outer_r + outer_race_inner_r)/2;  // 2.75

// Cage (thin ring)
cage_thickness_z = 0.6;
cage_radial_clear = 0.15;
cage_inner_r = inner_race_outer_r + cage_radial_clear;      // 2.65
cage_outer_r = outer_race_inner_r - cage_radial_clear;      // 2.85

// Clamp cage radii to valid range
cage_inner_r2 = min(cage_inner_r, cage_outer_r - 0.2);
cage_outer_r2 = max(cage_outer_r, cage_inner_r2 + 0.2);

module ring(r_out, r_in, h, center=true) {
    difference() {
        cylinder(r=r_out, h=h, center=center);
        cylinder(r=r_in,  h=h + 2*eps, center=center);
    }
}

// A thin radial "web" that bridges two radii so parts are fused.
// It stays within the bearing width and overlaps both sides by overlap_mm.
module radial_web(r0, r1, z_h, ang_deg, tangential_w=0.9) {
    rotate([0,0,ang_deg])
        translate([(r0+r1)/2, 0, 0])
            cube([abs(r1-r0) + 2*overlap_mm, tangential_w, z_h], center=true);
}

module ball_bearing() {
    union() {
        // Outer race (full width)
        ring(outer_r, outer_race_inner_r, width_mm, center=true);

        // Inner race (full width)
        ring(inner_race_outer_r, bore_r, width_mm, center=true);

        // Cage ring (centered)
        ring(cage_outer_r2, cage_inner_r2, cage_thickness_z, center=true);

        // Balls (they intersect the cage already, but not necessarily the races)
        for (i = [0:ball_count-1]) {
            rotate([0,0,i*360/ball_count])
                translate([ball_ring_r, 0, 0])
                    sphere(r=ball_diameter_mm/2);
        }

        // --- Connectivity fixes (make the whole assembly ONE connected solid) ---
        // 1) Bridge inner race -> cage (overlap 1–2mm)
        // 2) Bridge cage -> outer race (overlap 1–2mm)
        // These webs also ensure balls are not "separate solids" because they
        // intersect the cage, and the cage is now fused to BOTH races.
        web_h = min(width_mm, cage_thickness_z + 2*overlap_mm); // keep within width
        for (i = [0:ball_count-1]) {
            ang = i*360/ball_count;

            // Inner race outer surface to cage inner surface
            radial_web(
                inner_race_outer_r - overlap_mm,
                cage_inner_r2 + overlap_mm,
                web_h,
                ang,
                tangential_w = 0.9
            );

            // Cage outer surface to outer race inner surface
            radial_web(
                cage_outer_r2 - overlap_mm,
                outer_race_inner_r + overlap_mm,
                web_h,
                ang + 180/ball_count,   // stagger to avoid overly thick spokes
                tangential_w = 0.9
            );
        }
    }
}

ball_bearing();