// Ball bearing: 12.0mm bore, 32.0mm OD, 10.0mm width
// Single connected solid with visible balls + race grooves + shields (all fused with small overlaps)

$fn = 160;

// Requested dimensions
bore_diameter_mm  = 12.0;
outer_diameter_mm = 32.0;
width_mm          = 10.0;

// Derived radii
outer_r = outer_diameter_mm/2;
bore_r  = bore_diameter_mm/2;

// Visual/structural parameters (kept plausible for 32x12x10)
race_radial_thickness_mm = 3.0;   // radial thickness of each ring
ball_diameter_mm         = 4.0;
ball_count               = 9;

shield_thickness_mm      = 0.7;
shield_radial_overlap_mm = 0.9;

// Groove shaping (visual raceways)
groove_depth_mm          = 0.9;   // how deep the groove cuts into each ring
groove_clearance_mm      = 0.25;  // groove radius slightly larger than ball radius

// Connectivity / robustness
eps_mm  = 0.05;
fuse_mm = 0.30;  // intentional overlap between parts so union becomes one manifold

// Ring radii
inner_outer_r = bore_r + race_radial_thickness_mm;
outer_inner_r = outer_r - race_radial_thickness_mm;

// Ball path radius (between races)
ball_path_r = (inner_outer_r + outer_inner_r)/2;

// Ball radius
ball_r = ball_diameter_mm/2;

// Groove radius (slightly larger than ball)
groove_r = ball_r + groove_clearance_mm;

// Clamp helper
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Ensure groove doesn't cut through rings
groove_depth = clamp(groove_depth_mm, 0, race_radial_thickness_mm - 0.4);

// Z position of groove centers (near mid-plane)
groove_z = 0;

// Outer ring with race groove
module outer_ring() {
    difference() {
        // Base ring
        difference() {
            cylinder(r=outer_r, h=width_mm, center=true);
            cylinder(r=outer_inner_r, h=width_mm + 2*eps_mm, center=true);
        }

        // Raceway groove (torus-like cut)
        rotate_extrude(convexity=10)
            translate([outer_inner_r + groove_depth, groove_z, 0])
                circle(r=groove_r, $fn=96);
    }
}

// Inner ring with race groove
module inner_ring() {
    difference() {
        // Base ring
        difference() {
            cylinder(r=inner_outer_r, h=width_mm, center=true);
            cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
        }

        // Raceway groove (torus-like cut)
        rotate_extrude(convexity=10)
            translate([inner_outer_r - groove_depth, groove_z, 0])
                circle(r=groove_r, $fn=96);
    }
}

// Shields (fused into rings)
module shields() {
    for (zsign = [-1, 1]) {
        translate([0, 0, zsign*(width_mm/2 - shield_thickness_mm/2 - fuse_mm/2)])
            difference() {
                cylinder(r=outer_inner_r + shield_radial_overlap_mm,
                         h=shield_thickness_mm + fuse_mm, center=true);
                cylinder(r=inner_outer_r - shield_radial_overlap_mm,
                         h=shield_thickness_mm + fuse_mm + 2*eps_mm, center=true);
            }
    }
}

// Balls (slightly enlarged to fuse into grooves/shields for one connected solid)
module balls() {
    for (i = [0:ball_count-1]) {
        rotate([0, 0, i*360/ball_count])
            translate([ball_path_r, 0, 0])
                sphere(r=ball_r + fuse_mm/2, $fn=96);
    }
}

// Full bearing solid (single connected manifold), then open bore
module bearing_solid() {
    union() {
        outer_ring();
        inner_ring();
        shields();
        balls();
    }
}

difference() {
    bearing_solid();
    // Ensure bore is open through entire width
    cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
}