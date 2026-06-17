// Ball bearing: 4.0mm bore, 13.0mm OD, 5.0mm width
// One connected solid with visible races + balls (open bearing, no shields)

$fn = 180;

// Target dimensions
bore_diameter_mm  = 4.0;
outer_diameter_mm = 13.0;
width_mm          = 5.0;

// Small overlap to guarantee connectivity
overlap_mm = 0.15;

// Ring/race proportions (kept parametric but derived from the target size)
outer_ring_radial_thickness_mm = 1.55;
inner_ring_radial_thickness_mm = 1.25;

// Ball set
ball_diameter_mm = 2.0;
num_balls = 8;

// Derived radii
bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

inner_ring_outer_r = bore_r + inner_ring_radial_thickness_mm;
outer_ring_inner_r = outer_r - outer_ring_radial_thickness_mm;

// Ball path radius (between rings)
ball_path_r = (inner_ring_outer_r + outer_ring_inner_r)/2;

// Race groove shaping (subtractive torus-like groove)
groove_r = ball_diameter_mm*0.55; // slightly larger than ball radius for clearance/visual
groove_z = 0;                     // centered in width

module ring(r_outer, r_inner, h) {
    difference() {
        cylinder(r=r_outer, h=h, center=true);
        cylinder(r=r_inner, h=h + 2*overlap_mm, center=true);
    }
}

// Torus-like groove made by rotate_extrude of a circle
module race_groove(path_r, groove_radius) {
    translate([0,0,groove_z])
        rotate_extrude(convexity=10)
            translate([path_r, 0, 0])
                circle(r=groove_radius);
}

module balls() {
    for (i = [0:num_balls-1]) {
        rotate([0,0,i*360/num_balls])
            translate([ball_path_r, 0, 0])
                sphere(r=ball_diameter_mm/2);
    }
}

module bearing_solid() {
    // Build rings, carve grooves, then union balls.
    // Add a tiny axial "cage web" to ensure the balls are physically connected to the rings
    // while keeping the bearing visually recognizable.
    difference() {
        union() {
            // Outer ring
            ring(outer_r, outer_ring_inner_r, width_mm);

            // Inner ring
            ring(inner_ring_outer_r, bore_r, width_mm);

            // Minimal cage web (thin annulus) to connect balls to rings as ONE solid
            // Positioned at mid-plane; overlaps balls and both rings slightly.
            cage_h = ball_diameter_mm*0.35;
            cage_r_outer = outer_ring_inner_r + overlap_mm;
            cage_r_inner = inner_ring_outer_r - overlap_mm;
            ring(cage_r_outer, cage_r_inner, cage_h);

            // Balls
            balls();
        }

        // Carve matching grooves into both rings (slightly different radii for visual separation)
        // Outer ring groove
        race_groove(ball_path_r + ball_diameter_mm*0.08, groove_r);

        // Inner ring groove
        race_groove(ball_path_r - ball_diameter_mm*0.08, groove_r);

        // Ensure bore is perfectly circular and exact
        cylinder(r=bore_r, h=width_mm + 2*overlap_mm, center=true);
    }
}

bearing_solid();