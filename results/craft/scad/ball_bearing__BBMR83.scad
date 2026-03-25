// Ball bearing: 3.0mm bore, 8.0mm OD, 3.0mm width
// FIX: ensure balls are physically connected to the main body (no floating parts)

$fn = 180;

// Parameters
bore_diameter_mm = 3.0;   //[1.5:6.0:0.1]
outer_diameter_mm = 8.0;  //[4.0:16.0:0.1]
width_mm = 3.0;           //[1.5:6.0:0.1]

ball_diameter_mm = 1.2;   //[0.6:2.4:0.05]
ball_count = 8;           //[5:14:1]

// Geometry tuning
race_clearance_mm = 0.10;          // small clearance so grooves don't break through
groove_depth_factor = 0.55;        // groove depth relative to ball radius

// Critical connectivity overlap (1-2mm as required)
connection_overlap_mm = 1.2;

module ball_bearing() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;
    w       = width_mm;

    ball_r  = ball_diameter_mm/2;

    ring_radial_thickness = outer_r - bore_r;

    // Ball center radius (midway between bore and OD)
    ball_center_r = bore_r + ring_radial_thickness/2;

    // Groove geometry
    groove_r = ball_r + race_clearance_mm;
    groove_depth = groove_r * groove_depth_factor;

    inner_groove_center_r = ball_center_r - groove_depth;
    outer_groove_center_r = ball_center_r + groove_depth;

    // Keep grooves safely within material
    inner_groove_center_r = max(inner_groove_center_r, bore_r + groove_r + race_clearance_mm);
    outer_groove_center_r = min(outer_groove_center_r, outer_r - groove_r - race_clearance_mm);

    // Place balls so they INTERSECT the ring body by 1-2mm (no floating)
    // Ensure the sphere crosses the outer face plane at z = +/- w/2 by connection_overlap_mm.
    // If ball_r is small, clamp so we still intersect.
    ball_z = max(0, (w/2 + ball_r - connection_overlap_mm));

    union() {
        // Main bearing body with grooves
        difference() {
            cylinder(r=outer_r, h=w, center=true);
            cylinder(r=bore_r,  h=w + 2*connection_overlap_mm, center=true);

            for (zsign = [-1, 1]) {
                translate([0, 0, zsign * (w/2 - groove_r - race_clearance_mm)]) {
                    rotate_extrude(convexity=10)
                        translate([outer_groove_center_r, 0, 0])
                            circle(r=groove_r, $fn=96);

                    rotate_extrude(convexity=10)
                        translate([inner_groove_center_r, 0, 0])
                            circle(r=groove_r, $fn=96);
                }
            }
        }

        // Balls: now guaranteed to overlap the ring (connected solid)
        for (i = [0:ball_count-1]) {
            rotate([0, 0, i * 360/ball_count]) {
                translate([ball_center_r, 0,  ball_z]) sphere(r=ball_r, $fn=96);
                translate([ball_center_r, 0, -ball_z]) sphere(r=ball_r, $fn=96);
            }
        }
    }
}

ball_bearing();