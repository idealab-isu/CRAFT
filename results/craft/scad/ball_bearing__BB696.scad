// Ball bearing 6x16x5 (bore x OD x width) as ONE connected solid
// Includes visible balls and raceway grooves; bore is circular (high $fn).

// Parameters
bore_diameter_mm  = 6.0;   //[3:12:0.1]
outer_diameter_mm = 16.0;  //[8:32:0.1]
width_mm          = 5.0;   //[2.5:10:0.1]

ball_diameter_mm  = 2.2;   //[1.5:5:0.1]
ball_count        = 7;     //[5:12:1]

radial_rim_thickness_mm = 1.2; //[0.6:2.4:0.1]  // outer ring wall thickness
radial_hub_thickness_mm = 1.2; //[0.6:2.4:0.1]  // inner ring wall thickness

race_groove_depth_mm = 0.55; //[0.2:1.2:0.05]
race_groove_scale_xy = 1.15; //[1.0:1.6:0.05]   // makes groove slightly wider than ball

bridge_thickness_mm = 0.35; //[0.15:0.8:0.05]   // tiny web to ensure ONE connected solid
bridge_z_clear_mm   = 0.15; //[0.05:0.5:0.05]   // keep bridge away from faces

eps_mm = 0.05; //[0.01:0.2:0.01]

// Quality (prevents polygonal bore)
$fn = 128;

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module ball_bearing_connected() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;

    inner_ring_or = bore_r + radial_hub_thickness_mm;
    outer_ring_ir = outer_r - radial_rim_thickness_mm;

    // Ball center radius (between rings), clamped to fit
    ball_r = ball_diameter_mm/2;
    ball_center_r_nom = (inner_ring_or + outer_ring_ir)/2;
    ball_center_r = clamp(ball_center_r_nom, inner_ring_or + ball_r*0.9, outer_ring_ir - ball_r*0.9);

    // Raceway groove radius (slightly smaller than ball so groove is visible)
    groove_r = max(0.01, ball_r - race_groove_depth_mm);

    // Bridge: a thin annular web that connects inner+outer rings (keeps model ONE solid)
    // Placed near mid-plane, leaving small clearance to faces.
    bridge_h = max(0.01, width_mm - 2*(bridge_z_clear_mm));
    bridge_z = 0;

    // Bridge radial span: from inner ring OD to outer ring ID, with slight overlaps
    bridge_ir = inner_ring_or - eps_mm;
    bridge_or = outer_ring_ir + eps_mm;

    union() {
        // Rings with raceway grooves cut in
        difference() {
            union() {
                // Outer ring
                difference() {
                    cylinder(r=outer_r, h=width_mm, center=true);
                    cylinder(r=outer_ring_ir, h=width_mm + 2*eps_mm, center=true);
                }

                // Inner ring
                difference() {
                    cylinder(r=inner_ring_or, h=width_mm, center=true);
                    cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
                }

                // Connecting web (ensures single connected solid)
                difference() {
                    cylinder(r=bridge_or, h=bridge_h, center=true);
                    cylinder(r=bridge_ir, h=bridge_h + 2*eps_mm, center=true);
                }
            }

            // Cut two raceway grooves (one in each ring) using a torus-like cutter
            // Implemented as rotate_extrude of a circle placed at ball_center_r.
            for (side = [-1, 1]) {
                // Slightly offset grooves toward each ring to suggest two raceways
                groove_offset = side * (ball_r * 0.35);
                translate([0, 0, groove_offset])
                    rotate_extrude(angle=360, convexity=10)
                        translate([ball_center_r, 0, 0])
                            scale([race_groove_scale_xy, 1, 1])
                                circle(r=groove_r, $fn=96);
            }
        }

        // Balls (fused to the web by tiny overlap so everything is one solid)
        for (i = [0:ball_count-1]) {
            rotate([0, 0, i * 360/ball_count])
                translate([ball_center_r, 0, 0])
                    sphere(r=ball_r, $fn=96);
        }
    }
}

ball_bearing_connected();